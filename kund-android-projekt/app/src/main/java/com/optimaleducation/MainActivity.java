package com.optimaleducation;

import android.Manifest;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

import android.provider.Settings;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;

import java.io.File;
import java.util.List;


public class MainActivity extends AppCompatActivity {

    /*public static Long userID;
    public static int nInDB;
    public static String deviceID;
    public static Long firstUsage;*/
    public static long curNameId;
    public static String curName;
    public static String curOp;

    TextView txtSelectName, txtAddName;
    EditText newName;

    Spinner spinnerName;
    Button buttonAddName;
    Button buttonDelName;

    Button buttonUseAdd;
    Button buttonUseSub;
    Button buttonUseMul;
    Button buttonUseDiv;

    Button buttonUseGraphical;
    Button buttonUseTimer;

    Context context = this;

    public static DbComm dbComm;

    // Used to load the 'native-lib' library on application startup.
    static {
        System.loadLibrary("native-lib");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        txtSelectName = (TextView) findViewById(R.id.txtSelectName);
        txtAddName = (TextView) findViewById(R.id.txtAddName);
        newName = (EditText) findViewById(R.id.newName);

        spinnerName = (Spinner) findViewById(R.id.spinnerName);
        // String[] names = new String[]{"Amanda", "Gabriel", "Selma", "Gustav"};

        buttonAddName = (Button) findViewById(R.id.buttonAddName);
        buttonDelName = (Button) findViewById(R.id.buttonDelName);

        buttonUseAdd = (Button) findViewById(R.id.buttonUseAdd);
        buttonUseSub = (Button) findViewById(R.id.buttonUseSub);
        buttonUseMul = (Button) findViewById(R.id.buttonUseMul);
        buttonUseDiv = (Button) findViewById(R.id.buttonUseDiv);

        buttonUseGraphical = (Button) findViewById(R.id.buttonUseGraphical);
        buttonUseTimer = (Button) findViewById(R.id.buttonUseTimer);

        ManageNames.setContext(context);
        ManageNames.init();
        List<String> names = ManageNames.names;

        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, names);
        spinnerName.setAdapter(adapter);

        //deviceID = getIMEIDeviceId(context);
        /*firstUsage = getFirstUsage(context);
        deviceID = Build.FINGERPRINT + Long.toString(firstUsage);

        userID = Long.valueOf(0);
        nInDB = 0;*/

        dbComm = new DbComm(context);
        if (curName != null)
        {
            spinnerName.setSelection((int) curNameId);
            dbComm.setUser(curName);
        }
        Log.d("DbComm::Create", "Creating dbComm" + dbComm.userID());

        buttonDelName.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                AlertDialog.Builder builder = new AlertDialog.Builder(context);

                builder.setTitle("Delete name");
                builder.setMessage("Do you want to delete the name?");

                builder.setPositiveButton("Yes", new DialogInterface.OnClickListener() {

                    public void onClick(DialogInterface dialog, int which) {
                        String name = spinnerName.getSelectedItem().toString();
                        ManageNames.delName(name);
                        spinnerName.setSelection(0);

                        dialog.dismiss();
                    }

                });

                builder.setNegativeButton("No", new DialogInterface.OnClickListener() {

                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                });

