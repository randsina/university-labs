// lab5.cpp : Defines the entry point for the application.
//

#include "stdafx.h"
#include "lab5.h"
#include <tlhelp32.h>

#define MAX_LOADSTRING 100
#define ID_LISTBOX_1 11
#define ID_LISTBOX_2 12
#define ID_MENU_REALTIME 13
#define ID_MENU_HIGH 14
#define ID_MENU_ABOVENORMAL 15
#define ID_MENU_NORMAL 16
#define ID_MENU_BELOWNORMAL 17
#define ID_MENU_IDLE 18

// Global Variables:
HINSTANCE hInst;								// current instance
TCHAR szTitle[MAX_LOADSTRING];					// The title bar text
TCHAR szWindowClass[MAX_LOADSTRING];			// the main window class name
HWND hListBox1, hListBox2;
char text[1024];
HANDLE hProcess;
DWORD dwPriorityClass;

// Forward declarations of functions included in this code module:
ATOM				MyRegisterClass(HINSTANCE hInstance);
BOOL				InitInstance(HINSTANCE, int);
LRESULT CALLBACK	WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK	About(HWND, UINT, WPARAM, LPARAM);
void EnumerateProcesses();
void EnumerateModules(DWORD processID);
LPWSTR GetPriorityString(DWORD priorityClass);
void ChangeProcessPriority(DWORD priority);

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
	LoadString(hInstance, IDC_LAB5, szWindowClass, MAX_LOADSTRING);
	MyRegisterClass(hInstance);

	// Perform application initialization:
	if (!InitInstance (hInstance, nCmdShow))
	{
		return FALSE;
	}

	hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_LAB5));

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
	wcex.hIcon			= LoadIcon(hInstance, MAKEINTRESOURCE(IDI_LAB5));
	wcex.hCursor		= LoadCursor(NULL, IDC_ARROW);
	wcex.hbrBackground	= (HBRUSH)(COLOR_WINDOW+1);
	wcex.lpszMenuName	= MAKEINTRESOURCE(IDC_LAB5);
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

   hListBox1 = CreateWindow(L"ListBox", NULL, WS_CHILD | WS_VISIBLE | LBS_STANDARD,
	   10, 10, 400, 350, hWnd, (HMENU)ID_LISTBOX_1, hInstance, NULL);
   hListBox2 = CreateWindow(L"ListBox", NULL, WS_CHILD | WS_VISIBLE | LBS_STANDARD,
	   430, 10, 400, 350, hWnd, (HMENU)ID_LISTBOX_2, hInstance, NULL);

   EnumerateProcesses();

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
	int index;
	int pid;

	switch (message)
	{
	case WM_COMMAND:
		wmId    = LOWORD(wParam);
		wmEvent = HIWORD(wParam);
		// Parse the menu selections:
			index = SendMessage(hListBox1, LB_GETCURSEL, (WPARAM)0, (LPARAM)0);
			if (index != LB_ERR)
			{
				switch (wmId)
				{
				case ID_MENU_REALTIME:
					ChangeProcessPriority(REALTIME_PRIORITY_CLASS);
					break;
				case ID_MENU_HIGH:
					ChangeProcessPriority(HIGH_PRIORITY_CLASS);
					break;
				case ID_MENU_ABOVENORMAL:
					ChangeProcessPriority(ABOVE_NORMAL_PRIORITY_CLASS);
					break;
				case ID_MENU_NORMAL:
					ChangeProcessPriority(NORMAL_PRIORITY_CLASS);
					break;
				case ID_MENU_BELOWNORMAL:
					ChangeProcessPriority(BELOW_NORMAL_PRIORITY_CLASS);
					break;
				case ID_MENU_IDLE:
					ChangeProcessPriority(IDLE_PRIORITY_CLASS);
					break;
				case IDM_ABOUT:
					DialogBox(hInst, MAKEINTRESOURCE(IDD_ABOUTBOX), hWnd, About);
					break;
				case IDM_EXIT:
					DestroyWindow(hWnd);
					break;
				case ID_LISTBOX_1:
					if (wmEvent == LBN_SELCHANGE)
					{
						pid = SendMessage(hListBox1, LB_GETITEMDATA, index, 0);
						SendMessage(hListBox2, LB_RESETCONTENT, 0, 0);
						EnumerateModules(pid);
					}
					break;
				default:
					return DefWindowProc(hWnd, message, wParam, lParam);
				}
			}
		
		break;
	case WM_PAINT:
		hdc = BeginPaint(hWnd, &ps);
		// TODO: Add any drawing code here...
		EndPaint(hWnd, &ps);
		break;
	case WM_CONTEXTMENU:
		if ((HWND)wParam == hListBox1)
		{
			HMENU hContextMenu = CreatePopupMenu();
			InsertMenu(hContextMenu, 0, MF_BYCOMMAND | MF_STRING, ID_MENU_REALTIME, L"Realtime");
			InsertMenu(hContextMenu, 0, MF_BYCOMMAND | MF_STRING, ID_MENU_HIGH, L"High");
			InsertMenu(hContextMenu, 0, MF_BYCOMMAND | MF_STRING, ID_MENU_ABOVENORMAL, L"Above Normal");
			InsertMenu(hContextMenu, 0, MF_BYCOMMAND | MF_STRING, ID_MENU_NORMAL, L"Normal");
			InsertMenu(hContextMenu, 0, MF_BYCOMMAND | MF_STRING, ID_MENU_BELOWNORMAL, L"Below Normal");
			InsertMenu(hContextMenu, 0, MF_BYCOMMAND | MF_STRING, ID_MENU_IDLE, L"Idle");
			TrackPopupMenu(hContextMenu, TPM_TOPALIGN | TPM_LEFTALIGN, LOWORD(lParam), HIWORD(lParam), 0, hWnd, NULL);
		}
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


void EnumerateProcesses()
{
	HANDLE hSnap = NULL;
	PROCESSENTRY32 pe32;
	SendMessage(hListBox1, LB_RESETCONTENT, 0, 0);
	hSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
	if (hSnap != NULL)
	{
		pe32.dwSize = sizeof(pe32);
		if (Process32First(hSnap, &pe32))
		{
			do
			{
				dwPriorityClass = 0;
				hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, pe32.th32ProcessID);
				dwPriorityClass = GetPriorityClass(hProcess);
				wsprintf((wchar_t*)text, L"%s (%s)", pe32.szExeFile, GetPriorityString(dwPriorityClass));
				int index = SendMessage(hListBox1, LB_ADDSTRING, 0, (LPARAM)text);
				SendMessage(hListBox1, LB_SETITEMDATA, index, (LPARAM)pe32.th32ProcessID);
			} while (Process32Next(hSnap, &pe32));
		}
	}
	CloseHandle(hSnap);
}

