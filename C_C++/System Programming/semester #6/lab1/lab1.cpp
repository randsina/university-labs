// lab1.cpp : Defines the entry point for the application.
//

#include "stdafx.h"
#include "lab1.h"

#define MAX_LOADSTRING 100

#define IdRadioBtnRed		1
#define IdRadioBtnBlue		2
#define IdRadioBtnGreen		3
#define IdRadioBtnRhombus	4
#define IdRadioBtnSquare	5
#define IdRadioBtnCircle	6
#define IdRadioBtnStar		7

#define IdCheckBox			8

#define DRAWSTRUCT			9
#define WM_CTRL_CHANGE		(WM_USER + 1000)

// Global Variables:
HINSTANCE hInst;								// current instance
TCHAR szTitle[MAX_LOADSTRING];					// The title bar text
TCHAR szWindowClass[MAX_LOADSTRING];			// the main window class name

HWND hWndRadioBtnRed;
HWND hWndRadioBtnBlue;
HWND hWndRadioBtnGreen;
HWND hWndRadioBtnRhombus;
HWND hWndRadioBtnSquare;
HWND hWndRadioBtnCircle;
HWND hWndRadioBtnStar;

HWND hWndCheckBox;
HWND hwDispatch;

struct DrawStruct
{
	UINT figure;
	COLORREF colour;
	BOOL  isDraw;
};

DrawStruct drawStruct;
COPYDATASTRUCT copyDataStruct;
HRESULT hResult;

// Forward declarations of functions included in this code module:
ATOM				MyRegisterClass(HINSTANCE hInstance);
BOOL				InitInstance(HINSTANCE, int);
LRESULT CALLBACK	WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK	About(HWND, UINT, WPARAM, LPARAM);

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
	LoadString(hInstance, IDC_LAB1, szWindowClass, MAX_LOADSTRING);
	MyRegisterClass(hInstance);

	// Perform application initialization:
	if (!InitInstance (hInstance, nCmdShow))
	{
		return FALSE;
	}

	hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_LAB1));

	// Main message loop:
	while (GetMessage(&msg, NULL, 0, 0))
	{
		if (!TranslateAccelerator(msg.hwnd, hAccelTable, &msg))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}

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
	wcex.hIcon			= LoadIcon(hInstance, MAKEINTRESOURCE(IDI_LAB1));
	wcex.hCursor		= LoadCursor(NULL, IDC_ARROW);
	wcex.hbrBackground	= (HBRUSH)(COLOR_WINDOW+1);
	wcex.lpszMenuName	= MAKEINTRESOURCE(IDC_LAB1);
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

   hWndRadioBtnRed = CreateWindow(L"Button", L"Red", WS_VISIBLE | WS_CHILD | BS_AUTORADIOBUTTON | WS_GROUP, 10, 10, 80, 30,
	   hWnd, HMENU(IdRadioBtnRed), hInst, NULL);
   hWndRadioBtnGreen = CreateWindow(L"Button", L"Green", WS_VISIBLE | WS_CHILD | BS_AUTORADIOBUTTON, 10, 40, 80, 30,
	   hWnd, HMENU(IdRadioBtnGreen), hInst, NULL);
   hWndRadioBtnBlue = CreateWindow(L"Button", L"Blue", WS_VISIBLE | WS_CHILD | BS_AUTORADIOBUTTON, 10, 70, 80, 30,
	   hWnd, HMENU(IdRadioBtnBlue), hInst, NULL);

   hWndRadioBtnRhombus = CreateWindow(L"Button", L"Rhombus", WS_VISIBLE | WS_CHILD | BS_AUTORADIOBUTTON | WS_GROUP,
	   100, 10, 80, 30, hWnd, HMENU(IdRadioBtnRhombus), hInst, NULL);
   hWndRadioBtnSquare = CreateWindow(L"Button", L"Square", WS_VISIBLE | WS_CHILD | BS_AUTORADIOBUTTON, 100, 40, 80, 30,
	   hWnd, HMENU(IdRadioBtnSquare), hInst, NULL);
   hWndRadioBtnCircle = CreateWindow(L"Button", L"Circle", WS_VISIBLE | WS_CHILD | BS_AUTORADIOBUTTON, 100, 70, 80, 30,
	   hWnd, HMENU(IdRadioBtnCircle), hInst, NULL);
   hWndRadioBtnStar = CreateWindow(L"Button", L"Star", WS_VISIBLE | WS_CHILD | BS_AUTORADIOBUTTON, 100, 100, 80, 30,
	   hWnd, HMENU(IdRadioBtnStar), hInst, NULL);

   hWndCheckBox = CreateWindow(L"Button", L"Draw", WS_VISIBLE | WS_CHILD | BS_AUTOCHECKBOX, 200, 10, 70, 20,
	   hWnd, HMENU(IdCheckBox), hInst, NULL);

   drawStruct.isDraw = false;

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
		case IdCheckBox:
			drawStruct.isDraw = !(drawStruct.isDraw);
			SendMessage(hWnd, WM_CTRL_CHANGE, 0, 0);
			break;
		case IdRadioBtnBlue:
			drawStruct.colour = RGB(0, 0, 255);
			SendMessage(hWnd, WM_CTRL_CHANGE, 0, 0);
			break;
		case IdRadioBtnGreen:
			drawStruct.colour = RGB(0, 255, 0);
			SendMessage(hWnd, WM_CTRL_CHANGE, 0, 0);
			break;
		case IdRadioBtnRed:
			drawStruct.colour = RGB(255, 0, 0);
			SendMessage(hWnd, WM_CTRL_CHANGE, 0, 0);
			break;
		case IdRadioBtnCircle:
			drawStruct.figure = IdRadioBtnCircle;
			SendMessage(hWnd, WM_CTRL_CHANGE, 0, 0);
			break;
		case IdRadioBtnRhombus:
			drawStruct.figure = IdRadioBtnRhombus;
			SendMessage(hWnd, WM_CTRL_CHANGE, 0, 0);
			break;
		case IdRadioBtnSquare:
			drawStruct.figure = IdRadioBtnSquare;
			SendMessage(hWnd, WM_CTRL_CHANGE, 0, 0);
			break;
		case IdRadioBtnStar:
			drawStruct.figure = IdRadioBtnStar;
			SendMessage(hWnd, WM_CTRL_CHANGE, 0, 0);
			break;
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
	case WM_CTRL_CHANGE:
		//
		// Fill the COPYDATA structure
		// 
		copyDataStruct.dwData = DRAWSTRUCT;         // function identifier
		copyDataStruct.cbData = sizeof(drawStruct);  // size of data
		copyDataStruct.lpData = &drawStruct;           // data structure
		//
		// Call function, passing data in &MyCDS
		//
		hwDispatch = FindWindow(L"Lab1_1", L"Lab1_1");
		if (hwDispatch != NULL)
			SendMessage(hwDispatch, WM_COPYDATA, (WPARAM)(HWND)hWnd, (LPARAM)(LPVOID)&copyDataStruct);
		else
			MessageBox(hWnd, L"Can't send WM_COPYDATA", L"lab1", MB_OK);
		break;
	case WM_PAINT:
		hdc = BeginPaint(hWnd, &ps);
		// TODO: Add any drawing code here...
		EndPaint(hWnd, &ps);
		break;
	case WM_DESTROY:
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
