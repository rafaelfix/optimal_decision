// Write C++ code here.
//
// Do not forget to dynamically load the C++ library into your application.
//
// For instance,
//
// In MainActivity.java:
//    static {
//       System.loadLibrary("nativelib");
//    }
//
// Or, in MainActivity.kt:
//    companion object {
//      init {
//         System.loadLibrary("nativelib")
//      }
//    }

#include <jni.h>
#include <iostream>
#include <string>
#include "optQuestions.h"

extern "C" JNIEXPORT jstring JNICALL Java_com_example_nativelib_NLib_getstring(JNIEnv *env, jobject)
{
    return env->NewStringUTF("hello from cpp");
}

extern "C" JNIEXPORT jstring JNICALL Java_com_example_nativelib_NLib_convint(JNIEnv *env, jobject, jint num)
{
    char buf[64];
    sprintf(buf, "%d", num);
    return env->NewStringUTF(buf);
}

optQ oq(1, 1, 1, 1, 1, 1);

std::string jstring2string(JNIEnv *env, jstring js)
{
    const jclass stringClass = env->GetObjectClass(js);
    const jmethodID getBytes = env->GetMethodID(stringClass, "getBytes", "(Ljava/lang/String;)[B");
    const jbyteArray stringJbytes = (jbyteArray)env->CallObjectMethod(js, getBytes, env->NewStringUTF("UTF-8"));

    size_t length = (size_t)env->GetArrayLength(stringJbytes);
    jboolean isCopy;
    const char *convertedValue = (env)->GetStringUTFChars(js, &isCopy);
    return std::string(convertedValue, length);
}

JNIEXPORT jdoubleArray JNICALL vector2array(JNIEnv *env, std::vector<double> vec)
{
    double input[vec.size()];

    // Store vector in double*
    for (std::size_t i = 0; i < vec.size(); i++)
        input[i] = vec.at(i);

    // Copy into Java double[]
    jdoubleArray array = env->NewDoubleArray(vec.size());
    env->SetDoubleArrayRegion(array, 0, vec.size(), ((jdouble *)&input));
    return array;
}

extern "C" JNIEXPORT jstring JNICALL Java_com_example_nativelib_NLib_setDataFile(
    JNIEnv *env,
    jobject,
    jstring jFileName)
{
    std::string fileName = jstring2string(env, jFileName);
    try
    {
        oq.setDataFile(fileName);
    }
    catch (ExcQuestions &e)
    {
        return env->NewStringUTF(e.what().c_str());
        throw;
    }
    catch (std::exception &e)
    {
        return env->NewStringUTF(e.what());
    }
    catch (...)
    {
        return env->NewStringUTF("There was an error!\n");
    }
    return env->NewStringUTF("");
}

extern "C" JNIEXPORT jstring JNICALL Java_com_example_nativelib_NLib_checkFeasibleOperator(
    JNIEnv *env,
    jobject,
    jstring jOperator)
{
    try
    {
        std::string operatorStr = jstring2string(env, jOperator);
        char operatorChar = operatorStr.at(0);
        char necessaryOperator = oq.checkFeasibleOperator(operatorChar);
        std::string tmp(1, necessaryOperator);
        return env->NewStringUTF(tmp.c_str());
    }
    catch (ExcQuestions &e)
    {
        return env->NewStringUTF(e.what().c_str());
        throw;
    }
    catch (std::exception &e)
    {
        return env->NewStringUTF(e.what());
    }
    catch (...)
    {
        return env->NewStringUTF("There was an error!\n");
    }
    return env->NewStringUTF("");
}

extern "C" JNIEXPORT jstring JNICALL Java_com_example_nativelib_NLib_newQuestion(
    JNIEnv *env,
    jobject,
    jstring jOperator)
{
    try
    {
        std::string operatorStr = jstring2string(env, jOperator);
        char operatorChar = operatorStr.at(0);
        oq.newQuestion(operatorChar);
    }
    catch (ExcQuestions &e)
    {
        return env->NewStringUTF(e.what().c_str());
        throw;
    }
    catch (std::exception &e)
    {
        return env->NewStringUTF(e.what());
    }
    catch (...)
    {
        return env->NewStringUTF("There was an error!\n");
    }
    return env->NewStringUTF("");
}

extern "C" JNIEXPORT void JNICALL Java_com_example_nativelib_NLib_clearQuestion(
    JNIEnv *env,
    jobject)
{
    oq.clearQuestion();
}

