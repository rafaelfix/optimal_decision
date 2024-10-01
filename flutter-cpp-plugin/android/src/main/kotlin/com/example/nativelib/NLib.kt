package com.example.nativelib

import kotlin.reflect.full.memberFunctions
import android.util.Log

class NLib {

    private var functions = NLib::class.memberFunctions.toSet()

    init {
        System.loadLibrary("nativelib")
    }

    fun runFunction(name: String, vararg args: Any?): Any? {

        val found = functions.filter { it.name == name }

        if (found.isEmpty()) {
            throw IllegalArgumentException("Function '$name' not found")
        }

        if (found.count() > 1) {
            throw IllegalArgumentException("Function '$name' is ambiguous")
        }

        val function = found[0]
        // Log.d("NLib", "Found function $function")
        return function.call(this, *args)
    }
    
    external fun getstring(): String
    external fun convint(num: Int): String
    external fun twoargs(num: Int, num2: Int)
    external fun diffargs(num: Int, name: String)

    external fun setDataFile(jFileName: String): String
    external fun checkFeasibleOperator(jOperator: String): String
    external fun newQuestion(jOperator: String): String
    external fun clearQuestion()
    external fun addKey(key: String)
    external fun determineAnswer(): String
    external fun storeAnswer(): String
    external fun saveAnswerToFile()
    external fun correctString(jOperator: String): String

    external fun getQuestion(): String
    external fun getX(): Int
    external fun getY(): Int
    external fun getZ(): Int
    external fun getAnswer(): Int
    external fun getStatus(): String
    external fun getLevel(op: String): Int
    external fun statusTime(op: String): Double
    external fun nHistory(): Int

    external fun getDataTimes(): String
    external fun getDataTimesStart(startQuestion: Int): String
    external fun getDataInputs(): String
    external fun getDataInputsStart(startQuestion: Int): String

    external fun getSolutionTimes(nLast: Int): Array<Double>

    external fun setFiles(jPath: String, jUserName: String): String

    external fun gamingTimeStart()
    external fun gamingTimeEnd()
    
    external fun readGamingTimeFile(): String
}