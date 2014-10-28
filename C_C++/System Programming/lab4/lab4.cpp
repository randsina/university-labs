// lab4.cpp : Defines the entry point for the application.
//

#include "stdafx.h"
#include "lab4.h"
#include <tchar.h>
#include <stdlib.h>
#include <time.h>
#include <stdio.h>

#define MAX_LOADSTRING 100
#define ID_BUTTON_START 1
#define ID_BUTTON_STOP 2
#define ID_EDIT_CONTROL1 3
#define ID_EDIT_CONTROL2 4
#define ID_EDIT_CONTROL3 5
#define ID_THREAD1 6
#define ID_THREAD2 7
#define ID_THREAD3 8
#define ID_TIMER 9

// Global Variables:
HINSTANCE hInst;								// current instance
TCHAR szTitle[MAX_LOADSTRING];					// The title bar text
TCHAR szWindowClass[MAX_LOADSTRING];			// the main window class name
HWND hButtonStart, hButtonStop;
HWND hEditControl1, hEditControl2, hEditControl3;
HANDLE hThread1, hThread2, hThread3;
int	rand1, rand2, rand3;

// Forward declarations of functions included in this code module:
ATOM				MyRegisterClass(HINSTANCE hInstance);
BOOL				InitInstance(HINSTANCE, int);
LRESULT CALLBACK	WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK	About(HWND, UINT, WPARAM, LPARAM);
DWORD WINAPI		ThreadProc(LPVOID pParam);

int APIENTRY _tWinMain(_In_ HINSTANCE hInstance,
	_In_opt_ HINSTANCE hPrevInstance,
	_In_ LPTSTR    lpCmdLine,
	_In_ int       nCmdShow)
{
	UNREFERENCED_PARAMETER(hPrevInstance);
	UNREFERENCED_PARAMETER(lpCmdLine);

	// TODO: Place code here.
	MSG msg;
	HACCEL hAccelTable;

	// Initialize global strings
	LoadString(hInstance, IDS_APP_TITLE, szTitle, MAX_LOADSTRING);
	LoadString(hInstance, IDC_LAB4, szWindowClass, MAX_LOADSTRING);
	MyRegisterClass(hInstance);

	// Perform application initialization:
	if (!InitInstance(hInstance, nCmdShow))
	{
		return FALSE;
	}

	hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_LAB4));

	// Main message loop:
	while (GetMessage(&msg, NULL, 0, 0))
	{
		if (!TranslateAccelerator(msg.hwnd, hAccelTable, &msg))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}

	return (int)msg.wParam;
}



//
//  FUNCTION: MyRegisterClass()
//
//  PURPOSE: Registers the window class.
//
ATOM MyRegisterClass(HINSTANCE hInstance)
{
	WNDCLASSEX wcex;

	wcex.cbSize = sizeof(WNDCLASSEX);

	wcex.style = CS_HREDRAW | CS_VREDRAW;
	wcex.lpfnWndProc = WndProc;
	wcex.cbClsExtra = 0;
	wcex.cbWndExtra = 0;
	wcex.hInstance = hInstance;
	wcex.hIcon = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_LAB4));
	wcex.hCursor = LoadCursor(NULL, IDC_ARROW);
	wcex.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
	wcex.lpszMenuName = MAKEINTRESOURCE(IDC_LAB4);
	wcex.lpszClassName = szWindowClass;
	wcex.hIconSm = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_SMALL));

	return RegisterClassEx(&wcex);
}

//
//   FUNCTION: InitInstance(HINSTANCE, int)
//
//   PURPOSE: Saves instance handle and creates main window
//
//   COMMENTS:
//
//        In this function, we save the instance handle in a global variable and
//        create and display the main program window.
//
BOOL InitInstance(HINSTANCE hInstance, int nCmdShow)
{
	HWND hWnd;

	hInst = hInstance; // Store instance handle in our global variable

	hWnd = CreateWindow(szWindowClass, szTitle, WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT, CW_USEDEFAULT, 300, 300, NULL, NULL, hInstance, NULL);

	if (!hWnd)
	{
		return FALSE;
	}

	hButtonStart = CreateWindow(L"Button", L"Start", WS_CHILD | WS_VISIBLE,
		10, 10, 120, 50, hWnd, (HMENU)ID_BUTTON_START, hInstance, NULL);
	hButtonStop = CreateWindow(L"Button", L"Stop", WS_CHILD | WS_VISIBLE,
		140, 10, 120, 50, hWnd, (HMENU)ID_BUTTON_STOP, hInstance, NULL);

	hEditControl1 = CreateWindow(L"Edit", L"", WS_CHILD | WS_VISIBLE | WS_BORDER,
		10, 100, 200, 20, hWnd, (HMENU)ID_EDIT_CONTROL1, hInstance, NULL);
	hEditControl2 = CreateWindow(L"Edit", L"", WS_CHILD | WS_VISIBLE | WS_BORDER,
		10, 130, 200, 20, hWnd, (HMENU)ID_EDIT_CONTROL2, hInstance, NULL);
	hEditControl3 = CreateWindow(L"Edit", L"", WS_CHILD | WS_VISIBLE | WS_BORDER,
		10, 160, 200, 20, hWnd, (HMENU)ID_EDIT_CONTROL3, hInstance, NULL);

	ShowWindow(hWnd, nCmdShow);
	UpdateWindow(hWnd);

	return TRUE;
}

