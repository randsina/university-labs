package matrix;

import java.util.*;

/**
 * Created by roman on 2/25/15.
 */
public class ArrayListMatrix {
    private ArrayList<Integer> _matrix;
    private int height;
    private int width;

    public ArrayListMatrix(int height, int width) {
        _matrix = new ArrayList<Integer>();
        this.height = height;
        this.width = width;
        for (int i = 0; i < height * width; i++) {
            _matrix.add(0);
        }
    }

    public ArrayListMatrix(int height, int width, ArrayList<Integer> arrayList) {
        this._matrix = arrayList;
        this.height = height;
        this.width = width;
    }

    public int getHeight() {
        return height;
    }

    public int getWidth() {
        return width;
    }

    public void set(int i, int j, int value) {
        _matrix.set(i * height + j, value);
    }

    public int get(int i, int j) {
        return _matrix.get(i * height + j);
    }

    public static ArrayListMatrix multiplyMatrices(ArrayListMatrix A, ArrayListMatrix B) {
        if (A.getWidth() != B.getHeight()){
            return null;
        } else {
            ArrayListMatrix C = new ArrayListMatrix(A.getHeight(), B.getWidth());
            for (int i = 0; i < A.getHeight(); i++) {
                for (int j = 0; j < B.getWidth(); j++) {
                    for (int k = 0; k < B.getHeight(); k++) {
                        int value = A.get(i, k) * B.get(k, j);
                        C.set(i,j, C.get(i, j) + value);
                    }
                }
            }
            return C;
        }
    }

    public static void printArrayListMatrix(ArrayListMatrix matrix) {
        for (int i = 0; i < matrix.height; i++) {
            for (int j = 0; j < matrix.width; j++) {
                System.out.format("%3d", matrix.get(i, j));
            }
            System.out.println();
        }
    }
}
