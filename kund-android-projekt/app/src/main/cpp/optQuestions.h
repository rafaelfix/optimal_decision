//
// Created by Gabriel on 2020-06-14.
//

#ifndef OPTIMALEDUCATION_OPTQUESTIONS_H
#define OPTIMALEDUCATION_OPTQUESTIONS_H

#include <string>
#include <iostream>
#include <iomanip>
#include <vector>
#include <limits>
#include <fstream>
#include <algorithm>
#include <sstream>

#ifdef __linux__ 
  #include <sys/time.h>
#elif __APPLE__
  #include <sys/time.h>
#elif _WIN32
  #include <time.h>
#endif

class ExcQuestions
{
public:
  ExcQuestions(const std::string& name, const std::string& msg) : name_(name), msg_(msg) {}
  virtual void print() const
  {
#ifdef __linux__
#elif __APPLE__
#elif _WIN32
    std::cerr << name_ << " : " << msg_ << std::endl;
#endif
  }
  virtual std::string what() const { return name_ + " : " + msg_; }
  std::string name_;
  std::string msg_;
};


class Questioner
{
public:
  virtual ~Questioner() {}

  virtual void init() {}

  virtual void newQuestion(const long long tCur, char& op, int& xValue, int& yValue, int& zValue)
  {
    srand((unsigned int) time(NULL));
    xValue = rand() % 10;
    yValue = rand() % 10;
    if (op == '+')
    {
      zValue = xValue + yValue;
    }
    else if (op == '-')
    {
      zValue = xValue;
      xValue = zValue + yValue;
    }
    else if (op == '*')
    {
      zValue = xValue * yValue;
    }
    else if (op == '/')
    {
      zValue = xValue;
      if (yValue == 0)
        yValue = 1 + rand() % 9;
      xValue = zValue * yValue;
    }
  }

  virtual void setQuestion(const long long tCur, const char& op, const int& xValue, const int& yValue)
  {
    return;
  }

  virtual int determineAnswer(const char& op, const int& xValue, const int& yValue, const int& zValue, const std::vector<long long>& t, const std::vector<char>& c)
  {
    std::string str = "";
    for (size_t i=0 ; i<c.size() ; i++)
    {
      char ch = c.at(i);
      if (ch == 'C')
        str = "";
      else if (ch == '<' && c.size() > 0)
        str.pop_back();
      else if (c.at(i) == '=')
        break;
      else
        str = str + c.at(i);
    }
    return std::stoi(str);
  }

  virtual std::string status() { return std::string("No status"); }
  virtual unsigned int level() { return 0; }
  virtual unsigned int recordLevel() { return 0; }												  
  virtual unsigned int maxLearningLevel() { return 0; }
  virtual double statusTime() { return std::numeric_limits<double>::infinity(); }

protected:

};


class optQ
{
public:
  optQ(unsigned int idAdd, unsigned int idSub, unsigned int idMul, unsigned int idDiv) : nQuestions(4), nCorrect(4), hInd(1), gtStart(0), gtEnd(0)

  {
    for (size_t i=0 ; i<4 ; i++)
    {
      nQuestions.at(i) = 0;
      nCorrect.at(i) = 0;
    }
    hInd.at(0) = 0;

    if (idAdd == 0)
      qAdd = new Questioner;
    else
    {
#ifdef __linux__
#elif __APPLE__
#elif _WIN32
      std::cout << "Unknown id for addition" << std::endl;
#endif
      qAdd = new Questioner;
    }

    if (idSub == 0)
      qSub = new Questioner;
    else
    {
#ifdef __linux__
#elif __APPLE__
#elif _WIN32
      std::cout << "Unknown id for subtraction" << std::endl;
#endif
      qSub = new Questioner;
    }

    if (idMul == 0)
      qMul = new Questioner;
    else
    {
#ifdef __linux__
#elif __APPLE__
#elif _WIN32
      std::cout << "Unknown id for multiplication" << std::endl;
#endif
      qMul = new Questioner;
    }

    if (idDiv == 0)
      qDiv = new Questioner;
    else
    {
#ifdef __linux__
#elif __APPLE__
#elif _WIN32
      std::cout << "Unknown id for division" << std::endl;
#endif
      qDiv = new Questioner;
    }

  }

