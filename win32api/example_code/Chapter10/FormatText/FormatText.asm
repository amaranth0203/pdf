;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; FormatText.asm
; �ļ���д���� ���� �� Unix ��ʽ���ı��ļ�����0ah���У�ת���� PC ��ʽ
; ���ı��ļ�����0dh,0ah���У�����д�ļ�����ʹ���ļ�����������
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff FormatText.asm
; rc FormatText.rc
; Link /subsystem:windows FormatText.obj FormatText.res
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
include		comdlg32.inc
includelib	comdlg32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equ ��ֵ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN	equ		1000
DLG_MAIN	equ		100
IDC_FILE	equ		101
IDC_BROWSE	equ		102
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?

hInstance	dd	?
hWinMain	dd	?
szFileName	db	MAX_PATH dup (?)

		.const
szFileExt	db	'�ı��ļ�',0,'*.txt',0,0
szNewFile	db	'.new.txt',0
szErrOpenFile	db	'�޷���Դ�ļ�!',0
szErrCreateFile	db	'�޷������µ��ı��ļ�!',0
szSuccees	db	'�ļ�ת���ɹ����µ��ı��ļ�����Ϊ',0dh,0ah,'%s',0
szSucceesCap	db	'��ʾ',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �ڻ��������ҳ�һ�����ݣ������в�����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_FormatText	proc	uses esi _lpData,_dwSize,_hFile
		local	@szBuffer[128]:byte,@dwBytesWrite

		mov	esi,_lpData
		mov	ecx,_dwSize
		lea	edi,@szBuffer
		xor	edx,edx
		cld
_LoopBegin:
		or	ecx,ecx
		jz	_WriteLine
		lodsb
		dec	ecx
		cmp	al,0dh		;����0dh����
		jz	_LoopBegin
		cmp	al,0ah		;����0ah����չΪ0dh,0ah
		jz	_LineEnd
		stosb
		inc	edx
		cmp	edx,sizeof @szBuffer-2
		jae	_WriteLine	;�л��������򱣴�
		jmp	_LoopBegin
_LineEnd:
		mov	ax,0a0dh
		stosw
		inc	edx
		inc	edx
_WriteLine:
		push	ecx
		.if	edx
			invoke	WriteFile,_hFile,addr @szBuffer,edx,addr @dwBytesWrite,NULL
		.endif
		lea	edi,@szBuffer
		xor	edx,edx
		pop	ecx
		or	ecx,ecx
		jnz	_LoopBegin
		ret

_FormatText	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcFile	proc
		local	@hFile,@hFileNew,@dwBytesRead
		local	@szNewFile[MAX_PATH]:byte
		local	@szReadBuffer[512]:byte

;********************************************************************
; ���ļ�
;********************************************************************
		invoke	CreateFile,addr szFileName,GENERIC_READ,FILE_SHARE_READ,0,\
			OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
		.if	eax ==	INVALID_HANDLE_VALUE
			invoke	MessageBox,hWinMain,addr szErrOpenFile,NULL,MB_OK or MB_ICONEXCLAMATION
			ret
		.endif
		mov	@hFile,eax
;********************************************************************
; ��������ļ�
;********************************************************************
		invoke	lstrcpy,addr @szNewFile,addr szFileName
		invoke	lstrcat,addr @szNewFile,addr szNewFile
		invoke	CreateFile,addr @szNewFile,GENERIC_WRITE,FILE_SHARE_READ,\
			0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if	eax ==	INVALID_HANDLE_VALUE
			invoke	MessageBox,hWinMain,addr szErrCreateFile,NULL,MB_OK or MB_ICONEXCLAMATION
			invoke	CloseHandle,@hFile
			ret
		.endif
		mov	@hFileNew,eax
;********************************************************************
; ѭ�������ļ�������ÿ���ֽ�
;********************************************************************
		xor	eax,eax
		mov	@dwBytesRead,eax
		.while	TRUE
			lea	esi,@szReadBuffer
			invoke	ReadFile,@hFile,esi,sizeof @szReadBuffer,addr @dwBytesRead,0
			.break	.if ! @dwBytesRead
			invoke	_FormatText,esi,@dwBytesRead,@hFileNew
		.endw
		invoke	CloseHandle,@hFile
		invoke	CloseHandle,@hFileNew
		invoke	wsprintf,addr @szReadBuffer,addr szSuccees,addr @szNewFile
		invoke	MessageBox,hWinMain,addr @szReadBuffer,addr szSucceesCap,MB_OK
		ret

_ProcFile	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@stOpenFileName:OPENFILENAME

		mov	eax,wMsg
		.if	eax ==	WM_CLOSE
			invoke	EndDialog,hWnd,NULL
;********************************************************************
		.elseif	eax ==	WM_INITDIALOG
			push	hWnd
			pop	hWinMain
			invoke	LoadIcon,hInstance,ICO_MAIN
			invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
			invoke	SendDlgItemMessage,hWnd,IDC_FILE,EM_SETLIMITTEXT,MAX_PATH,0
;********************************************************************
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
			.if	ax ==	IDC_BROWSE
;********************************************************************
				invoke	RtlZeroMemory,addr @stOpenFileName,sizeof OPENFILENAME
				mov	@stOpenFileName.lStructSize,SIZEOF @stOpenFileName
				mov	@stOpenFileName.Flags,OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
				push	hWinMain
				pop	@stOpenFileName.hwndOwner
				mov	@stOpenFileName.lpstrFilter,offset szFileExt
				mov	@stOpenFileName.lpstrFile,offset szFileName
				mov	@stOpenFileName.nMaxFile,MAX_PATH
				invoke	GetOpenFileName,addr @stOpenFileName
				.if	eax
					invoke	SetDlgItemText,hWnd,IDC_FILE,addr szFileName
				.endif
;********************************************************************
			.elseif	ax ==	IDC_FILE
				invoke	GetDlgItemText,hWnd,IDC_FILE,addr szFileName,MAX_PATH
				mov	ebx,eax
				invoke	GetDlgItem,hWnd,IDOK
				invoke	EnableWindow,eax,ebx
;********************************************************************
			.elseif	ax ==	IDOK
				call	_ProcFile
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
