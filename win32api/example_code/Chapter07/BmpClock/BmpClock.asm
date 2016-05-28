;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; BmpClock.asm
; һ��Բ�δ���ʱ�����ӣ�ʹ�� GDI �������л滭
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff BmpClock.asm
; rc BmpClock.rc
; Link /subsystem:windows BmpClock.obj BmpClock.res
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.386
		.model flat, stdcall
		option casemap :none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include �ļ�����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
include		Gdi32.inc
includelib	Gdi32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equ ��ֵ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
CLOCK_SIZE	equ	150
ICO_MAIN	equ	100
IDC_MAIN	equ	100
IDC_MOVE	equ	101
IDB_BACK1	equ	100
IDB_CIRCLE1	equ	101
IDB_MASK1	equ	102
IDB_BACK2	equ	103
IDB_CIRCLE2	equ	104
IDB_MASK2	equ	105
ID_TIMER	equ	1
IDM_BACK1	equ	100
IDM_BACK2	equ	101
IDM_CIRCLE1	equ	102
IDM_CIRCLE2	equ	103
IDM_EXIT	equ	104
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?

hInstance	dd		?
hWinMain	dd		?
hCursorMove	dd		?	;Cursor when move
hCursorMain	dd		?	;Cursor when normal
hMenu		dd		?

hBmpBack	dd		?
hDcBack		dd		?
hBmpClock	dd		?
hDcClock	dd		?

dwNowBack	dd		?
dwNowCircle	dd		?
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const

szClassName	db	'Clock',0
dwPara180	dw	180
dwRadius	dw	CLOCK_SIZE/2
szMenuBack1	db	'ʹ�ø��ӱ���(&A)',0
szMenuBack2	db	'ʹ�û�������(&B)',0
szMenuCircle1	db	'ʹ�õ���ɫ�߿�(&C)',0
szMenuCircle2	db	'ʹ�÷ۺ�ɫ�߿�(&D)',0
szMenuExit	db	'�˳�(&X)...',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ����ʱ��Բ����ĳ���Ƕȶ�Ӧ�� X ����
; X = Բ��X + Sin(�Ƕ�) * �뾶
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_CalcX		proc	_dwDegree,_dwRadius
		local	@dwReturn

		fild	dwRadius
		fild	_dwDegree
		fldpi
		fmul			;�Ƕ�*Pi
		fild	dwPara180
		fdivp	st(1),st	;�Ƕ�*Pi/180
		fsin			;Sin(�Ƕ�*Pi/180)
		fild	_dwRadius
		fmul			;�뾶*Sin(�Ƕ�*Pi/180)
		fadd			;X+�뾶*Sin(�Ƕ�*Pi/180)
		fistp	@dwReturn
		mov	eax,@dwReturn
		ret

_CalcX		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ����ʱ��Բ����ĳ���Ƕȶ�Ӧ�� Y ����
; Y = Բ��Y - Cos(�Ƕ�) * �뾶
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_CalcY		proc	_dwDegree,_dwRadius
		local	@dwReturn

		fild	dwRadius
		fild	_dwDegree
		fldpi
		fmul
		fild	dwPara180
		fdivp	st(1),st
		fcos
		fild	_dwRadius
		fmul
		fsubp	st(1),st
		fistp	@dwReturn
		mov	eax,@dwReturn
		ret

_CalcY		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �� _dwDegree �Ƕȵ��������뾶=_dwRadius
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_DrawLine	proc	_hDC,_dwDegree,_dwRadius
		local	@dwX1,@dwY1,@dwX2,@dwY2

		invoke	_CalcX,_dwDegree,_dwRadius
		mov	@dwX1,eax
		invoke	_CalcY,_dwDegree,_dwRadius
		mov	@dwY1,eax
		add	_dwDegree,180
		invoke	_CalcX,_dwDegree,10
		mov	@dwX2,eax
		invoke	_CalcY,_dwDegree,10
		mov	@dwY2,eax
		invoke	MoveToEx,_hDC,@dwX1,@dwY1,NULL
		invoke	LineTo,_hDC,@dwX2,@dwY2
		ret

