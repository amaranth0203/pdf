;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Counter.asm
; ʹ���¼���������Ϊ����߳�֮��ġ��źŵơ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff Counter.asm
; rc Counter.rc
; Link  /subsystem:windows Counter.obj Counter.res
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
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equ ��ֵ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN	equ	1000
DLG_MAIN	equ	1000
IDC_COUNTER	equ	1001
IDC_PAUSE	equ	1002
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd	?
hWinMain	dd	?
hWinCount	dd	?
hWinPause	dd	?
hEvent		dd	?

dwOption	dd	?
F_PAUSE		equ	0001h
F_STOP		equ	0002h
F_COUNTING	equ	0004h

		.const
szStop		db	'ֹͣ����',0
szStart		db	'����',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Counter	proc	uses ebx esi edi,_lParam

		or	dwOption,F_COUNTING
		and	dwOption,not (F_STOP or F_PAUSE)
		invoke	SetEvent,hEvent
		invoke	SetWindowText,hWinCount,addr szStop
		invoke	EnableWindow,hWinPause,TRUE

		xor	ebx,ebx
		.while	! (dwOption & F_STOP)
			inc	ebx
			invoke	SetDlgItemInt,hWinMain,IDC_COUNTER,ebx,FALSE
			invoke	WaitForSingleObject,hEvent,INFINITE
		.endw

		invoke	SetWindowText,hWinCount,addr szStart
		invoke	EnableWindow,hWinPause,FALSE
		and	dwOption,not (F_COUNTING or F_STOP or F_PAUSE)
		ret

_Counter	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@dwThreadID

		mov	eax,wMsg
;********************************************************************
		.if	eax ==	WM_COMMAND
			mov	eax,wParam
			.if	ax ==	IDOK
				.if	dwOption & F_COUNTING
					invoke	SetEvent,hEvent
					or	dwOption,F_STOP
				.else
					invoke	CreateThread,NULL,0,offset _Counter,NULL,\
						NULL,addr @dwThreadID
					invoke	CloseHandle,eax
				.endif
			.elseif	ax ==	IDC_PAUSE
				xor	dwOption,F_PAUSE
				.if	dwOption & F_PAUSE
					invoke	ResetEvent,hEvent
				.else
					invoke	SetEvent,hEvent
				.endif
			.endif
;********************************************************************
		.elseif	eax ==	WM_CLOSE
			invoke	CloseHandle,hEvent
			invoke	EndDialog,hWnd,NULL
;********************************************************************
		.elseif	eax ==	WM_INITDIALOG
			push	hWnd
			pop	hWinMain
			invoke	GetDlgItem,hWnd,IDOK
			mov	hWinCount,eax
			invoke	GetDlgItem,hWnd,IDC_PAUSE
			mov	hWinPause,eax
			invoke	CreateEvent,NULL,TRUE,FALSE,NULL
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
