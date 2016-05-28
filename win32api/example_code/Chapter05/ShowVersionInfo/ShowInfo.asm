;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ShowInfo.asm
; ��ʾ PE �ļ���Դ�а汾��Ϣ������
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff ShowInfo.asm
; rc ShowInfo.rc
; Link /subsystem:windows ShowInfo.obj ShowInfo.res
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
include		Version.inc
includelib	Version.lib
include		comctl32.inc
includelib	comctl32.lib
include		comdlg32.inc
includelib	comdlg32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equ ��ֵ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN	equ	1000h
DLG_MAIN	equ	1
IDC_INFO	equ	101
IDC_FILE	equ	102
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?

hInstance	dd	?
szBuffer	db	4096 dup (?)

		.const

szPeFileExt	db	'PE�ļ�',0,'*.exe;*.dll;*.scr;*.drv',0,0
szError		db	'�ļ���û�а����汾��Ϣ��',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code

include		GetVersionInfo.inc

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@szBuffer[MAX_PATH]:byte
		local	@stOpenFileName:OPENFILENAME

		mov	eax,wMsg
		.if	eax == WM_CLOSE
			invoke	EndDialog,hWnd,NULL
		.elseif	eax == WM_INITDIALOG
;********************************************************************
; ���ñ�����ͼ��
;********************************************************************
			invoke	LoadIcon,hInstance,ICO_MAIN
			invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
;********************************************************************
		.elseif	eax == WM_COMMAND
			mov	eax,wParam
			.if	ax ==	IDOK
;********************************************************************
; ��һ��ѡ���ļ��ĶԻ���
;********************************************************************
				invoke	RtlZeroMemory,addr @stOpenFileName,sizeof OPENFILENAME
				invoke	RtlZeroMemory,addr @szBuffer,sizeof @szBuffer
				mov	@stOpenFileName.lStructSize,SIZEOF @stOpenFileName
				mov	@stOpenFileName.Flags,OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
				push	hWnd
				pop	@stOpenFileName.hwndOwner
				mov	@stOpenFileName.lpstrFilter,offset szPeFileExt
				lea	eax,@szBuffer
				mov	@stOpenFileName.lpstrFile,eax
				mov	@stOpenFileName.nMaxFile,MAX_PATH
				invoke	GetOpenFileName,addr @stOpenFileName
				.if	eax
;********************************************************************
; ��ȡ�汾��Ϣ����ʾ����
;********************************************************************
					invoke	_GetVersionInfo,addr @szBuffer,addr szBuffer
					.if	eax
						invoke	SetDlgItemText,hWnd,IDC_FILE,addr @szBuffer
						invoke	SetDlgItemText,hWnd,IDC_INFO,addr szBuffer
					.else
						invoke	MessageBox,hWnd,addr szError,NULL,MB_OK or MB_ICONHAND
					.endif
				.endif
			.endif
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
		invoke	InitCommonControls
		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		invoke	DialogBoxParam,hInstance,DLG_MAIN,NULL,offset _ProcDlgMain,NULL
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