  ~optQ()
  {
    delete qAdd;
    if (qSub != qAdd)
      delete qSub;
    if (qMul != qAdd && qMul != qSub)
      delete qMul;
    if (qDiv != qAdd && qDiv != qSub && qDiv != qMul)
      delete qDiv;
  }

  void setDataFile(const std::string& _fileName)
  {
    fileName = _fileName;

    ht.resize(0);
    hop.resize(0);
    hx.resize(0);
    hy.resize(0);

    hInd.resize(1);
    hInd.at(0) = 0;
    hk.resize(0);
    hkt.resize(0);

    hz.resize(0);
    hanswer.resize(0);

    for (size_t i=0 ; i<4 ; i++)
    {
      nQuestions.at(i) = 0;
      nCorrect.at(i) = 0;
    }

    qAdd->init();
    qSub->init();
    qMul->init();
    qDiv->init();

    loadDataFile(fileName);
  }

  void setGamingTimeFile(const std::string& _fileName)
  {
    fileNameGamingTime = _fileName;

    hGtStart.resize(0);
    hGtEnd.resize(0);

    loadGamingTimeFile(fileNameGamingTime);
  }

  char checkFeasibleOperator(const char& _op)
  {
    long long T = getTime();

    op = _op;
    if (op == '+')
      return '+';
    else if (op == '-')
      return '-';
    else if (op == '*')
      return '*';
    else if (op == '/')
      return '/';
    return '+';
  }


  void newQuestion(const char& _op)
  {
    clearQuestion();
    long long T = getTime();

    op = _op;
    if (op == '+')
      qAdd->newQuestion(T, op, xValue, yValue, zValue);
    else if (op == '-')
      qSub->newQuestion(T, op, xValue, yValue, zValue);
    else if (op == '*')
      qMul->newQuestion(T, op, xValue, yValue, zValue);
    else if (op == '/')
      qDiv->newQuestion(T, op, xValue, yValue, zValue);

    question = std::to_string(xValue) + op + std::to_string(yValue);
    t.push_back(T);
  }

  void addKey(char c)
  {
    a.push_back(c);
    t.push_back(getTime());
  }

  void addKey(char c, long long time)
  {
    a.push_back(c);
    t.push_back(time);
  }

  void determineAnswer()
  {
    try
    {
      checkValidQuestionAnswer();
      if (op == '+')
        answer = qAdd->determineAnswer(op, xValue, yValue, zValue, t, a);
      else if (op == '-')
        answer = qSub->determineAnswer(op, xValue, yValue, zValue, t, a);
      else if (op == '*')
        answer = qMul->determineAnswer(op, xValue, yValue, zValue, t, a);
      else if (op == '/')
        answer = qDiv->determineAnswer(op, xValue, yValue, zValue, t, a);
    }
    catch (...)
    {
      clearQuestion();
      throw;
    }
  }

  void storeAnswer()
  {
    try
    {
      checkValidQuestionAnswer();

      size_t j=operatorIndex();

      if (zValue == answer)
        nCorrect.at(j)++;
      nQuestions.at(j)++;

      ht.push_back(t.at(0));
      hx.push_back(xValue);
      hop.push_back(op);
      hy.push_back(yValue);
      hz.push_back(zValue);
      hanswer.push_back(answer);

      for (size_t i=0 ; i<a.size() ; i++)
      {
        hk.push_back(a.at(i));
        hkt.push_back(t.at(i+1));
      }
      hInd.push_back(hk.size());
    }
    catch (...)
    {
      clearQuestion();
      throw;
    }
    clearQuestion();
  }

  void saveAnswerToFile()
  {
    checkValidQuestionAnswer();

    std::ofstream file(fileName, std::ofstream::out | std::ofstream::app);
    file << t.at(0) << " " << question << std::endl;

    for (size_t i=0 ; i<a.size() ; i++)
      file << t.at(i+1) << " " << a.at(i) << std::endl;

  }

  std::string correctString(const char& _op)
  {
    size_t j=operatorIndex(_op);
    return std::to_string(nCorrect.at(j)) + "/" + std::to_string(nQuestions.at(j));
  }

  const std::string& getQuestion()  const { return question; }
  const int&         getX()         const { return xValue;    }
  const int&         getY()         const { return yValue;    }
  const int&         getZ()         const { return zValue;    }
  const int&         getAnswer()    const { return answer;    }
  const size_t       nHistory()     const { return ht.size(); }
  const size_t       nHistoryRows() const { return ht.size() + hkt.size(); }

