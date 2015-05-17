import matrix.*;

import java.lang.reflect.Array;
import java.util.*;

import static matrix.ArrayListMatrix.*;
import static matrix.LinkedListMatrix.*;

/**
 * Created by roman on 2/23/15.
 */
public class Main {
    public static void main(String[] args) {
        testMultiplyMatrices();
        testLists();
    }

    public static void testMultiplyMatrices() {
        Random random = new Random();

        ArrayListMatrix arrayListMatrix_O = new ArrayListMatrix(4, 4);
        ArrayListMatrix arrayListMatrix_E = new ArrayListMatrix(4, 4);
        ArrayListMatrix arrayListMatrix = new ArrayListMatrix(4, 4);

        LinkedListMatrix linkedListMatrix_O = new LinkedListMatrix(4, 4);
        LinkedListMatrix linkedListMatrix_E = new LinkedListMatrix(4, 4);
        LinkedListMatrix linkedListMatrix = new LinkedListMatrix(4, 4);

        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 4; j++) {
                arrayListMatrix.set(i, j, random.nextInt(5));
                linkedListMatrix.set(i, j, random.nextInt(5));
                if (i == j) {
                    arrayListMatrix_E.set(i, j, 1);
                    linkedListMatrix_E.set(i, j, 1);
                }
            }
        }

        System.out.println("ArrayList matrix:");
        printArrayListMatrix(multiplyMatrices(arrayListMatrix_O, arrayListMatrix_O));
        printArrayListMatrix(multiplyMatrices(arrayListMatrix_O, arrayListMatrix_E));
        printArrayListMatrix(multiplyMatrices(arrayListMatrix_O, arrayListMatrix));
        printArrayListMatrix(multiplyMatrices(arrayListMatrix_E, arrayListMatrix_E));
        printArrayListMatrix(multiplyMatrices(arrayListMatrix_E, arrayListMatrix));
        printArrayListMatrix(multiplyMatrices(arrayListMatrix, arrayListMatrix));

        System.out.println("LinkedList matrix:");
        printLinkedListMatrix(multiplyMatrices(linkedListMatrix_O, linkedListMatrix_O));
        printLinkedListMatrix(multiplyMatrices(linkedListMatrix_O, linkedListMatrix_E));
        printLinkedListMatrix(multiplyMatrices(linkedListMatrix_O, linkedListMatrix));
        printLinkedListMatrix(multiplyMatrices(linkedListMatrix_E, linkedListMatrix_E));
        printLinkedListMatrix(multiplyMatrices(linkedListMatrix_E, linkedListMatrix));
        printLinkedListMatrix(multiplyMatrices(linkedListMatrix, linkedListMatrix));
    }

    public static void testLists() {
        Random random = new Random();

        ArrayListMatrix arrayListMatrix = new ArrayListMatrix(100, 100);
        ArrayListMatrix arrayListMatrix1 = new ArrayListMatrix(100, 100);

        LinkedListMatrix linkedListMatrix = new LinkedListMatrix(100,100);
        LinkedListMatrix linkedListMatrix1 = new LinkedListMatrix(100, 100);

        for (int i = 0; i < 100; i++) {
            for (int j = 0; j < 100; j++) {
                arrayListMatrix.set(i, j, random.nextInt(10));
                arrayListMatrix1.set(i, j, random.nextInt(10));
                linkedListMatrix.set(i, j, random.nextInt(10));
                linkedListMatrix1.set(i, j, random.nextInt(10));
            }
        }

        long timeBefore = System.currentTimeMillis();
        multiplyMatrices(arrayListMatrix, arrayListMatrix1);
        long timeAfter = System.currentTimeMillis();
        System.out.println(timeAfter - timeBefore);

        timeBefore = System.currentTimeMillis();
        multiplyMatrices(linkedListMatrix, linkedListMatrix1);
        timeAfter = System.currentTimeMillis();
        System.out.println(timeAfter - timeBefore);
    }
}
