package matrix;

import java.util.*;
/**
 * Created by roman on 2/23/15.
 */
public class Matrix {
    private int[][] _matrix;
    private int width;
    private int height;

    public Matrix(int[][] array) {
        this._matrix = array;
        this.height = array.length;
        this.width = array[0].length;
    }

    public Matrix(int height, int width) {
        _matrix = new int[height][width];
        this.width = width;
        this.height = height;
        for (int i=0; i < height;i++)
            for (int j=0; j < width;j++)
                _matrix[i][j] = 0;
    }

    public int get_width() {
        return width;
    }

    public int get_height() {
        return height;
    }

    public void set(int i, int j,int value) {
        _matrix[i][j] = value;
    }

    public int get(int i, int j) {
        return _matrix[i][j];
    }

    public static Matrix multiply_matrix(Matrix A, Matrix B) {
        if (A.get_width() != B.get_height()){
            return null;
        } else {
            Matrix C = new Matrix(A.get_height(), B.get_width());
            for (int i = 0; i < A.get_height(); i++) {
                for (int j = 0; j < B.get_width(); j++) {
                    for (int k = 0; k < B.get_height(); k++) {
                        int value = A.get(i, k) * B.get(k, j);
                        C.set(i,j, C.get(i, j) + value);
                    }
                }
            }

            return C;
        }
    }

    public static void print_matrix(Matrix matrix) {
        for (int i=0; i < matrix.get_height();i++) {
            for (int j=0; j < matrix.get_width();j++) {
                System.out.format("%3d", matrix.get(i, j));
            }
            System.out.println();
        }
    }
}