  std::string status()
  {
    if (op == '+')
      return qAdd->status();
    else if (op == '-')
      return qSub->status();
    else if (op == '*')
      return qMul->status();
    else if (op == '/')
      return qDiv->status();
    return std::string("No status");
  }

  unsigned int level(char nop = 0)
  {
    char tmp = nop;
    if (nop == 0)
      tmp = op;
    if (tmp == '+')
      return qAdd->level();
    else if (tmp == '-')
      return qSub->level();
    else if (tmp == '*')
      return qMul->level();
    else if (tmp == '/')
      return qDiv->level();
    return 0;
  }
  unsigned int recordLevel()
  {
    if (op == '+')
      return qAdd->recordLevel();
    else if (op == '-')
      return qSub->recordLevel();
    else if (op == '*')
      return qMul->recordLevel();
    else if (op == '/')
      return qDiv->recordLevel();
    return 0;
  }
  double statusTime(char nop = 0)
  {
    char tmp = nop;
								 
    if (nop == 0)
      tmp = op;
	  
    if (tmp == '+')
      return qAdd->statusTime();
    else if (tmp == '-')
      return qSub->statusTime();
    else if (tmp == '*')
      return qMul->statusTime();
    else if (tmp == '/')
      return qDiv->statusTime();
    return std::numeric_limits<double>::infinity();
  }
  void clearQuestion()
  {
    t.clear();
    a.clear();
    question = "No question";
    op = '?';
    xValue = -1;
    yValue = -1;
    zValue = -1;
    answer = -1;
  }

  virtual std::string getDataTimes()
  {
    std::string times = std::to_string(t.at(0));

    for (size_t i=0 ; i<a.size() ; i++)
      times += std::string(" ") + std::to_string(t.at(i+1));

    return times;
  }

  virtual std::string getDataTimes(const size_t startQuestion)
  {
    std::string times;
    for (size_t i=startQuestion ; i<ht.size() ; i++)
    {
      if (i==startQuestion)
        times = std::to_string(ht.at(i));
      else
        times += std::string(" ") + std::to_string(ht.at(i));

      for (size_t j=hInd.at(i) ; j<hInd.at(i+1) ; j++)
        times += std::string(" ") + std::to_string(hkt.at(j));
    }

    return times;
  }

  virtual std::string getDataTimesRows(const size_t startRow)
  {
    std::string times;
    size_t iRow = 0;
    for (size_t i=0 ; i<ht.size() ; i++)
    {
      if (iRow++ >= startRow)
      {
        if (times.size() == 0)
          times = std::to_string(ht.at(i));
        else
          times += std::string(" ") + std::to_string(ht.at(i));
      }

      for (size_t j=hInd.at(i) ; j<hInd.at(i+1) ; j++)
        if (iRow++ >= startRow)
        {
          if (times.size() == 0)
            times = std::to_string(hkt.at(j));
          else
            times += std::string(" ") + std::to_string(hkt.at(j));
        }
    }

    return times;
  }

  virtual std::string getDataInputs()
  {
    std::string inputs = question;

    for (size_t i=0 ; i<a.size() ; i++)
      inputs += std::string(" ") + a.at(i);

    return inputs;
  }

  virtual std::string getDataInputs(const size_t startQuestion)
  {
    std::string inputs;
    for (size_t i=startQuestion ; i<ht.size() ; i++)
    {
      std::string q = std::to_string(hx.at(i)) + hop.at(i) + std::to_string(hy.at(i));
      if (i==startQuestion)
        inputs = q;
      else
        inputs += std::string(" ") + q;

      for (size_t j=hInd.at(i) ; j<hInd.at(i+1) ; j++)
        inputs += std::string(" ") + hk.at(j);
    }

    return inputs;
  }

