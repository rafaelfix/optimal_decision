package com.optimaleducation;

import androidx.appcompat.app.AppCompatActivity;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;

public class NumberCanvas extends AppCompatActivity {


    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(new MyView(this));
    }

    public class MyView extends View
    {
        float xx;
        float yy;

        int number1;
        int number2;
        int number1x1;
        int number1y1;
        int number1x2;
        int number1y2;
        int number2x1;
        int number2y1;
        int number2x2;
        int number2y2;
        int number3x1;
        int number3y1;
        int number3x2;
        int number3y2;

        Paint paintBkg = null;
        Paint paintBox = null;
        Paint paintFilled = null;
        Paint paintFilled2 = null;
        Paint paintEmpty = null;
        Paint paintText = null;
        Paint paintTextRed = null;
        public MyView(Context context)
        {
            super(context);
            paintBkg = new Paint();
            paintBkg.setStyle(Paint.Style.FILL);
            paintBkg.setColor(Color.WHITE);

            paintBox = new Paint();
            paintBox.setColor(Color.BLACK);
            paintBox.setStrokeWidth(0);
            paintBox.setStyle(Paint.Style.STROKE);

            paintFilled = new Paint();
            paintFilled.setStyle(Paint.Style.FILL);
            paintFilled.setColor(Color.BLACK);

            paintFilled2 = new Paint();
            paintFilled2.setStyle(Paint.Style.FILL);
            paintFilled2.setColor(Color.RED);

            paintEmpty = new Paint();
            paintEmpty.setColor(Color.BLACK);
            paintEmpty.setStrokeWidth(0);
            paintEmpty.setStyle(Paint.Style.STROKE);

            paintText = new Paint();
            paintText.setColor(Color.BLACK);
            paintText.setTextSize(100);

            paintTextRed = new Paint();
            paintTextRed.setColor(Color.RED);
            paintTextRed.setTextSize(100);

            number1 = 6;
            number2 = 7;
        }

        @Override
        protected void onDraw(Canvas canvas)
        {
            super.onDraw(canvas);
            int nx = getWidth();
            int ny = getHeight();
            int radius;
            radius = nx/40;
            canvas.drawPaint(paintBkg);

            //int width = nx/2;
            //int height = ny/8;
            int width = (nx*8)/10;
            int height = ny/15;

            number1x1 = 0;
            number1y1 = ny*1/40;
            number1x2 = number1x1+width;
            number1y2 = number1y1+height;
            number2x1 = 0;
            number2y1 = number1y2+ny*1/80;
            number2x2 = number2x1+width;
            number2y2 = number2y1+height;
            number3x1 = 0;
            number3y1 = number2y2+ny*1/80;
            number3x2 = number3x1+width;
            number3y2 = number3y1+height;

            //drawDot5(canvas, 0, number1y1, width, height, number1);
            //drawDot5(canvas, 0, number2y1, width, height, number2);

            drawDot10(canvas, number1x1, number1y1, number1x2, number1y2, number1, number1);
            drawDot10(canvas, number2x1, number2y1, number2x2, number2y2, 0, number2);
            drawDot10(canvas, number3x1, number3y1, number3x2, number3y2, number1, number1+number2);
            drawAddAlgorithm(canvas, number1x2, number1y2, number2y2, number3y2,2*nx/10, height, number1, number2, number1+number2);

            canvas.drawText(String.valueOf(xx) + "," + String.valueOf(yy) , 0, ny/2, paintText);
            canvas.drawText(String.valueOf(number2x1) + "," + String.valueOf(number2y1), 0, 100+ny/2, paintText);
            canvas.drawText(String.valueOf(number2x2) + "," + String.valueOf(number2y2), 0, 200+ny/2, paintText);
        }

        @Override
        public boolean onTouchEvent(MotionEvent event) {
            // Get the coordinate (x,y) for the current status of event.
            float x=event.getX();
            float y=event.getY();

            xx = x;
            yy = y;

            if (event.getAction() == MotionEvent.ACTION_DOWN)
            {
                if (x >= number1x1 && y >= number1y1 && x <= number1x2 && y <= number1y2 && number1>0)
                {
                    number1--;
                    number2++;
                }
                if (x >= number2x1 && y >= number2y1 && x <= number2x2 && y <= number2y2 && number2>0)
                {
                    number2--;
                    number1++;
                }
            }
            invalidate();
            return true;
        }

        protected int dot5PositionX(int nx, int dotNumber){
            if (dotNumber >= 6)
                dotNumber -= 5;
            return nx * (1+(dotNumber-1)*2) / 10;
        }

        protected int dot5PositionY(int ny, int dotNumber){
            if (dotNumber <= 5)
                return ny * 1 / 3;
            else
                return ny * 2 / 3;
        }

        protected int dot10PositionX(int X1, int X2, int dotNumber){
            if (dotNumber >= 11)
                dotNumber -= 10;
            double lambda = (11-dotNumber)/11.0;
            return (int)(lambda*X1 + (1-lambda)*X2);
        }

        protected int dot10PositionY(int Y1, int Y2, int dotNumber){
            double lambda;
            if (dotNumber <= 10)
                lambda = 2.0 / 3;
            else
                lambda = 1.0 / 3;
            return (int)(lambda*Y1 + (1-lambda)*Y2);
        }

        protected boolean dotFilled(int number, int dotNumber){
            return (dotNumber <= number);
        }

        protected void drawDot5(Canvas canvas, int X1, int Y1, int width, int height, int number){

            int radius;
            radius = width/15;

            paintFilled.setStyle(Paint.Style.FILL);
            paintFilled.setColor(Color.BLACK);

            paintEmpty.setColor(Color.BLACK);
            paintEmpty.setStrokeWidth(0);
            paintEmpty.setStyle(Paint.Style.STROKE);

            paintBox.setColor(Color.BLACK);
            paintBox.setStrokeWidth(0);
            paintBox.setStyle(Paint.Style.STROKE);

            canvas.drawRect(X1+width/80, Y1+height/20, X1+width*79/80, Y1+19*height/20, paintBox);
            int y1 = Y1+dot5PositionY(height, 1);
            int y2 = Y1+dot5PositionY(height, 6);
            for (int i=1 ; i<=5 ; i++)
            {
                int x = X1+dot5PositionX(width, i);
                if (dotFilled(number, i))
                    canvas.drawCircle(x, y1, radius, paintFilled);
                else
                    canvas.drawCircle(x, y1, radius, paintEmpty);
                if (dotFilled(number, 5+i))
                    canvas.drawCircle(x, y2, radius, paintFilled);
                else
                    canvas.drawCircle(x, y2, radius, paintEmpty);
            }
        }

        protected void drawDot10(Canvas canvas, int X1, int Y1, int X2, int Y2, int color1end, int number){

            int radius;
            radius = Math.min((int)((X2-X1)/40), (int)((Y2-Y1)/8));

            double lambda = 0.01;
            canvas.drawRect((float)((1-lambda)*X1+lambda*X2), (float)((1-lambda)*Y1+lambda*Y2), (float)(lambda*X1+(1-lambda)*X2), (float)(lambda*Y1+(1-lambda)*Y2), paintBox);
            canvas.drawLine((float)(0.5*X1+0.5*X2), (float)((1-lambda)*Y1+lambda*Y2), (float)(0.5*X1+0.5*X2), (float)(lambda*Y1+(1-lambda)*Y2), paintBox);
            int y1 = dot10PositionY(Y1, Y2, 1);
            int y2 = dot10PositionY(Y1, Y2, 11);
            for (int i=1 ; i<=10 ; i++)
            {
                int x = dot10PositionX(X1, X2, i);
                if (dotFilled(number, i))
                    if (i <= color1end)
                        canvas.drawCircle(x, y1, radius, paintFilled);
                    else
                        canvas.drawCircle(x, y1, radius, paintFilled2);
                else
                    canvas.drawCircle(x, y1, radius, paintEmpty);
                if (dotFilled(number, 10+i))
                    if (10+i <= color1end)
                        canvas.drawCircle(x, y2, radius, paintFilled);
                    else
                        canvas.drawCircle(x, y2, radius, paintFilled2);
                else
                    canvas.drawCircle(x, y2, radius, paintEmpty);
            }

        }

        protected void drawAddAlgorithm(Canvas canvas, int offsetX, int offsetY1, int offsetY2, int offsetY3, int width, int height, int number1, int number2, int number3){
            double lambda = 0.1;

            if (number1 <= 9)
                canvas.drawText(String.valueOf(number1) , offsetX+(2*width)/3, offsetY1-(int)(lambda*height), paintText);
            else
            {
                canvas.drawText(String.valueOf(1) , offsetX+(1*width)/3, offsetY1-(int)(lambda*height), paintText);
                canvas.drawText(String.valueOf(number1-10) , offsetX+(2*width)/3, offsetY1-(int)(lambda*height), paintText);
            }

            canvas.drawText("+" , offsetX, offsetY2-(int)(lambda*height), paintText);
            if (number2 <= 9)
                canvas.drawText(String.valueOf(number2) , offsetX+(2*width)/3, offsetY2-(int)(lambda*height), paintTextRed);
            else
            {
                canvas.drawText(String.valueOf(1) , offsetX+(1*width)/3, offsetY2-(int)(lambda*height), paintTextRed);
                canvas.drawText(String.valueOf(number2-10) , offsetX+(2*width)/3, offsetY2-(int)(lambda*height), paintTextRed);
            }

            canvas.drawLine(offsetX, offsetY2, offsetX+width, offsetY2, paintBox);
            canvas.drawText("=" , offsetX, offsetY3-(int)(lambda*height), paintText);
            if (number3 <= 9)
                canvas.drawText(String.valueOf(number3) , offsetX+(2*width)/3, offsetY3-(int)(lambda*height), paintText);
            else
            {
                canvas.drawText(String.valueOf(1) , offsetX+(1*width)/3, offsetY3-(int)(lambda*height), paintText);
                canvas.drawText(String.valueOf(number3-10) , offsetX+(2*width)/3, offsetY3-(int)(lambda*height), paintText);
            }
        }

    }

}