                AlertDialog alert = builder.create();
                alert.show();
            }
        });

        buttonAddName.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String name = newName.getText().toString();
                ManageNames.addName(name);
                newName.setText("");
            }
        });


        buttonUseAdd.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //Start your second activity
                initUser();
                curOp = "+";
                Intent intent = new Intent(MainActivity.this, AnswerQuestionsActivity.class);
                startActivity(intent);
            }
        });

        buttonUseSub.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //Start your second activity
                initUser();
                curOp = "-";
                Intent intent = new Intent(MainActivity.this, AnswerQuestionsActivity.class);
                startActivity(intent);
            }
        });

        buttonUseMul.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //Start your second activity
                initUser();
                curOp = "*";
                Intent intent = new Intent(MainActivity.this, AnswerQuestionsActivity.class);
                startActivity(intent);
            }
        });

        buttonUseDiv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //Start your second activity
                initUser();
                curOp = "/";
                Intent intent = new Intent(MainActivity.this, AnswerQuestionsActivity.class);
                startActivity(intent);
            }
        });

        buttonUseGraphical.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //Start your second activity
                initUser();
                Intent intent = new Intent(MainActivity.this, NumberCanvas.class);
                startActivity(intent);
            }
        });

        buttonUseTimer.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    //Start your second activity
                    initUser();
                    Intent intent = new Intent(MainActivity.this, TimeActivity.class);
                    startActivity(intent);
                }
        });

    }

    private void initUser() {
        curNameId = spinnerName.getSelectedItemId();
        curName = spinnerName.getSelectedItem().toString();
        dbComm.setUser(curName);

        File path = context.getCacheDir();
        if (path.exists()){
            path.mkdir();
        }
        String msg = setFiles(path.getAbsolutePath(), curName);

        /*nInDB = readFileUserId(context, curName);
        if (nInDB < 0) {
            insertUser(deviceID, curName); // Asynchronous call
            nInDB = 0;
        }*/
    }

    public static String getIMEIDeviceId(Context context) {
        // From https://stackoverflow.com/questions/55173823/i-am-getting-imei-null-in-android-q
        String deviceId;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            Log.d("deviceID1", "From Android ID");

            deviceId = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
        } else {
            final TelephonyManager mTelephony = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (context.checkSelfPermission(Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
                    Log.d("deviceID1", "Cannot read phone state");
                    return "";
                }
            }
            assert mTelephony != null;
            if (mTelephony.getDeviceId() != null) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    Log.d("deviceID1", "Imei");
                    deviceId = mTelephony.getImei();
                } else {
                    Log.d("deviceID1", "Device ID");
                    deviceId = mTelephony.getDeviceId();
                }
            } else {
                Log.d("deviceID1", "Android ID 2");
                deviceId = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
            }
        }
        Log.d("deviceId", deviceId);
        return deviceId;
    }

    /* Declaration of C++ function */
    public native String setFiles(String path, String userName);


    /*public void insertUser(final String deviceId, final String curName) {

        class SendPostReqAsyncTask extends AsyncTask<String, Void, String> {
            @Override
            protected String doInBackground(String... params) {

                Log.d("InsertUser", "Step 0");
                String deviceIdHolder = deviceId;
                String nameHolder = curName;

                List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();

                nameValuePairs.add(new BasicNameValuePair("deviceID", deviceIdHolder));
                nameValuePairs.add(new BasicNameValuePair("name", nameHolder));
                Log.d("InsertUser", "Step 1");
                nameValuePairs.add(new BasicNameValuePair("firstUsage", Long.toString(firstUsage)));
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
                Log.d("InsertUser", "Step 20");
                nameValuePairs.add(new BasicNameValuePair("vRelease", Build.VERSION.RELEASE));
                nameValuePairs.add(new BasicNameValuePair("vIncremental", Build.VERSION.INCREMENTAL));
                nameValuePairs.add(new BasicNameValuePair("vSdkInt", Integer.toString(Build.VERSION.SDK_INT)));
                Log.d("InsertUser", "Step 30 " + Integer.toString(Build.VERSION.SDK_INT));

                String ServerURL = "http://79.136.70.172:7403/addUser.php";
                //String ServerURL = "http://192.168.1.65/addUser.php";

                try {
                    HttpClient httpClient = new DefaultHttpClient();

                    HttpPost httpPost = new HttpPost(ServerURL);

                    Log.d("InsertUser", "Step 31");
                    httpPost.setEntity(new UrlEncodedFormEntity(nameValuePairs));
                    Log.d("InsertUser", "Step 32");

                    HttpResponse httpResponse = httpClient.execute(httpPost);
                    Log.d("InsertUser", "Step 33");

                    HttpEntity httpEntity = httpResponse.getEntity();
                    String responseBody = EntityUtils.toString(httpEntity);
                    Log.d("InsertUser", "Step 34 " + responseBody);

                    int ind = responseBody.indexOf('=');
                    String strUserID = responseBody.substring(ind+2);
                    userID = Long.parseLong(strUserID);

                    Log.d("InsertUser", "Retrieved userID = " + userID);


                } catch (ClientProtocolException e) {
                    Log.d("InsertUser", "ClientProtocolException");

                } catch (IOException e) {
                    Log.d("InsertUser", "IOException");
                }
                return "Data Inserted Successfully";
            }

            @Override
            protected void onPostExecute(String result) {
                if (userID != 0)
                    createFileUserId(context, curName, userID);
                // userID = result;
                // Log.d("InsertUser Post", Long.toString((result)));
                // super.onPostExecute(result);

                //Toast.makeText(AnswerQuestionsActivity.this, "Data Submit Successfully", Toast.LENGTH_LONG).show();

            }
        }

        SendPostReqAsyncTask sendPostReqAsyncTask = new SendPostReqAsyncTask();

        sendPostReqAsyncTask.execute(deviceID, curName);
    }*/

    /*private static int readFileUserId(Context context, String name) {
        File path = context.getCacheDir();

        File file = new File(path, "user" + name + ".txt");

        try {
            BufferedReader in = new BufferedReader(new FileReader(file));
            String line = in.readLine();

            if (line == null)
                return -1;
            Log.d("readFileUserId", "Reading line" + line);
            String userIdStr = line.substring(0, line.indexOf(' '));
            String nInDBStr = line.substring(line.indexOf(' ') + 1);
            userID = Long.parseLong(userIdStr);
            int nInDB = Integer.parseInt(nInDBStr);
            return nInDB;
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            //Logger.logError(TAG, e);
        } catch (IOException e) {
            e.printStackTrace();
            //Logger.logError(TAG, e);
        }
        return -1;
    }*/

    /*private static void createFileUserId(Context context, String name, Long userID) {
        File path = context.getCacheDir();
        if(!path.exists()){
            path.mkdir();
        }

        String fileName = "user" + name + ".txt";
        File file = context.getFileStreamPath(fileName);
        if(!(file == null || !file.exists())) {
            Log.d("createFileUserId", "Error: File already exist" + file.toString());
            return;
        }

        file = new File(path, fileName);
        Log.d("createFileUserId", "Storing answers in" + file.toString());
        try {
            FileWriter writer = new FileWriter(file, false);
            writer.append(userID + " 0\n");

            writer.flush();
            writer.close();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }*/

    /*private Long getFirstUsage(Context context)
    {
        File path = context.getCacheDir();
        if(!path.exists()){
            path.mkdir();
        }

        String fileName = "firstUsage.txt";
        File file = new File(path, fileName);

        if(!file.exists())
        { // Create file
            Date d = new Date();
            Long time = d.getTime();

            Log.d("getFirstUsage", "Storing first usage in " + file.toString());
            try {
                FileWriter writer = new FileWriter(file, false);
                writer.append(time + "\n");

                writer.flush();
                writer.close();

            } catch (IOException e) {
                e.printStackTrace();
            }

            return time;
        }
        else
        { // Load file

            try {
                BufferedReader in = new BufferedReader(new FileReader(file));
                String line = in.readLine();

                if (line == null)
                    return Long.valueOf(-1);
                Log.d("getFirstUsage", "Reading file " + line);
                 return Long.parseLong(line);
            } catch (FileNotFoundException e) {
                e.printStackTrace();
                //Logger.logError(TAG, e);
            } catch (IOException e) {
                e.printStackTrace();
                //Logger.logError(TAG, e);
            }

            return Long.valueOf(-1);

        }

    }*/

}


