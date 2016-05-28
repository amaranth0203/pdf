;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; CommDlg.asm
; �����ļ���������ӡ�����������ı�����ͨ�öԻ����ʹ������
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff CommDlg.asm
; rc CommDlg.rc
; Link /subsystem:windows CommDlg.obj CommDlg.res
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
include		Comdlg32.inc
includelib	Comdlg32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equ ��ֵ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN	equ	1000
DLG_MAIN	equ	1000
IDM_MAIN	equ	1000
IDM_OPEN	equ	1101
IDM_SAVEAS	equ	1102
IDM_PAGESETUP	equ	1103
IDM_EXIT	equ	1104
IDM_FIND	equ	1201
IDM_REPLACE	equ	1202
IDM_SELFONT	equ	1203
IDM_SELCOLOR	equ	1204
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?

hInstance	dd	?
hWinMain	dd	?
dwFontColor	dd	?
dwBackColor	dd	?
dwCustColors	dd	16 dup (?)
stLogFont	LOGFONT		<?>
szFileName	db	MAX_PATH dup (?)
szBuffer	db	1024 dup (?)
;********************************************************************
; �����滻�Ի���ʹ��
;********************************************************************
idFindMessage	dd	?
stFind		FINDREPLACE	<?>
szFindText	db	100 dup (?)
szReplaceText	db	100 dup (?)

		.const
FINDMSGSTRING	db	'commdlg_FindReplace',0
szSaveCaption	db	'�����뱣����ļ���',0
szFormatColor	db	'��ѡ�����ɫֵ��%08x',0
szFormatFont	db	'����ѡ��',0dh,0ah,'�������ƣ�%s',0dh,0ah
		db	'������ɫֵ��%08x�������С��%d',0
szFormatFind	db	'�������ˡ�%s����ť',0dh,0ah,'�����ַ�����%s',0dh,0ah
		db	'�滻�ַ�����%s',0
szFormatPrt	db	'��ѡ��Ĵ�ӡ����%s',0
szCaption	db	'ִ�н��',0
szFindNext	db	'������һ��',0
szReplace	db	'�滻',0
szReplaceAll	db	'ȫ���滻',0
szFilter	db	'Text Files(*.txt)',0,'*.txt',0,'All Files(*.*)',0,'*.*',0,0
szDefExt	db	'txt',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ҳ�����öԻ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_PageSetup	proc
		local	@stPS:PAGESETUPDLG

		invoke	RtlZeroMemory,addr @stPS,sizeof @stPS
		mov	@stPS.lStructSize,sizeof @stPS
		push	hWinMain
		pop	@stPS.hwndOwner
		invoke	PageSetupDlg,addr @stPS
		.if	eax && @stPS.hDevMode
			mov	eax,@stPS.hDevMode
			mov	eax,[eax]
			invoke	wsprintf,addr szBuffer,addr szFormatPrt,eax
			invoke	MessageBox,hWinMain,addr szBuffer,addr szCaption,MB_OK
		.endif
		ret

_PageSetup	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ��ʾ�������ļ����Ի���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_SaveAs		proc
		local	@stOF:OPENFILENAME

		invoke	RtlZeroMemory,addr @stOF,sizeof @stOF
		mov	@stOF.lStructSize,sizeof @stOF
		push	hWinMain
		pop	@stOF.hwndOwner
		mov	@stOF.lpstrFilter,offset szFilter
		mov	@stOF.lpstrFile,offset szFileName
		mov	@stOF.nMaxFile,MAX_PATH
		mov	@stOF.Flags,OFN_PATHMUSTEXIST
		mov	@stOF.lpstrDefExt,offset szDefExt
		mov	@stOF.lpstrTitle,offset szSaveCaption
		invoke	GetSaveFileName,addr @stOF
		.if	eax
			invoke	MessageBox,hWinMain,addr szFileName,addr szCaption,MB_OK
		.endif
		ret

_SaveAs		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ��ʾ�����ļ����Ի���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_OpenFile	proc
		local	@stOF:OPENFILENAME

		invoke	RtlZeroMemory,addr @stOF,sizeof @stOF
		mov	@stOF.lStructSize,sizeof @stOF
		push	hWinMain
		pop	@stOF.hwndOwner
		mov	@stOF.lpstrFilter,offset szFilter
		mov	@stOF.lpstrFile,offset szFileName
		mov	@stOF.nMaxFile,MAX_PATH
		mov	@stOF.Flags,OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
		invoke	GetOpenFileName,addr @stOF
		.if	eax
			invoke	MessageBox,hWinMain,addr szFileName,addr szCaption,MB_OK
		.endif
		ret

