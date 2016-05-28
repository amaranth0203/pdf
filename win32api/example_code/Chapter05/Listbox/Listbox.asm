;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Listbox.asm
; �ڶԻ�����ʹ���б��ؼ�������
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff Listbox.asm
; rc Listbox.rc
; Link /subsystem:windows Listbox.obj Listbox.res
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
ICO_MAIN	equ	1000h
DLG_MAIN	equ	1
IDC_LISTBOX1	equ	101
IDC_LISTBOX2	equ	102
IDC_SEL1	equ	103
IDC_RESET	equ	104
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?

hInstance	dd	?

		.const
szText1		db	'��Ŀ1',0
szText2		db	'��Ŀ2',0
szText3		db	'��Ŀ3',0
szPath		db	'*.*',0
szMessage	db	'ѡ������%s',0
szTitle		db	'����ѡ��',0
szSelect	db	'��ѡ�������µ���Ŀ��'
szReturn	db	0dh,0ah,0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@szBuffer[128]:byte
		local	@szBuffer1[128]:byte
		local	@szTextBuff[2048]:byte
		local	@dwCount

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
; ��ʼ���б��
;********************************************************************
			invoke	SendDlgItemMessage,hWnd,IDC_LISTBOX1,LB_ADDSTRING,0,addr szText1
			invoke	SendDlgItemMessage,hWnd,IDC_LISTBOX1,LB_ADDSTRING,0,addr szText2
			invoke	SendDlgItemMessage,hWnd,IDC_LISTBOX1,LB_ADDSTRING,0,addr szText3
			invoke	SendDlgItemMessage,hWnd,IDC_LISTBOX2,LB_DIR,\
				DDL_ARCHIVE or DDL_DRIVES or DDL_DIRECTORY,addr szPath
;********************************************************************
		.elseif	eax == WM_COMMAND
			mov	eax,wParam
			.if	ax ==	IDOK
;********************************************************************
; ȡ��ѡ���б����Ŀ
;********************************************************************
				invoke	SendDlgItemMessage,hWnd,IDC_LISTBOX2,LB_GETSELCOUNT,0,0
				mov	@dwCount,eax
				invoke	SendDlgItemMessage,hWnd,IDC_LISTBOX2,LB_GETSELITEMS,128/4,addr @szBuffer
				invoke	lstrcpy,addr @szTextBuff,addr szSelect
				lea	esi,@szBuffer
				.while	@dwCount
					lodsd
					lea	ecx,@szBuffer1
					invoke	SendDlgItemMessage,hWnd,IDC_LISTBOX2,LB_GETTEXT,eax,ecx
					invoke	lstrcat,addr @szTextBuff,addr szReturn
					invoke	lstrcat,addr @szTextBuff,addr @szBuffer1
					dec	@dwCount
				.endw
				invoke	MessageBox,hWnd,addr @szTextBuff,addr szTitle,MB_OK
;********************************************************************
			.elseif	ax ==	IDC_RESET
				invoke	SendDlgItemMessage,hWnd,IDC_LISTBOX2,LB_SETSEL,FALSE,-1
;********************************************************************
			.elseif	ax ==	IDC_LISTBOX1
				shr	eax,16
				.if	ax ==	LBN_SELCHANGE
;********************************************************************
; ������������ʾ���ı�����
;********************************************************************
					invoke	SendMessage,lParam,LB_GETCURSEL,0,0
					lea	ecx,@szBuffer
					invoke	SendMessage,lParam,LB_GETTEXT,eax,ecx
					invoke	SetDlgItemText,hWnd,IDC_SEL1,addr @szBuffer
				.elseif	ax ==	LBN_DBLCLK
;********************************************************************
; ˫����Ŀ�򵯳��Ի���
;********************************************************************
					invoke	SendMessage,lParam,LB_GETCURSEL,0,0
					lea	ecx,@szBuffer
					invoke	SendMessage,lParam,LB_GETTEXT,eax,ecx
					invoke	wsprintf,addr @szBuffer1,addr szMessage,addr @szBuffer
					invoke	MessageBox,hWnd,addr @szBuffer1,addr szTitle,MB_OK
				.endif
			.elseif	ax ==	IDC_LISTBOX2
				shr	eax,16
				.if	ax ==	LBN_SELCHANGE
					invoke	SendMessage,lParam,LB_GETSELCOUNT,0,0
					mov	ebx,eax
					invoke	GetDlgItem,hWnd,IDOK
					invoke	EnableWindow,eax,ebx
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
		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		invoke	DialogBoxParam,hInstance,DLG_MAIN,NULL,offset _ProcDlgMain,NULL
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
