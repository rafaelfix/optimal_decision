//
// Created by Gabriel Blomvall on 2020-06-14.
// Deals with operators +, p, -, *, m, /, where e.g. 3p8 is 3+y=11 and 4m8 is 4*y=32 i.e. p = plus and m = multiplied

// Special characters used in file
// B = Backspace (old symbol <)
// C = Clear
// E = Enter (old symbol =)
// R = Return - exit visualization
// ? = Visualization

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

#define NOPERATORS 6 // +, p, -, *, m, /

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

void readQuestion(const std::string& actionStr, char& op, int& xValue, int& yValue, bool& hasEquality, int& zValue, char& visualizationQuestion)
{
  // String types: "1+9", "40/5a", "10+y=3a", "3*y=12"
  int i = 0;
  while (isdigit(actionStr.at(i)))
    i++;
  std::string xValueStr = actionStr.substr(0, i);
  xValue = std::stoi(xValueStr);
  char opChar = actionStr.at(i);

  std::string yzStr;
  char lastCh = actionStr.at(actionStr.length()-1);
  if (isdigit(lastCh)) // Assumes that last character is y- or z-value
  {
    yzStr = actionStr.substr(i+1);
    visualizationQuestion = ' ';
  }
  else
  {
    yzStr = actionStr.substr(i+1, actionStr.length()-i-2);
    visualizationQuestion = lastCh;
  }

  std::string yValueStr;
  size_t eqPos = yzStr.find('=');
  hasEquality = (eqPos != std::string::npos);
  if (hasEquality) // Has equality sign
  {
    yValueStr = yzStr.substr(0,eqPos);
    if (yValueStr.at(0) != 'y')
      throw ExcQuestions("readQuestion", "Incorrectly formatted question: " + actionStr + "\n With an equality sign, there should be the letter 'y' after + or *.");
    //throw ExcQuestions("optQ::readQuestion", "Incorrectly formatted data file " + _fileName + " in line " + std::to_string(ht.size() + hkt.size()+1) + ":" + actionStr + "\n With an equality sign, there should be the letter 'y' after + or *.");

    std::string zValueStr = yzStr.substr(eqPos+1);
    zValue = std::stoi(zValueStr);

    if (opChar == '+')
    {
      op = 'p';
      yValue = zValue - xValue;
    }
    else if (opChar == '*')
    {
      op = 'm';
      yValue = zValue / xValue;
    }
  }
  else // No equality sign
  {
    yValueStr = yzStr;
    yValue = std::stoi(yValueStr);
    if (opChar == '+')
    {
      op = opChar;
      zValue = xValue + yValue;
    }
    else if (opChar == '-')
    {
      op = opChar;
      zValue = xValue - yValue;
    }
    else if (opChar == '*')
    {
      op = opChar;
      zValue = xValue * yValue;
    }
    else if (opChar == '/')
    {
      op = opChar;
      zValue = xValue / yValue;
    }

  }

}

class Questioner
{
public:
  virtual ~Questioner() {}

  virtual void init() {}

