;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ThreadSyn.asm
; ʹ�û�������������߳�֮���ͬ��
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff ThreadSyn.asm
; rc ThreadSyn.rc
; Link  /subsystem:windows ThreadSyn.obj ThreadSyn.res
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
IDC_COUNTER1	equ	1001
IDC_COUNTER2	equ	1002
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd	?
hWinMain	dd	?
hWinCount	dd	?

dwCounter1	dd	?
dwCounter2	dd	?

dwThreads	dd	?
hSemaphore	dd	?
dwOption	dd	?
F_STOP		equ	0001h

		.const
szStop		db	'ֹͣ����',0
szStart		db	'����',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Counter	proc	uses ebx esi edi,_lParam

		inc	dwThreads
		invoke	SetWindowText,hWinCount,addr szStop
		and	dwOption,not F_STOP

		.while	! (dwOption & F_STOP)
			invoke	WaitForSingleObject,hSemaphore,INFINITE
			inc	dwCounter1
			mov	eax,dwCounter2
			inc	eax
			mov	dwCounter2,eax
			invoke	ReleaseSemaphore,hSemaphore,1,NULL
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
			invoke	WaitForSingleObject,hSemaphore,INFINITE
			invoke	SetDlgItemInt,hWinMain,IDC_COUNTER1,dwCounter1,FALSE
			invoke	SetDlgItemInt,hWinMain,IDC_COUNTER2,dwCounter2,FALSE
			invoke	ReleaseSemaphore,hSemaphore,1,NULL
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
				invoke	CloseHandle,hSemaphore
				invoke	EndDialog,hWnd,NULL
			.endif
;********************************************************************
		.elseif	eax ==	WM_INITDIALOG
			push	hWnd
			pop	hWinMain
			invoke	GetDlgItem,hWnd,IDOK
			mov	hWinCount,eax
			invoke	CreateSemaphore,NULL,1,1,NULL
			mov	hSemaphore,eax
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