_DrawLine	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_CreateClockPic	proc
		local	@stTime:SYSTEMTIME

		pushad
		invoke	BitBlt,hDcClock,0,0,CLOCK_SIZE,CLOCK_SIZE,hDcBack,0,0,SRCCOPY
;********************************************************************
; ��ʱ��ָ��
;********************************************************************
		invoke	GetLocalTime,addr @stTime
		invoke	CreatePen,PS_SOLID,1,0
		invoke	SelectObject,hDcClock,eax
		invoke	DeleteObject,eax
		movzx	eax,@stTime.wSecond
		mov	ecx,360/60
		mul	ecx			;������� = �� * 360/60
		invoke	_DrawLine,hDcClock,eax,60
;********************************************************************
		invoke	CreatePen,PS_SOLID,2,0
		invoke	SelectObject,hDcClock,eax
		invoke	DeleteObject,eax
		movzx	eax,@stTime.wMinute
		mov	ecx,360/60
		mul	ecx			;������� = �� * 360/60
		invoke	_DrawLine,hDcClock,eax,55
;********************************************************************
		invoke	CreatePen,PS_SOLID,3,0
		invoke	SelectObject,hDcClock,eax
		invoke	DeleteObject,eax
		movzx	eax,@stTime.wHour
		.if	eax >=	12
			sub	eax,12
		.endif
		mov	ecx,360/12
		mul	ecx
		movzx	ecx,@stTime.wMinute
		shr	ecx,1
		add	eax,ecx
		invoke	_DrawLine,hDcClock,eax,50
;********************************************************************
		invoke	GetStockObject,NULL_PEN
		invoke	SelectObject,hDcClock,eax
		invoke	DeleteObject,eax
		popad
		ret

_CreateClockPic	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_CreateBackGround	proc
			local	@hDc,@hDcCircle,@hDcMask
			local	@hBmpBack,@hBmpCircle,@hBmpMask

;********************************************************************
; ������Ҫ����ʱ����
;********************************************************************
		invoke	GetDC,hWinMain
		mov	@hDc,eax
		invoke	CreateCompatibleDC,@hDc
		mov	hDcBack,eax
		invoke	CreateCompatibleDC,@hDc
		mov	hDcClock,eax
		invoke	CreateCompatibleDC,@hDc
		mov	@hDcCircle,eax
		invoke	CreateCompatibleDC,@hDc
		mov	@hDcMask,eax
		invoke	CreateCompatibleBitmap,@hDc,CLOCK_SIZE,CLOCK_SIZE
		mov	hBmpBack,eax
		invoke	CreateCompatibleBitmap,@hDc,CLOCK_SIZE,CLOCK_SIZE
		mov	hBmpClock,eax
		invoke	ReleaseDC,hWinMain,@hDc

		invoke	LoadBitmap,hInstance,dwNowBack
		mov	@hBmpBack,eax
		invoke	LoadBitmap,hInstance,dwNowCircle
		mov	@hBmpCircle,eax
		mov	eax,dwNowCircle
		inc	eax
		invoke	LoadBitmap,hInstance,eax
		mov	@hBmpMask,eax

		invoke	SelectObject,hDcBack,hBmpBack
		invoke	SelectObject,hDcClock,hBmpClock
		invoke	SelectObject,@hDcCircle,@hBmpCircle
		invoke	SelectObject,@hDcMask,@hBmpMask
;********************************************************************
; �Ա���ͼƬ���
;********************************************************************
		invoke	CreatePatternBrush,@hBmpBack
		push	eax
		invoke	SelectObject,hDcBack,eax
		invoke	PatBlt,hDcBack,0,0,CLOCK_SIZE,CLOCK_SIZE,PATCOPY
		pop	eax
		invoke	DeleteObject,eax
;********************************************************************
; ��������
;********************************************************************
		invoke	BitBlt,hDcBack,0,0,CLOCK_SIZE,CLOCK_SIZE,@hDcMask,0,0,SRCAND
		invoke	BitBlt,hDcBack,0,0,CLOCK_SIZE,CLOCK_SIZE,@hDcCircle,0,0,SRCPAINT

		invoke	DeleteDC,@hDcCircle
		invoke	DeleteDC,@hDcMask
		invoke	DeleteObject,@hBmpBack
		invoke	DeleteObject,@hBmpCircle
		invoke	DeleteObject,@hBmpMask
		ret

