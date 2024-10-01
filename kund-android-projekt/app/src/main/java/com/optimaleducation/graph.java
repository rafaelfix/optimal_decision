package com.optimaleducation;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;

public class graph extends View {
    double[] solutionTimes;

    public graph(Context cxt, AttributeSet attrs) {
        super(cxt, attrs);
        setMinimumHeight(100);
        setMinimumWidth(100);
    }

    public void setSolutionTimes(double[] _solutionTimes) {
        this.solutionTimes = _solutionTimes;
    }

    @Override
    protected void onDraw(Canvas cv) {
        cv.drawColor(Color.WHITE);
        Paint p = new Paint();
        p.setColor(Color.BLUE);
        p.setStrokeWidth(5);
        int nx = cv.getWidth();
        int ny = cv.getHeight();

        double maxVal = 0;
        for (int i=0 ; i<solutionTimes.length ; i++)
            if (solutionTimes[i] > maxVal)
                maxVal = solutionTimes[i];

        for (int i=0 ; i<solutionTimes.length-1 ; i++)
        {
            float x1 = (i*nx)/(solutionTimes.length-1);
            float x2 = ((i+1)*nx)/(solutionTimes.length-1);
            float y1 =  (float)(ny-solutionTimes[i]/maxVal*ny);
            float y2 = (float)(ny-solutionTimes[i+1]/maxVal*ny);
            cv.drawLine(x1,y1, x2, y2, p);
            // Log.d("plotGraph", "Graph: " + String.valueOf(x1)+ " "  + String.valueOf(y1) + " to " + String.valueOf(x2)+ " "  + String.valueOf(y2));

        }
    }



}
