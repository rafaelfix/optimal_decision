package com.optimaleducation;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.media.AudioManager;
import android.media.SoundPool;
import android.media.ToneGenerator;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

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

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Vector;

import static com.optimaleducation.MainActivity.curName;

public class AnswerQuestionsActivity extends AppCompatActivity {


    Button button0, button1, button2, button3, button4, button5, button6,
            button7, button8, button9, buttonC, buttonEqual;
    // Button buttonAdd, buttonSub, buttonDivision, buttonMul, buttonStop;
    TextView answerText, outputTextLvl, outputTextTime, outputTextCorrect;
    TextView question, lastQuestion;

    TextView outputTmp, outputInDB;
    ImageView imgDB;

    String operator, operatorC;
    Context context = this;

    static SoundPool soundPool;
    static int soundOk;
    static int soundFail;

    graph graphView;

    /*public static boolean savingToDB;
    public static boolean blockSaveToDB;
    public static int nToDB;*/

    // Used to load the 'native-lib' library on application startup.
    static {
        System.loadLibrary("native-lib");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_answer_questions);

        button0 = (Button) findViewById(R.id.button0);
        button1 = (Button) findViewById(R.id.button1);
        button2 = (Button) findViewById(R.id.button2);
        button2 = (Button) findViewById(R.id.button2);
        button3 = (Button) findViewById(R.id.button3);
        button4 = (Button) findViewById(R.id.button4);
        button5 = (Button) findViewById(R.id.button5);
        button6 = (Button) findViewById(R.id.button6);
        button7 = (Button) findViewById(R.id.button7);
        button8 = (Button) findViewById(R.id.button8);
        button9 = (Button) findViewById(R.id.button9);
        //buttonStop = (Button) findViewById(R.id.buttonStop);
        /*buttonAdd = (Button) findViewById(R.id.buttonadd);
        buttonSub = (Button) findViewById(R.id.buttonsub);
        buttonMul = (Button) findViewById(R.id.buttonmul);
        buttonDivision = (Button) findViewById(R.id.buttondiv);*/
        buttonC = (Button) findViewById(R.id.buttonC);
        buttonEqual = (Button) findViewById(R.id.buttoneql);
        question = (TextView) findViewById(R.id.question);
        answerText = (TextView) findViewById(R.id.edt1);
        lastQuestion = (TextView) findViewById(R.id.lastQuestion);
        outputTextLvl = (TextView) findViewById(R.id.outputLvl);
        outputTextTime = (TextView) findViewById(R.id.outputTime);
        outputTextCorrect = (TextView) findViewById(R.id.outputCorrect);

        outputTmp = (TextView) findViewById(R.id.outputTmp);
        outputInDB = (TextView) findViewById(R.id.outputInDB);
        imgDB = (ImageView) findViewById(R.id.imgDB);

        if (MainActivity.dbComm.userID() == 0)
            imgDB.setImageResource(R.drawable.syncdisabled);

        int maxStreams = 1;
        soundPool = new SoundPool(maxStreams, AudioManager.STREAM_MUSIC, 0);
        Context mContext = getApplicationContext();
        soundOk = soundPool.load(mContext, R.raw.click_x, 1); // Downloaded from https://www.wavsource.com/sfx/sfx3.htm
        soundFail = soundPool.load(mContext, R.raw.buzzer_x, 1); // Downloaded from https://www.wavsource.com/sfx/sfx3.htm



        //History.init();
        //History.setContext(context);
        //History.readFileToHistory();

