package com.optimaleducation;

import android.content.Context;
import android.media.Image;
import android.os.AsyncTask;
import android.os.Build;
import android.util.Log;
import android.widget.ImageView;
import android.widget.TextView;

import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class DbComm {
    private Context context_;
    private TextView outputInDB;
    private ImageView imgDB;

    private long firstUsage_;
    private String deviceId_;

    private String userName_;
    private long userID_;
    private int nRowsInDB_;

    private boolean savingToDB_;
    private boolean blockSaveToDB_;
    private int nRowsToDB_;
    private long startTime_;

    public DbComm(Context _context)
    {
        context_ = _context;
        firstUsage_ = 0;
        setFirstUsage();
        deviceId_ = Build.FINGERPRINT + Long.toString(firstUsage_);

        userName_ = "";
        userID_ = 0;
        nRowsInDB_ = 0;

        savingToDB_ = false;
        blockSaveToDB_ = false;
        nRowsToDB_ = 0;
    }

    public void setUser(String _userName)
    {
        userName_ = _userName;
        userID_ = 0;
        nRowsInDB_ = 0;

        File path = context_.getCacheDir();
        if(!path.exists()){
            path.mkdir();
        }

        String fileName = "user" + userName_ + ".txt";
        File file = new File(path, fileName);

        Log.d("DbComm::setUser", "Try to open file");

        if(file.exists())
        { // Read file
            try {
                BufferedReader in = new BufferedReader(new FileReader(file));
                String line = in.readLine();

                if (line != null) {
                    Log.d("DbComm::setUser", "Reading line" + line);
                    String userIdStr = line.substring(0, line.indexOf(' '));
                    String nRowsInDBStr = line.substring(line.indexOf(' ') + 1);
                    userID_ = Long.parseLong(userIdStr);
                    nRowsInDB_ = Integer.parseInt(nRowsInDBStr);
                }
            } catch (FileNotFoundException e) {
                e.printStackTrace();
                //Logger.logError(TAG, e);
            } catch (IOException e) {
                e.printStackTrace();
                //Logger.logError(TAG, e);
            }
        }
        else
        { // Create file
            insertUser(); // Asynchronous call, file is created after call
        }
    }

    public long userID() { return userID_; }

    public void insertUser() {

        class SendPostReqAsyncTask extends AsyncTask<String, Void, String> {
            @Override
            protected String doInBackground(String... params) {

                String deviceIdHolder = deviceId_;
                String nameHolder = userName_;

                List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();

                //nameValuePairs.add(new BasicNameValuePair("deviceID", deviceId_));
                //nameValuePairs.add(new BasicNameValuePair("name", userName_));
                nameValuePairs.add(new BasicNameValuePair("deviceID", deviceIdHolder));
                nameValuePairs.add(new BasicNameValuePair("name", nameHolder));
                Log.d("DbComm::InsertUser", "deviceID = " + deviceIdHolder);
                Log.d("DbComm::InsertUser", "name = " + nameHolder);

                nameValuePairs.add(new BasicNameValuePair("firstUsage", Long.toString(firstUsage_)));
                Log.d("DbComm::InsertUser", "Retrieved firstUsage = " + Long.toString(firstUsage_));
                nameValuePairs.add(new BasicNameValuePair("board", Build.BOARD));
                nameValuePairs.add(new BasicNameValuePair("brand", Build.BRAND));
                nameValuePairs.add(new BasicNameValuePair("device", Build.DEVICE));
                nameValuePairs.add(new BasicNameValuePair("hardware", Build.HARDWARE));
                nameValuePairs.add(new BasicNameValuePair("host", Build.HOST));
                nameValuePairs.add(new BasicNameValuePair("id", Build.ID));
                nameValuePairs.add(new BasicNameValuePair("manufacturer", Build.MANUFACTURER));
                nameValuePairs.add(new BasicNameValuePair("model", Build.MODEL));
                nameValuePairs.add(new BasicNameValuePair("product", Build.PRODUCT));
                nameValuePairs.add(new BasicNameValuePair("tags", Build.TAGS));
                nameValuePairs.add(new BasicNameValuePair("type", Build.TYPE));
                nameValuePairs.add(new BasicNameValuePair("user", Build.USER));
                nameValuePairs.add(new BasicNameValuePair("radioVersion", Build.getRadioVersion()));
                nameValuePairs.add(new BasicNameValuePair("vRelease", Build.VERSION.RELEASE));
                nameValuePairs.add(new BasicNameValuePair("vIncremental", Build.VERSION.INCREMENTAL));
                nameValuePairs.add(new BasicNameValuePair("vSdkInt", Integer.toString(Build.VERSION.SDK_INT)));

                String ServerURL = "http://130.236.56.97:8080/addUser.php";
                //String ServerURL = "http://79.136.70.172:7403/addUser.php";
                //String ServerURL = "http://192.168.1.65/addUser.php";

                try {

                    HttpClient httpClient = new DefaultHttpClient();

                    HttpPost httpPost = new HttpPost(ServerURL);

                    httpPost.setEntity(new UrlEncodedFormEntity(nameValuePairs)); // Encoded with char set ISO-8859-1

                    HttpResponse httpResponse = httpClient.execute(httpPost);

                    HttpEntity httpEntity = httpResponse.getEntity();
                    String responseBody = EntityUtils.toString(httpEntity);
                    Log.d("DbComm::InsertUser", "DB response " + responseBody);

                    int ind = responseBody.indexOf('=');
                    if (ind >= 0) {
                        String strUserID = responseBody.substring(ind + 2);
                        userID_ = Long.parseLong(strUserID);
                        Log.d("DbComm::InsertUser", "Retrieved userID = " + userID_);
                    }
                    else
                        Log.d("DbComm::InsertUser", "Failed to retrieve userID");


                } catch (ClientProtocolException e) {
                    Log.d("DbComm::InsertUser", "ClientProtocolException");

                } catch (IOException e) {
                    Log.d("DbComm::InsertUser", "IOException: " + e.getMessage());
                }
                return "Data Inserted Successfully";
            }

            @Override
            protected void onPostExecute(String result) {
                if (userID_ != 0)
                    saveFileUserId(0);
                // Log.d("InsertUser Post", Long.toString((result)));
            }
        }

        SendPostReqAsyncTask sendPostReqAsyncTask = new SendPostReqAsyncTask();
        sendPostReqAsyncTask.execute();
    }

    public void syncWithDatabase(TextView _outputInDB, ImageView _imgDB)
    {
        outputInDB = _outputInDB;
        imgDB = _imgDB;

        if (savingToDB_ == true)
        { // Missed to save to database, do not save any more... (Need to save all in a batch)
            imgDB.setImageResource(R.drawable.syncdisabled);
            blockSaveToDB_ = true;
        }
        if (userID_ != 0 && blockSaveToDB_ == false) {
            imgDB.setImageResource(R.drawable.vecsyncronizing);
            String userID = Long.toString(userID_);
            nRowsToDB_ = nHistoryRows();
            Log.d("DbComm:syncWithDatabase", "User " + userID_ + " Storing question " + nRowsInDB_ + " to " + (nRowsToDB_-1) + " in DB");
            String time = getDataTimesStartRows(nRowsInDB_);
            Log.d("DbComm:syncWithDatabase", "Times " + time);
            String input = getDataInputsStartRows(nRowsInDB_);
            Log.d("DbComm:syncWithDatabase", "Inputs " + input);
            Log.d("DbComm:syncWithDatabase", "Storing inputs " + input);
            if (input.length() > 1)
                InsertData(nRowsToDB_, time, input);
        }
    }

     private void InsertData(final int nRowsInApp, final String time, final String input){

        class SendPostReqAsyncTask extends AsyncTask<String, Void, String> {
            @Override
            protected String doInBackground(String... params) {
                Date d = new Date();
                startTime_ = d.getTime();


                savingToDB_ = true;

                String userIdHolder = Long.toString(userID_);
                String timeHolder = time; //.replaceAll(" ", "%20");
                String inputHolder = input; //.replaceAll(" ", "%20");
                Log.d("DbComm::InsertData", "Time = " + time);

                List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();

                nameValuePairs.add(new BasicNameValuePair("userID", userIdHolder));
                nameValuePairs.add(new BasicNameValuePair("version", Integer.toString(1)));
                nameValuePairs.add(new BasicNameValuePair("nApp", Integer.toString(nRowsInApp)));
                nameValuePairs.add(new BasicNameValuePair("time", timeHolder));
                nameValuePairs.add(new BasicNameValuePair("input", inputHolder));
                Log.d("DbComm::InsertData", "Time2 = " + nameValuePairs.get(1).toString());

                String ServerURL = "http://130.236.56.97:8080/addValue.php";
                //String ServerURL = "http://79.136.70.172:7403/addValue.php";
                //String ServerURL = "http://192.168.1.65/addValue.php";

                try {
                    HttpClient httpClient = new DefaultHttpClient();

                    HttpPost httpPost = new HttpPost(ServerURL);

                    httpPost.setEntity(new UrlEncodedFormEntity(nameValuePairs)); // Encoded
                    Log.d("DbComm::InsertData", "Sent: " + httpPost.getRequestLine().toString());
                    Log.d("DbComm::InsertData", "Sent: " + httpPost.getEntity().getContent().toString());
                    Log.d("DbComm::InsertData", "Sent: " + httpPost.toString());

                    Header[] headers = httpPost.getAllHeaders();
                    for (Header header : headers) {
                        Log.d("DbComm::InsertData", "Sent: " + header.getName() + ": " + header.getValue());
                    }


                    HttpResponse httpResponse = httpClient.execute(httpPost);

                    HttpEntity httpEntity = httpResponse.getEntity();
                    String responseBody = EntityUtils.toString(httpEntity);
                    Log.d("DbComm::InsertData", "Received: " + responseBody);
                    String nRowsInDBStr = responseBody.substring(responseBody.indexOf('=') + 2);
                    nRowsInDB_ = Integer.parseInt(nRowsInDBStr);
                    Log.d("DbComm::InsertData", "Received nRowsInDB: " + nRowsInDB_);

                } catch (ClientProtocolException e) {
                    Log.d("DbComm::InsertData", "ClientProtocolException");

                } catch (IOException e) {
                    Log.d("DbComm::InsertData", "IOException");

                }
                return "Data Inserted Successfully";
            }

            @Override
            protected void onPostExecute(String result) {
                Log.d("DbComm::InsertData", "Post execute " + result);
                Date d = new Date();
                Long endTime = d.getTime();
                outputInDB.setText(Integer.toString(nRowsToDB_) + "\n" + Double.toString((endTime-startTime_)/1000.0) + "s");
                if (imgDB == null)
                    Log.d("DbComm::InsertData", "Trying to set image with null pointer 2");
                imgDB.setImageResource(R.drawable.vecok);
                savingToDB_ = false;
                blockSaveToDB_ = false;
                // nRowsInDB_ = nRowsToDB_;
                saveFileUserId(nRowsInDB_);
            }
        }

        SendPostReqAsyncTask sendPostReqAsyncTask = new SendPostReqAsyncTask();
        sendPostReqAsyncTask.execute(time, input);
    }


    private void setFirstUsage()
    {
        File path = context_.getCacheDir();
        if(!path.exists()){
            path.mkdir();
        }

        String fileName = "firstUsage.txt";
        File file = new File(path, fileName);

        firstUsage_ = 0;

        if(!file.exists())
        { // Create file

            Log.d("DbComm::getFirstUsage", "Storing first usage in " + file.toString());
            try {
                Date d = new Date();
                long firstUsage = d.getTime();

                FileWriter writer = new FileWriter(file, false);
                writer.append(firstUsage + "\n");

                writer.flush();
                writer.close();
                firstUsage_ = firstUsage; // Ok, it succeded in storing the value

            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        else
        { // Load file

            try {
                BufferedReader in = new BufferedReader(new FileReader(file));
                String line = in.readLine();

                if (line != null)
                {
                    Log.d("DbComm::getFirstUsage", "Reading file " + line);
                    firstUsage_ = Long.parseLong(line);
                }
            } catch (FileNotFoundException e) {
                e.printStackTrace();
                //Logger.logError(TAG, e);
            } catch (IOException e) {
                e.printStackTrace();
                //Logger.logError(TAG, e);
            }
        }
    }

    private void saveFileUserId(int nRowsInDBnew) {
        File path = context_.getCacheDir();
        if(!path.exists()){
            path.mkdir();
        }

        String fileName = "user" + userName_ + ".txt";

        File file = new File(path, fileName);
        Log.d("DbComm::createFileUserI", "Storing userID in" + file.toString());
        try {
            FileWriter writer = new FileWriter(file, false);
            writer.append(userID_ + " " + nRowsInDBnew + "\n");

            writer.flush();
            writer.close();

        } catch (IOException e) {
            e.printStackTrace();
        }
        nRowsInDB_ = nRowsInDBnew; // Stores value even if file save failed (Database have been updated)
    }

    public native int nHistory();
    public native int nHistoryRows();
    public native String getDataTimesStart(int startQuestion);
    public native String getDataInputsStart(int startQuestion);
    public native String getDataTimesStartRows(int startRow);
    public native String getDataInputsStartRows(int startRow);

}
