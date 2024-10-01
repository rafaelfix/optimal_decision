package com.optimaleducation;

import android.content.Context;
import android.media.AudioManager;
import android.media.ToneGenerator;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;

public class TimeActivity extends AppCompatActivity {
    Button buttonTimeStart, buttonTimeStop;
    TextView tvTime;

    Context context = this;

    boolean runClock;
    double tAvail;
    double tStart;

    // Used to load the 'native-lib' library on application startup.
    static {
        System.loadLibrary("native-lib");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.d("TimeActivity::init", "onCreate");

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_clock);

        tvTime = (TextView) findViewById(R.id.textViewTime);
        buttonTimeStart = (Button) findViewById(R.id.buttonTimeStart);
        buttonTimeStop = (Button) findViewById(R.id.buttonTimeStop);

        tAvail = gamingTimeAvail();
        Log.d("TimeActivity::init", "onCreate, remaining " + Double.toString(tAvail));
        if (tAvail < 0)
            tAvail = 0;
        SimpleDateFormat formatter = new SimpleDateFormat("HH:mm:ss");
        formatter.setTimeZone(TimeZone.getTimeZone("GMT"));
        Date gamingTime = new Date(Math.round(tAvail*1000));
        tvTime.setText(formatter.format(gamingTime));
        runClock = false;

        buttonTimeStart.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!runClock)
                {
                    gamingTimeStart();
                    Log.d("TimeActivity::Start", "Start");
                    runClock = true;
                    timeTick();
                }
            }
        });

        buttonTimeStop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (runClock)
                {
                    Log.d("TimeActivity::Stop", "Stop");
                    double t = gamingTimeCur();
                    tAvail -= t;
                    if (tAvail < 0)
                        tAvail = 0;
                    gamingTimeEnd();
                    runClock = false;
                }
            }
        });

        /*Log.d("TimeActivity::init", "onCreate File");
        File path = context.getCacheDir();
        if (path.exists()){
            path.mkdir();
        }
        String curName = MainActivity.curName;
        Log.d("TimeActivity::init", "onCreate File" + curName);
        String fileName = path.getAbsolutePath() + "/optGamingTime" + curName + ".txt";
        Log.d("TimeActivity::init", "onCreate File" + fileName);

        String msg = setGamingTimeFile(fileName);
        Log.d("TimeActivity::init", "onCreate File end");*/

    }

    private void timeTick() {
        final Handler handler = new Handler();
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    Thread.sleep(200);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (runClock)
                        {
                            double t = gamingTimeCur();
                            Log.d("TimeActivity::Tick", "Gaming time " + Double.toString(t));
                            Date curTime = new Date(Math.round(t));
                            long diff = Math.round((tAvail - t) * 1000);
                            if (diff < 0)
                                diff = 0;
                            Date remainingTime = new Date(diff);
                            Log.d("TimeActivity::Tick", "Remain " + Double.toString(diff));
                            SimpleDateFormat formatter = new SimpleDateFormat("HH:mm:ss");
                            formatter.setTimeZone(TimeZone.getTimeZone("GMT"));
                            tvTime.setText(formatter.format(remainingTime));
                            if (diff > 0)
                                timeTick();
                            else
                            {
                                Log.d("TimeActivity::timeTick", "Out of time");
                                tAvail -= t;
                                if (tAvail < 0)
                                    tAvail = 0;
                                gamingTimeEnd();
                                runClock = false;
                                ToneGenerator toneGenerator = new ToneGenerator(AudioManager.STREAM_MUSIC, 200);
                                toneGenerator.startTone(ToneGenerator.TONE_SUP_BUSY, 10000);
                            }
                        }
                    }
                });
            }
        }).start();
    }

    /* Declaration of C++ function */
    public native String setGamingTimeFile(String jFileName);
    public native void gamingTimeStart();
    public native void gamingTimeEnd();
    public native double gamingTimeAvail();
    public native double gamingTimeCur();
}
