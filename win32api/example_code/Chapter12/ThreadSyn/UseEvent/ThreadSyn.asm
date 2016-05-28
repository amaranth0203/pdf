;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ThreadSyn.asm
; 使用事件对象进行线程之间的同步
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff ThreadSyn.asm
; rc ThreadSyn.rc
; Link  /subsystem:windows ThreadSyn.obj ThreadSyn.res
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
ICO_MAIN	equ	1000
DLG_MAIN	equ	1000
IDC_COUNTER1	equ	1001
IDC_COUNTER2	equ	1002
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd	?
hWinMain	dd	?
hWinCount	dd	?

dwCounter1	dd	?
dwCounter2	dd	?

dwThreads	dd	?
hEvent		dd	?
dwOption	dd	?
F_STOP		equ	0001h

		.const
szStop		db	'停止计数',0
szStart		db	'计数',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Counter	proc	uses ebx esi edi,_lParam

		inc	dwThreads
		invoke	SetWindowText,hWinCount,addr szStop
		and	dwOption,not F_STOP

		.while	! (dwOption & F_STOP)
			invoke	WaitForSingleObject,hEvent,INFINITE
			inc	dwCounter1
			mov	eax,dwCounter2
			inc	eax
			mov	dwCounter2,eax
			invoke	SetEvent,hEvent
		.endw
		dec	dwThreads
		invoke	SetWindowText,hWinCount,addr szStart
		ret

_Counter	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@dwThreadID

		mov	eax,wMsg
;********************************************************************
		.if	eax ==	WM_TIMER
			invoke	WaitForSingleObject,hEvent,INFINITE
			invoke	SetDlgItemInt,hWinMain,IDC_COUNTER1,dwCounter1,FALSE
			invoke	SetDlgItemInt,hWinMain,IDC_COUNTER2,dwCounter2,FALSE
			invoke	SetEvent,hEvent
;********************************************************************
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
			.if	ax ==	IDOK
				.if	dwThreads
					or	dwOption,F_STOP
					invoke	KillTimer,hWnd,1
				.else
					mov	dwCounter1,0
					mov	dwCounter2,0
					xor	ebx,ebx
					.while	ebx <	20
						invoke	CreateThread,NULL,0,offset _Counter,NULL,\
							NULL,addr @dwThreadID
						invoke	CloseHandle,eax
						inc	ebx
					.endw
					invoke	SetTimer,hWnd,1,500,NULL
				.endif
			.endif
;********************************************************************
		.elseif	eax ==	WM_CLOSE
			.if	! dwThreads
				invoke	CloseHandle,hEvent
				invoke	EndDialog,hWnd,NULL
			.endif
;********************************************************************
		.elseif	eax ==	WM_INITDIALOG
			push	hWnd
			pop	hWinMain
			invoke	GetDlgItem,hWnd,IDOK
			mov	hWinCount,eax
			invoke	CreateEvent,NULL,FALSE,TRUE,NULL
			mov	hEvent,eax
;********************************************************************
		.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
		ret

_ProcDlgMain	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		invoke	DialogBoxParam,eax,DLG_MAIN,NULL,offset _ProcDlgMain,NULL
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