        button1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                answerText.setText(answerText.getText() + "1");
                //History.addKey('1', true);
                addKey("1");
            }
        });

        button2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                answerText.setText(answerText.getText() + "2");
                //History.addKey('2', true);
                addKey("2");
            }
        });

        button3.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                answerText.setText(answerText.getText() + "3");
                //History.addKey('3', true);
                addKey("3");
            }
        });

        button4.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                answerText.setText(answerText.getText() + "4");
                //History.addKey('4', true);
                addKey("4");
            }
        });

        button5.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                answerText.setText(answerText.getText() + "5");
                //History.addKey('5', true);
                addKey("5");
            }
        });

        button6.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                answerText.setText(answerText.getText() + "6");
                //History.addKey('6', true);
                addKey("6");
            }
        });

        button7.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                answerText.setText(answerText.getText() + "7");
                //History.addKey('7', true);
                addKey("7");
            }
        });

        button8.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                answerText.setText(answerText.getText() + "8");
                //History.addKey('8', true);
                addKey("8");
            }
        });

        button9.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                answerText.setText(answerText.getText() + "9");
                //History.addKey('9', true);
                addKey("9");
            }
        });

        button0.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                answerText.setText(answerText.getText() + "0");
                //History.addKey('0', true);
                addKey("0");
            }
        });

        /*buttonAdd.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                answerText.setText(null);
                operator = "Addition";
                //History.newQuestion(operator);
                //question.setText(History.question);
                //outputText.setText(History.correctString());

                operatorC = "+";
                String msg = newQuestion(operatorC);
                if (msg.isEmpty())
                {
                    question.setText(getQuestion());
                    outputText.setText(correctString(operatorC));
                }
                else
                    question.setText(msg);
            }
        });

        buttonSub.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                answerText.setText(null);
                operator = "Subtraction";
                //History.newQuestion(operator);
                //question.setText(History.question);
                //outputText.setText(History.correctString());

                operatorC = "-";
                String msg = newQuestion(operatorC);
                if (msg.isEmpty())
                {
                    question.setText(getQuestion());
                    outputText.setText(correctString(operatorC));
                }
                else
                    question.setText(msg);
            }
        });

        buttonMul.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                answerText.setText(null);
                operator = "Multiplication";
                //History.newQuestion(operator);
                //question.setText(History.question);
                //outputText.setText(History.correctString());

                operatorC = "*";
                String msg = newQuestion(operatorC);
                if (msg.isEmpty())
                {
                    question.setText(getQuestion());
                    outputText.setText(correctString(operatorC));
                }
                else
                    question.setText(msg);
            }
        });

        buttonDivision.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                answerText.setText(null);
                operator = "Division";
                //History.newQuestion(operator);
                //question.setText(History.question);
                //outputText.setText(History.correctString());

                operatorC = "/";
                String msg = newQuestion(operatorC);
                if (msg.isEmpty())
                {
                    question.setText(getQuestion());
                    outputText.setText(correctString(operatorC));
                }
                else
                    question.setText(msg);
            }
        });*/

        buttonEqual.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                /*String a = answerEditText.getText().toString();
                int answer = Integer.parseInt(a);
                //outputText.setText(outputText.getText() + Util.getTimeStampNow() + " " + answer + "\n");
                answerEditText.setText(null);
                if (answer == History.zValue)
                    lastQuestion.setText(History.question + " = " + answer + "\n ");
                else
                    lastQuestion.setText(History.question + " = " + answer + "\nCorrect answer is " + History.question + " = " + History.zValue);*/

                String a = answerText.getText().toString();

                if (a.isEmpty())
                    return;

                answerText.setText(null);
                //History.addKey('=', true);
                //if (History.answer == History.zValue)
                //    lastQuestion.setText(History.question + " = " + History.answer + "\n ");
                //else
                //    lastQuestion.setText(History.question + " = " + History.answer + "\nCorrect answer is " + History.question + " = " + History.zValue);

                addKey("=");

                /*if (savingToDB == true)
                { // Missed to save to database, do not save any more... (Need to save all in a batch)
                    blockSaveToDB = true;
                }
                if (MainActivity.userID != 0 && blockSaveToDB == false) {
                    String userID = Long.toString(MainActivity.userID);
                    String time = getDataTimes();
                    String input = getDataInputs();
                    InsertData(userID, time, input);
                }*/
                Log.d("AnswerActivity", "Saving question in file");

                String msg = determineAnswer();
                if (msg.isEmpty())
                {
                    saveAnswerToFile();

                    double[] solutionTimes = getSolutionTimes(100);
                    graphView.setSolutionTimes(solutionTimes);
                    graphView.invalidate();

                    //ToneGenerator toneGenerator = new ToneGenerator(AudioManager.STREAM_MUSIC, 200);
                    if (getAnswer() == getZ())
                    {
                        lastQuestion.setText(new String(Character.toChars(0x2714)) + "  " + getQuestion() + " = " + getAnswer() + new String(Character.toChars(0x1F60A)) + "\n ");
                        //toneGenerator.startTone(ToneGenerator.TONE_PROP_BEEP);
                        soundPool.play(soundOk, (float)0.5, (float)0.5, 0, 0, 1);
                    }
                    else
                    {
                        lastQuestion.setText(new String(Character.toChars(0x274C)) + "  " + getQuestion() + " = " + getAnswer() + new String(Character.toChars(0x1F633)) + "\n" + new String(Character.toChars(0x2714)) + "  " + getQuestion() + " = " + getZ() + new String(Character.toChars(0x1F60A)));
                        soundPool.play(soundFail, (float)0.5, (float)0.5, 0, 0, 1);
                        //toneGenerator.startTone(ToneGenerator.TONE_CDMA_SOFT_ERROR_LITE);
                    }

                    msg = storeAnswer();

                    if (msg.isEmpty())
                    {
                        Log.d("AnswerActivity", "Saved question in file");

                        //MainActivity.dbComm.syncWithDatabase(outputInDB, imgDB);

                        newQuestion(operatorC);
                        question.setText(getQuestion());

                        outputTextLvl.setText("Level\n" + Integer.toString(getLevel()));
                        outputTextTime.setText("Time\n" + String.format("%.3f",statusTime()) + " s") ;
                        outputTextCorrect.setText("#Correct/N\n" + correctString(operatorC));

                        //History.newQuestion(operator);
                        //question.setText(History.question);
                        //outputText.setText(History.correctString());
                    }
                    else
                        question.setText(msg);
                }
                else
                    question.setText(msg);
            }
        });

        buttonC.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                answerText.setText("");
                //History.addKey('C', true);
                addKey("C");
            }
        });

        /*buttonStop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                answerText.setText(null);
                question.setText("");
                //History.derpQuestion();
                clearQuestion();
            }
        });*/

        /*savingToDB = false;
        blockSaveToDB = false;*/

        /*File path = context.getCacheDir();
        if(!path.exists()){
            path.mkdir();
        }
        String curName = MainActivity.curName;
        String fileName = path.getAbsolutePath() + "/optCalcDigit" + curName + ".txt";

        String msg = setDataFile(fileName);*/

        //if (msg.isEmpty())
        {
            operatorC = MainActivity.curOp;
            String necessaryOperator = checkFeasibleOperator(operatorC);
            if (!necessaryOperator.equals(operatorC))
            {
                Log.d("syncWithDatabase", "Times hejsan");
                lastQuestion.setText("Not sufficient proficiency with operator " + necessaryOperator + "\nChanging to " + necessaryOperator);
                operatorC = necessaryOperator;
            }

            newQuestion(operatorC);
            question.setText(getQuestion());
            outputTextLvl.setText("Level\n" + Integer.toString(getLevel()));
            outputTextTime.setText("Time\n" + String.format("%.3f",statusTime()) + " s") ;
            outputTextCorrect.setText("#Correct/N\n" + correctString(operatorC));

            // lastQuestion.setText(Long.toString(MainActivity.userID));
        }
        //else
        //    question.setText(msg);

        outputTmp.setText("uID = " + Long.toString(MainActivity.dbComm.userID()));

        graphView = (graph) findViewById(R.id.view);
        graphView.setVisibility(View.VISIBLE);
        double[] solutionTimes = getSolutionTimes(100);
        graphView.setSolutionTimes(solutionTimes);

    }


    /*public void InsertData(final String userID, final String time, final String input){

        class SendPostReqAsyncTask extends AsyncTask<String, Void, String> {
            @Override
            protected String doInBackground(String... params) {
                savingToDB = true;

                String userIdHolder = userID;
                String timeHolder = time;
                String inputHolder = input;

                List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();

                nameValuePairs.add(new BasicNameValuePair("userID", userIdHolder));
                nameValuePairs.add(new BasicNameValuePair("time", timeHolder));
                nameValuePairs.add(new BasicNameValuePair("input", inputHolder));

                String ServerURL = "http://79.136.70.172:7403/addValue.php";
                //String ServerURL = "http://192.168.1.65/addValue.php";

                try {
                    HttpClient httpClient = new DefaultHttpClient();

                    HttpPost httpPost = new HttpPost(ServerURL);

                    httpPost.setEntity(new UrlEncodedFormEntity(nameValuePairs));

                    HttpResponse httpResponse = httpClient.execute(httpPost);

                    HttpEntity httpEntity = httpResponse.getEntity();
                    String responseBody = EntityUtils.toString(httpEntity);
                    Log.d("InsertData", "Step 8 " + responseBody);


                } catch (ClientProtocolException e) {
                    Log.d("InsertData", "ClientProtocolException");

                } catch (IOException e) {
                    Log.d("InsertData", "IOException");

                }
                return "Data Inserted Successfully";
            }

            @Override
            protected void onPostExecute(String result) {
                savingToDB = false;
                // MainActivity.nInDB = MainActivity.nInDB + 1;
                MainActivity.nInDB = nToDB;
                nToDB = 0;
                saveFileUserId(context, MainActivity.curName, MainActivity.userID, MainActivity.nInDB);

                // super.onPostExecute(result);

                //Toast.makeText(AnswerQuestionsActivity.this, "Data Submit Successfully", Toast.LENGTH_LONG).show();

            }
        }

        SendPostReqAsyncTask sendPostReqAsyncTask = new SendPostReqAsyncTask();

        sendPostReqAsyncTask.execute(userID, time, input);
    }

    private static void saveFileUserId(Context context, String name, Long userID, int nInDB) {
        File path = context.getCacheDir();
        if(!path.exists()){
            path.mkdir();
        }

        String fileName = "user" + name + ".txt";

        File file = new File(path, fileName);
        Log.d("createFileUserId", "Storing userID in" + file.toString());
        try {
            FileWriter writer = new FileWriter(file, false);
            writer.append(userID + " " + nInDB + "\n");

            writer.flush();
            writer.close();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void syncWithDatabase()
    {
        if (savingToDB == true)
        { // Missed to save to database, do not save any more... (Need to save all in a batch)
            blockSaveToDB = true;
        }
        if (MainActivity.userID != 0 && blockSaveToDB == false) {
            String userID = Long.toString(MainActivity.userID);
            nToDB = nHistory();
            Log.d("syncWithDatabase", "User " + userID + " Storing question " + MainActivity.nInDB + " to " + (nToDB-1) + " in DB");
            String time = getDataTimesStart(MainActivity.nInDB);
            Log.d("syncWithDatabase", "Times " + time);
            String input = getDataInputsStart(MainActivity.nInDB);
            Log.d("syncWithDatabase", "Inputs " + input);
            Log.d("syncWithDatabase", "Storing inputs " + input);
            InsertData(userID, time, input);
        }
    }*/

    protected void onStop() {
        super.onStop();
        MainActivity.dbComm.syncWithDatabase(outputInDB, imgDB);
    }


    /* Declaration of C++ function */
    public native String setDataFile(String jFileName);
    public native String checkFeasibleOperator(String jOperator);
    public native String newQuestion(String jOperator);
    public native void clearQuestion();
    public native void addKey(String key);
    public native String determineAnswer();
    public native String storeAnswer();
    public native void saveAnswerToFile();
    public native String correctString(String jOperator);

    public native String getQuestion();
    public native int getX();
    public native int getY();
    public native int getZ();
    public native int getAnswer();
    public native String getStatus();
    public native int getLevel();
    public native double statusTime();
    public native int nHistory();

    public native String getDataTimes();
    public native String getDataTimesStart(int startQuestion);
    public native String getDataInputs();
    public native String getDataInputsStart(int startQuestion);

    public native double[] getSolutionTimes(int nLast);

}