_OpenFile	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ѡ����ɫ
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ChooseColor	proc
		local	@stCC:CHOOSECOLOR

		invoke	RtlZeroMemory,addr @stCC,sizeof @stCC
		mov	@stCC.lStructSize,sizeof @stCC
		push	hWinMain
		pop	@stCC.hwndOwner
		push	dwBackColor
		pop	@stCC.rgbResult
		mov	@stCC.Flags,CC_RGBINIT or CC_FULLOPEN
		mov	@stCC.lpCustColors,offset dwCustColors
		invoke	ChooseColor,addr @stCC
		.if	eax
			push	@stCC.rgbResult
			pop	dwBackColor
			invoke	wsprintf,addr szBuffer,addr szFormatColor,dwBackColor
			invoke	MessageBox,hWinMain,addr szBuffer,addr szCaption,MB_OK
		.endif
		ret

_ChooseColor	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ѡ������
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ChooseFont	proc
		local	@stCF:CHOOSEFONT

		invoke	RtlZeroMemory,addr @stCF,sizeof @stCF
		mov	@stCF.lStructSize,sizeof @stCF
		push	hWinMain
		pop	@stCF.hwndOwner
		mov	@stCF.lpLogFont,offset stLogFont
		push	dwFontColor
		pop	@stCF.rgbColors
		mov	@stCF.Flags,CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT or CF_EFFECTS
		invoke	ChooseFont,addr @stCF
		.if	eax
			push	@stCF.rgbColors
			pop	dwFontColor
			invoke	wsprintf,addr szBuffer,addr szFormatFont,addr stLogFont.lfFaceName,\
				dwFontColor,@stCF.iPointSize
			invoke	MessageBox,hWinMain,addr szBuffer,addr szCaption,MB_OK
		.endif
		ret

_ChooseFont	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@szBuffer[128]:byte

		mov	eax,wMsg
		.if	eax ==	WM_CLOSE
			invoke	EndDialog,hWnd,NULL
		.elseif	eax ==	WM_INITDIALOG
;********************************************************************
; ע�ᡰ���ҡ��Ի�����Ϣ����ʼ�������ҡ��Ի���Ľṹ
;********************************************************************
			mov	eax,hWnd
			mov	hWinMain,eax
			mov	stFind.hwndOwner,eax
			mov	stFind.lStructSize,sizeof stFind
			mov	stFind.Flags,FR_DOWN
			mov	stFind.lpstrFindWhat,offset szFindText
			mov	stFind.wFindWhatLen,sizeof szFindText
			mov	stFind.lpstrReplaceWith,offset szReplaceText
			mov	stFind.wReplaceWithLen,sizeof szReplaceText
			invoke	RegisterWindowMessage,addr FINDMSGSTRING
			mov	idFindMessage,eax
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
			.if	ax ==	IDM_EXIT
				invoke	EndDialog,hWnd,NULL
			.elseif	ax ==	IDM_OPEN
				invoke	_OpenFile
			.elseif	ax ==	IDM_SAVEAS
				invoke	_SaveAs
			.elseif	ax ==	IDM_PAGESETUP
				invoke	_PageSetup
			.elseif	ax ==	IDM_FIND
				and	stFind.Flags,not FR_DIALOGTERM
				invoke	FindText,addr stFind
			.elseif	ax ==	IDM_REPLACE
				and	stFind.Flags,not FR_DIALOGTERM
				invoke	ReplaceText,addr stFind
			.elseif	ax ==	IDM_SELFONT
				invoke	_ChooseFont
			.elseif	ax ==	IDM_SELCOLOR
				invoke	_ChooseColor
			.endif
;********************************************************************
		.elseif	eax ==	idFindMessage
			xor	ecx,ecx
			.if	stFind.Flags & FR_FINDNEXT
				mov	ecx,offset szFindNext
			.elseif	stFind.Flags & FR_REPLACE
				mov	ecx,offset szReplace
			.elseif	stFind.Flags & FR_REPLACEALL
				mov	ecx,offset szReplaceAll
			.endif
			.if	ecx
				invoke	wsprintf,addr szBuffer,addr szFormatFind,\
					ecx,addr szFindText,addr szReplaceText
				invoke	MessageBox,hWinMain,addr szBuffer,addr szCaption,MB_OK
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
