package org.twinone.rubiksolver.model;

import android.graphics.Color;

/**
 * Created by twinone on 6/20/15.
 */
public class CapturedFace {

    public final int size;
    // Colors of this CapturedFace
    public final double[][][] m;

    public CapturedFace(int size) {
        this.size = size;
        this.m = new double[size][size][3];
    }

    public int getColor(int i, int j) {
        double[] c = m[i][j];
        return Color.rgb((int) c[0], (int) c[1], (int) c[2]);
    }

    public float[] getHSV(int i, int j) {
        double[] c = m[i][j];

        float hsv[] = new float[3];
        Color.colorToHSV(getColor(i, j), hsv);
        return hsv;
    }
}