_CreateBackGround	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_DeleteBackGround	proc

		invoke	DeleteDC,hDcBack
		invoke	DeleteDC,hDcClock
		invoke	DeleteObject,hBmpBack
		invoke	DeleteObject,hBmpClock
		ret

_DeleteBackGround	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Init		proc
		local	@hBmpBack,@hBmpCircle

;********************************************************************
; ��ʼ���˵�
;********************************************************************
		invoke	CreatePopupMenu
		mov	hMenu,eax
		invoke	AppendMenu,hMenu,0,IDM_BACK1,offset szMenuBack1
		invoke	AppendMenu,hMenu,0,IDM_BACK2,offset szMenuBack2
		invoke	AppendMenu,hMenu,MF_SEPARATOR,0,NULL
		invoke	AppendMenu,hMenu,0,IDM_CIRCLE1,offset szMenuCircle1
		invoke	AppendMenu,hMenu,0,IDM_CIRCLE2,offset szMenuCircle2
		invoke	AppendMenu,hMenu,MF_SEPARATOR,0,NULL
		invoke	AppendMenu,hMenu,0,IDM_EXIT,offset szMenuExit
		invoke	CheckMenuRadioItem,hMenu,IDM_BACK1,IDM_BACK2,IDM_BACK1,NULL
		invoke	CheckMenuRadioItem,hMenu,IDM_CIRCLE1,IDM_CIRCLE2,IDM_CIRCLE1,NULL
;********************************************************************
; ����Բ�δ��ڲ����á�������ǰ�桱
;********************************************************************
		invoke	CreateEllipticRgn,0,0,CLOCK_SIZE+1,CLOCK_SIZE+1
		push	eax
		invoke	SetWindowRgn,hWinMain,eax,TRUE
		pop	eax
		invoke	DeleteObject,eax
		invoke	SetWindowPos,hWinMain,HWND_TOPMOST,0,0,0,0,\
			SWP_NOMOVE or SWP_NOSIZE
;********************************************************************
; ��������
;********************************************************************
		mov	dwNowBack,IDB_BACK1
		mov	dwNowCircle,IDB_CIRCLE1
		invoke	_CreateBackGround
		invoke	_CreateClockPic
		invoke	SetTimer,hWinMain,ID_TIMER,1000,NULL

		ret

_Init		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Quit		proc

		invoke	KillTimer,hWinMain,ID_TIMER
		invoke	DestroyWindow,hWinMain
		invoke	PostQuitMessage,NULL
		invoke	_DeleteBackGround
		invoke	DestroyMenu,hMenu
		ret

_Quit		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcWinMain	proc	uses ebx edi esi hWnd,uMsg,wParam,lParam
		local	@stPS:PAINTSTRUCT
		local	@hDC
		local	@stPos:POINT

		mov	eax,uMsg
;********************************************************************
		.if	eax ==	WM_TIMER
			invoke	_CreateClockPic
			invoke	InvalidateRect,hWnd,NULL,FALSE
;********************************************************************
		.elseif	eax ==	WM_PAINT
			invoke	BeginPaint,hWnd,addr @stPS
			mov	@hDC,eax

			mov	eax,@stPS.rcPaint.right
			sub	eax,@stPS.rcPaint.left
			mov	ecx,@stPS.rcPaint.bottom
			sub	ecx,@stPS.rcPaint.top

			invoke	BitBlt,@hDC,@stPS.rcPaint.left,@stPS.rcPaint.top,eax,ecx,\
				hDcClock,@stPS.rcPaint.left,@stPS.rcPaint.top,SRCCOPY
			invoke	EndPaint,hWnd,addr @stPS
;********************************************************************
		.elseif	eax ==	WM_CREATE
			mov	eax,hWnd
			mov	hWinMain,eax
			invoke	_Init
