;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Fragment.asm
; �ظ�������ͷŹ̶��ڴ��ʹ�ڴ���Ƭ��
; Windows NT ��ʹ�á�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff Fragment.asm
; rc Fragment.rc
; Link /subsystem:windows Fragment.obj Fragment.res
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
DLG_MAIN	equ	100
IDC_MEMORY	equ 	101
IDC_COUNT	equ 	102
IDC_INFO	equ	103
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?

hInstance	dd	?
hWinMain	dd	?
dwTotalMemory	dd	?
dwCount		dd	?
ifCanQuit	dd	?

		.const
szInfo		db	'�޷��������� 1MB ��С���ڴ�!',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcThread	proc	uses ebx ecx edx esi edi,lParam
		local	@lpLastMem

		invoke	GlobalAlloc,GPTR,1000000
		mov	@lpLastMem,eax
		inc	dwCount
		add	dwTotalMemory,1000000
		.repeat
			push	@lpLastMem
			invoke	GlobalAlloc,GPTR,1000000
			mov	@lpLastMem,eax
			.if	eax
				add	dwTotalMemory,1000000
				inc	dwCount
			.endif
			pop	eax
			invoke	GlobalReAlloc,eax,100,GMEM_ZEROINIT
			sub	dwTotalMemory,1000000 - 100
			invoke	SetDlgItemInt,hWinMain,IDC_MEMORY,dwTotalMemory,FALSE
			invoke	SetDlgItemInt,hWinMain,IDC_COUNT,dwCount,FALSE
		.until	! @lpLastMem
		invoke	SetDlgItemText,hWinMain,IDC_INFO,addr szInfo
		mov	ifCanQuit,1
		ret

_ProcThread	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@dwTemp

		mov	eax,wMsg
		.if	eax ==	WM_CLOSE
			.if	ifCanQuit
				invoke	EndDialog,hWnd,NULL
			.endif
;********************************************************************
		.elseif	eax ==	WM_INITDIALOG
			push	hWnd
			pop	hWinMain
			invoke	LoadIcon,hInstance,ICO_MAIN
			invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
			invoke	CreateThread,NULL,0,offset _ProcThread,NULL,\
				NULL,addr @dwTemp
			invoke	CloseHandle,eax
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
		invoke	DialogBoxParam,hInstance,DLG_MAIN,NULL,offset _ProcDlgMain,NULL
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