LPWSTR GetPriorityString(DWORD priorityClass) 
{
	switch (priorityClass)
	{
	case IDLE_PRIORITY_CLASS:
		return L"IDLE";
	case BELOW_NORMAL_PRIORITY_CLASS:
		return L"BELOW NORMAL";
	case NORMAL_PRIORITY_CLASS:
		return L"NORMAL";
	case ABOVE_NORMAL_PRIORITY_CLASS:
		return L"ABOVE NORMAL";
	case HIGH_PRIORITY_CLASS:
		return L"HIGH";
	case REALTIME_PRIORITY_CLASS:
		return L"REALTIME";
	default:
		return L"UNKNOWN";
	}
}


void EnumerateModules(DWORD processID)
{
	HANDLE hModuleSnap;
	MODULEENTRY32 me32;

	hModuleSnap = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, processID);
	me32.dwSize = sizeof(MODULEENTRY32);

	Module32First(hModuleSnap, &me32);
	do
	{
		if (me32.th32ModuleID != (DWORD)1)
		{
			SendMessage(hListBox2, LB_ADDSTRING, 0, (LPARAM)L"You have no access!");
		}
		else
		{
			int idx = SendMessage(hListBox2, LB_ADDSTRING, 0, (LPARAM)me32.szModule);
			SendMessage(hListBox2, LB_SETITEMDATA, idx, (LPARAM)me32.szModule);
		}
	} while (Module32Next(hModuleSnap, &me32));

	CloseHandle(hModuleSnap);
}

void ChangeProcessPriority(DWORD priority)
{
	int index = SendMessage(hListBox1, LB_GETCURSEL, 0, 0);
	int processId = SendMessage(hListBox1, LB_GETITEMDATA, index, 0);

	HANDLE hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, processId);
	if (!SetPriorityClass(hProcess, priority))
		MessageBox(NULL, L"Can't change priority for selected process!", L"Something wrong", MB_ICONERROR);
	CloseHandle(hProcess);

	EnumerateProcesses();
}