//
//  FUNCTION: WndProc(HWND, UINT, WPARAM, LPARAM)
//
//  PURPOSE:  Processes messages for the main window.
//
//  WM_COMMAND	- process the application menu
//  WM_PAINT	- Paint the main window
//  WM_DESTROY	- post a quit message and return
//
//
LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	int wmId, wmEvent;
	PAINTSTRUCT ps;
	HDC hdc;

	wchar_t text1[10], text2[10], text3[10];
	_itow_s((int)rand1, text1, 10, 10);
	_itow_s((int)rand2, text2, 10, 10);
	_itow_s((int)rand3, text3, 10, 10);

	switch (message)
	{
	case WM_CREATE:
		hThread1 = CreateThread(NULL, 0, ThreadProc, LPVOID(ID_THREAD1), 0, NULL);
		hThread2 = CreateThread(NULL, 0, ThreadProc, LPVOID(ID_THREAD2), 0, NULL);
		hThread3 = CreateThread(NULL, 0, ThreadProc, LPVOID(ID_THREAD3), 0, NULL);
		SetTimer(hWnd, ID_TIMER, 2000, NULL);
		break;
	case WM_COMMAND:
		wmId = LOWORD(wParam);
		wmEvent = HIWORD(wParam);
		switch (LOWORD(wParam))
		{
		case ID_BUTTON_START:
			/*while (ResumeThread(hThread1))
			{
			while (ResumeThread(hThread2))
			{
			ResumeThread(hThread3);
			}

			}*/
			ResumeThread(hThread1);
			ResumeThread(hThread2);
			ResumeThread(hThread3);
			break;
		case ID_BUTTON_STOP:
			SuspendThread(hThread1);
			SuspendThread(hThread2);
			SuspendThread(hThread3);
			break;
		default:
			break;
		}
		// Parse the menu selections:
		switch (wmId)
		{
		case IDM_ABOUT:
			DialogBox(hInst, MAKEINTRESOURCE(IDD_ABOUTBOX), hWnd, About);
			break;
		case IDM_EXIT:
			DestroyWindow(hWnd);
			break;
		default:
			return DefWindowProc(hWnd, message, wParam, lParam);
		}
		break;
	case WM_PAINT:
		hdc = BeginPaint(hWnd, &ps);
		// TODO: Add any drawing code here...
		EndPaint(hWnd, &ps);
		break;
	case WM_TIMER:

		switch (wParam)
		{
		case ID_TIMER:
//			_stprintf_s(txt, _T("%d"), rand1);
			SendMessage(GetDlgItem(hWnd, ID_EDIT_CONTROL1), WM_SETTEXT, (WPARAM)0, (LPARAM)text1);
			SendMessage(GetDlgItem(hWnd, ID_EDIT_CONTROL2), WM_SETTEXT, (WPARAM)0, (LPARAM)text2);
			SendMessage(GetDlgItem(hWnd, ID_EDIT_CONTROL3), WM_SETTEXT, (WPARAM)0, (LPARAM)text3);
			break;
		default:
			break;
		}
		break;
	case WM_DESTROY:
		TerminateThread(hThread1, 0);
		TerminateThread(hThread2, 0);
		TerminateThread(hThread3, 0);
		CloseHandle(hThread1);
		CloseHandle(hThread2);
		CloseHandle(hThread3);
		PostQuitMessage(0);
		break;
	default:
		return DefWindowProc(hWnd, message, wParam, lParam);
	}
	return 0;
}

// Message handler for about box.
INT_PTR CALLBACK About(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
	UNREFERENCED_PARAMETER(lParam);
	switch (message)
	{
	case WM_INITDIALOG:
		return (INT_PTR)TRUE;

	case WM_COMMAND:
		if (LOWORD(wParam) == IDOK || LOWORD(wParam) == IDCANCEL)
		{
			EndDialog(hDlg, LOWORD(wParam));
			return (INT_PTR)TRUE;
		}
		break;
	}
	return (INT_PTR)FALSE;
}

DWORD WINAPI ThreadProc(LPVOID pParam)
{
	int threadId = (int)pParam;
	while (true)
	{
		srand((unsigned)time(NULL));
		switch (threadId)
		{
		case ID_THREAD1:
			rand1 = rand() % 97;
			Sleep(2000);
			break;
		case ID_THREAD2:
			Sleep(2000);
			rand2 = rand() % 59;
			break;
		case ID_THREAD3:
			rand3 = rand() % 79;
			Sleep(2000);
			break;
		default:
			break;
		}
	}
}
