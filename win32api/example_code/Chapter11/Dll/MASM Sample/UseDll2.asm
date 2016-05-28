;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; UseDll2.asm
; �Ա� Sample.dll �еĺ�����ʹ�÷�����ʾ����
; �ö�̬װ�� dll �ļ��ķ�ʽ���� dll �еĺ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff UseDll2.asm
; rc UseDll.rc
; Link /subsystem:windows UseDll2.obj UseDll.res
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
IDC_COUNT	equ	1001
IDC_INC		equ	1002
IDC_DEC		equ	1003
IDC_NUM1	equ	1004
IDC_NUM2	equ	1005
IDC_MOD		equ	1006

_PROCVAR2	typedef proto :dword,:dword
_PROCVAR0	typedef proto
PROCVAR2	typedef ptr _PROCVAR2
PROCVAR0	typedef ptr _PROCVAR0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?

hDllInstance	dd		?
lpIncCounter	PROCVAR0	?
lpDecCounter	PROCVAR0	?
lpMod		PROCVAR2	?

		.const
szError		db	'Sample.dll �ļ���ʧ��װ��ʧ�ܣ��������޷�ʵ��',0
szDll		db	'Sample.dll',0
szIncCounter	db	'_IncCounter',0
szDecCounter	db	'_DecCounter',0
szMod		db	'_Mod',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam

		mov	eax,wMsg
;********************************************************************
		.if	eax ==	WM_CLOSE
			.if	hDllInstance
				xor	eax,eax
				mov	lpIncCounter,eax
				mov	lpDecCounter,eax
				mov	lpMod,eax
				invoke	FreeLibrary,hDllInstance
			.endif
			invoke	EndDialog,hWnd,NULL
;********************************************************************
		.elseif	eax ==	WM_INITDIALOG
			invoke	LoadLibrary,addr szDll
			.if	eax
				mov	hDllInstance,eax
				invoke	GetProcAddress,hDllInstance,addr szIncCounter
				mov	lpIncCounter,eax
				invoke	GetProcAddress,hDllInstance,addr szDecCounter
				mov	lpDecCounter,eax
				invoke	GetProcAddress,hDllInstance,addr szMod
				mov	lpMod,eax
			.else
				invoke	MessageBox,hWnd,addr szError,NULL,MB_OK or MB_ICONWARNING
				invoke	GetDlgItem,hWnd,IDC_INC
				invoke	EnableWindow,eax,FALSE
				invoke	GetDlgItem,hWnd,IDC_DEC
				invoke	EnableWindow,eax,FALSE
				invoke	GetDlgItem,hWnd,IDC_NUM1
				invoke	EnableWindow,eax,FALSE
				invoke	GetDlgItem,hWnd,IDC_NUM2
				invoke	EnableWindow,eax,FALSE
			.endif
;********************************************************************
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
			.if	ax ==	IDC_INC
				.if	lpIncCounter
					invoke	lpIncCounter
					invoke	SetDlgItemInt,hWnd,IDC_COUNT,eax,FALSE
				.endif
			.elseif	ax ==	IDC_DEC
				.if	lpDecCounter
					invoke	lpDecCounter
					invoke	SetDlgItemInt,hWnd,IDC_COUNT,eax,FALSE
				.endif
			.elseif ax ==	IDC_NUM1 || ax == IDC_NUM2
				.if	lpMod
					invoke	GetDlgItemInt,hWnd,IDC_NUM1,NULL,FALSE
					push	eax
					invoke	GetDlgItemInt,hWnd,IDC_NUM2,NULL,FALSE
					pop	ecx
					invoke	lpMod,ecx,eax
					invoke	SetDlgItemInt,hWnd,IDC_MOD,eax,FALSE
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
		invoke	GetModuleHandle,NULL
		invoke	DialogBoxParam,eax,DLG_MAIN,NULL,offset _ProcDlgMain,NULL
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