  virtual std::string getDataInputsRows(const size_t startRow)
  {
    std::string inputs;
    size_t iRow = 0;
    for (size_t i=0 ; i<ht.size() ; i++)
    {
      if (iRow++ >= startRow)
      {
        std::string q = std::to_string(hx.at(i)) + hop.at(i) + std::to_string(hy.at(i));
        if (inputs.size() == 0)
          inputs = q;
        else
          inputs += std::string(" ") + q;
      }

      for (size_t j=hInd.at(i) ; j<hInd.at(i+1) ; j++)
        if (iRow++ >= startRow)
        {
          std::string q = std::to_string(hx.at(i)) + hop.at(i) + std::to_string(hy.at(i));
          if (inputs.size() == 0)
            inputs = hk.at(j);
          else
            inputs += std::string(" ") + hk.at(j);
        }
    }

    return inputs;
  }

  std::string readGamingTimeFile()
  {
    std::ifstream gtFile(fileNameGamingTime);
    if (gtFile)
    {
      std::ostringstream s;
      s << gtFile.rdbuf();
      return s.str();
    } 
    return ""; 
  }
  
  std::vector<double> getSolutionTimes(std::size_t nLast)
  {
    if (hInd.size()-1 < nLast)
      nLast = hInd.size()-1;

    std::size_t startQuestion = hInd.size()-1 - nLast;
    std::vector<double> times(nLast);

    for (std::size_t i=0 ; i<nLast ; i++)
    {
      std::size_t ii = startQuestion+i;
      size_t j=hInd.at(ii+1)-1;
      times.at(i) = (hkt.at(j)-ht.at(ii))/1000.0;
      if (times.at(i) <= 0)
        times.at(i) = 0.1;
    }

    return times;
  }

  double gamingTime(std::size_t startQuestion = 0)
  {
    double time = 0;
    for (std::size_t i=startQuestion ; i<hInd.size()-1 ; i++)
    {
      size_t j=hInd.at(i+1)-1;
      double qTime = (hkt.at(j)-ht.at(i))/1000.0;
      if (qTime < 0)
        qTime = 0;
      bool correct = (hanswer.at(i) == hz.at(i));
      if (correct)
      {
        if (qTime >= 10)
          time += 10;
        else
          time += qTime;
      }
    }
    return 4*time;
  }

  double spentGamingTime()
  {
    double time = 0;
    for (std::size_t i=0 ; i<hGtStart.size() ; i++)
    {
      double gtTime = (hGtEnd.at(i)-hGtStart.at(i))/1000.0;
      if (gtTime < 0)
        gtTime = 0;
      time += gtTime;
    }
    return time;
  }

  double spentGamingTimeCur()
  {
    double t = (getTime()-gtStart)/1000.0;
    if (t<0)
      return 0;
    else
      return t;
  }

  void saveGamingTimeToFile(const long long start, const long long end)
  {
    hGtStart.push_back(start);
    hGtEnd.push_back(end);
    std::ofstream file(fileNameGamingTime, std::ofstream::out | std::ofstream::app);
    file << start << " " << end << std::endl;
  }

  void gamingTimeStart()
  {
    gtStart = getTime();
  }

  void gamingTimeEnd()
  {
    gtEnd = getTime();
    saveGamingTimeToFile(gtStart, gtEnd);
    gtStart = 0;
    gtEnd = 0;
  }
private:
  const long long getTime() const
  {
    struct timeval tp;
    gettimeofday(&tp, NULL);
    long long time = (long long) tp.tv_sec * 1000L + tp.tv_usec / 1000; //get current timestamp in milliseconds
    return time;
  }

  size_t operatorIndex(const char& _op)
  {
    switch (_op)
    {
      case '+':
        return 0;
      case '-':
        return 1;
      case '*':
        return 2;
      case '/':
        return 3;
      default:
        return std::numeric_limits<size_t>::max();
    }
  }

  inline size_t operatorIndex()
  {
    return operatorIndex(op);
  }

