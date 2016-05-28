;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; SubClass.asm
; �������໯���� ���� ��һ���༭�����໯Ϊֻ����16��չ�ַ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff SubClass.asm
; rc SubClass.rc
; Link /subsystem:windows SubClass.obj SubClass.res
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
IDC_HEX		equ	1001
IDC_DEC		equ	1002
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd	?
hWinMain	dd	?
dwOption	dd	?
lpOldProcEdit	dd	?

		.const
szFmtDecToHex	db	'%08X',0
szFmtHexToDec	db	'%u',0
szAllowedChar	db	'0123456789ABCDEFabcdef',08h
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; IDC_HEX�༭����´��ڹ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcEdit	proc	uses ebx edi esi hWnd,uMsg,wParam,lParam

		mov	eax,uMsg
		.if	uMsg ==	WM_CHAR
			mov	eax,wParam
			mov	edi,offset szAllowedChar
			mov	ecx,sizeof szAllowedChar
			repnz	scasb
			.if	ZERO?
				.if	al > '9'
					and	al,not 20h
				.endif
				invoke	CallWindowProc,lpOldProcEdit,hWnd,uMsg,eax,lParam
				ret
			.endif
		.else
			invoke	CallWindowProc,lpOldProcEdit,hWnd,uMsg,wParam,lParam
			ret
		.endif
		xor	eax,eax
		ret

_ProcEdit	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ����16���Ƶ�10����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_HexToDec	proc
		local	@szBuffer[512]:byte

		invoke	GetDlgItemText,hWinMain,IDC_HEX,addr @szBuffer,sizeof @szBuffer
		lea	esi,@szBuffer
		cld
		xor	eax,eax
		mov	ebx,16
		.while	TRUE
			movzx	ecx,byte ptr [esi]
			inc	esi
			.break	.if ! ecx
			.if	cl > '9'
				sub	cl,'A' - 0ah
			.else
				sub	cl,'0'
			.endif
			mul	ebx
			add	eax,ecx
		.endw
		invoke	wsprintf,addr @szBuffer,addr szFmtHexToDec,eax
		invoke	SetDlgItemText,hWinMain,IDC_DEC,addr @szBuffer
		ret

_HexToDec	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ����10���Ƶ�16����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_DecToHex	proc
		local	@szBuffer[512]:byte

		invoke	GetDlgItemInt,hWinMain,IDC_DEC,NULL,FALSE
		invoke	wsprintf,addr @szBuffer,addr szFmtDecToHex,eax
		invoke	SetDlgItemText,hWinMain,IDC_HEX,addr @szBuffer
		ret

_DecToHex	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam

		mov	eax,wMsg
;********************************************************************
		.if	eax ==	WM_CLOSE
			invoke	EndDialog,hWnd,NULL
;********************************************************************
		.elseif	eax ==	WM_INITDIALOG
			mov	eax,hWnd
			mov	hWinMain,eax
			invoke	SendDlgItemMessage,hWnd,IDC_HEX,EM_LIMITTEXT,8,0
			invoke	SendDlgItemMessage,hWnd,IDC_DEC,EM_LIMITTEXT,10,0
			invoke	GetDlgItem,hWnd,IDC_HEX
			invoke	SetWindowLong,eax,GWL_WNDPROC,addr _ProcEdit
			mov	lpOldProcEdit,eax
;********************************************************************
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
			.if	! dwOption
				mov	dwOption,TRUE
				.if	ax ==	IDC_HEX
					invoke	_HexToDec
				.elseif	ax ==	IDC_DEC
					invoke	_DecToHex
				.endif
				mov	dwOption,FALSE
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
		mov	hInstance,eax
		invoke	DialogBoxParam,hInstance,DLG_MAIN,NULL,offset _ProcDlgMain,NULL
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