;********************************************************************
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
			.if	ax ==	IDM_BACK1
				mov	dwNowBack,IDB_BACK1
				invoke	CheckMenuRadioItem,hMenu,IDM_BACK1,IDM_BACK2,IDM_BACK1,NULL
			.elseif	ax ==	IDM_BACK2
				mov	dwNowBack,IDB_BACK2
				invoke	CheckMenuRadioItem,hMenu,IDM_BACK1,IDM_BACK2,IDM_BACK2,NULL
			.elseif	ax ==	IDM_CIRCLE1
				mov	dwNowCircle,IDB_CIRCLE1
				invoke	CheckMenuRadioItem,hMenu,IDM_CIRCLE1,IDM_CIRCLE2,IDM_CIRCLE1,NULL
			.elseif	ax ==	IDM_CIRCLE2
				mov	dwNowCircle,IDB_CIRCLE2
				invoke	CheckMenuRadioItem,hMenu,IDM_CIRCLE1,IDM_CIRCLE2,IDM_CIRCLE2,NULL
			.elseif	ax ==	IDM_EXIT
				call	_Quit
				xor	eax,eax
				ret
			.endif
			invoke	_DeleteBackGround
			invoke	_CreateBackGround
			invoke	_CreateClockPic
			invoke	InvalidateRect,hWnd,NULL,FALSE
;********************************************************************
		.elseif	eax ==	WM_CLOSE
			call	_Quit
;********************************************************************
; �����Ҽ�ʱ����һ��POPUP�˵�
;********************************************************************
		.elseif eax == WM_RBUTTONDOWN
			invoke	GetCursorPos,addr @stPos
			invoke	TrackPopupMenu,hMenu,TPM_LEFTALIGN,@stPos.x,@stPos.y,NULL,hWnd,NULL
;********************************************************************
; ����û�б�����������������ڰ������ʱ�ƶ�����
; UpdateWindow����ʱˢ�£�����Ҫ�ȵ��ſ����ʱ���ڲŻ��ػ�
;********************************************************************
		.elseif eax ==	WM_LBUTTONDOWN
			invoke	SetCursor,hCursorMove
			invoke	UpdateWindow,hWnd
			invoke	ReleaseCapture
			invoke	SendMessage,hWnd,WM_NCLBUTTONDOWN,HTCAPTION,0
			invoke	SetCursor,hCursorMain
;********************************************************************
		.else
			invoke	DefWindowProc,hWnd,uMsg,wParam,lParam
			ret
		.endif
;********************************************************************
		xor	eax,eax
		ret

_ProcWinMain	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_WinMain	proc
		local	@stWndClass:WNDCLASSEX
		local	@stMsg:MSG

		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		invoke	LoadCursor,hInstance,IDC_MOVE
		mov	hCursorMove,eax
		invoke	LoadCursor,hInstance,IDC_MAIN
		mov	hCursorMain,eax
;********************************************************************
; ע�ᴰ����
;********************************************************************
		invoke	RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
		invoke	LoadIcon,hInstance,ICO_MAIN
		mov	@stWndClass.hIcon,eax
		mov	@stWndClass.hIconSm,eax
		push	hCursorMain
		pop	@stWndClass.hCursor
		push	hInstance
		pop	@stWndClass.hInstance
		mov	@stWndClass.cbSize,sizeof WNDCLASSEX
		mov	@stWndClass.style,CS_HREDRAW or CS_VREDRAW
		mov	@stWndClass.lpfnWndProc,offset _ProcWinMain
		mov	@stWndClass.hbrBackground,COLOR_WINDOW + 1
		mov	@stWndClass.lpszClassName,offset szClassName
		invoke	RegisterClassEx,addr @stWndClass
;********************************************************************
; ��������ʾ����
;********************************************************************
		invoke	CreateWindowEx,NULL,\
			offset szClassName,offset szClassName,\
			WS_POPUP or WS_SYSMENU,\
			100,100,CLOCK_SIZE,CLOCK_SIZE,\
			NULL,NULL,hInstance,NULL
		mov	hWinMain,eax
		invoke	ShowWindow,hWinMain,SW_SHOWNORMAL
		invoke	UpdateWindow,hWinMain
;********************************************************************
; ��Ϣѭ��
;********************************************************************
		.while	TRUE
			invoke	GetMessage,addr @stMsg,NULL,0,0
			.break	.if eax	== 0
			invoke	TranslateMessage,addr @stMsg
			invoke	DispatchMessage,addr @stMsg
		.endw
		ret

_WinMain	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		call	_WinMain
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
