;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; DcCopy.asm
; �����豸�����Ĵ��룬��һ������ DC ��Ӧ�����ؿ�������һ��������
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff DcCopy.asm
; Link /subsystem:windows DcCopy.obj
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.386
		.model flat,stdcall
		option casemap:none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include �ļ�����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		gdi32.inc
includelib	gdi32.lib
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ID_TIMER	equ	1
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd		?
hWin1		dd		?
hWin2		dd		?

		.const
szClass1	db	'SourceWindow',0
szClass2	db	'DestWindow',0
szCaption1	db	'�볢���ñ�Ĵ��ڸ��Ǳ����ڣ�',0
szCaption2	db	'������ͼ�񿽱�����һ����',0
szText		db	'Win32 Assembly, Simple and powerful !',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ��ʱ������
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcTimer	proc	_hWnd,uMsg,_idEvent,_dwTime
		local	@hDc1,@hDc2
		local	@stRect:RECT

		invoke	GetDC,hWin1
		mov	@hDc1,eax
		invoke	GetDC,hWin2
		mov	@hDc2,eax
		invoke	GetClientRect,hWin1,addr @stRect
		invoke	BitBlt,@hDc2,0,0,@stRect.right,@stRect.bottom,\
			@hDc1,0,0,SRCCOPY
		invoke	ReleaseDC,hWin1,@hDc1
		invoke	ReleaseDC,hWin2,@hDc2
		ret

_ProcTimer	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ڹ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcWinMain	proc	uses ebx edi esi,hWnd,uMsg,wParam,lParam
		local	@stPs:PAINTSTRUCT
		local	@stRect:RECT
		local	@hDc

		mov	eax,uMsg
		mov	ecx,hWnd
;********************************************************************
		.if	eax ==	WM_PAINT && ecx == hWin1
			invoke	BeginPaint,hWnd,addr @stPs
			mov	@hDc,eax
			invoke	GetClientRect,hWnd,addr @stRect
			invoke	DrawText,@hDc,addr szText,-1,\
				addr @stRect,\
				DT_SINGLELINE or DT_CENTER or DT_VCENTER
			invoke	EndPaint,hWnd,addr @stPs
;********************************************************************
		.elseif	eax ==	WM_CLOSE
			invoke	PostQuitMessage,NULL
			invoke	DestroyWindow,hWin1
			invoke	DestroyWindow,hWin2
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
		local	@hTimer

		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		invoke	RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
;********************************************************************
		invoke	LoadCursor,0,IDC_ARROW
		mov	@stWndClass.hCursor,eax
		push	hInstance
		pop	@stWndClass.hInstance
		mov	@stWndClass.cbSize,sizeof WNDCLASSEX
		mov	@stWndClass.style,CS_HREDRAW or CS_VREDRAW
		mov	@stWndClass.lpfnWndProc,offset _ProcWinMain
		mov	@stWndClass.hbrBackground,COLOR_WINDOW + 1
		mov	@stWndClass.lpszClassName,offset szClass1
		invoke	RegisterClassEx,addr @stWndClass
		invoke	CreateWindowEx,WS_EX_CLIENTEDGE,offset szClass1,offset szCaption1,\
			WS_OVERLAPPEDWINDOW,\
			450,100,300,300,\
			NULL,NULL,hInstance,NULL
		mov	hWin1,eax
		invoke	ShowWindow,hWin1,SW_SHOWNORMAL
		invoke	UpdateWindow,hWin1
;********************************************************************
		mov	@stWndClass.lpszClassName,offset szClass2
		invoke	RegisterClassEx,addr @stWndClass
		invoke	CreateWindowEx,WS_EX_CLIENTEDGE,offset szClass2,offset szCaption2,\
			WS_OVERLAPPEDWINDOW,\
			100,100,300,300,\
			NULL,NULL,hInstance,NULL
		mov	hWin2,eax
		invoke	ShowWindow,hWin2,SW_SHOWNORMAL
		invoke	UpdateWindow,hWin2
;********************************************************************
; ���ö�ʱ��
;********************************************************************
		invoke	SetTimer,NULL,NULL,100,addr _ProcTimer
		mov	@hTimer,eax
;********************************************************************
; ��Ϣѭ��
;********************************************************************
		.while	TRUE
			invoke	GetMessage,addr @stMsg,NULL,0,0
			.break	.if eax	== 0
			invoke	TranslateMessage,addr @stMsg
			invoke	DispatchMessage,addr @stMsg
		.endw
;********************************************************************
; �����ʱ��
;********************************************************************
		invoke	KillTimer,NULL,@hTimer
		ret

_WinMain	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		call	_WinMain
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
