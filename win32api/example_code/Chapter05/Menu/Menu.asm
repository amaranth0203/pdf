;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Menu.asm
; 菜单资源的使用例子
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff Menu.asm
; rc Menu.rc
; Link /subsystem:windows Menu.obj Menu.res
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
ICO_MAIN	equ		1000h	;图标
IDM_MAIN	equ		2000h	;菜单
IDA_MAIN	equ		2000h	;加速键
IDM_OPEN	equ		4101h
IDM_OPTION	equ		4102h
IDM_EXIT	equ		4103h
IDM_SETFONT	equ		4201h
IDM_SETCOLOR	equ		4202h
IDM_INACT	equ		4203h
IDM_GRAY	equ		4204h
IDM_BIG		equ		4205h
IDM_SMALL	equ		4206h
IDM_LIST	equ		4207h
IDM_DETAIL	equ		4208h
IDM_TOOLBAR	equ		4209h
IDM_TOOLBARTEXT	equ		4210h
IDM_INPUTBAR	equ		4211h
IDM_STATUSBAR	equ		4212h
IDM_HELP	equ		4301h
IDM_ABOUT	equ		4302h
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd		?
hWinMain	dd		?
hMenu		dd		?
hSubMenu	dd		?
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const
szClassName	db	'Menu Example',0
szCaptionMain	db	'Menu',0
szMenuHelp	db	'帮助主题(&H)',0
szMenuAbout	db	'关于本程序(&A)...',0
szCaption	db	'菜单选择',0
szFormat	db	'您选择了菜单命令：%08x',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_DisplayMenuItem	proc	_dwCommandID
			local	@szBuffer[256]:byte

		pushad
		invoke	wsprintf,addr @szBuffer,addr szFormat,_dwCommandID
		invoke	MessageBox,hWinMain,addr @szBuffer,offset szCaption,MB_OK
		popad
		ret

_DisplayMenuItem	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Quit		proc

		invoke	DestroyWindow,hWinMain
		invoke	PostQuitMessage,NULL
		ret

_Quit		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcWinMain	proc	uses ebx edi esi hWnd,uMsg,wParam,lParam
		local	@stPos:POINT
		local	@hSysMenu

		mov	eax,uMsg
		.if	eax ==	WM_CREATE
			invoke	GetSubMenu,hMenu,1
			mov	hSubMenu,eax
;********************************************************************
;	在系统菜单中添加菜单项
;********************************************************************
			invoke	GetSystemMenu,hWnd,FALSE
			mov	@hSysMenu,eax
			invoke	AppendMenu,@hSysMenu,MF_SEPARATOR,0,NULL
			invoke	AppendMenu,@hSysMenu,0,IDM_HELP,offset szMenuHelp
			invoke	AppendMenu,@hSysMenu,0,IDM_ABOUT,offset szMenuAbout
;********************************************************************
; 处理菜单及加速键消息
;********************************************************************
		.elseif	eax ==	WM_COMMAND
			invoke	_DisplayMenuItem,wParam
			mov	eax,wParam
			movzx	eax,ax
			.if	eax ==	IDM_EXIT
				call	_Quit
			.elseif	eax >=	IDM_TOOLBAR && eax <= IDM_STATUSBAR
				mov	ebx,eax
				invoke	GetMenuState,hMenu,ebx,MF_BYCOMMAND
				.if	eax ==	MF_CHECKED
					mov	eax,MF_UNCHECKED
				.else
					mov	eax,MF_CHECKED
				.endif
				invoke	CheckMenuItem,hMenu,ebx,eax
			.elseif	eax >=	IDM_BIG && eax <= IDM_DETAIL
				invoke	CheckMenuRadioItem,hMenu,IDM_BIG,IDM_DETAIL,eax,MF_BYCOMMAND
			.endif
;********************************************************************
; 处理系统菜单消息
;********************************************************************
		.elseif	eax == WM_SYSCOMMAND
			mov	eax,wParam
			movzx	eax,ax
			.if	eax == IDM_HELP || eax == IDM_ABOUT
				invoke	_DisplayMenuItem,wParam
			.else
				invoke	DefWindowProc,hWnd,uMsg,wParam,lParam
				ret
			.endif
;********************************************************************
; 按下右键时弹出一个POPUP菜单
;********************************************************************
		.elseif eax == WM_RBUTTONDOWN
			invoke	GetCursorPos,addr @stPos
			invoke	TrackPopupMenu,hSubMenu,TPM_LEFTALIGN,@stPos.x,@stPos.y,NULL,hWnd,NULL
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
		local	@hAccelerator

		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		invoke	LoadMenu,hInstance,IDM_MAIN
		mov	hMenu,eax
		invoke	LoadAccelerators,hInstance,IDA_MAIN
		mov	@hAccelerator,eax
;********************************************************************
; 注册窗口类
;********************************************************************
		invoke	RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
		invoke	LoadIcon,hInstance,ICO_MAIN
		mov	@stWndClass.hIcon,eax
		mov	@stWndClass.hIconSm,eax
		invoke	LoadCursor,0,IDC_ARROW
		mov	@stWndClass.hCursor,eax
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
			offset szClassName,offset szCaptionMain,\
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
			invoke	TranslateAccelerator,hWinMain,@hAccelerator,addr @stMsg
			.if	eax == 0
				invoke	TranslateMessage,addr @stMsg
				invoke	DispatchMessage,addr @stMsg
			.endif
		.endw
		ret

_WinMain	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		call	_WinMain
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
