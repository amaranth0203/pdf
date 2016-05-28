;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Icon.asm
; 光标资源和图标资源的使用例子
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff Icon.asm
; rc Icon.rc
; Link /subsystem:windows Icon.obj Icon.res
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.386
		.model flat, stdcall
		option casemap :none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include 文件定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equ 等值定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_BIG		equ		1000h
ICO_SMALL	equ		1001h
CUR_2		equ		1000h
IDM_MAIN	equ		2000h
IDM_EXIT	equ		2101h
IDM_BIG		equ		2201h
IDM_SMALL	equ		2202h
IDM_CUR1	equ		2203h
IDM_CUR2	equ		2204h
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd		?
hWinMain	dd		?
hMenu		dd		?
hIcoBig		dd		?
hIcoSmall	dd		?
hCur1		dd		?
hCur2		dd		?
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const
szClassName	db	'Icon and Cursor Example',0
szCursorFile	db	'1.ani',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Quit		proc

		invoke	DestroyWindow,hWinMain
		invoke	PostQuitMessage,NULL
		ret

_Quit		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcWinMain	proc	uses ebx edi esi hWnd,uMsg,wParam,lParam

		mov	eax,uMsg
;********************************************************************
		.if	eax ==	WM_CREATE
			invoke	LoadIcon,hInstance,ICO_BIG
			mov	hIcoBig,eax
			invoke	LoadIcon,hInstance,ICO_SMALL
			mov	hIcoSmall,eax
			invoke	LoadCursorFromFile,addr szCursorFile
			mov	hCur1,eax
			invoke	LoadCursor,hInstance,CUR_2
			mov	hCur2,eax
			invoke	SendMessage,hWnd,WM_COMMAND,IDM_BIG,NULL
			invoke	SendMessage,hWnd,WM_COMMAND,IDM_CUR1,NULL
;********************************************************************
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
			movzx	eax,ax
			.if	eax ==	IDM_EXIT
				call	_Quit
			.elseif	eax ==	IDM_BIG
				invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,hIcoBig
				invoke	CheckMenuRadioItem,hMenu,IDM_BIG,IDM_SMALL,IDM_BIG,MF_BYCOMMAND
			.elseif	eax ==	IDM_SMALL
				invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,hIcoSmall
				invoke	CheckMenuRadioItem,hMenu,IDM_BIG,IDM_SMALL,IDM_SMALL,MF_BYCOMMAND
			.elseif	eax ==	IDM_CUR1
				invoke	SetClassLong,hWnd,GCL_HCURSOR,hCur1
				invoke	CheckMenuRadioItem,hMenu,IDM_CUR1,IDM_CUR2,IDM_CUR1,MF_BYCOMMAND
			.elseif	eax ==	IDM_CUR2
				invoke	SetClassLong,hWnd,GCL_HCURSOR,hCur2
				invoke	CheckMenuRadioItem,hMenu,IDM_CUR1,IDM_CUR2,IDM_CUR2,MF_BYCOMMAND
			.endif
;********************************************************************
		.elseif	eax ==	WM_CLOSE
			call	_Quit
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
		invoke	LoadMenu,hInstance,IDM_MAIN
		mov	hMenu,eax
;********************************************************************
; 注册窗口类
;********************************************************************
		invoke	RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
		push	hInstance
		pop	@stWndClass.hInstance
		mov	@stWndClass.cbSize,sizeof WNDCLASSEX
		mov	@stWndClass.style,CS_HREDRAW or CS_VREDRAW
		mov	@stWndClass.lpfnWndProc,offset _ProcWinMain
		mov	@stWndClass.hbrBackground,COLOR_WINDOW + 1
		mov	@stWndClass.lpszClassName,offset szClassName
		invoke	RegisterClassEx,addr @stWndClass
;********************************************************************
; 建立并显示窗口
;********************************************************************
		invoke	CreateWindowEx,WS_EX_CLIENTEDGE,\
			offset szClassName,offset szClassName,\
			WS_OVERLAPPEDWINDOW,\
			100,100,400,300,\
			NULL,hMenu,hInstance,NULL
		mov	hWinMain,eax
		invoke	ShowWindow,hWinMain,SW_SHOWNORMAL
		invoke	UpdateWindow,hWinMain
;********************************************************************
; 消息循环
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
