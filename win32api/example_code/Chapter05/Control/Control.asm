;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Control.asm
; �Ի�����Դ���Ӵ��ڿؼ���ʹ�÷���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff Control.asm
; rc Control.rc
; Link /subsystem:windows Control.obj Control.res
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
include		gdi32.inc
includelib	gdi32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equ ��ֵ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN	equ	1000h
DLG_MAIN	equ	1
IDB_1		equ	1
IDB_2		equ	2
IDC_ONTOP	equ	101
IDC_SHOWBMP	equ	102
IDC_ALOW	equ 	103
IDC_MODALFRAME	equ	104
IDC_THICKFRAME	equ	105
IDC_TITLETEXT	equ	106
IDC_CUSTOMTEXT	equ	107
IDC_BMP		equ	108
IDC_SCROLL	equ	109
IDC_VALUE	equ	110
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?

hInstance	dd	?
hBmp1		dd	?
hBmp2		dd	?
dwPos		dd	?

		.const
szText1		db	'Hello, World!',0
szText2		db	'�٣��㿴��������������?',0
szText3		db	'�Զ���',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@szBuffer[128]:byte

		mov	eax,wMsg
		.if	eax == WM_CLOSE
			invoke	EndDialog,hWnd,NULL
			invoke	DeleteObject,hBmp1
			invoke	DeleteObject,hBmp2
		.elseif	eax == WM_INITDIALOG
;********************************************************************
; ���ñ�����ͼ��
;********************************************************************
			invoke	LoadIcon,hInstance,ICO_MAIN
			invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
;********************************************************************
; ��ʼ����Ͽ�
;********************************************************************
			invoke	SendDlgItemMessage,hWnd,IDC_TITLETEXT,CB_ADDSTRING,0,addr szText1
			invoke	SendDlgItemMessage,hWnd,IDC_TITLETEXT,CB_ADDSTRING,0,addr szText2
			invoke	SendDlgItemMessage,hWnd,IDC_TITLETEXT,CB_ADDSTRING,0,addr szText3
			invoke	SendDlgItemMessage,hWnd,IDC_TITLETEXT,CB_SETCURSEL,0,0
			invoke	GetDlgItem,hWnd,IDC_CUSTOMTEXT
			invoke	EnableWindow,eax,FALSE

			invoke	LoadBitmap,hInstance,IDB_1
			mov	hBmp1,eax
			invoke	LoadBitmap,hInstance,IDB_2
			mov	hBmp2,eax
;********************************************************************
; ��ʼ����ѡť�͸�ѡ��
;********************************************************************
			invoke	CheckDlgButton,hWnd,IDC_SHOWBMP,BST_CHECKED
			invoke	CheckDlgButton,hWnd,IDC_ALOW,BST_CHECKED
			invoke	CheckDlgButton,hWnd,IDC_THICKFRAME,BST_CHECKED
;********************************************************************
; ��ʼ��������
;********************************************************************
			invoke	SendDlgItemMessage,hWnd,IDC_SCROLL,SBM_SETRANGE,0,100
		.elseif	eax == WM_COMMAND
			mov	eax,wParam
			.if	ax ==	IDCANCEL
				invoke	EndDialog,hWnd,NULL
				invoke	DeleteObject,hBmp1
				invoke	DeleteObject,hBmp2
;********************************************************************
; ����ͼƬ
;********************************************************************
			.elseif	ax ==	IDOK
				mov	eax,hBmp1
				xchg	eax,hBmp2
				mov	hBmp1,eax
				invoke	SendDlgItemMessage,hWnd,IDC_BMP,STM_SETIMAGE,IMAGE_BITMAP,eax
;********************************************************************
; �����Ƿ�������ǰ�桱
;********************************************************************
			.elseif	ax ==	IDC_ONTOP
				invoke	IsDlgButtonChecked,hWnd,IDC_ONTOP
				.if	eax == BST_CHECKED
					invoke	SetWindowPos,hWnd,HWND_TOPMOST,0,0,0,0,\
					SWP_NOMOVE or SWP_NOSIZE
				.else
					invoke	SetWindowPos,hWnd,HWND_NOTOPMOST,0,0,0,0,\
					SWP_NOMOVE or SWP_NOSIZE
				.endif
