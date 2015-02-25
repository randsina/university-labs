import matrix.*;

import static matrix.Matrix.*;

/**
 * Created by roman on 2/23/15.
 */
public class Main {
    public static void main(String[] args) {
//        int[][] num = { {1, 2, 3}, {4, 5, 6}, {7, 8, 9} };
        int[][] ints = {{1,2,3,4},{4,5,6,3},{1,2,1,3},{1,1,1,2}};
        int[][] ints1 = {{2,1},{5,4},{8,7},{3,2}};
        Matrix matrix = new Matrix(ints);
        Matrix matrix1 = new Matrix(ints1);
        Matrix matrix2 = multiply_matrix(matrix, matrix1);
        System.out.println("Multiply random matrices");
        print_matrix(matrix2);

        int[][] ints_O = {{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}};
        int[][] ints_E = {{1,0,0,0},{0,1,0,0},{0,0,1,0},{0,0,0,1}};
        Matrix matrix_O = new Matrix(ints_O);
        Matrix matrix_E = new Matrix(ints_E);
        System.out.println("Zero matrix * zero matrix");
        print_matrix(multiply_matrix(matrix_O, matrix_O));
        System.out.println("Zero matrix * identity matrix");
        print_matrix(multiply_matrix(matrix_E, matrix_O));
        System.out.println("Zero matrix * random matrix");
        print_matrix(multiply_matrix(matrix_O, matrix));
        System.out.println("Identity matrix * random matrix");
        print_matrix(multiply_matrix(matrix_E, matrix));
        System.out.println("Random matrix * random matrix");
        print_matrix(multiply_matrix(matrix, matrix));
    }
}
