package matrix;

import java.util.*;

/**
 * Created by roman on 2/25/15.
 */
public class LinkedListMatrix {
    private LinkedList<Integer> _matrix;
    private int height;
    private int width;

    public LinkedListMatrix(int height, int width) {
        _matrix = new LinkedList<Integer>();
        this.height = height;
        this.width = width;
        for (int i = 0; i < height * width; i++) {
            _matrix.add(0);
        }
    }

    public LinkedListMatrix(int height, int width, LinkedList<Integer> linkedList) {
        this._matrix = linkedList;
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

    public static LinkedListMatrix multiplyMatrices(LinkedListMatrix A, LinkedListMatrix B) {
        if (A.getWidth() != B.getHeight()){
            return null;
        } else {
            LinkedListMatrix C = new LinkedListMatrix(A.getHeight(), B.getWidth());
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

    public static void printLinkedListMatrix(LinkedListMatrix matrix) {
        for (int i = 0; i < matrix.height; i++) {
            for (int j = 0; j < matrix.width; j++) {
                System.out.format("%3d", matrix.get(i, j));
            }
            System.out.println();
        }
    }
}
