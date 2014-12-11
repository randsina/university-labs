// ConsoleApplication2.cpp : Defines the entry point for the console application.
//
#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "stdafx.h"

__int8 A[8] = { 1, 2, 3, 4, 5, 6, 7, 8 };
__int8 B[8] = { 1, 2, 3, 4, 5, 6, 7, 8 };
__int8 C[8] = { 1, 2, 3, 4, 5, 6, 7, 8 };
__int16 D[8] = { 1, 2, 3, 4, 5, 6, 7, 8 };
__int16 F[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };

void print_input()
{
	printf("A = ");
	for (int i = 0; i < 8; i++)
		printf("%6d", A[i]);

	printf("\nB = ");
	for (int i = 0; i < 8; i++)
		printf("%6d", B[i]);

	printf("\nC = ");
	for (int i = 0; i < 8; i++)
		printf("%6d", C[i]);

	printf("\nD = ");
	for (int i = 0; i < 8; i++)
		printf("%6d", D[i]);
}

void print_output()
{
	printf("\nF = ");
	for (int i = 0; i < 8; i++)
	{
		printf("%6d", F[i]);
	}

	printf("\nA * B + C - D\n");
}

void calculate()
{
	__asm
	{
		pxor mm0, mm0
			movq mm1, A //A[0..7]
			movq mm2, B //B[0..7]
			movq mm3, C //C[0..7]
			movq mm4, D //D[0..3]
			punpcklbw mm1, mm0 //A[0..3] - распаковка
			punpcklbw mm2, mm0 //B[0..3]
			punpcklbw mm3, mm0 //C[0..3]
			pmullw mm1, mm2    //умножаем A * B
			paddw mm1, mm3     // A * B + C
			psubw mm1, mm2     // A * B + C - D

			movq F, mm1	// сохраняем первые 64 бита

			movq mm1, qword ptr[A + 4] //A[4..7, xxxx] - заносим числа со сдвигом
			movq mm2, qword ptr[B + 4] //B[4..7, xxxx]
			movq mm3, qword ptr[C + 4] //C[4..7, xxxx]
			movq mm4, qword ptr[D + 8] //D[4..7]

			punpcklbw mm1, mm0 //A[4..7] - распаковка
			punpcklbw mm2, mm0 //B[4..7]
			punpcklbw mm3, mm0 //C[4..7]
			pmullw mm1, mm2    //умножаем A * B
			paddb mm1, mm3     // A * B + C
			psubb mm1, mm2     // A * B + C - D
			movq qword ptr[F + 8], mm1 //помещаем результат во вторые 64 бита

			emms //конец использования MMX
	}
}


int _tmain(int argc, char* argv[])
{
	print_input();
	calculate();
	print_output();

	while (getchar() != '\n') {}

	return 0;
}

