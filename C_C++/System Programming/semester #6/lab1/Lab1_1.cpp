// Lab1_1.cpp : Defines the entry point for the application.
//

#include "stdafx.h"
#include "Lab1_1.h"
#include <windowsx.h>

#define MAX_LOADSTRING 100
#define IdRadioBtnRhombus	4
#define IdRadioBtnSquare	5
#define IdRadioBtnCircle	6
#define IdRadioBtnStar		7

#define IdCheckBox			8

#define DRAWSTRUCT			9

struct DrawStruct
{
	UINT figure;
	COLORREF colour;
	BOOL  isDraw;
};

// Global Variables:
HINSTANCE hInst;								// current instance
TCHAR szTitle[MAX_LOADSTRING];					// The title bar text
TCHAR szWindowClass[MAX_LOADSTRING];			// the main window class name

// Forward declarations of functions included in this code module:
ATOM				MyRegisterClass(HINSTANCE hInstance);
BOOL				InitInstance(HINSTANCE, int);
LRESULT CALLBACK	WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK	About(HWND, UINT, WPARAM, LPARAM);

void DrawSquare(HWND &hWnd, UINT xCenter, UINT yCenter, COLORREF color);
void DrawCircle(HWND &hWnd, UINT xCenter, UINT yCenter, COLORREF color);
void DrawRhombus(HWND &hWnd, UINT xCenter, UINT yCenter, COLORREF color);
void DrawStar(HWND &hWnd, UINT xCenter, UINT yCenter, COLORREF color);

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
	LoadString(hInstance, IDC_LAB1_1, szWindowClass, MAX_LOADSTRING);
	MyRegisterClass(hInstance);

	// Perform application initialization:
	if (!InitInstance (hInstance, nCmdShow))
	{
		return FALSE;
	}

	hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_LAB1_1));

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
	wcex.hIcon			= LoadIcon(hInstance, MAKEINTRESOURCE(IDI_LAB1_1));
	wcex.hCursor		= LoadCursor(NULL, IDC_ARROW);
	wcex.hbrBackground	= (HBRUSH)(COLOR_WINDOW+1);
	wcex.lpszMenuName	= MAKEINTRESOURCE(IDC_LAB1_1);
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

	UINT xPos, yPos;
	static DrawStruct drawStruct;
	PCOPYDATASTRUCT copyDataStruct;
	HWND hwDispatch;

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
	case WM_LBUTTONDOWN:
		hwDispatch = FindWindow(L"lab1", L"lab1");
		if (hwDispatch)
		{
			xPos = GET_X_LPARAM(lParam);
			yPos = GET_Y_LPARAM(lParam);
			if (drawStruct.isDraw)
			{
				switch (drawStruct.figure)
				{
				case IdRadioBtnRhombus:
					DrawRhombus(hWnd, xPos, yPos, drawStruct.colour);
					break;
				case IdRadioBtnSquare:
					DrawSquare(hWnd, xPos, yPos, drawStruct.colour);
					break;
				case IdRadioBtnCircle:
					DrawCircle(hWnd, xPos, yPos, drawStruct.colour);
					break;
				case IdRadioBtnStar:
					DrawStar(hWnd, xPos, yPos, drawStruct.colour);
					break;
				}
			}
		}
		else
		{
			MessageBox(hWnd,
				_T("Can't load data"),
				szTitle,
				MB_OK);
		}
		break;
	case WM_COPYDATA:
		copyDataStruct = (PCOPYDATASTRUCT)lParam;
		if (copyDataStruct->dwData == DRAWSTRUCT)
		{
			drawStruct.figure = (UINT)((DrawStruct *)(copyDataStruct->lpData))->figure;
			drawStruct.colour = (COLORREF)((DrawStruct *)(copyDataStruct->lpData))->colour;
			drawStruct.isDraw = (BOOL)((DrawStruct *)(copyDataStruct->lpData))->isDraw;
		}
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

void DrawSquare(HWND &hWnd, UINT xCenter, UINT yCenter, COLORREF color)
{
	HPEN hPen;
	HBRUSH hBrush;
	HDC hdc;
	UINT side = 100;

	hdc = GetDC(hWnd);

	hPen = CreatePen(PS_SOLID, 1, color);
	hBrush = CreateSolidBrush(color);

	SelectObject(hdc, hPen);
	SelectObject(hdc, hBrush);

	Rectangle(hdc, (xCenter - side / 2), (yCenter - side / 2), (xCenter + side / 2), (yCenter + side / 2));

	DeleteObject(hPen);
	DeleteObject(hBrush);

	ReleaseDC(hWnd, hdc);
}

void DrawCircle(HWND &hWnd, UINT xCenter, UINT yCenter, COLORREF color)
{
	HPEN hPen;
	HBRUSH hBrush;
	HDC hdc;
	UINT radius = 50;

	hdc = GetDC(hWnd);

	hPen = CreatePen(PS_SOLID, 1, color);
	hBrush = CreateSolidBrush(color);

	SelectObject(hdc, hPen);
	SelectObject(hdc, hBrush);

	Ellipse(hdc, (xCenter - radius), (yCenter - radius), (xCenter + radius), (yCenter + radius));

	DeleteObject(hPen);
	DeleteObject(hBrush);

	ReleaseDC(hWnd, hdc);
}

void DrawRhombus(HWND &hWnd, UINT xCenter, UINT yCenter, COLORREF color)
{
	HPEN hPen;
	HBRUSH hBrush;
	HDC hdc;
	UINT hDiag = 100;
	UINT vDiag = 100;

	POINT pt[5] = {
		(xCenter - hDiag / 2), yCenter,
		xCenter, (yCenter - vDiag / 2),
		(xCenter + hDiag / 2), yCenter,
		xCenter, (yCenter + vDiag / 2),
		(xCenter - hDiag / 2), yCenter
	};

	hdc = GetDC(hWnd);

	hPen = CreatePen(PS_SOLID, 1, color);
	hBrush = CreateSolidBrush(color);

	SelectObject(hdc, hPen);
	SelectObject(hdc, hBrush);

	Polygon(hdc, pt, 5);

	DeleteObject(hPen);
	DeleteObject(hBrush);

	ReleaseDC(hWnd, hdc);
}

void DrawStar(HWND &hWnd, UINT xCenter, UINT yCenter, COLORREF color)
{
	HPEN hPen;
	HBRUSH hBrush;
	HDC hdc;
	UINT diag = 100;

	POINT pt[9] = {
		(xCenter - diag / 2), yCenter,
		(xCenter - diag / 8), (yCenter - diag / 8),
		xCenter, (yCenter - diag / 2),
		(xCenter + diag / 8), (yCenter - diag / 8),
		(xCenter + diag / 2), yCenter,
		(xCenter + diag / 8), (yCenter + diag / 8),
		xCenter, (yCenter + diag / 2),
		(xCenter - diag / 8), (yCenter + diag / 8),
		(xCenter - diag / 2), yCenter
	};

	hdc = GetDC(hWnd);

	hPen = CreatePen(PS_SOLID, 1, color);
	hBrush = CreateSolidBrush(color);

	SelectObject(hdc, hPen);
	SelectObject(hdc, hBrush);

	Polygon(hdc, pt, 9);

	DeleteObject(hPen);
	DeleteObject(hBrush);

	ReleaseDC(hWnd, hdc);
}