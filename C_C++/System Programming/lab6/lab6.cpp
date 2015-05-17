// lab6.cpp : Defines the entry point for the application.
//

#include "stdafx.h"
#include "lab6.h"
#include <CommCtrl.h>
#include <windows.h>
#include <stdio.h>
#include <tchar.h>
#include <Shlwapi.h>

#define MAX_LOADSTRING 100
#define ID_COMBOBOX 11
#define ID_LISTBOX 12
#define ID_EDIT 13
#define ID_BUTTON 14
#define MAX_KEY_LENGTH 255
#define MAX_VALUE_NAME 16383

// Global Variables:
HINSTANCE hInst;								// current instance
TCHAR szTitle[MAX_LOADSTRING];					// The title bar text
TCHAR szWindowClass[MAX_LOADSTRING];			// the main window class name
HWND hWndComboBox, hWndListBox, hWndEdit, hWndButton;
int ItemIndex;

// Forward declarations of functions included in this code module:
ATOM				MyRegisterClass(HINSTANCE hInstance);
BOOL				InitInstance(HINSTANCE, int);
LRESULT CALLBACK	WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK	About(HWND, UINT, WPARAM, LPARAM);
void				InitializeComboBoxWithKeys();
bool				IsSpace(TCHAR string[MAX_LOADSTRING]);
void				SearchKeys(HKEY root, LPWSTR subkey, HWND hwnd, wchar_t* buff);

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
	LoadString(hInstance, IDC_LAB6, szWindowClass, MAX_LOADSTRING);
	MyRegisterClass(hInstance);

	// Perform application initialization:
	if (!InitInstance (hInstance, nCmdShow))
	{
		return FALSE;
	}

	hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_LAB6));

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
	wcex.hIcon			= LoadIcon(hInstance, MAKEINTRESOURCE(IDI_LAB6));
	wcex.hCursor		= LoadCursor(NULL, IDC_ARROW);
	wcex.hbrBackground	= (HBRUSH)(COLOR_WINDOW+1);
	wcex.lpszMenuName	= MAKEINTRESOURCE(IDC_LAB6);
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
      50, 50, 1200, 650, NULL, NULL, hInstance, NULL);

   if (!hWnd)
   {
      return FALSE;
   }

   hWndComboBox = CreateWindow(WC_COMBOBOX, NULL, CBS_DROPDOWN | CBS_HASSTRINGS | WS_CHILD | WS_OVERLAPPED | WS_VISIBLE,
	   20, 20, 300, 200, hWnd, (HMENU)ID_COMBOBOX, hInstance, NULL);
   InitializeComboBoxWithKeys();

   hWndListBox = CreateWindow(WC_LISTBOX, NULL, WS_CHILD | WS_VISIBLE | LBS_NOTIFY | WS_VSCROLL | WS_BORDER,
	   20, 50, 1100, 500, hWnd, (HMENU)ID_LISTBOX, hInstance, NULL);

   hWndEdit = CreateWindow(WC_EDIT, NULL, WS_CHILD | WS_VISIBLE | WS_BORDER | ES_CENTER | ES_AUTOHSCROLL,
	   350, 20, 600, 20, hWnd, (HMENU)ID_EDIT, hInstance, NULL);

   hWndButton = CreateWindow(WC_BUTTON, L"Search", WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
	   970, 20, 150, 20, hWnd, (HMENU)ID_BUTTON, hInstance, NULL);
   
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
	TCHAR buff[MAX_LOADSTRING];
	bool isSpace;
	
	TCHAR  ListItem[256];

	switch (message)
	{
	case WM_COMMAND:
		wmId    = LOWORD(wParam);
		wmEvent = HIWORD(wParam);
		// Parse the menu selections:
		if (wmEvent == CBN_SELCHANGE)
			// If the user makes a selection from the list:
			//   Send CB_GETCURSEL message to get the index of the selected list item.
			//   Send CB_GETLBTEXT message to get the item.
			//   Display the item in a messagebox.
		{
			ItemIndex = SendMessage((HWND)lParam, (UINT)CB_GETCURSEL,
				(WPARAM)0, (LPARAM)0);
		}
		switch (wmId)
		{
		case IDM_ABOUT:
			DialogBox(hInst, MAKEINTRESOURCE(IDD_ABOUTBOX), hWnd, About);
			break;
		case IDM_EXIT:
			DestroyWindow(hWnd);
			break;
		case ID_BUTTON:
			if (wmEvent == BN_CLICKED)
			{
				GetWindowText(hWndEdit, (LPWSTR)buff, MAX_LOADSTRING);
				isSpace = IsSpace(buff);
				if (!isSpace)
				{
					SendMessage(hWndListBox, LB_RESETCONTENT, (WPARAM)0, (LPARAM)0);
					switch (ItemIndex)
					{
					case 0:
						SearchKeys(HKEY_CURRENT_USER, L"", NULL, buff);
						break;
					case 1:
						SearchKeys(HKEY_CLASSES_ROOT, L"", NULL, buff);
						break;
					case 2:
						SearchKeys(HKEY_LOCAL_MACHINE, L"", NULL, buff);
						break;
					case 3:
						SearchKeys(HKEY_USERS, L"", NULL, buff);
						break;
					case 4:
						SearchKeys(HKEY_CURRENT_CONFIG, L"", NULL, buff);
						break;
					default:
						break;
					}
				}
			}
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

void InitializeComboBoxWithKeys()
{
	// load the combobox with item list.  
	// Send a CB_ADDSTRING message to load each item

	TCHAR Planets[5][20] =
	{
		L"HKEY_CURRENT_USER", L"HKEY_CLASSES_ROOT",
		L"HKEY_LOCAL_MACHINE", L"HKEY_USERS", L"HKEY_CURRENT_CONFIG"
	};

	TCHAR A[32];
	int  k = 0;

	memset(&A, 0, sizeof(A));
	for (k = 0; k <= 4; k += 1)
	{
		wcscpy_s(A, sizeof(A) / sizeof(TCHAR), (TCHAR*)Planets[k]);

		// Add string to combobox.
		SendMessage(hWndComboBox, (UINT)CB_ADDSTRING, (WPARAM)0, (LPARAM)A);
	}

	// Send the CB_SETCURSEL message to display an initial item 
	//  in the selection field  
	SendMessage(hWndComboBox, CB_SETCURSEL, (WPARAM)0, (LPARAM)0);
}

bool IsSpace(TCHAR string[MAX_LOADSTRING])
{
	int i;
	bool isSpace = false;
	for (i = 0; i < _tcslen(string); i++)
	{
		if (isspace(string[i]))
		{
			isSpace = true;
		}
		else
		{
			break;
		}
	}
	return isSpace = (i == _tcslen(string)) ? true : false;
}


void SearchKeys(HKEY root, LPWSTR subkey, HWND hwnd, wchar_t* buff)
{
	HKEY key;
	int resultCode = RegOpenKeyEx(root, subkey, 0, KEY_QUERY_VALUE | KEY_ENUMERATE_SUB_KEYS, &key);
	if (resultCode != 0)
		return;

	int index = 0;
	char name[1024];
	while (RegEnumKey(key, index++, (LPWSTR)name, 1024) != ERROR_NO_MORE_ITEMS)
	{
		if (lstrlen(subkey) == 0)
			SearchKeys(root, (LPWSTR)name, hwnd, buff);
		else
		{
			char path[1024];
			swprintf((LPWSTR)path, L"%s\\%s", subkey, name);
			SearchKeys(root, (LPWSTR)path, hwnd, buff);
		}
	}
	index = 0;
	int type, size = 1024;
	wchar_t data[1024];
	int namesize = 1024;
	while (RegEnumValue(key, index++, (LPWSTR)name, (LPDWORD)&namesize, 0, (LPDWORD)&type, (LPBYTE)data, (LPDWORD)&size) == 0)
	{
		if (wcsstr(data, buff) != NULL)
		{
			SendMessage(hWndListBox, LB_ADDSTRING, (WPARAM)0, (LPARAM)subkey);
			SendMessage(hWndListBox, LB_ADDSTRING, (WPARAM)0, (LPARAM)name);
			SendMessage(hWndListBox, LB_ADDSTRING, (WPARAM)0, (LPARAM)data);
			SendMessage(hWndListBox, LB_ADDSTRING, (WPARAM)0, (LPARAM)L"");
		}
		namesize = size = 1024;
	}
	RegCloseKey(key);
}