;********************************************************************
; ��ʾ���غ���ʾͼƬ�ؼ�
;********************************************************************
			.elseif	ax ==	IDC_SHOWBMP
				invoke	GetDlgItem,hWnd,IDC_BMP
				mov	ebx,eax
				invoke	IsWindowVisible,ebx
				.if	eax
					invoke	ShowWindow,ebx,SW_HIDE
				.else
					invoke	ShowWindow,ebx,SW_SHOW
				.endif
;********************************************************************
; ��ʾ����ͻһ�������ͼƬ����ť
;********************************************************************
			.elseif	ax ==	IDC_ALOW
				invoke	IsDlgButtonChecked,hWnd,IDC_ALOW
				.if	eax == BST_CHECKED
					mov	ebx,TRUE
				.else
					xor	ebx,ebx
				.endif
				invoke	GetDlgItem,hWnd,IDOK
				invoke	EnableWindow,eax,ebx
;********************************************************************
			.elseif	ax ==	IDC_MODALFRAME
				invoke	GetWindowLong,hWnd,GWL_STYLE
				and	eax,not WS_THICKFRAME
				invoke	SetWindowLong,hWnd,GWL_STYLE,eax
			.elseif	ax ==	IDC_THICKFRAME
				invoke	GetWindowLong,hWnd,GWL_STYLE
				or	eax,WS_THICKFRAME
				invoke	SetWindowLong,hWnd,GWL_STYLE,eax
;********************************************************************
; ��ʾ��������ʽ��Ͽ�
;********************************************************************
			.elseif	ax ==	IDC_TITLETEXT
				shr	eax,16
				.if	ax ==	CBN_SELENDOK
					invoke	SendDlgItemMessage,hWnd,IDC_TITLETEXT,CB_GETCURSEL,0,0
					.if	eax ==	2
						invoke	GetDlgItem,hWnd,IDC_CUSTOMTEXT
						invoke	EnableWindow,eax,TRUE
					.else
						mov	ebx,eax
						invoke	SendDlgItemMessage,hWnd,IDC_TITLETEXT,CB_GETLBTEXT,ebx,addr @szBuffer
						invoke	SetWindowText,hWnd,addr @szBuffer
						invoke	GetDlgItem,hWnd,IDC_CUSTOMTEXT
						invoke	EnableWindow,eax,FALSE
					.endif
				.endif
;********************************************************************
; ���ı�������������
;********************************************************************
			.elseif	ax ==	IDC_CUSTOMTEXT
				invoke	GetDlgItemText,hWnd,IDC_CUSTOMTEXT,addr @szBuffer,sizeof @szBuffer
				invoke	SetWindowText,hWnd,addr @szBuffer
			.endif
;********************************************************************
; �����������Ϣ
;********************************************************************
		.elseif	eax ==	WM_HSCROLL
			mov	eax,wParam
			.if	ax ==	SB_LINELEFT
				dec	dwPos
			.elseif	ax ==	SB_LINERIGHT
				inc	dwPos
			.elseif	ax ==	SB_PAGELEFT
				sub	dwPos,10
			.elseif	ax ==	SB_PAGERIGHT
				add	dwPos,10
			.elseif	ax ==	SB_THUMBPOSITION || ax == SB_THUMBTRACK
				mov	eax,wParam
				shr	eax,16
				mov	dwPos,eax
			.else
				mov	eax,TRUE
				ret
			.endif
			cmp	dwPos,0
			jge	@F
			mov	dwPos,0
			@@:
			cmp	dwPos,100
			jle	@F
			mov	dwPos,100
			@@:
			invoke	SetDlgItemInt,hWnd,IDC_VALUE,dwPos,FALSE
			invoke	SendDlgItemMessage,hWnd,IDC_SCROLL,SBM_SETPOS,dwPos,TRUE
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
