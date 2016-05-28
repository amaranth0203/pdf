;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; StatusBar.asm
; 状态栏控件的使用例子
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff StatusBar.asm
; rc StatusBar.rc
; Link /subsystem:windows StatusBar.obj StatusBar.res
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
include		Comctl32.inc
includelib	Comctl32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equ 等值定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN	equ	1000
DLG_MAIN	equ	1000
IDM_MAIN	equ	1000
IDM_EXIT	equ	1104
IDM_MENUHELP	equ	1300

ID_STATUSBAR	equ	1
ID_EDIT		equ	2
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd	?
hWinMain	dd	?
hWinStatus	dd	?
hWinEdit	dd	?
lpsz1		dd	?
lpsz2		dd	?

		.const
szClass		db	'EDIT',0
szFormat0	db	'%02d:%02d:%02d',0
szFormat1	db	'字节数:%d',0
sz1		db	'插入',0
sz2		db	'改写',0
dwStatusWidth	dd	60,140,172,-1
dwMenuHelp	dd	0,IDM_MENUHELP,0,0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Resize		proc
		local	@stRect:RECT,@stRect1:RECT

		invoke	MoveWindow,hWinStatus,0,0,0,0,TRUE
		invoke	GetWindowRect,hWinStatus,addr @stRect
		invoke	GetClientRect,hWinMain,addr @stRect1
		mov	ecx,@stRect1.right
		sub	ecx,@stRect1.left
		mov	eax,@stRect1.bottom
		sub	eax,@stRect1.top
		sub	eax,@stRect.bottom
		add	eax,@stRect.top
		invoke	MoveWindow,hWinEdit,0,0,ecx,eax,TRUE
		ret

_Resize		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@szBuffer[128]:byte
		local	@stST:SYSTEMTIME
		local	@stPoint:POINT,@stRect:RECT

		mov	eax,wMsg
;********************************************************************
		.if	eax ==	WM_TIMER
			invoke	GetLocalTime,addr @stST
			movzx	eax,@stST.wHour
			movzx	ebx,@stST.wMinute
			movzx	ecx,@stST.wSecond
			invoke	wsprintf,addr @szBuffer,addr szFormat0,eax,ebx,ecx
			invoke	SendMessage,hWinStatus,SB_SETTEXT,0,addr @szBuffer
;********************************************************************
		.elseif	eax ==	WM_CLOSE
			invoke	KillTimer,hWnd,1
			invoke	EndDialog,hWnd,NULL
;********************************************************************
		.elseif	eax ==	WM_INITDIALOG
			mov	eax,hWnd
			mov	hWinMain,eax

			invoke	CreateStatusWindow,WS_CHILD OR WS_VISIBLE OR \
				SBS_SIZEGRIP,NULL,hWinMain,ID_STATUSBAR
			mov	hWinStatus,eax
			invoke	SendMessage,hWinStatus,SB_SETPARTS,4,offset dwStatusWidth
			mov	lpsz1,offset sz1
			mov	lpsz2,offset sz2
			invoke	SendMessage,hWinStatus,SB_SETTEXT,2,lpsz1

			invoke	CreateWindowEx,WS_EX_CLIENTEDGE,addr szClass,NULL,\
				WS_CHILD or WS_VISIBLE or ES_MULTILINE or ES_WANTRETURN or WS_VSCROLL or ES_AUTOHSCROLL,\
				0,0,0,0,hWnd,ID_EDIT,hInstance,NULL
			mov	hWinEdit,eax

			call	_Resize
			invoke	SetTimer,hWnd,1,300,NULL
;********************************************************************
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
			.if	ax ==	IDM_EXIT
				invoke	EndDialog,hWnd,NULL
			.elseif	ax ==	ID_EDIT
				invoke	GetWindowTextLength,hWinEdit
				invoke	wsprintf,addr @szBuffer,addr szFormat1,eax
				invoke	SendMessage,hWinStatus,SB_SETTEXT,1,addr @szBuffer
			.endif
;********************************************************************
		.elseif	eax ==	WM_MENUSELECT
			invoke	MenuHelp,WM_MENUSELECT,wParam,lParam,lParam,hInstance,\
				hWinStatus,offset dwMenuHelp
		.elseif	eax ==	WM_SIZE
			call	_Resize
;********************************************************************
; 检测用户在第3栏的按鼠标动作并将文字在“插入”和“改写”之间切换
;********************************************************************
		.elseif	eax ==	WM_NOTIFY
			.if	wParam == ID_STATUSBAR
				mov	eax,lParam
				mov	eax,[eax + NMHDR.code]
				.if	eax ==	NM_CLICK
					invoke	GetCursorPos,addr @stPoint
					invoke	GetWindowRect,hWinStatus,addr @stRect
					mov	eax,@stRect.left
					mov	ecx,eax
					add	eax,140
					add	ecx,172
					.if	(@stPoint.x >= eax) && (@stPoint.x <= ecx)
						mov	eax,lpsz1
						xchg	eax,lpsz2
						mov	lpsz1,eax
						invoke	SendMessage,hWinStatus,SB_SETTEXT,2,lpsz1
					.endif
				.endif
			.endif
		.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
		ret

_ProcDlgMain	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		invoke	InitCommonControls
		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		invoke	DialogBoxParam,hInstance,DLG_MAIN,NULL,offset _ProcDlgMain,NULL
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