extern "C" JNIEXPORT void JNICALL Java_com_example_nativelib_NLib_addKey(
    JNIEnv *env,
    jobject,
    jstring jkey)
{
    std::string keyStr = jstring2string(env, jkey);
    char key = keyStr.at(0);
    oq.addKey(key);
}

extern "C" JNIEXPORT jstring JNICALL Java_com_example_nativelib_NLib_determineAnswer(
    JNIEnv *env,
    jobject)
{
    try
    {
        oq.determineAnswer();
    }
    catch (ExcQuestions &e)
    {
        return env->NewStringUTF(e.what().c_str());
        throw;
    }
    catch (std::exception &e)
    {
        return env->NewStringUTF(e.what());
    }
    catch (...)
    {
        return env->NewStringUTF("There was an error!\n");
    }
    return env->NewStringUTF("");
}

extern "C" JNIEXPORT jstring JNICALL Java_com_example_nativelib_NLib_storeAnswer(
    JNIEnv *env,
    jobject)
{
    try
    {
        oq.storeAnswer();
    }
    catch (ExcQuestions &e)
    {
        return env->NewStringUTF(e.what().c_str());
        throw;
    }
    catch (std::exception &e)
    {
        return env->NewStringUTF(e.what());
    }
    catch (...)
    {
        return env->NewStringUTF("There was an error!\n");
    }
    return env->NewStringUTF("");
}

extern "C" JNIEXPORT void JNICALL Java_com_example_nativelib_NLib_saveAnswerToFile(
    JNIEnv *env,
    jobject)
{
    oq.saveAnswerToFile();
}

extern "C" JNIEXPORT jstring JNICALL Java_com_example_nativelib_NLib_correctString(
    JNIEnv *env,
    jobject,
    jstring jOperator)
{
    std::string operatorStr = jstring2string(env, jOperator);
    char operatorChar = operatorStr.at(0);
    std::string str = oq.correctString(operatorChar);
    return env->NewStringUTF(str.c_str());
}

extern "C" JNIEXPORT jstring JNICALL Java_com_example_nativelib_NLib_getQuestion(
    JNIEnv *env,
    jobject)
{
    std::string question = oq.getQuestion();
    return env->NewStringUTF(question.c_str());
}

extern "C" JNIEXPORT int JNICALL Java_com_example_nativelib_NLib_getX( // TODO: avoid package name
    JNIEnv *env,
    jobject)
{
    int xValue = oq.getX();
    return xValue;
}

extern "C" JNIEXPORT int JNICALL Java_com_example_nativelib_NLib_getY(
    JNIEnv *env,
    jobject)
{
    int yValue = oq.getY();
    return yValue;
}

extern "C" JNIEXPORT int JNICALL Java_com_example_nativelib_NLib_getZ(
    JNIEnv *env,
    jobject)
{
    int zValue = oq.getZ();
    return zValue;
}

extern "C" JNIEXPORT int JNICALL Java_com_example_nativelib_NLib_getAnswer(
    JNIEnv *env,
    jobject)
{
    int answer = oq.getAnswer();
    return answer;
}

extern "C" JNIEXPORT int JNICALL Java_com_example_nativelib_NLib_nHistory(
    JNIEnv *env,
    jobject)
{
    int nHistory = oq.nHistory();
    return nHistory;
}

extern "C" JNIEXPORT int JNICALL Java_com_example_nativelib_NLib_nHistoryRows(
    JNIEnv *env,
    jobject)
{
    int nHistoryRows = oq.nHistoryRows();
    return nHistoryRows;
}

extern "C" JNIEXPORT jstring JNICALL Java_com_example_nativelib_NLib_getStatus(
    JNIEnv *env,
    jobject)
{
    std::string status = oq.status();
    return env->NewStringUTF(status.c_str());
}

extern "C" JNIEXPORT int JNICALL Java_com_example_nativelib_NLib_getLevel(
    JNIEnv *env,
    jobject,
    jstring op)
{
    std::string op_str = jstring2string(env, op);
    unsigned int level = oq.level(op_str.at(0));
    return (int)level;
}

extern "C" JNIEXPORT double JNICALL Java_com_example_nativelib_NLib_statusTime(
    JNIEnv *env,
    jobject,
    jstring op)
{
    std::string op_str = jstring2string(env, op);
    double time = oq.statusTime(op_str.at(0));
    return time;
}

