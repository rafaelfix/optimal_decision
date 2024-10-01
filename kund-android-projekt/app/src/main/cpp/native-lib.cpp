#include <jni.h>
#include <string>

#include "optQuestions.h"

optQ oq(1,1,1,1);

std::string jstring2string(JNIEnv* env, jstring js)
{
    const jclass stringClass = env->GetObjectClass(js);
    const jmethodID getBytes = env->GetMethodID(stringClass, "getBytes", "(Ljava/lang/String;)[B");
    const jbyteArray stringJbytes = (jbyteArray) env->CallObjectMethod(js, getBytes, env->NewStringUTF("UTF-8"));

    size_t length = (size_t) env->GetArrayLength(stringJbytes);
    jboolean isCopy;
    const char *convertedValue = (env)->GetStringUTFChars(js, &isCopy);
    return std::string(convertedValue, length);
}

JNIEXPORT jdoubleArray JNICALL vector2array(JNIEnv *env, std::vector<double> vec)
{
    double input[vec.size()];

    // Store vector in double*
    for(std::size_t i=0 ; i<vec.size() ; i++)
        input[i] = vec.at(i);

    // Copy into Java double[]
    jdoubleArray array = env->NewDoubleArray(vec.size());
    env->SetDoubleArrayRegion(array, 0, vec.size(), ((jdouble*) &input));
    return array;
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_setDataFile(
        JNIEnv* env,
        jobject,
        jstring jFileName)
{
    std::string fileName = jstring2string(env, jFileName);
    try
    {
        oq.setDataFile(fileName);
    }
    catch (ExcQuestions& e) {
        return env->NewStringUTF(e.what().c_str());
        throw;
    }
    catch (std::exception& e) {
        return env->NewStringUTF(e.what());
    }
    catch (...) {
        return env->NewStringUTF("There was an error!\n");
    }
    return env->NewStringUTF("");
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_checkFeasibleOperator(
        JNIEnv* env,
        jobject,
        jstring jOperator)
{
    try
    {
        std::string operatorStr = jstring2string(env, jOperator);
        char operatorChar = operatorStr.at(0);
        char necessaryOperator = oq.checkFeasibleOperator(operatorChar);
        std::string tmp(1,necessaryOperator);
        return env->NewStringUTF(tmp.c_str());
    }
    catch (ExcQuestions& e) {
        return env->NewStringUTF(e.what().c_str());
        throw;
    }
    catch (std::exception& e) {
        return env->NewStringUTF(e.what());
    }
    catch (...) {
        return env->NewStringUTF("There was an error!\n");
    }
    return env->NewStringUTF("");
}


extern "C" JNIEXPORT jstring JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_newQuestion(
        JNIEnv* env,
        jobject,
        jstring jOperator)
{
    try
    {
        std::string operatorStr = jstring2string(env, jOperator);
        char operatorChar = operatorStr.at(0);
        oq.newQuestion(operatorChar);
    }
    catch (ExcQuestions& e) {
        return env->NewStringUTF(e.what().c_str());
        throw;
    }
    catch (std::exception& e) {
        return env->NewStringUTF(e.what());
    }
    catch (...) {
        return env->NewStringUTF("There was an error!\n");
    }
    return env->NewStringUTF("");
}

extern "C" JNIEXPORT void JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_clearQuestion(
        JNIEnv* env,
        jobject)
{
    oq.clearQuestion();
}

extern "C" JNIEXPORT void JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_addKey(
        JNIEnv* env,
        jobject,
        jstring jkey)
{
    std::string keyStr = jstring2string(env, jkey);
    char key = keyStr.at(0);
    oq.addKey(key);
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_determineAnswer(
        JNIEnv* env,
        jobject)
{
    try
    {
        oq.determineAnswer();
    }
    catch (ExcQuestions& e) {
        return env->NewStringUTF(e.what().c_str());
        throw;
    }
    catch (std::exception& e) {
        return env->NewStringUTF(e.what());
    }
    catch (...) {
        return env->NewStringUTF("There was an error!\n");
    }
    return env->NewStringUTF("");
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_storeAnswer(
        JNIEnv* env,
        jobject)
{
    try
    {
        oq.storeAnswer();
    }
    catch (ExcQuestions& e) {
        return env->NewStringUTF(e.what().c_str());
        throw;
    }
    catch (std::exception& e) {
        return env->NewStringUTF(e.what());
    }
    catch (...) {
        return env->NewStringUTF("There was an error!\n");
    }
    return env->NewStringUTF("");
}

extern "C" JNIEXPORT void JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_saveAnswerToFile(
        JNIEnv* env,
        jobject)
{
    oq.saveAnswerToFile();
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_correctString(
        JNIEnv* env,
        jobject,
        jstring jOperator)
{
    std::string operatorStr = jstring2string(env, jOperator);
    char operatorChar = operatorStr.at(0);
    std::string str = oq.correctString(operatorChar);
    return env->NewStringUTF(str.c_str());
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_getQuestion(
        JNIEnv* env,
        jobject)
{
    std::string question = oq.getQuestion();
    return env->NewStringUTF(question.c_str());
}

extern "C" JNIEXPORT int JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_getX(
        JNIEnv* env,
        jobject)
{
    int xValue = oq.getX();
    return xValue;
}

extern "C" JNIEXPORT int JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_getY(
        JNIEnv* env,
        jobject)
{
    int yValue = oq.getY();
    return yValue;
}

extern "C" JNIEXPORT int JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_getZ(
        JNIEnv* env,
        jobject)
{
    int zValue = oq.getZ();
    return zValue;
}

extern "C" JNIEXPORT int JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_getAnswer(
        JNIEnv* env,
        jobject)
{
    int answer = oq.getAnswer();
    return answer;
}

extern "C" JNIEXPORT int JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_nHistory(
        JNIEnv* env,
        jobject)
{
    int nHistory = oq.nHistory();
    return nHistory;
}

extern "C" JNIEXPORT int JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_nHistoryRows(
        JNIEnv* env,
        jobject)
{
    int nHistoryRows = oq.nHistoryRows();
    return nHistoryRows;
}

extern "C" JNIEXPORT int JNICALL
Java_com_optimaleducation_DbComm_nHistory(
        JNIEnv* env,
        jobject)
{
    int nHistory = oq.nHistory();
    return nHistory;
}

extern "C" JNIEXPORT int JNICALL
Java_com_optimaleducation_DbComm_nHistoryRows(
        JNIEnv* env,
        jobject)
{
    int nHistoryRows = oq.nHistoryRows();
    return nHistoryRows;
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_getStatus(
        JNIEnv* env,
        jobject)
{
    std::string status = oq.status();
    return env->NewStringUTF(status.c_str());
}

extern "C" JNIEXPORT int JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_getLevel(
        JNIEnv* env,
        jobject)
{
    unsigned int level = oq.level();
    return (int)level;
}

extern "C" JNIEXPORT double JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_statusTime(
        JNIEnv* env,
        jobject)
{
    double time = oq.statusTime();
    return time;
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_getDataTimes(
        JNIEnv* env,
        jobject)
{
    std::string status = oq.getDataTimes();
    return env->NewStringUTF(status.c_str());
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_getDataTimesStart(
        JNIEnv* env,
        jobject,
        int startQuestion)
{
    std::string status = oq.getDataTimes(startQuestion);
    return env->NewStringUTF(status.c_str());
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_getDataTimesStartRows(
        JNIEnv* env,
        jobject,
        int startRow)
{
    std::string status = oq.getDataTimesRows(startRow);
    return env->NewStringUTF(status.c_str());
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_getDataInputs(
        JNIEnv* env,
        jobject)
{
    std::string status = oq.getDataInputs();
    return env->NewStringUTF(status.c_str());
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_getDataInputsStart(
        JNIEnv* env,
        jobject,
        int startQuestion)
{
    std::string status = oq.getDataInputs(startQuestion);
    return env->NewStringUTF(status.c_str());
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_getDataInputsStartRows(
        JNIEnv* env,
        jobject,
        int startRow)
{
    std::string status = oq.getDataInputsRows(startRow);
    return env->NewStringUTF(status.c_str());
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_optimaleducation_DbComm_getDataTimesStart(
        JNIEnv* env,
        jobject,
        int startQuestion)
{
    std::string status = oq.getDataTimes(startQuestion);
    return env->NewStringUTF(status.c_str());
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_optimaleducation_DbComm_getDataTimesStartRows(
        JNIEnv* env,
        jobject,
        int startRow)
{
    std::string status = oq.getDataTimesRows(startRow);
    return env->NewStringUTF(status.c_str());
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_optimaleducation_DbComm_getDataInputsStart(
        JNIEnv* env,
        jobject,
        int startQuestion)
{
    std::string status = oq.getDataInputs(startQuestion);
    return env->NewStringUTF(status.c_str());
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_optimaleducation_DbComm_getDataInputsStartRows(
        JNIEnv* env,
        jobject,
        int startRow)
{
    std::string status = oq.getDataInputsRows(startRow);
    return env->NewStringUTF(status.c_str());
}

extern "C"
JNIEXPORT jdoubleArray JNICALL
Java_com_optimaleducation_AnswerQuestionsActivity_getSolutionTimes(JNIEnv *env, jobject thiz,
                                                                   jint nLast)
{
    std::vector<double> times = oq.getSolutionTimes(nLast);
    return vector2array(env, times);
}

extern "C"
JNIEXPORT jstring JNICALL
Java_com_optimaleducation_TimeActivity_setGamingTimeFile(JNIEnv *env, jobject thiz,
                                                         jstring jFileName) {
    std::string fileName = jstring2string(env, jFileName);
    try
    {
        oq.setGamingTimeFile(fileName);
    }
    catch (ExcQuestions& e) {
        return env->NewStringUTF(e.what().c_str());
        throw;
    }
    catch (std::exception& e) {
        return env->NewStringUTF(e.what());
    }
    catch (...) {
        return env->NewStringUTF("There was an error!\n");
    }
    return env->NewStringUTF("");
}

extern "C"
JNIEXPORT void JNICALL
Java_com_optimaleducation_TimeActivity_gamingTimeStart(JNIEnv *env, jobject thiz)
{
    oq.gamingTimeStart();
}

extern "C"
JNIEXPORT void JNICALL
Java_com_optimaleducation_TimeActivity_gamingTimeEnd(JNIEnv *env, jobject thiz)
{
    oq.gamingTimeEnd();
}

extern "C"
JNIEXPORT jdouble JNICALL
Java_com_optimaleducation_TimeActivity_gamingTimeAvail(JNIEnv *env, jobject thiz)
{
    return oq.gamingTime() - oq.spentGamingTime();
}

extern "C"
JNIEXPORT jdouble JNICALL
Java_com_optimaleducation_TimeActivity_gamingTimeCur(JNIEnv *env, jobject thiz)
{
    return oq.spentGamingTimeCur();
}
extern "C"
JNIEXPORT jstring JNICALL
Java_com_optimaleducation_MainActivity_setFiles(JNIEnv *env, jobject thiz, jstring jPath, jstring jUserName) {
    std::string path = jstring2string(env, jPath);
    std::string userName = jstring2string(env, jUserName);
    std::string fileName = path + "/optCalcDigit" + userName + ".txt";
    std::string gtFileName = path + "/optGamingTime" + userName + ".txt";
    try
    {
        oq.setDataFile(fileName);
        oq.setGamingTimeFile(gtFileName);
    }
    catch (ExcQuestions& e) {
        return env->NewStringUTF(e.what().c_str());
        throw;
    }
    catch (std::exception& e) {
        return env->NewStringUTF(e.what());
    }
    catch (...) {
        return env->NewStringUTF("There was an error!\n");
    }
    return env->NewStringUTF("");
}
