package com.optimaleducation;

import android.content.Context;
import android.util.Log;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Date;
import java.util.Random;
import java.util.Vector;

public class History {
    public static int xValue, yValue, zValue, answer;
    public static String operator;
    public static String question;

    private static Vector<Long> t = new Vector<>(); // Times for current answer
    private static Vector<String> a = new Vector<>(); // Answers (keys pressed) for current answer
    private static Vector<String> h = new Vector<>(); // Answers (keys pressed) for current answer for historical questions
    private static Vector<Long> ht = new Vector<>(); // Times when answers where given (keys were pressed) for historical questions
    private static Context context;

    private static Vector<Long> nQuestions = new Vector<>();
    private static Vector<Long> nCorrect = new Vector<>();

    public static void init() {
        for (int i=0 ; i<4 ; i++) {
            nQuestions.add(new Long(0));
            nCorrect.add(new Long(0));
        }
    }
    public static void setContext(Context _context) {
        context = _context;
    }

    public static void newQuestion(String o) {
        operator = o;
        Random rand = new Random();
        xValue = rand.nextInt(10);
        yValue = rand.nextInt(10);
        String q = "";
        if (operator.equals("Addition")) {
            q = xValue + "+" + yValue;
            zValue = xValue + yValue;
        }
        else if (operator.equals("Subtraction")) {
            zValue = xValue;
            xValue = xValue + yValue;
            q = xValue + "-" + yValue;
        }
        else if (operator.equals("Multiplication")) {
            q = xValue + "*" + yValue;
            zValue = xValue * yValue;
        }
        else if (operator.equals("Division")) {
            zValue = xValue;
            while (yValue == 0)
                yValue = 1+rand.nextInt(9);
            xValue = xValue * yValue;
            q = xValue + "/" + yValue;
        }

        question = q;
        Date d = new Date();
        t.add(d.getTime());
        Log.d("History", "Creating question: " + q);
    }
    public static void derpQuestion() {
        operator = "";
        xValue = 0;
        yValue = 0;
        zValue = 0;

        question = "";
        t.clear();
        a.clear();
        Log.d("History", "Cleaning question: ");
    }


    public static void addKey(Character c, boolean storeInFile) {
        a.add(c.toString());
        Date d = new Date();
        t.add(d.getTime());
        if (c == '=') {
            storeAnswer(storeInFile);
        }
    }

    public static String correctString() {
        int j = operatorIndex();
        return nCorrect.get(j) + "/" + nQuestions.get(j);
    }
    private static void storeAnswer(boolean storeInFile){
        determineAnswer(a, 0, a.size());
        int j=operatorIndex();

        if (zValue == answer)
            nCorrect.set(j, nCorrect.get(j)+1);
        nQuestions.set(j, nQuestions.get(j)+1);

        ht.add(t.get(0));
        h.add(question);
        for (int i=0 ; i<a.size() ; i++) {
            h.add(a.get(i).toString());
            ht.add(t.get(i+1));
        }
        if (storeInFile)
            writeToFile();
        t.clear();
        a.clear();
    }

    private static void writeToFile() {
        File path = context.getCacheDir();
        if(!path.exists()){
            path.mkdir();
        }
        File file = new File(path, "optCalcDigit.txt");
        Log.d("History", "Storing answers in" + file.toString());
        try {
            FileWriter writer = new FileWriter(file, true);
            writer.append(t.get(0) + " " + question + "\n");
            for (int i=0 ; i<a.size() ; i++) {
                writer.append(t.get(i+1) + " " + a.get(i) + "\n");
            }

            writer.flush();
            writer.close();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void readFileToHistory() {
        File path = context.getCacheDir();
        File file = new File(path, "optCalcDigit.txt");

        String line;

        try {
            BufferedReader in = new BufferedReader(new FileReader(file));
            while ((line = in.readLine()) != null)
            {
                Log.d("History", "Reading line" + line);
                String timeStr = line.substring(0, line.indexOf(' '));
                String actionStr = line.substring(line.indexOf(' ') + 1);
                t.add(Long.parseLong(timeStr));

                if (actionStr.length() >= 3)
                {
                    int i = 0;
                    while (Character.isDigit(actionStr.charAt(i)))
                        i++;
                    String xValueStr = actionStr.substring(0, i);
                    xValue = Integer.parseInt(xValueStr);
                    String yValueStr = actionStr.substring(i+1);
                    yValue = Integer.parseInt(yValueStr);
                    if (actionStr.charAt(i) == '+')
                    {
                        operator = "Addition";
                        zValue = xValue + yValue;
                    }
                    else if (actionStr.charAt(i) == '-')
                    {
                        operator = "Subtraction";
                        zValue = xValue - yValue;
                    }
                    else if (actionStr.charAt(i) == '*')
                    {
                        operator = "Multiplication";
                        zValue = xValue * yValue;
                    }
                    else if (actionStr.charAt(i) == '/')
                    {
                        operator = "Division";
                        zValue = xValue / yValue;
                    }
                    Log.d("History", "Reading line z");
                    question = actionStr;
                }
                else
                    addKey(actionStr.charAt(0), false);
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            //Logger.logError(TAG, e);
        } catch (IOException e) {
            e.printStackTrace();
            //Logger.logError(TAG, e);
        }
    }

    private static String readFileAsString() {
        File path = context.getCacheDir();
        File file = new File(path, "optCalcDigit.txt");

        StringBuilder stringBuilder = new StringBuilder();
        String line;

        try {
            BufferedReader in = new BufferedReader(new FileReader(file));
            while ((line = in.readLine()) != null) stringBuilder.append(line);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            //Logger.logError(TAG, e);
        } catch (IOException e) {
            e.printStackTrace();
            //Logger.logError(TAG, e);
        }
        return stringBuilder.toString();
    }

    private static int determineAnswer(Vector<String> c, int iStart, int iEnd) {
        String str = "";
        for (int i=iStart ; i<iEnd ; i++) {
            Log.d("History", "Determine answer: " + i);
            if (c.get(i).equals("C"))
                str = "";
            else if (c.get(i).equals("=")) {
                iEnd = i;
                break;
            }
            else
                str = str + c.get(i);
        }
        answer = Integer.parseInt(str);
        return iEnd;
    }


    private static int operatorIndex() {
        if (operator.equals("Addition"))
            return 0;
        else if (operator.equals("Subtraction"))
            return 1;
        else if (operator.equals("Multiplication"))
            return 2;
        else if (operator.equals("Division"))
            return 3;
        return -1;
    }
}
