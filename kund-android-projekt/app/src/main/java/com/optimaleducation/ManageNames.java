package com.optimaleducation;

import android.content.Context;
import android.util.Log;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class ManageNames {

    public static List<String> names;

    private static Context context;

    public static void setContext(Context _context) {
        context = _context;
    }

    public static void init() {
        Log.d("ManageNames", "Constructor");

        names = new ArrayList<String>();
        File path = context.getCacheDir();
        File file = new File(path, "names.txt");

        String line;

        try {
            BufferedReader in = new BufferedReader(new FileReader(file));
            while ((line = in.readLine()) != null)
            {
                Log.d("ManageNames", "Reading line" + line);
                names.add(line);
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            //Logger.logError(TAG, e);
        } catch (IOException e) {
            e.printStackTrace();
            //Logger.logError(TAG, e);
        }
        if (names.size() == 0)
        {
            names.add("Default");
            writeNamesToFile();
        }
    }

    public static void delName(String name) {
        for (int i=0 ; i<names.size() ; i++)
            if (name.equals(names.get(i)))
                names.remove(i);

        if (names.size() == 0)
            names.add("Default");

        writeNamesToFile();
    }

    public static void addName(String name) {
        for (int i=0 ; i<names.size() ; i++)
            if (name.equals(names.get(i)))
                return;

        names.add(names.size(), name);
        writeNamesToFile();
    }

    private static void writeNamesToFile() {
        File path = context.getCacheDir();
        if(!path.exists()){
            path.mkdir();
        }
        File file = new File(path, "names.txt");
        Log.d("History", "Storing names in" + file.toString());
        try {
            FileWriter writer = new FileWriter(file, false);
            for (int i=0 ; i<names.size() ; i++)
            {
                String name = names.get(i);
                writer.append(name + "\n");
            }
            writer.flush();
            writer.close();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }



}