  virtual void newQuestion(const long long tCur, char& op, int& xValue, int& yValue, int& zValue, char& visualizationQuestion)
  {
    srand((unsigned int) time(NULL));
    xValue = rand() % 10;
    yValue = rand() % 10;
    if (op == '+')
    {
      zValue = xValue + yValue;
    }
    else if (op == 'p')
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
    else if (op == 'm')
    {
      if (xValue == 0)
        xValue = 1 + rand() % 9;
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

  virtual int determineAnswer(const char& op, const int& xValue, const int& yValue, const int& zValue, const char visualizationQuestion, const std::vector<long long>& t, const std::vector<char>& c)
  {
    std::string str = "";
    bool flgVisualization = false;
    for (size_t i=0 ; i<c.size() ; i++)
    {
      char ch = c.at(i);
      if (flgVisualization)
      { // Skip all pressed items except 'R' - Return
        if (ch == 'R')
          flgVisualization = false;
        else if (ch == '?')
          throw ExcQuestions("QuestionerSequentialForgetting::determineAnswer", "Incorrect formatted string cannot enter visualization twice");
      }
      else
      { 
        if (ch == 'C')
          str = "";
        else if ((ch == 'B' || ch == '<') && c.size() > 0)
          str.pop_back();
        else if (ch == 'E' || ch == '=')
          break;
        else if (ch == '?')
          flgVisualization = true;
        else if (ch == 'R')
          throw ExcQuestions("QuestionerSequentialForgetting::determineAnswer", "Incorrect formatted string cannot exit visualization without entering it");
        else
          str = str + ch;
      }
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

class Sequence
{
public:
  Sequence() {}
  virtual ~Sequence() {}

  virtual unsigned int maxLearningLevel() const { return 0; }
  virtual unsigned int questionLevel(const int& x, const int& y) const { return 0; }

  bool validate() const
  {
    for (int x=0 ; x<=9 ; x++)
      for (int y=x+1 ; y<=9 ; y++)
        if (questionLevel(x, y) != questionLevel(y, x))
        {
#ifdef __linux__
#elif __APPLE__
#elif _WIN32
          std::cerr << "Levels for " << x << "+" << y << " do not reflect commutative property" << std::endl;
#endif
          return false;
        }
    return true;
  }

  void printLatex() const
  {
    validate();

#ifdef __linux__
#elif __APPLE__
#elif _WIN32
    std::cout << "\\begin{table}[h!]" << std::endl;
    std::cout << "\\tiny" << std::endl;
    std::cout << "\\begin{tabular}{|c|ccccc|ccccc|} \\hline" << std::endl;

    std::cout << "     + &";
    for (int y=0 ; y<10 ; y++)
    {
      std::cout << "       " << y;
      if (y<9)
        std::cout  << "  &";
      else
        std::cout  << " \\\\ \\hline" << std::endl;
    }

    for (int x=0 ; x<=9 ; x++)
    {
      std::cout << "     " << x << " &";
      for (int y=0 ; y<=9 ; y++)
      {
        int level = questionLevel(x, y);
        std::cout << " " << latexColor(x,y) << " " << std::setw(2) << level;
        if (y<9)
          std::cout  << "  &";
        else
          if (x==4 || x==9)
            std::cout  << " \\\\ \\hline" << std::endl;
          else
            std::cout  << " \\\\" << std::endl;
      }
    }
    std::cout << "\\end{tabular}" << std::endl;
    std::cout << "\\end{table}" << std::endl;
#endif
  }

  void generateLevelVector(std::vector<int>& level) const
  {
    validate();

    level.resize(100);
    std::size_t i=0;
    for (int x = 0; x <= 9; x++)
      for (int y = 0; y <= 9; y++)
        level.at(i++) = questionLevel(x, y);
  }

protected:
  std::string latexColor(const int& x, const int& y) const
  {
    if (x+y==10 || x==y)
      return std::string("\\ccG");
    else if (x+y < 10)
      return std::string("\\ccB");
    else
      return std::string("\\ccR");
  }
};

class SequenceAddV1 : public Sequence // Version 1.0
{
public:
  SequenceAddV1() {}
  virtual ~SequenceAddV1() {}

  virtual unsigned int maxLearningLevel() const { return 20; }
  virtual unsigned int questionLevel(const int& x, const int& y) const
  {
    if (x==0 || y==0) // x+0 and 0+y
      return 1;
    else if (x==1 || y==1) // x+1 and 1+y
      return 2;
    else if (x==2 && y==2) // 2+2
      return 3;
    else if (x==3 && y==3) // 3+3
      return 4;
    else if (x==4 && y==4) // 4+4
      return 5;
    else if (x==5 && y==5) // 5+5
      return 6;
    else if (x==6 && y==6) // 6+6
      return 7;
    else if (x==7 && y==7) // 7+7
      return 8;
    else if (x==8 && y==8) // 8+8
      return 9;
    else if (x==9 && y==9) // 9+9
      return 10;
    else if (x+2==y || x==y+2) // 2+4,3+5,4+6,5+7,6+8,7+9,4+2,5+3,6+4,7+5,8+6,9+7 - 12 values
      return 11;
    else if (x+1==y || x==y+1) // 2+3,3+4,4+5,5+6,6+7,7+8,8+9,3+2,4+3,5+4,6+5,7+6,8+7,9+8 - 14 values
      return 12;
    else if (x+y==10) // 2+8,3+7,7+3,8+2 - 4 values
      return 13;
    else if ((x==2 || y==2) && x+y<10) // 2+5,2+6,2+7,5+2,6+2,7+2 - 6 values
      return 14;
    else if (x+y==9) // 3+6,6+3 - 2 values
      return 15;
    else if (x+y==11) // 2+9,3+8,4+7,7+4,8+3,9+2 - 6 values
      return 16;
    else if (x+y==12) // 3+9,4+8,8+4,9+3 - 4 values
      return 17;
    else if (x+y==13) // 4+9,5+8,8+5,9+4 - 4 values
      return 18;
    else if (x+y==14) // 5+9,9+5 - 2 values
      return 19;
    else if (x+y==15) // 6+9,9+6 - 2 values
      return 20;
    else
      throw ExcQuestions("SequenceAddV1::questionLevel", "Unknown level");
  }
};

class SequenceAddV2 : public Sequence // Version 2.0
{
public:
  SequenceAddV2() {}
  virtual ~SequenceAddV2() {}

  virtual unsigned int maxLearningLevel() const { return 20; }
  virtual unsigned int questionLevel(const int& x, const int& y) const
  {
    if (x==0 || y==0) // x+0 and 0+y
      return 1;
    else if (x==1 || y==1) // x+1 and 1+y
      return 2;
    else if ((x==2 && y<=3) || (x<=3 && y==2)) // 2+2, 2+3, 3+2 - 3 values
      return 3;
    else if ((x==3 && y==3) || (x==2 && y<=6) || (x<=6 && y==2)) // 3+3, 2+4, 2+5, 2+6, 6+2, 5+2, 4+2 - 7 values
      return 4;
    else if (x==4 && y==4) // 4+4
      return 5;
    else if (x==5 && y==5) // 5+5
      return 6;
    else if (x==6 && y==6) // 6+6
      return 7;
    else if (x==7 && y==7) // 7+7
      return 8;
    else if (x==8 && y==8) // 8+8
      return 9;
    else if (x==9 && y==9) // 9+9
      return 10;
    else if (x+2==y || x==y+2) // 3+5,4+6,5+7,6+8,7+9,5+3,6+4,7+5,8+6,9+7 - 10 values
      return 11;
    else if (x+1==y || x==y+1) // 3+4,4+5,5+6,6+7,7+8,8+9,4+3,5+4,6+5,7+6,8+7,9+8 - 12 values
      return 12;
    else if (x+y==10) // 2+8,3+7,7+3,8+2 - 4 values
      return 13;
    else if ((x==2 || y==2) && x+y<10) // 2+7,7+2 - 2 values
      return 14;
    else if (x+y==9) // 3+6,6+3 - 2 values
      return 15;
    else if (x+y==11) // 2+9,3+8,4+7,7+4,8+3,9+2 - 6 values
      return 16;
    else if (x+y==12) // 3+9,4+8,8+4,9+3 - 4 values
      return 17;
    else if (x+y==13) // 4+9,5+8,8+5,9+4 - 4 values
      return 18;
    else if (x+y==14) // 5+9,9+5 - 2 values
      return 19;
    else if (x+y==15) // 6+9,9+6 - 2 values
      return 20;
    else
      throw ExcQuestions("SequenceAddV2::questionLevel", "Unknown level");
  }
};

class SequenceAddV3 : public Sequence // Version 3.0
{
public:
    SequenceAddV3() {}
    virtual ~SequenceAddV3() {}

    virtual unsigned int maxLearningLevel() const { return 44; }
    virtual unsigned int questionLevel(const int& x, const int& y) const
    {
        if (x==0 || y==0) // x+0 and 0+y
            return 1;
        else if (x==1 && y==1) // 1+1 - 1 value
            return 2;
        else if ((x==1 && y==2) || (x==2 && y==1)) // 1+2, 2+1 - 2 values
            return 3;
        else if ((x==1 && y==3) || (x==3 && y==1)) // 1+3, 3+1 - 2 values
            return 4;
        else if ((x==1 && y==4) || (x==4 && y==1)) // 1+4, 4+1 - 2 values
            return 5;
        else if ((x==1 && y==5) || (x==5 && y==1)) // 1+5, 5+1 - 2 values
            return 6;
        else if ((x==1 && y==6) || (x==6 && y==1)) // 1+6, 6+1 - 2 values
            return 7;
        else if ((x==1 && y==7) || (x==7 && y==1)) // 1+7, 7+1 - 2 values
            return 8;
        else if ((x==1 && y==8) || (x==8 && y==1)) // 1+8, 8+1 - 2 values
            return 9;
        else if ((x==1 && y==9) || (x==9 && y==1)) // 1+9, 9+1 - 2 values
            return 10;
        else if (x==2 && y==2) // 2+2 - 1 value
            return 11;
        else if ((x==2 && y==3) || (x==3 && y==2)) // 2+3, 3+2 - 2 values
            return 12;
        else if ((x==2 && y==4) || (x==4 && y==2)) // 2+4, 4+2 - 2 values
            return 13;
        else if ((x==2 && y==5) || (x==5 && y==2)) // 2+5, 5+2 - 2 values
            return 14;
        else if ((x==2 && y==6) || (x==6 && y==2)) // 2+6, 6+2 - 2 values
            return 15;
        else if ((x==2 && y==7) || (x==7 && y==2)) // 2+7, 7+2 - 2 values
            return 16;
        else if ((x==2 && y==8) || (x==8 && y==2)) // 2+8, 8+2 - 2 values
            return 17;
        else if ((x==2 && y==9) || (x==9 && y==2)) // 2+9, 9+2 - 2 values
            return 18;
        else if (x==3 && y==3) // 3+3
            return 19;
        else if (x==4 && y==4) // 4+4
            return 20;
        else if (x==5 && y==5) // 5+5
            return 21;
        else if (x==6 && y==6) // 6+6
            return 22;
        else if (x==7 && y==7) // 7+7
            return 23;
        else if (x==8 && y==8) // 8+8
            return 24;
        else if (x==9 && y==9) // 9+9
            return 25;
        else if ((x==3 && y==4) || (x==4 && y==3)) // 3+4, 4+3 - 2 values
            return 26;
        else if ((x==4 && y==5) || (x==5 && y==4)) // 4+5, 5+4 - 2 values
            return 27;
        else if ((x==5 && y==6) || (x==6 && y==5)) // 5+6, 6+5 - 2 values
            return 28;
        else if ((x==6 && y==7) || (x==7 && y==6)) // 6+7, 7+6 - 2 values
            return 29;
        else if ((x==7 && y==8) || (x==8 && y==7)) // 7+8, 8+7 - 2 values
            return 30;
        else if ((x==8 && y==9) || (x==9 && y==8)) // 8+9, 9+8 - 2 values
            return 31;
        else if ((x==3 && y==5) || (x==5 && y==3)) // 3+5, 5+3 - 2 values
            return 32;
        else if ((x==4 && y==6) || (x==6 && y==4)) // 4+6, 6+4 - 2 values
            return 33;
        else if ((x==5 && y==7) || (x==7 && y==5)) // 5+7, 7+5 - 2 values
            return 34;
        else if ((x==6 && y==8) || (x==8 && y==6)) // 6+8, 8+6 - 2 values
            return 35;
        else if ((x==7 && y==9) || (x==9 && y==7)) // 7+9, 9+7 - 2 values
            return 36;
        else if ((x==3 && y==7) || (x==7 && y==3)) // 3+7, 7+3 - 2 values
            return 37;
        else if ((x==3 && y==6) || (x==6 && y==3)) // 3+6,6+3 - 2 values
            return 38;
        else if ((x==3 && y==8) || (x==8 && y==3)) // 3+8, 8+3 - 2 values
            return 39;
        else if ((x==4 && y==7) || (x==7 && y==4)) // 4+7, 7+4 - 2 values
            return 40;
        else if ((x==3 && y==9) || (x==9 && y==3)) // 3+9, 9+3 - 2 values
            return 41;
        else if ((x==4 && y==8) || (x==8 && y==4)) // 4+8, 8+4 - 2 values
            return 42;
        else if ((x==4 && y==9) || (x==9 && y==4)) // 4+9, 9+4 - 2 values
            return 41;
        else if ((x==5 && y==8) || (x==8 && y==5)) // 5+8, 8+5 - 2 values
            return 42;
        else if (x+y==14) // 5+9,9+5 - 2 values
            return 43;
        else if (x+y==15) // 6+9,9+6 - 2 values
            return 44;
        else
            throw ExcQuestions("SequenceAddV3::questionLevel", "Unknown level");
    }
};

class SequenceMulV1 : public Sequence // Version 1.0
{
public:
    SequenceMulV1() {}
    virtual ~SequenceMulV1() {}

    virtual unsigned int maxLearningLevel() const { return 31; }
    virtual unsigned int questionLevel(const int& x, const int& y) const
    {
      if (x==0 || y==0) // x*0 and 0*y - 19 values
        return 1;
      else if (x==1 || y==1) // x*1 and 1*y - 17 values
        return 2;
      else if (x==2 || y==2) // x*2 and 2*y - 15 values
        return 3;
      else if (x==3 && y==3) // 3*3 - 1 value
        return 4;
      else if ((x==3 && y==4) || (x==4 && y==3)) // 3*4, 4*3 - 2 values
        return 5;
      else if ((x==3 && y==5) || (x==5 && y==3)) // 3*5, 5*3 - 2 values
        return 6;
      else if ((x==3 && y==6) || (x==6 && y==3)) // 3*6, 6*3 - 2 values
        return 7;
      else if ((x==3 && y==7) || (x==7 && y==3)) // 3*7, 7*3 - 2 values
        return 8;
      else if ((x==3 && y==8) || (x==8 && y==3)) // 3*8, 8*3 - 2 values
        return 9;
      else if ((x==3 && y==9) || (x==9 && y==3)) // 3*9, 9*3 - 2 values
        return 10;
      else if (x==4 && y==4) // 4*4 - 1 value
        return 11;
      else if ((x==4 && y==5) || (x==5 && y==4)) // 4*5, 5*4 - 2 values
        return 12;
      else if ((x==4 && y==6) || (x==6 && y==4)) // 4*6, 6*4 - 2 values
        return 13;
      else if ((x==4 && y==7) || (x==7 && y==4)) // 4*7, 7*4 - 2 values
        return 14;
      else if ((x==4 && y==8) || (x==8 && y==4)) // 4*8, 8*4 - 2 values
        return 15;
      else if ((x==4 && y==9) || (x==9 && y==4)) // 4*9, 9*4 - 2 values
        return 16;
      else if (x==5 && y==5) // 5*5 - 1 value
        return 17;
      else if ((x==5 && y==6) || (x==6 && y==5)) // 5*6, 6*5 - 2 values
        return 18;
      else if ((x==5 && y==7) || (x==7 && y==5)) // 5*7, 7*5 - 2 values
        return 19;
      else if ((x==5 && y==8) || (x==8 && y==5)) // 5*8, 8*5 - 2 values
        return 20;
      else if ((x==5 && y==9) || (x==9 && y==5)) // 5*9, 9*5 - 2 values
        return 21;
      else if (x==6 && y==6) // 6*6 - 1 value
        return 22;
      else if ((x==6 && y==7) || (x==7 && y==6)) // 6*7, 7*6 - 2 values
        return 23;
      else if ((x==6 && y==8) || (x==8 && y==6)) // 6*8, 8*6 - 2 values
        return 24;
      else if ((x==6 && y==9) || (x==9 && y==6)) // 6*9, 9*6 - 2 values
        return 25;
      else if (x==7 && y==7) // 7*7 - 1 value
        return 26;
      else if ((x==7 && y==8) || (x==8 && y==7)) // 7*8, 8*7 - 2 values
        return 27;
      else if ((x==7 && y==9) || (x==9 && y==7)) // 7*9, 9*7 - 2 values
        return 28;
      else if (x==8 && y==8) // 8*8 - 1 value
        return 29;
      else if ((x==8 && y==9) || (x==9 && y==8)) // 8*9, 9*8 - 2 values
        return 30;
      else if (x==9 && y==9) // 9*9 - 1 value
        return 31;
      else
        throw ExcQuestions("SequenceMulV1::questionLevel", "Unknown level");
    }
};

class SequenceMulyV1 : public Sequence // Version 1.0
{
public:
  SequenceMulyV1() {}
  virtual ~SequenceMulyV1() {}

  virtual unsigned int maxLearningLevel() const { return 31; }
  virtual unsigned int questionLevel(const int& x, const int& y) const
  {
    if (x==0) // Do not use these questions
      return 1000;
    else if (x==0 || y==0) // x*0 and 0*y - 19 values
      return 1;
    else if (x==1 || y==1) // x*1 and 1*y - 17 values
      return 2;
    else if (x==2 || y==2) // x*2 and 2*y - 15 values
      return 3;
    else if (x==3 && y==3) // 3*3 - 1 value
      return 4;
    else if ((x==3 && y==4) || (x==4 && y==3)) // 3*4, 4*3 - 2 values
      return 5;
    else if ((x==3 && y==5) || (x==5 && y==3)) // 3*5, 5*3 - 2 values
      return 6;
    else if ((x==3 && y==6) || (x==6 && y==3)) // 3*6, 6*3 - 2 values
      return 7;
    else if ((x==3 && y==7) || (x==7 && y==3)) // 3*7, 7*3 - 2 values
      return 8;
    else if ((x==3 && y==8) || (x==8 && y==3)) // 3*8, 8*3 - 2 values
      return 9;
    else if ((x==3 && y==9) || (x==9 && y==3)) // 3*9, 9*3 - 2 values
      return 10;
    else if (x==4 && y==4) // 4*4 - 1 value
      return 11;
    else if ((x==4 && y==5) || (x==5 && y==4)) // 4*5, 5*4 - 2 values
      return 12;
    else if ((x==4 && y==6) || (x==6 && y==4)) // 4*6, 6*4 - 2 values
      return 13;
    else if ((x==4 && y==7) || (x==7 && y==4)) // 4*7, 7*4 - 2 values
      return 14;
    else if ((x==4 && y==8) || (x==8 && y==4)) // 4*8, 8*4 - 2 values
      return 15;
    else if ((x==4 && y==9) || (x==9 && y==4)) // 4*9, 9*4 - 2 values
      return 16;
    else if (x==5 && y==5) // 5*5 - 1 value
      return 17;
    else if ((x==5 && y==6) || (x==6 && y==5)) // 5*6, 6*5 - 2 values
      return 18;
    else if ((x==5 && y==7) || (x==7 && y==5)) // 5*7, 7*5 - 2 values
      return 19;
    else if ((x==5 && y==8) || (x==8 && y==5)) // 5*8, 8*5 - 2 values
      return 20;
    else if ((x==5 && y==9) || (x==9 && y==5)) // 5*9, 9*5 - 2 values
      return 21;
    else if (x==6 && y==6) // 6*6 - 1 value
      return 22;
    else if ((x==6 && y==7) || (x==7 && y==6)) // 6*7, 7*6 - 2 values
      return 23;
    else if ((x==6 && y==8) || (x==8 && y==6)) // 6*8, 8*6 - 2 values
      return 24;
    else if ((x==6 && y==9) || (x==9 && y==6)) // 6*9, 9*6 - 2 values
      return 25;
    else if (x==7 && y==7) // 7*7 - 1 value
      return 26;
    else if ((x==7 && y==8) || (x==8 && y==7)) // 7*8, 8*7 - 2 values
      return 27;
    else if ((x==7 && y==9) || (x==9 && y==7)) // 7*9, 9*7 - 2 values
      return 28;
    else if (x==8 && y==8) // 8*8 - 1 value
      return 29;
    else if ((x==8 && y==9) || (x==9 && y==8)) // 8*9, 9*8 - 2 values
      return 30;
    else if (x==9 && y==9) // 9*9 - 1 value
      return 31;
    else
      throw ExcQuestions("SequenceMulyV1::questionLevel", "Unknown level");
  }
};

class SequenceDivV1 : public Sequence // Version 1.0
{
public:
  SequenceDivV1() {}
  virtual ~SequenceDivV1() {}

  virtual unsigned int maxLearningLevel() const { return 31; }
  virtual unsigned int questionLevel(const int& x, const int& y) const
  {
    if (y==0) // Do not use these questions
      return 1000;
    else if (x==0 || y==0) // x*0 and 0*y - 19 values
      return 1;
    else if (x==1 || y==1) // x*1 and 1*y - 17 values
      return 2;
    else if (x==2 || y==2) // x*2 and 2*y - 15 values
      return 3;
    else if (x==3 && y==3) // 3*3 - 1 value
      return 4;
    else if ((x==3 && y==4) || (x==4 && y==3)) // 3*4, 4*3 - 2 values
      return 5;
    else if ((x==3 && y==5) || (x==5 && y==3)) // 3*5, 5*3 - 2 values
      return 6;
    else if ((x==3 && y==6) || (x==6 && y==3)) // 3*6, 6*3 - 2 values
      return 7;
    else if ((x==3 && y==7) || (x==7 && y==3)) // 3*7, 7*3 - 2 values
      return 8;
    else if ((x==3 && y==8) || (x==8 && y==3)) // 3*8, 8*3 - 2 values
      return 9;
    else if ((x==3 && y==9) || (x==9 && y==3)) // 3*9, 9*3 - 2 values
      return 10;
    else if (x==4 && y==4) // 4*4 - 1 value
      return 11;
    else if ((x==4 && y==5) || (x==5 && y==4)) // 4*5, 5*4 - 2 values
      return 12;
    else if ((x==4 && y==6) || (x==6 && y==4)) // 4*6, 6*4 - 2 values
      return 13;
    else if ((x==4 && y==7) || (x==7 && y==4)) // 4*7, 7*4 - 2 values
      return 14;
    else if ((x==4 && y==8) || (x==8 && y==4)) // 4*8, 8*4 - 2 values
      return 15;
    else if ((x==4 && y==9) || (x==9 && y==4)) // 4*9, 9*4 - 2 values
      return 16;
    else if (x==5 && y==5) // 5*5 - 1 value
      return 17;
    else if ((x==5 && y==6) || (x==6 && y==5)) // 5*6, 6*5 - 2 values
      return 18;
    else if ((x==5 && y==7) || (x==7 && y==5)) // 5*7, 7*5 - 2 values
      return 19;
    else if ((x==5 && y==8) || (x==8 && y==5)) // 5*8, 8*5 - 2 values
      return 20;
    else if ((x==5 && y==9) || (x==9 && y==5)) // 5*9, 9*5 - 2 values
      return 21;
    else if (x==6 && y==6) // 6*6 - 1 value
      return 22;
    else if ((x==6 && y==7) || (x==7 && y==6)) // 6*7, 7*6 - 2 values
      return 23;
    else if ((x==6 && y==8) || (x==8 && y==6)) // 6*8, 8*6 - 2 values
      return 24;
    else if ((x==6 && y==9) || (x==9 && y==6)) // 6*9, 9*6 - 2 values
      return 25;
    else if (x==7 && y==7) // 7*7 - 1 value
      return 26;
    else if ((x==7 && y==8) || (x==8 && y==7)) // 7*8, 8*7 - 2 values
      return 27;
    else if ((x==7 && y==9) || (x==9 && y==7)) // 7*9, 9*7 - 2 values
      return 28;
    else if (x==8 && y==8) // 8*8 - 1 value
      return 29;
    else if ((x==8 && y==9) || (x==9 && y==8)) // 8*9, 9*8 - 2 values
      return 30;
    else if (x==9 && y==9) // 9*9 - 1 value
      return 31;
    else
      throw ExcQuestions("SequenceDivV1::questionLevel", "Unknown level");
  }
};

class PreQuestion
{
public:
  PreQuestion() {}
  virtual ~PreQuestion() {}

  virtual void insertQuestion(const int& xValue, const int& yValue, const char& op, int& xValuePre, int& yValuePre, char& opPre) const {}
};

class PreQuestionAddV1 : public PreQuestion
{
public:
  PreQuestionAddV1() {}
  virtual ~PreQuestionAddV1() {}

  virtual void insertQuestion(const int& xValue, const int& yValue, const char& op, int& xValuePre, int& yValuePre, char& opPre) const
  {
    xValuePre = std::numeric_limits<int>::max();
    yValuePre = std::numeric_limits<int>::max();
    opPre = '+';
    if (xValue==2)
    {
      if (yValue==2)
        ; // Perhaps use 1+1
      else if (yValue==3)
      { xValuePre = 2; yValuePre = 2; }
      else if (yValue==4)
      { xValuePre = 1; yValuePre = 4; }
      //{ xValuePre = 3; yValuePre = 3; }
      else if (yValue==5)
      { xValuePre = 1; yValuePre = 5; }
      else if (yValue==6)
      { xValuePre = 1; yValuePre = 6; }
      else if (yValue==7)
      { xValuePre = 1; yValuePre = 7; }
      else if (yValue==8)
        ; // 10-friend
      else if (yValue==9)
      { xValuePre = 1; yValuePre = 9; }
    }
    else if (xValue==3)
    {
      if (yValue==2)
      { xValuePre = 2; yValuePre = 2; }
      else if (yValue==3)
      { xValuePre = 2; yValuePre = 2; }
      else if (yValue==4)
      { xValuePre = 3; yValuePre = 3; }
      else if (yValue==5)
      { xValuePre = 4; yValuePre = 4; }
      else if (yValue==6)
      { xValuePre = 2; yValuePre = 6; }
      else if (yValue==7)
        ; // 10-friend
      else if (yValue==8)
      { xValuePre = 2; yValuePre = 8; }
      else if (yValue==9)
      { xValuePre = 1; yValuePre = 9; }
    }
    else if (xValue==4)
    {
      if (yValue==2)
      { xValuePre = 4; yValuePre = 1; }
      //{ xValuePre = 3; yValuePre = 3; }
      else if (yValue==3)
      { xValuePre = 3; yValuePre = 3; }
      else if (yValue==4)
      { xValuePre = 3; yValuePre = 3; }
      else if (yValue==5)
      { xValuePre = 4; yValuePre = 4; }
      else if (yValue==6)
      { xValuePre = 5; yValuePre = 5; } // 10-friend - but still almost double
      else if (yValue==7)
      { xValuePre = 3; yValuePre = 7; }
      else if (yValue==8)
      { xValuePre = 2; yValuePre = 8; }
      else if (yValue==9)
      { xValuePre = 1; yValuePre = 9; }
    }
    else if (xValue==5)
    {
      if (yValue==2)
      { xValuePre = 5; yValuePre = 1; }
      else if (yValue==3)
      { xValuePre = 4; yValuePre = 4; }
      else if (yValue==4)
      { xValuePre = 4; yValuePre = 4; }
      else if (yValue==5)
        ; // 10-friend
      else if (yValue==6)
      { xValuePre = 5; yValuePre = 5; }
      else if (yValue==7)
      { xValuePre = 6; yValuePre = 6; }
      else if (yValue==8)
      { xValuePre = 2; yValuePre = 8; }
      else if (yValue==9)
      { xValuePre = 1; yValuePre = 9; }
    }
    else if (xValue==6)
    {
      if (yValue==2)
      { xValuePre = 6; yValuePre = 1; }
      else if (yValue==3)
      { xValuePre = 6; yValuePre = 2; }
      else if (yValue==4)
      { xValuePre = 5; yValuePre = 5; } // 10-friend - but still almost double
      else if (yValue==5)
      { xValuePre = 5; yValuePre = 5; }
      else if (yValue==6)
      { xValuePre = 5; yValuePre = 5; }
      else if (yValue==7)
      { xValuePre = 6; yValuePre = 6; }
      else if (yValue==8)
      { xValuePre = 7; yValuePre = 7; }
      else if (yValue==9)
      { xValuePre = 1; yValuePre = 9; }
    }
    else if (xValue==7)
    {
      if (yValue==2)
      { xValuePre = 7; yValuePre = 1; }
      else if (yValue==3)
        ; // 10-friend
      else if (yValue==4)
      { xValuePre = 7; yValuePre = 3; }
      else if (yValue==5)
      { xValuePre = 6; yValuePre = 6; }
      else if (yValue==6)
      { xValuePre = 6; yValuePre = 6; }
      else if (yValue==7)
      { xValuePre = 6; yValuePre = 6; }
      else if (yValue==8)
      { xValuePre = 7; yValuePre = 7; }
      else if (yValue==9)
      { xValuePre = 8; yValuePre = 8; }
    }
    else if (xValue==8)
    {
      if (yValue==2)
        ; // 10-friend
      else if (yValue==3)
      { xValuePre = 8; yValuePre = 2; }
      else if (yValue==4)
      { xValuePre = 8; yValuePre = 2; }
      else if (yValue==5)
      { xValuePre = 8; yValuePre = 2; }
      else if (yValue==6)
      { xValuePre = 7; yValuePre = 7; }
      else if (yValue==7)
      { xValuePre = 7; yValuePre = 7; }
      else if (yValue==8)
      { xValuePre = 7; yValuePre = 7; }
      else if (yValue==9)
      { xValuePre = 8; yValuePre = 8; }
    }
    else if (xValue==9)
    {
      if (yValue==2)
      { xValuePre = 9; yValuePre = 1; }
      else if (yValue==3)
      { xValuePre = 9; yValuePre = 1; }
      else if (yValue==4)
      { xValuePre = 9; yValuePre = 1; }
      else if (yValue==5)
      { xValuePre = 9; yValuePre = 1; }
      else if (yValue==6)
      { xValuePre = 9; yValuePre = 1; }
      else if (yValue==7)
      { xValuePre = 8; yValuePre = 8; }
      else if (yValue==8)
      { xValuePre = 8; yValuePre = 8; }
      else if (yValue==9)
      { xValuePre = 8; yValuePre = 8; }
    }

  }

};

class PreQuestionMulV1 : public PreQuestion
{
public:
  PreQuestionMulV1() {}
  virtual ~PreQuestionMulV1() {}

  virtual void insertQuestion(const int& xValue, const int& yValue, const char& op, int& xValuePre, int& yValuePre, char& opPre) const
  {
    xValuePre = std::numeric_limits<int>::max();
    yValuePre = std::numeric_limits<int>::max();
    opPre = '*';
    if (xValue>=2)
    {
      if (yValue>=2)
      { 
        xValuePre = xValue-1; 
        yValuePre = yValue; 
      }
    }

  }

};


class QuestionerSequentialForgetting : public Questioner
{
public:
  QuestionerSequentialForgetting() : priority(100), nQuestions(100), pIncorrect(100), lnt(100), lntAll(0),
    s(NULL), pq(NULL)
  {}

  virtual ~QuestionerSequentialForgetting() 
  {
    delete s;
    delete pq;
  }

  virtual void init()
  {
    pIncorrectAll = 1.0;
    for (size_t i=0 ; i<100 ; i++)
    {
      priority.at(i) = -1;
      nQuestions.at(i) = 0;
      pIncorrect.at(i) = 0;
      lnt.at(i) = 0;
    }

    curLevel = 1;
    tLast = 0;
    xValueNext = -1;
    yValueNext = -1;

    initLevel(curLevel);
    curLevel++;
    initLevel(curLevel);
    recordLevel_ = curLevel;
  }

  virtual void newQuestion(const long long tCur, char& op, int& xValue, int& yValue, int& zValue, char& visualizationQuestion)
  {
    throw ExcQuestions("QuestionerSequentialForgetting::newQuestion", "Not initialized");
  }

  virtual void setQuestion(const long long tCur, const char& op, const int& xValue, const int& yValue)
  {
    updatePriority(tCur);
    unsigned int qLevel = questionLevel(xValue, yValue);

    if (qLevel > curLevel)
    {
      for (curLevel++ ; curLevel <= qLevel ; curLevel++)
        initLevel(curLevel);
      curLevel = qLevel;
    }
    // printPriority();
  }

  virtual int determineAnswer(const char& op, const int& xValue, const int& yValue, const int& zValue, const char visualizationQuestion, const std::vector<long long>& t, const std::vector<char>& c)
  {
    if (!isspace(visualizationQuestion))
      return -1; // No answer is given from user during visualization

    std::string str = "";
    bool flgVisualization = false;
    std::size_t iStart = 0;
    long long tVisualization = 0;
    for (size_t i=0 ; i<c.size() ; i++)
    {
      char ch = c.at(i);
      if (flgVisualization)
      { // Skip all pressed items except 'R' - Return
        if (ch == 'R')
        {
          flgVisualization = false;
          tVisualization += t.at(i)-t.at(iStart);
        }
        else if (ch == '?')
          throw ExcQuestions("QuestionerSequentialForgetting::determineAnswer", "Incorrect formatted string cannot enter visualization twice");
      }
      else
      { 
        if (ch == 'C')
          str = "";
        else if ((ch == 'B' || ch == '<') && c.size() > 0)
          str.pop_back();
        else if (ch == 'E' || ch == '=')
          break;
        else if (ch == '?')
        {
          flgVisualization = true;
          iStart = i;
        }
        else if (ch == 'R')
          throw ExcQuestions("QuestionerSequentialForgetting::determineAnswer", "Incorrect formatted string cannot exit visualization without entering it");
        else
          str = str + ch;
      }
    }

    int answer = std::stoi(str);

    long long tFinished = t.at(t.size()-1);
    double qt = (tFinished - t.at(0) - tVisualization)/1000.0;

    bool isCorrect = false;
    if (op == 'p' || op =='m')
      isCorrect = (answer == yValue);
    else
      isCorrect = (answer == zValue);

    if (!isCorrect)
      qt += 10; // Penalty for incorrect answer

    std::size_t ii = getIndex(xValue, yValue);
    //double lambda = 0.9;
    double lambda = 0.8; // Decrease for smaller children (if focus stray)
    double& p = priority.at(ii);

    if (p<=0)
      throw ExcQuestions("QuestionerSequentialForgetting::determineAnswer", "Priority should be positive");
    p = exp(lambda*log(p) + (1-lambda)*log(qt));

    double lambdaI = 0.995;
    double lambdaT = 0.95;

    long& rn = nQuestions.at(ii);
    double& rpI = pIncorrect.at(ii);
    double& rlnt = lnt.at(ii);

    double incorrect = (double)(!isCorrect);

    rn++;
    rpI = lambdaI*rpI + (1-lambdaI)*incorrect;
    pIncorrectAll = lambdaI*pIncorrectAll + (1-lambdaI)*incorrect;
    rlnt = lambdaT*rlnt + (1-lambdaT)*log(qt);
    lntAll = lambdaT*lntAll + (1-lambdaT)*log(qt);

    double lvlf = 0.0;
    for (size_t i=0 ; i<100 ; i++)
    {
      lvlf += log(pIncorrect.at(i) + pIncorrectAll*pow(lambdaI,(double)nQuestions.at(i)));
      lvlf += lnt.at(i) + lntAll*pow(lambdaT,(double)nQuestions.at(i));
    }

    unsigned int lvl_ = s->maxLearningLevel();
    if (curLevel >= lvl_)
    {
      curLevel = (unsigned int)round(lvl_+ (-lvlf/600)*(100-lvl_));
      if (curLevel < lvl_)
        curLevel = lvl_;
    }
    if (curLevel > recordLevel_)
      recordLevel_ = curLevel;

    return answer;
  }

  void printPriorityOrder()
  {
#ifdef __linux__
#elif __APPLE__
#elif _WIN32
    for (int x=0 ; x<= 9 ; x++)
    {
      for (int y=0 ; y<= 9 ; y++)
        std::cout << std::setw(2) << questionLevel(x, y) << " ";
      std::cout << std::endl;
    }
#endif
  }

  void printPriority()
  {
#ifdef __linux__
#elif __APPLE__
#elif _WIN32
    for (int x=0 ; x<= 9 ; x++)
    {
      for (int y=0 ; y<= 9 ; y++)
        std::cout << std::setprecision(3) << std::setw(5) << priority.at(x*10+y) << " ";
      std::cout << std::endl;
    }
#endif
  }

  void checkSymmetryinsertQuestionHelper()
  {
    for (int x=0 ; x<= 9 ; x++)
      for (int y=x+1 ; y<= 9 ; y++)
      {
        int xValue = x;
        int yValue = y;
        insertQuestion(xValue, yValue);
        int xValue1 = xValue;
        int yValue1 = yValue;
        int xValueNext1 = xValueNext;
        int yValueNext1 = yValueNext;
        xValue = y;
        yValue = x;
        insertQuestion(xValue, yValue);
        if (xValueNext1 >= 0 || yValueNext1 >= 0 || xValueNext >= 0 || yValueNext >= 0)
        {
          if (xValue1 != yValue || yValue1 != xValue)
#ifdef __linux__
            ;
#elif __APPLE__
            ;
#elif _WIN32
            std::cout << "Unsymmetric: " << xValue1 << "+" << yValue1 << " precedes " << xValueNext1 << "+" << yValueNext1 << " and " << std::endl
            << "             " << xValue << "+" << yValue << " precedes " << xValueNext << "+" << yValueNext << std::endl;
#endif
        }
        xValueNext = -1;
        yValueNext = -1;
      }
  }

  double maxPriority()
  {
    double max = priority.at(0);
    for (size_t i=1 ; i<priority.size() ; i++)
      if (priority.at(i) > max)
        max = priority.at(i);
    return max;
  }

  virtual std::string status() 
  {
    return std::string("Lvl:") + std::to_string(curLevel) + std::string(" Max s: ") + std::to_string(maxPriority());
  }

  virtual unsigned int level()
  {
    return curLevel;
  }

  virtual unsigned int recordLevel()
  {
    return recordLevel_;
  }

  virtual unsigned int maxLearningLevel()
  {
    if (s != NULL)
      return s->maxLearningLevel();
    else
      return 0;
  }

  virtual double statusTime()
  {
    return maxPriority();
  }

protected:
  virtual size_t getIndex(int xValue, int yValue)
  {
    if (xValue < 0 || xValue > 9 || yValue < 0 || yValue > 9)
      throw ExcQuestions("QuestionerSequentialForgetting::getIndex", "x or y out of range");
    return (size_t)xValue*10 + (size_t)yValue;
  }

  double& getPriority(int xValue, int yValue)
  {
    return priority.at(getIndex(xValue, yValue));
  }

  void updatePriority(long long tCur)
  {
    double pt = (tCur - tLast)/1000.0;
    if (tLast > 0)
      for (size_t i=0 ; i<priority.size() ; i++)
      {
        double& p = priority.at(i);
        if (p > 0)
          p *= std::min(exp(log(2)*pt/(3600*24*7*4)), 2.0); // Double every month
      }
    tLast = tCur;
  }

  virtual void initLevel(unsigned int iLevel)
  {
    // double initValue = ((iLevel == 1)?5:maxPriority())*1.1;
    double initValue = 5;
    for (int x=0 ; x<=9 ; x++)
      for (int y=0 ; y<=9 ; y++)
        if (questionLevel(x, y) <= iLevel)
        {
          double& p = getPriority(x, y);
          if (p<0)
          {
            if (iLevel <= 2)
              p = initValue + ((rand() % 1000)-500)/10000.0;
            else
              p = initValue + (rand() % 1000)/10000.0;
          }
        }

  }

  virtual unsigned int questionLevel(int x, int y)
  { 
    return s->questionLevel(x,y);
  }

  void insertQuestion(int& xValue, int& yValue)
  {
    throw ExcQuestions("QuestionerSequentialForgetting::insertQuestion", "Not initialized");
  }
  std::vector<double> priority;
  std::vector<long> nQuestions;
  std::vector<double> pIncorrect;
  double pIncorrectAll;
  std::vector<double> lnt;
  double lntAll;
  unsigned int curLevel;
  unsigned int recordLevel_;
  long long tLast; // Time when previous questions was answered

  Sequence* s;
  PreQuestion* pq;

  int xValueNext;
  int yValueNext;
  int invVisualizationFrequency;
};

class QuestionerAddSequentialForgetting : public QuestionerSequentialForgetting
{
public:
  QuestionerAddSequentialForgetting() 
  {
    s = new SequenceAddV3;
    pq = new PreQuestionAddV1;
    invVisualizationFrequency = 5;

    init();
    //printPriority();

    // printPriorityOrder();
    // checkSymmetryinsertQuestionHelper();
  }

  virtual ~QuestionerAddSequentialForgetting() {}

  virtual void newQuestion(const long long tCur, char& op, int& xValue, int& yValue, int& zValue, char& visualizationQuestion)
  {
    updatePriority(tCur);

    if (op == '+')
    {
      visualizationQuestion = ' ';
      if (xValueNext >= 0 && yValueNext >= 0)
      {
        xValue = xValueNext;
        yValue = yValueNext;
        xValueNext = -1;
        yValueNext = -1;
        zValue = xValue + yValue;
        return;
      }
      size_t iMax = 0;
      double max = priority.at(0);
      for (size_t i=1 ; i<priority.size() ; i++)
        if (priority.at(i) > max)
        {
          max = priority.at(i);
          iMax = i;
        }

      if (max < 3 && curLevel < s->maxLearningLevel())
      {
        curLevel++;
        initLevel(curLevel);
      }

      int q = (int)iMax;
      yValue = q%10;
      xValue = (q-yValue)/10;

      xValueNext = -1;
      yValueNext = -1;

      if (max >= 5 && tCur%invVisualizationFrequency == 0) // Use visual help
      {
        visualizationQuestion = 'a';
        xValueNext = xValue;
        yValueNext = yValue;
      }
      else if (max >= 5) // Ask leading question (if available)
      {
        insertQuestion(xValue, yValue);
      }

      zValue = xValue + yValue;
    }
    else
      throw ExcQuestions("QuestionerAddSequentialForgetting::newQuestion", "Can only deal with addition");
  }


protected:

  void insertQuestion(int& xValue, int& yValue)
  {
    int xPre, yPre;
    char opPre;

    pq->insertQuestion(xValue, yValue, '+', xPre, yPre, opPre);

    if (xPre == std::numeric_limits<int>::max() || yPre == std::numeric_limits<int>::max())
    {
      xValueNext = -1;
      yValueNext = -1;
    }
    else
    {
      unsigned int qLevel = questionLevel(xPre, yPre);
      if (qLevel > curLevel)
#ifdef __linux__
        ;
#elif __APPLE__
        ;
#elif _WIN32
        std::cout << "Should not ask " << xPre << "+" << yPre << " ( level " << qLevel << ")" << " before " << xValue << "+" << yValue << " ( level " << curLevel << ")" << std::endl;
#endif
      xValueNext = xValue;
      yValueNext = yValue;
      xValue = xPre;
      yValue = yPre;
    }

  }
};

class QuestionerAddySequentialForgetting : public QuestionerSequentialForgetting
{
public:
  QuestionerAddySequentialForgetting() 
  {
    s = new SequenceAddV2;
    init();
    invVisualizationFrequency = 5;
    //printPriority();

    // printPriorityOrder();
    // checkSymmetryinsertQuestionHelper();
  }

  virtual ~QuestionerAddySequentialForgetting() {}

  virtual void newQuestion(const long long tCur, char& op, int& xValue, int& yValue, int& zValue, char& visualizationQuestion)
  {
    updatePriority(tCur);

    if (op == 'p')
    {
      visualizationQuestion = ' ';
      if (xValueNext >= 0 && yValueNext >= 0)
      {
        xValue = xValueNext;
        yValue = yValueNext;
        xValueNext = -1;
        yValueNext = -1;
        zValue = xValue + yValue;
        return;
      }
      size_t iMax = 0;
      double max = priority.at(0);
      for (size_t i = 1; i < priority.size(); i++)
        if (priority.at(i) > max)
        {
          max = priority.at(i);
          iMax = i;
        }

      if (max < 3 && curLevel < s->maxLearningLevel())
      {
        curLevel++;
        initLevel(curLevel);
      }

      int q = (int) iMax;
      yValue = q % 10;
      xValue = (q - yValue) / 10;
      zValue = xValue + yValue;


      xValueNext = -1;
      yValueNext = -1;

      if (max >= 5 && tCur%invVisualizationFrequency == 0) // Use visual help
      {
        visualizationQuestion = 'a';
        xValueNext = xValue;
        yValueNext = yValue;
      }
      else if (max >= 5) // Ask leading question (if available)
      { // These are currently only addition
        xValueNext = xValue;
        yValueNext = yValue;
        op = '+';
        //zValue = xValue;
        //xValue -= yValue;
      }
    } 
    else
      throw ExcQuestions("QuestionerAddySequentialForgetting::newQuestion", "Can only deal with addition with y");
  }


protected:

  virtual void initLevel(unsigned int iLevel)
  {
    // double initValue = ((iLevel == 1)?5:maxPriority())*1.1;
    double initValue = 5;
    for (int x=0 ; x<=9 ; x++)
      for (int y=0 ; y<=9 ; y++)
        if (questionLevel(x, y) <= iLevel)
        {
          double& p = getPriority(x, y);
          if (p<0)
          {
            if (iLevel <= 2)
              p = initValue + ((rand() % 1000)-500)/10000.0;
            else
              p = initValue + (rand() % 1000)/10000.0;
          }
        }
  }
};


class QuestionerSubSequentialForgetting : public QuestionerSequentialForgetting
{
public:
  QuestionerSubSequentialForgetting() 
  {
    s = new SequenceAddV2;
    init();
    invVisualizationFrequency = 5;

    // printPriorityOrder();
    // checkSymmetryinsertQuestionHelper();
  }

  virtual ~QuestionerSubSequentialForgetting() {}

  virtual void newQuestion(const long long tCur, char& op, int& xValue, int& yValue, int& zValue, char& visualizationQuestion)
  {
    updatePriority(tCur);

    if (op == '-')
    {
      visualizationQuestion = ' ';
      if (xValueNext >= 0 && yValueNext >= 0)
      {
        xValue = xValueNext;
        yValue = yValueNext;
        xValueNext = -1;
        yValueNext = -1;
        zValue = xValue - yValue;
        return;
      }
      size_t iMax = 0;
      double max = priority.at(0);
      for (size_t i = 1; i < priority.size(); i++)
        if (priority.at(i) > max)
        {
          max = priority.at(i);
          iMax = i;
        }

      if (max < 3 && curLevel < s->maxLearningLevel())
      {
        curLevel++;
        initLevel(curLevel);
      }

      int q = (int) iMax;
      yValue = q % 10;
      xValue = (q - yValue) / 10;
      zValue = xValue;
      xValue = zValue + yValue;


      xValueNext = -1;
      yValueNext = -1;

      if (max >= 5 && tCur%invVisualizationFrequency == 0) // Use visual help
      {
        visualizationQuestion = 'a';
        xValueNext = xValue;
        yValueNext = yValue;
      }
      else if (max >= 5) // Ask leading question (if available)
      { // These are currently only addition
        xValueNext = xValue;
        yValueNext = yValue;
        op = 'p';
        zValue = xValue;
        xValue -= yValue;
      }
    } 
    else
      throw ExcQuestions("QuestionerSubSequentialForgetting::newQuestion", "Can only deal with subtraction");
  }

protected:
  virtual size_t getIndex(int xValue, int yValue)
  {
    int zValue = xValue - yValue;
    if (zValue < 0 || zValue > 9 || yValue < 0 || yValue > 9)
      throw ExcQuestions("QuestionerSubSequentialForgetting::getIndex", "x or y out of range");
    return (size_t)zValue*10 + (size_t)yValue;
  }

  virtual void initLevel(unsigned int iLevel)
  {
    // double initValue = ((iLevel == 1)?5:maxPriority())*1.1;
    double initValue = 5;
    for (int x=0 ; x<=9 ; x++)
      for (int y=0 ; y<=9 ; y++)
        if (questionLevel(x+y, y) <= iLevel)
        {
          double& p = getPriority(x+y, y);
          if (p<0)
          {
            if (iLevel <= 2)
              p = initValue + ((rand() % 1000)-500)/10000.0;
            else
              p = initValue + (rand() % 1000)/10000.0;
          }
        }
  }

  virtual unsigned int questionLevel(int x, int y)
  {
    return s->questionLevel(x-y, y);
  }
};

class QuestionerMulSequentialForgetting : public QuestionerSequentialForgetting
{
public:
  QuestionerMulSequentialForgetting()
  {
    s = new SequenceMulV1;
    pq = new PreQuestionMulV1;
    invVisualizationFrequency = 5;

    init();
    //printPriority();

    // printPriorityOrder();
    // checkSymmetryinsertQuestionHelper();
  }

  virtual ~QuestionerMulSequentialForgetting() {}

  virtual void newQuestion(const long long tCur, char& op, int& xValue, int& yValue, int& zValue, char& visualizationQuestion)
  {
    updatePriority(tCur);

    if (op == '*')
    {
      visualizationQuestion = ' ';
      if (xValueNext >= 0 && yValueNext >= 0)
      {
        xValue = xValueNext;
        yValue = yValueNext;
        xValueNext = -1;
        yValueNext = -1;
        zValue = xValue * yValue;
        return;
      }
      size_t iMax = 0;
      double max = priority.at(0);
      for (size_t i=1 ; i<priority.size() ; i++)
        if (priority.at(i) > max)
        {
          max = priority.at(i);
          iMax = i;
        }

      if (max < 3 && curLevel < s->maxLearningLevel())
      {
        curLevel++;
        initLevel(curLevel);
      }

      int q = (int)iMax;
      yValue = q%10;
      xValue = (q-yValue)/10;

      xValueNext = -1;
      yValueNext = -1;

      if (max >= 5 && tCur%invVisualizationFrequency == 0) // Use visual help
      {
        visualizationQuestion = 'a';
        xValueNext = xValue;
        yValueNext = yValue;
      }
      else if (max >= 5) // Ask leading question (if available)
      {
        insertQuestion(xValue, yValue);
      }

      zValue = xValue * yValue;
    }
    else
      throw ExcQuestions("QuestionerAddSequentialForgetting::newQuestion", "Can only deal with addition");
  }


protected:

  void insertQuestion(int& xValue, int& yValue)
  {
    int xPre, yPre;
    char opPre;

    pq->insertQuestion(xValue, yValue, '*', xPre, yPre, opPre);

    if (xPre == std::numeric_limits<int>::max() || yPre == std::numeric_limits<int>::max())
    {
      xValueNext = -1;
      yValueNext = -1;
    }
    else
    {
      unsigned int qLevel = questionLevel(xPre, yPre);
      if (qLevel > curLevel)
#ifdef __linux__
        ;
#elif __APPLE__
        ;
#elif _WIN32
        std::cout << "Should not ask " << xPre << "+" << yPre << " ( level " << qLevel << ")" << " before " << xValue << "+" << yValue << " ( level " << curLevel << ")" << std::endl;
#endif
      xValueNext = xValue;
      yValueNext = yValue;
      xValue = xPre;
      yValue = yPre;
    }

  }
};

class QuestionerMulySequentialForgetting : public QuestionerSequentialForgetting
{
public:
  QuestionerMulySequentialForgetting()
  {
    s = new SequenceMulyV1;
    init();
    invVisualizationFrequency = 5;

    // printPriorityOrder();
    // checkSymmetryinsertQuestionHelper();
  }

  virtual ~QuestionerMulySequentialForgetting() {}

  virtual void newQuestion(const long long tCur, char& op, int& xValue, int& yValue, int& zValue, char& visualizationQuestion)
  {
    updatePriority(tCur);

    if (op == 'm')
    {
      visualizationQuestion = ' ';
      if (xValueNext >= 0 && yValueNext >= 0)
      {
        xValue = xValueNext;
        yValue = yValueNext;
        xValueNext = -1;
        yValueNext = -1;
        zValue = xValue * yValue;
        return;
      }
      size_t iMax = 0;
      double max = priority.at(0);
      for (size_t i = 1; i < priority.size(); i++)
        if (priority.at(i) > max)
        {
          max = priority.at(i);
          iMax = i;
        }

      if (max < 3 && curLevel < s->maxLearningLevel())
      {
        curLevel++;
        initLevel(curLevel);
      }

      int q = (int)iMax;
      yValue = q % 10;
      xValue = (q - yValue) / 10;
      if (xValue == 0) // Quick fix
        xValue = 1;
      zValue = xValue * yValue;

      xValueNext = -1;
      yValueNext = -1;

      if (max >= 5 && tCur%invVisualizationFrequency == 0) // Use visual help
      {
        visualizationQuestion = 'a';
        xValueNext = xValue;
        yValueNext = yValue;
      }
      else if (max >= 5) // Ask leading question (if available)
      { // These are currently only addition
        xValueNext = xValue;
        yValueNext = yValue;
        op = '*';
        //zValue = xValue;
        //xValue /= yValue;
      }
    }
    else
      throw ExcQuestions("QuestionerDivSequentialForgetting::newQuestion", "Can only deal with division");
  }

protected:

  virtual void initLevel(unsigned int iLevel)
  {
    // double initValue = ((iLevel == 1)?5:maxPriority())*1.1;
    double initValue = 5;
    for (int x=0 ; x<=9 ; x++)
      for (int y=1 ; y<=9 ; y++)
        if (questionLevel(x, y) <= iLevel)
        {
          double& p = getPriority(x, y);
          if (p<0)
          {
            if (iLevel <= 2)
              p = initValue + ((rand() % 1000)-500)/10000.0;
            else
              p = initValue + (rand() % 1000)/10000.0;
          }
        }
  }

};



class QuestionerDivSequentialForgetting : public QuestionerSequentialForgetting
{
public:
  QuestionerDivSequentialForgetting()
  {
    s = new SequenceDivV1;
    init();
    invVisualizationFrequency = 5;

    // printPriorityOrder();
    // checkSymmetryinsertQuestionHelper();
  }

  virtual ~QuestionerDivSequentialForgetting() {}

  virtual void newQuestion(const long long tCur, char& op, int& xValue, int& yValue, int& zValue, char& visualizationQuestion)
  {
    updatePriority(tCur);

    if (op == '/')
    {
      visualizationQuestion = ' ';
      if (xValueNext >= 0 && yValueNext >= 0)
      {
        xValue = xValueNext;
        yValue = yValueNext;
        xValueNext = -1;
        yValueNext = -1;
        zValue = xValue / yValue;
        return;
      }
      size_t iMax = 0;
      double max = priority.at(0);
      for (size_t i = 1; i < priority.size(); i++)
        if (priority.at(i) > max)
        {
          max = priority.at(i);
          iMax = i;
        }

      if (max < 3 && curLevel < s->maxLearningLevel())
      {
        curLevel++;
        initLevel(curLevel);
      }

      int q = (int)iMax;
      yValue = q % 10;
      xValue = (q - yValue) / 10;
      if (yValue == 0) // Quick fix
        yValue = 1;
      zValue = xValue;
      xValue = zValue * yValue;

      xValueNext = -1;
      yValueNext = -1;

      if (max >= 5 && tCur%invVisualizationFrequency == 0) // Use visual help
      {
        visualizationQuestion = 'a';
        xValueNext = xValue;
        yValueNext = yValue;
      }
      else if (max >= 5 && xValue != 0 && yValue != 0) // Ask leading question (if available)
      { // These are currently only multiplication with y
        xValueNext = xValue;
        yValueNext = yValue;
        op = 'm';
        zValue = xValue;
        xValue /= yValue;
      }
    }
    else
      throw ExcQuestions("QuestionerDivSequentialForgetting::newQuestion", "Can only deal with division");
  }

protected:
  virtual size_t getIndex(int xValue, int yValue)
  {
    int zValue = xValue / yValue;
    if (zValue < 0 || zValue > 9 || yValue < 0 || yValue > 9)
      throw ExcQuestions("QuestionerDivSequentialForgetting::getIndex", "x or y out of range");
    return (size_t)zValue*10 + (size_t)yValue;
  }

  virtual void initLevel(unsigned int iLevel)
  {
    // double initValue = ((iLevel == 1)?5:maxPriority())*1.1;
    double initValue = 5;
    for (int x=0 ; x<=9 ; x++)
      for (int y=1 ; y<=9 ; y++)
        if (questionLevel(x*y, y) <= iLevel)
        {
          double& p = getPriority(x*y, y);
          if (p<0)
          {
            if (iLevel <= 2)
              p = initValue + ((rand() % 1000)-500)/10000.0;
            else
              p = initValue + (rand() % 1000)/10000.0;
          }
        }
  }

  virtual unsigned int questionLevel(int x, int y)
  {
    return s->questionLevel(x/y, y);
  }
};


class optQ
{
public:
  optQ(unsigned int idAdd, unsigned int idAddy, unsigned int idSub, unsigned int idMul, unsigned int idMuly, unsigned int idDiv) 
    : nQuestions(NOPERATORS), nVisualizations(NOPERATORS), nCorrect(NOPERATORS), hInd(1), gtStart(0), gtEnd(0)

  {
    for (size_t i=0 ; i<NOPERATORS ; i++)
    {
      nQuestions.at(i) = 0;
      nVisualizations.at(i) = 0;
      nCorrect.at(i) = 0;
    }
    hInd.at(0) = 0;

    if (idAdd == 0)
      qAdd = new Questioner;
    else if (idAdd == 1)
      qAdd = new QuestionerAddSequentialForgetting;
    else
    {
#ifdef __linux__
#elif __APPLE__
#elif _WIN32
      std::cout << "Unknown id for addition" << std::endl;
#endif
      qAdd = new Questioner;
    }

    if (idAddy == 0)
      qAddy = new Questioner;
    else if (idAdd == 1)
      qAddy = new QuestionerAddySequentialForgetting;
    else
    {
#ifdef __linux__
#elif __APPLE__
#elif _WIN32
    std::cout << "Unknown id for addition" << std::endl;
#endif
      qAddy = new Questioner;
    }

    if (idSub == 0)
      qSub = new Questioner;
    else if (idSub == 1)
        qSub = new QuestionerSubSequentialForgetting;
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
    else if (idMul == 1)
      qMul = new QuestionerMulSequentialForgetting;
    else
    {
#ifdef __linux__
#elif __APPLE__
#elif _WIN32
      std::cout << "Unknown id for multiplication" << std::endl;
#endif
      qMul = new Questioner;
    }

    if (idMuly == 0)
      qMuly = new Questioner;
    else if (idMul == 1)
      qMuly = new QuestionerMulySequentialForgetting;
    else
    {
#ifdef __linux__
#elif __APPLE__
#elif _WIN32
      std::cout << "Unknown id for multiplication" << std::endl;
#endif
      qMuly = new Questioner;
    }

    if (idDiv == 0)
      qDiv = new Questioner;
    else if (idDiv == 1)
      qDiv = new QuestionerDivSequentialForgetting;
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
    if (qAddy != qAdd)
      delete qAddy;
    if (qSub != qAdd && qSub != qAddy)
      delete qSub;
    if (qMul != qAdd && qMul != qAddy && qMul != qSub)
      delete qMul;
    if (qMuly != qAdd && qMuly != qAddy && qMuly != qSub && qMuly != qMul)
      delete qMuly;
    if (qDiv != qAdd && qDiv != qAddy && qDiv != qSub && qDiv != qMul && qDiv != qMuly)
      delete qDiv;
  }

  void setDataFile(const std::string& _fileName)
  {
    fileName = _fileName;

    ht.resize(0);
    hop.resize(0);
    hx.resize(0);
    hy.resize(0);
    hVisualizationQuestion.resize(0);

    hInd.resize(1);
    hInd.at(0) = 0;
    hk.resize(0);
    hkt.resize(0);

    hz.resize(0);
    hanswer.resize(0);

    for (size_t i=0 ; i<NOPERATORS ; i++)
    {
      nQuestions.at(i) = 0;
      nVisualizations.at(i) = 0;
      nCorrect.at(i) = 0;
    }

    qAdd->init();
    qAddy->init();
    qSub->init();
    qMul->init();
    qMuly->init();
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
    else if (op == 'p')
    {
        if (QuestionerAddSequentialForgetting* add = dynamic_cast<QuestionerAddSequentialForgetting*>(qAdd))
            if (add->level() < add->maxLearningLevel())
                return '+';

        return 'p';
    }
    else if (op == '-')
    {
      if (QuestionerAddSequentialForgetting* addy = dynamic_cast<QuestionerAddSequentialForgetting*>(qAddy))
        if (addy->level() < addy->maxLearningLevel())
          return 'p';

      return '-';
    }
    else if (op == '*')
      return '*';
    else if (op == 'm')
    {
      if (QuestionerMulSequentialForgetting* mul = dynamic_cast<QuestionerMulSequentialForgetting*>(qMul))
        if (mul->level() < mul->maxLearningLevel())
          return '*';

      return 'm';
    }
    else if (op == '/')
    {
      if (QuestionerMulSequentialForgetting* muly = dynamic_cast<QuestionerMulSequentialForgetting*>(qMuly))
        if (muly->level() < muly->maxLearningLevel())
          return 'm';

      return '/';
    }
    return '+';
  }


  void newQuestion(const char& _op)
  {
    clearQuestion();
    long long T = getTime();

    op = _op;
    if (op == '+')
      qAdd->newQuestion(T, op, xValue, yValue, zValue, visualizationQuestion);
    else if (op == 'p')
      qAddy->newQuestion(T, op, xValue, yValue, zValue, visualizationQuestion);
    else if (op == '-')
      qSub->newQuestion(T, op, xValue, yValue, zValue, visualizationQuestion);
    else if (op == '*')
      qMul->newQuestion(T, op, xValue, yValue, zValue, visualizationQuestion);
    else if (op == 'm')
      qMuly->newQuestion(T, op, xValue, yValue, zValue, visualizationQuestion);
    else if (op == '/')
      qDiv->newQuestion(T, op, xValue, yValue, zValue, visualizationQuestion);

    if (op == 'p')
      question = std::to_string(xValue) + "+y=" + std::to_string(zValue) + visualizationQuestion;
    else if (op == 'm')
      question = std::to_string(xValue) + "*y=" + std::to_string(zValue) + visualizationQuestion;
    else
      question = std::to_string(xValue) + op + std::to_string(yValue) + visualizationQuestion;

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
        answer = qAdd->determineAnswer(op, xValue, yValue, zValue, visualizationQuestion, t, a);
      else if (op == 'p')
        answer = qAddy->determineAnswer(op, xValue, yValue, zValue, visualizationQuestion, t, a);
      else if (op == '-')
        answer = qSub->determineAnswer(op, xValue, yValue, zValue, visualizationQuestion, t, a);
      else if (op == '*')
        answer = qMul->determineAnswer(op, xValue, yValue, zValue, visualizationQuestion, t, a);
      else if (op == 'm')
        answer = qMuly->determineAnswer(op, xValue, yValue, zValue, visualizationQuestion, t, a);
      else if (op == '/')
        answer = qDiv->determineAnswer(op, xValue, yValue, zValue, visualizationQuestion, t, a);
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

      if (!isspace(visualizationQuestion))
        nVisualizations.at(j)++;
      else 
      {
        bool isCorrect;
        if (op == 'p' || op =='m')
          isCorrect = (answer == yValue);
        else
          isCorrect = (answer == zValue);
        if (isCorrect)
          nCorrect.at(j)++;
      }

      nQuestions.at(j)++;

      ht.push_back(t.at(0));
      hx.push_back(xValue);
      hop.push_back(op);
      hy.push_back(yValue);
      hVisualizationQuestion.push_back(visualizationQuestion);
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

  const std::string& getQuestion()   const { return question; }
  const int&         getX()          const { return xValue;    }
  const int&         getY()          const { return yValue;    }
  const int&         getZ()          const { return zValue;    }
  const char&        getVisualHelp() const { return visualizationQuestion;    }
  const int&         getAnswer()     const { return answer;    }
  const size_t       nHistory()      const { return ht.size(); }
  const size_t       nHistoryRows()  const { return ht.size() + hkt.size(); }

  std::string status()
  {
    if (op == '+')
      return qAdd->status();
    else if (op == 'p')
      return qAddy->status();
    else if (op == '-')
      return qSub->status();
    else if (op == '*')
      return qMul->status();
    else if (op == 'm')
      return qMuly->status();
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
    else if (tmp == 'p')
      return qAddy->level();
    else if (tmp == '-')
      return qSub->level();
    else if (tmp == '*')
      return qMul->level();
    else if (tmp == 'm')
      return qMuly->level();
    else if (tmp == '/')
      return qDiv->level();
    return 0;
  }

  unsigned int maxLearningLevel(char nop = 0)
  {
    char tmp = nop;
    if (nop == 0)
      tmp = op;
    if (tmp == '+')
      return qAdd->maxLearningLevel();
    else if (tmp == 'p')
      return qAddy->maxLearningLevel();
    else if (tmp == '-')
      return qSub->maxLearningLevel();
    else if (tmp == '*')
      return qMul->maxLearningLevel();
    else if (tmp == 'm')
      return qMuly->maxLearningLevel();
    else if (tmp == '/')
      return qDiv->maxLearningLevel();
    return 0;
  }

  unsigned int recordLevel(char nop = 0)
  {
    char tmp = nop;
    if (nop == 0)
      tmp = op;
    if (tmp == '+')
      return qAdd->recordLevel();
    else if (tmp == 'p')
      return qAddy->recordLevel();
    else if (tmp == '-')
      return qSub->recordLevel();
    else if (tmp == '*')
      return qMul->recordLevel();
    else if (tmp == 'm')
      return qMuly->recordLevel();
    else if (tmp == '/')
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
    else if (tmp == 'p')
      return qAddy->statusTime();
    else if (tmp == '-')
      return qSub->statusTime();
    else if (tmp == '*')
      return qMul->statusTime();
    else if (tmp == 'm')
      return qMuly->statusTime();
    else if (tmp == '/')
      return qDiv->statusTime();
    return std::numeric_limits<double>::infinity();
  }

  long nQuestion(char nop = 0)
  {
    char tmp = nop;

    if (nop == 0)
      tmp = op;
    size_t i = operatorIndex(tmp);

    return nQuestions.at(i);
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
      std::string q = std::to_string(hx.at(i)) + hop.at(i) + std::to_string(hy.at(i)) + hVisualizationQuestion.at(i);
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
        std::string q = std::to_string(hx.at(i)) + hop.at(i) + std::to_string(hy.at(i)) + hVisualizationQuestion.at(i);
        if (inputs.size() == 0)
          inputs = q;
        else
          inputs += std::string(" ") + q;
      }

      for (size_t j=hInd.at(i) ; j<hInd.at(i+1) ; j++)
        if (iRow++ >= startRow)
        {
          std::string q = std::to_string(hx.at(i)) + hop.at(i) + std::to_string(hy.at(i)) + hVisualizationQuestion.at(i);
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
    // return 0;
  }

  size_t operatorIndex(const char& _op)
  {
    switch (_op)
    {
      case '+':
        return 0;
      case 'p':
        return 1;
      case '-':
        return 2;
      case '*':
        return 3;
      case 'm':
        return 4;
      case '/':
        return 5;
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
    bool hasEquality;

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
        readQuestion(actionStr, op, xValue, yValue, hasEquality, zValue, visualizationQuestion);
          
        question = actionStr;
        long long T = t.at(0);
        if (hasEquality)
        {
          if (op == 'p')
            qAddy->setQuestion(T, op, xValue, yValue);
          else if (op == 'm')
            qMuly->setQuestion(T, op, xValue, yValue);
        }
        else if (op == '+')
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
        if (actionStr.at(0) == 'E' || actionStr.at(0) == '=') // Also accept = sign (for now)
        {
          //std::cout << actionStr << " " << xValue << op << yValue << " " << hasEquality << " " << zValue << " " << visualizationQuestion << std::endl;
          determineAnswer();
          storeAnswer();
        }
        else if (!isspace(visualizationQuestion) && actionStr.at(0) == 'R') // visualization question ends with 'R' - Return 
        {
          //std::cout << actionStr << " " << xValue << op << yValue << " " << hasEquality << " " << zValue << " " << visualizationQuestion << std::endl;
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
    if (op != '+' && op != 'p' && op != '-' && op != '*' && op != 'm' && op != '/')
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
  Questioner* qAddy;
  Questioner* qSub;
  Questioner* qMul;
  Questioner* qMuly;
  Questioner* qDiv;


  // Data for current question
  std::string question;
  char op; // Operator
  int xValue;
  int yValue;
  int zValue;
  int answer;
  char visualizationQuestion;

  std::vector<long long> t; // Times for current answer
  std::vector<char> a; // Answers (keys pressed) for current answer

  // Data for history
  std::vector<long long> ht; // Times when question where asked for historical questions
  std::vector<char> hop; // Historical questions operator
  std::vector<int> hx; // Historical questions xValue
  std::vector<int> hy; // Historical questions yValue
  std::vector<char> hVisualizationQuestion; // Historical visualization questions

  std::vector<size_t> hInd; // Keys pressed for question i starts in position hInd(i)
  std::vector<char> hk; // Answers (keys pressed) for current answer for historical questions
  std::vector<long long> hkt; // Times when answers where given (keys were pressed) for historical questions

  std::vector<int> hz; // Historical questions zValue
  std::vector<int> hanswer; // Historical questions answer


  // Statistics
  std::vector<long> nQuestions;
  std::vector<long> nVisualizations; // Only visualizations that has been shown as a question
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