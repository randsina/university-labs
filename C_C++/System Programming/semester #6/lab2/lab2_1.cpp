// lab2_1.cpp : Defines the entry point for the application.
//

#include "stdafx.h"
#include "lab2_1.h"

#define MAX_LOADSTRING 100

#define ID_EDIT_CONTROL 3
#define THREADCOUNT 3

// Global Variables:
HINSTANCE hInst;								// current instance
TCHAR szTitle[MAX_LOADSTRING];					// The title bar text
TCHAR szWindowClass[MAX_LOADSTRING];			// the main window class name

HWND hWndEditControl;
HANDLE ghWriteEvent;
HANDLE ghThreads[THREADCOUNT];
DWORD dwThreadIdArray[THREADCOUNT];
CRITICAL_SECTION CriticalSection;

// Forward declarations of functions included in this code module:
ATOM				MyRegisterClass(HINSTANCE hInstance);
BOOL				InitInstance(HINSTANCE, int);
LRESULT CALLBACK	WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK	About(HWND, UINT, WPARAM, LPARAM);
DWORD WINAPI		ThreadProc(LPVOID param);

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
	LoadString(hInstance, IDC_LAB2_1, szWindowClass, MAX_LOADSTRING);
	MyRegisterClass(hInstance);

	// Perform application initialization:
	if (!InitInstance (hInstance, nCmdShow))
	{
		return FALSE;
	}
	InitializeCriticalSection(&CriticalSection);

	hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_LAB2_1));

	SetEvent(ghWriteEvent);
	// Main message loop:
	while (GetMessage(&msg, NULL, 0, 0))
	{
		if (!TranslateAccelerator(msg.hwnd, hAccelTable, &msg))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}
	ResetEvent(ghWriteEvent);
	CloseHandle(ghWriteEvent);
	return (int) msg.wParam;
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

	wcex.style			= CS_HREDRAW | CS_VREDRAW;
	wcex.lpfnWndProc	= WndProc;
	wcex.cbClsExtra		= 0;
	wcex.cbWndExtra		= 0;
	wcex.hInstance		= hInstance;
	wcex.hIcon			= LoadIcon(hInstance, MAKEINTRESOURCE(IDI_LAB2_1));
	wcex.hCursor		= LoadCursor(NULL, IDC_ARROW);
	wcex.hbrBackground	= (HBRUSH)(COLOR_WINDOW+1);
	wcex.lpszMenuName	= MAKEINTRESOURCE(IDC_LAB2_1);
	wcex.lpszClassName	= szWindowClass;
	wcex.hIconSm		= LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_SMALL));

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
      CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, NULL, NULL, hInstance, NULL);

   if (!hWnd)
   {
      return FALSE;
   }

   hWndEditControl = CreateWindow(L"EDIT", L"", WS_CHILD | WS_VISIBLE | WS_BORDER, 
	   10, 10, 150, 20, hWnd, (HMENU)ID_EDIT_CONTROL, hInst, NULL);

   ghWriteEvent = CreateEvent(NULL, true, false, L"Event");
   
   ghThreads[0] = CreateThread(NULL, 0, ThreadProc, L"First", 0, &dwThreadIdArray[0]);
   ghThreads[1] = CreateThread(NULL, 0, ThreadProc, L"Second", 0, &dwThreadIdArray[1]);
   ghThreads[2] = CreateThread(NULL, 0, ThreadProc, L"Third", 0, &dwThreadIdArray[2]);

   ghThreads[3] = CreateThread(NULL, 0, ThreadProc, L"Fourth", 0, &dwThreadIdArray[3]);
   ghThreads[4] = CreateThread(NULL, 0, ThreadProc, L"Fifth", 0, &dwThreadIdArray[4]);
   ghThreads[5] = CreateThread(NULL, 0, ThreadProc, L"Sixth", 0, &dwThreadIdArray[5]);
   ghThreads[6] = CreateThread(NULL, 0, ThreadProc, L"Seventh", 0, &dwThreadIdArray[6]);
   ghThreads[7] = CreateThread(NULL, 0, ThreadProc, L"Eighth", 0, &dwThreadIdArray[7]);
   ghThreads[8] = CreateThread(NULL, 0, ThreadProc, L"Ninth", 0, &dwThreadIdArray[8]);
   ghThreads[9] = CreateThread(NULL, 0, ThreadProc, L"Tenth", 0, &dwThreadIdArray[9]);
   
   // OpenEvent(EVENT_MODIFY_STATE, TRUE, L"Global\\");

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

	switch (message)
	{
	case WM_COMMAND:
		wmId    = LOWORD(wParam);
		wmEvent = HIWORD(wParam);
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
	case WM_DESTROY:
		for (int i = 0; i < THREADCOUNT; i++)
		{
			CloseHandle(ghThreads[i]);
		}
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

DWORD WINAPI ThreadProc(LPVOID param)
{
	DWORD dwWaitResult;
	dwWaitResult = WaitForSingleObject(ghWriteEvent, 1000);
	switch (dwWaitResult)
	{
	case WAIT_OBJECT_0:
		EnterCriticalSection(&CriticalSection);
		SendMessage(hWndEditControl, WM_SETTEXT, NULL, LPARAM(param));
		Sleep(1000);
		LeaveCriticalSection(&CriticalSection);
		break;
	default:
		break;
	}/*
	while (true)
	{
		do {
			dwWaitResult = WaitForSingleObject(ghWriteEvent, 1000);
		} while (dwWaitResult != WAIT_OBJECT_0);
		EnterCriticalSection(&CriticalSection);
		SendMessage(hWndEditControl, WM_SETTEXT, NULL, LPARAM(param));
		Sleep(1000);
		LeaveCriticalSection(&CriticalSection);
	}*/
	return 0;
}