extern "C" JNIEXPORT jstring JNICALL Java_com_example_nativelib_NLib_getDataTimes(
    JNIEnv *env,
    jobject)
{
    std::string status = oq.getDataTimes();
    return env->NewStringUTF(status.c_str());
}

extern "C" JNIEXPORT jstring JNICALL Java_com_example_nativelib_NLib_getDataTimesStart(
    JNIEnv *env,
    jobject,
    int startQuestion)
{
    std::string status = oq.getDataTimes(startQuestion);
    return env->NewStringUTF(status.c_str());
}

extern "C" JNIEXPORT jstring JNICALL Java_com_example_nativelib_NLib_getDataInputs(
    JNIEnv *env,
    jobject)
{
    std::string status = oq.getDataInputs();
    return env->NewStringUTF(status.c_str());
}

extern "C" JNIEXPORT jstring JNICALL Java_com_example_nativelib_NLib_getDataInputsStart(
    JNIEnv *env,
    jobject,
    int startQuestion)
{
    std::string status = oq.getDataInputs(startQuestion);
    return env->NewStringUTF(status.c_str());
}

extern "C" JNIEXPORT jdoubleArray JNICALL Java_com_example_nativelib_NLib_getSolutionTimes(JNIEnv *env, jobject thiz,
                                                                                           jint nLast)
{
    std::vector<double> times = oq.getSolutionTimes(nLast);
    return vector2array(env, times);
}

extern "C" JNIEXPORT jstring JNICALL Java_com_example_nativelib_NLib_setGamingTimeFile(JNIEnv *env, jobject thiz,
                                                                                       jstring jFileName)
{
    std::string fileName = jstring2string(env, jFileName);
    try
    {
        oq.setGamingTimeFile(fileName);
    }
    catch (ExcQuestions &e)
    {
        return env->NewStringUTF(e.what().c_str());
        throw;
    }
    catch (std::exception &e)
    {
        return env->NewStringUTF(e.what());
    }
    catch (...)
    {
        return env->NewStringUTF("There was an error!\n");
    }
    return env->NewStringUTF("");
}

extern "C" JNIEXPORT void JNICALL Java_com_example_nativelib_NLib_gamingTimeStart(JNIEnv *env, jobject thiz)
{
    oq.gamingTimeStart();
}    //

extern "C" JNIEXPORT void JNICALL Java_com_example_nativelib_NLib_gamingTimeEnd(JNIEnv *env, jobject thiz)
{
    oq.gamingTimeEnd();
}

extern "C" JNIEXPORT jdouble JNICALL Java_com_example_nativelib_NLib_gamingTimeAvail(JNIEnv *env, jobject thiz)
{
    return oq.gamingTime() - oq.spentGamingTime();
}

extern "C" JNIEXPORT jdouble JNICALL Java_com_example_nativelib_NLib_gamingTimeCur(JNIEnv *env, jobject thiz)
{
    return oq.spentGamingTimeCur();
}
extern "C" JNIEXPORT jstring JNICALL Java_com_example_nativelib_NLib_setFiles(JNIEnv *env, jobject thiz, jstring jPath, jstring jUserName)
{
    std::string path = jstring2string(env, jPath);
    std::string userName = jstring2string(env, jUserName);
    std::string fileName = path + "/optCalcDigit" + userName + ".txt";
    std::string gtFileName = path + "/optGamingTime" + userName + ".txt";
    try
    {
        oq.setDataFile(fileName);
        oq.setGamingTimeFile(gtFileName);
    }
    catch (ExcQuestions &e)
    {
        return env->NewStringUTF(e.what().c_str());
        throw;
    }
    catch (std::exception &e)
    {
        return env->NewStringUTF(e.what());
    }
    catch (...)
    {
        return env->NewStringUTF("There was an error!\n");
    }
    return env->NewStringUTF("");
}

extern "C" JNIEXPORT jstring JNICALL Java_com_example_nativelib_NLib_readGamingTimeFile(JNIEnv *env, jobject thiz)
{
    return env->NewStringUTF(oq.readGamingTimeFile().c_str());
}

extern "C" JNIEXPORT void JNICALL
Java_com_example_nativelib_NLib_twoargs(JNIEnv *env, jobject thiz, jint num, jint num2)
{
    // TODO: implement twoargs()
}
extern "C" JNIEXPORT void JNICALL
Java_com_example_nativelib_NLib_diffargs(JNIEnv *env, jobject thiz, jint num, jstring name)
{
    // TODO: implement diffargs()
}