  void loadDataFile(const std::string& _fileName)
  {
    std::string line;
    std::ifstream file(_fileName);

    clearQuestion();
    while (std::getline(file, line))
    {
#ifdef _WIN32
      std::cout << line << std::endl;
#endif

      size_t spacePos = line.find(' ');
      std::string timeStr = line.substr(0, spacePos);
      std::string actionStr = line.substr(spacePos + 1);

      if (actionStr.length() >= 3)
      {
        t.push_back(std::stoll(timeStr));
        int i = 0;
        while (isdigit(actionStr.at(i)))
          i++;
        std::string xValueStr = actionStr.substr(0, i);
        xValue = std::stoi(xValueStr);
        std::string yValueStr = actionStr.substr(i+1);
        yValue = std::stoi(yValueStr);
        if (actionStr.at(i) == '+')
        {
          op = actionStr.at(i);
          zValue = xValue + yValue;
        }
        else if (actionStr.at(i) == '-')
        {
          op = actionStr.at(i);
          zValue = xValue - yValue;
        }
        else if (actionStr.at(i) == '*')
        {
          op = actionStr.at(i);
          zValue = xValue * yValue;
        }
        else if (actionStr.at(i) == '/')
        {
          op = actionStr.at(i);
          zValue = xValue / yValue;
        }
        question = actionStr;
        long long T = t.at(0);
        if (op == '+')
          qAdd->setQuestion(T, op, xValue, yValue);
        else if (op == '-')
          qSub->setQuestion(T, op, xValue, yValue);
        else if (op == '*')
          qMul->setQuestion(T, op, xValue, yValue);
        else if (op == '/')
          qDiv->setQuestion(T, op, xValue, yValue);

      }
      else
      {
        if (t.size() == 0)
          throw ExcQuestions("optQ::loadDataFile", "Incorrectly formatted data file " + _fileName + " in line " + std::to_string(ht.size() + hkt.size()+1) + ". Missing question.");
        addKey(actionStr.at(0), std::stoll(timeStr));
        if (actionStr.at(0) == '=')
        {
          determineAnswer();
          storeAnswer();
        }
      }
    }
  }

  void loadGamingTimeFile(const std::string& _fileName)
  {
    std::string line;
    std::ifstream file(_fileName);

    while (std::getline(file, line))
    {
#ifdef _WIN32
      std::cout << line << std::endl;
#endif

      size_t spacePos = line.find(' ');
      std::string startStr = line.substr(0, spacePos);
      std::string endStr = line.substr(spacePos + 1);

      hGtStart.push_back(std::stoll(startStr));
      hGtEnd.push_back(std::stoll(endStr));
    }
  }

  void checkValidQuestionAnswer()
  {
    if (op != '+' && op != '-' && op != '*' && op != '/')
      throw ExcQuestions("optQ::checkValidQuestionAnswer", std::string("Incorrect operator: ") + op);
    else if (xValue < 0)
      throw ExcQuestions("optQ::checkValidQuestionAnswer", "Negative xValue: " + std::to_string(xValue));
    else if (yValue < 0)
      throw ExcQuestions("optQ::checkValidQuestionAnswer", "Negative yValue: " + std::to_string(yValue));
    else if (zValue < 0)
      throw ExcQuestions("optQ::checkValidQuestionAnswer", "Negative zValue: " + std::to_string(zValue));
    else if (a.size()+1 != t.size())
      throw ExcQuestions("optQ::checkValidQuestionAnswer", "Number of stored time points are incorrect: " + std::to_string(t.size()) + " and the number of keys pressed are " + std::to_string(a.size()));
  }


  Questioner* qAdd;
  Questioner* qSub;
  Questioner* qMul;
  Questioner* qDiv;


  // Data for current question
  std::string question;
  char op; // Operator
  int xValue;
  int yValue;
  int zValue;
  int answer;

  std::vector<long long> t; // Times for current answer
  std::vector<char> a; // Answers (keys pressed) for current answer

  // Data for history
  std::vector<long long> ht; // Times when question where asked for historical questions
  std::vector<char> hop; // Historical questions operator
  std::vector<int> hx; // Historical questions xValue
  std::vector<int> hy; // Historical questions yValue

  std::vector<size_t> hInd; // Keys pressed for question i starts in position hInd(i)
  std::vector<char> hk; // Answers (keys pressed) for current answer for historical questions
  std::vector<long long> hkt; // Times when answers where given (keys were pressed) for historical questions

  std::vector<int> hz; // Historical questions zValue
  std::vector<int> hanswer; // Historical questions answer


  // Statistics
  std::vector<long> nQuestions;
  std::vector<long> nCorrect;

  // Gaming time
  long long gtStart;
  long long gtEnd;

  std::vector<long long> hGtStart; // Times when timer was started
  std::vector<long long> hGtEnd; // Times when timer was ended

  std::string fileName;
  std::string fileNameGamingTime;

};

#endif //OPTIMALEDUCATION_OPTQUESTIONS_H
