;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; FindFile.asm
; ȫ���ļ��������� ���� ָ��һ����ʼĿ¼�����������ļ���������Ŀ¼��
; ���ļ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff FindFile.asm
; rc FindFile.rc
; Link /subsystem:windows FindFile.obj FindFile.res
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
include		ole32.inc
includelib	ole32.lib
include		shell32.inc
includelib	shell32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equ ��ֵ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN	equ		1000
DLG_MAIN	equ		100
IDC_PATH	equ		101
IDC_BROWSE	equ		102
IDC_NOWFILE	equ		103
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd	?
hWinMain	dd	?

dwFileSizeHigh	dd	?
dwFileSizeLow	dd	?
dwFileCount	dd	?
dwFolderCount	dd	?

szPath		db	MAX_PATH dup (?)
dwOption	db	?
F_SEARCHING	equ	0001h
F_STOP		equ	0002h

		.const
szStart		db	'��ʼ(&S)',0
szStop		db	'ֹͣ(&S)',0
szFilter	db	'*.*',0
szSearchInfo	db	'���ҵ� %d ���ļ��У�%d ���ļ����� %luK �ֽ�',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code

include		_BrowseFolder.asm

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����ҵ����ļ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcessFile	proc	_lpszFile
		local	@hFile

		inc	dwFileCount
		invoke	SetDlgItemText,hWinMain,IDC_NOWFILE,_lpszFile
		invoke	CreateFile,_lpszFile,GENERIC_READ,FILE_SHARE_READ,0,\
			OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
		.if	eax !=	INVALID_HANDLE_VALUE
			mov	@hFile,eax
			invoke	GetFileSize,eax,NULL
			add	dwFileSizeLow,eax
			adc	dwFileSizeHigh,0
			invoke	CloseHandle,@hFile
		.endif
		ret

_ProcessFile	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_FindFile	proc	_lpszPath
		local	@stFindFile:WIN32_FIND_DATA
		local	@hFindFile
		local	@szPath[MAX_PATH]:byte		;������š�·��\��
		local	@szSearch[MAX_PATH]:byte	;������š�·��\*.*��
		local	@szFindFile[MAX_PATH]:byte	;������š�·��\�ҵ����ļ���

		pushad
		invoke	lstrcpy,addr @szPath,_lpszPath
;********************************************************************
; ��·���������\*.*
;********************************************************************
		@@:
		invoke	lstrlen,addr @szPath
		lea	esi,@szPath
		add	esi,eax
		xor	eax,eax
		mov	al,'\'
		.if	byte ptr [esi-1] != al
			mov	word ptr [esi],ax
		.endif
		invoke	lstrcpy,addr @szSearch,addr @szPath
		invoke	lstrcat,addr @szSearch,addr szFilter
;********************************************************************
; Ѱ���ļ�
;********************************************************************
		invoke	FindFirstFile,addr @szSearch,addr @stFindFile
		.if	eax !=	INVALID_HANDLE_VALUE
			mov	@hFindFile,eax
			.repeat
				invoke	lstrcpy,addr @szFindFile,addr @szPath
				invoke	lstrcat,addr @szFindFile,addr @stFindFile.cFileName
				.if	@stFindFile.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY
					.if	@stFindFile.cFileName != '.'
						inc	dwFolderCount
						invoke	_FindFile,addr @szFindFile
					.endif
				.else
					invoke	_ProcessFile,addr @szFindFile
				.endif
				invoke	FindNextFile,@hFindFile,addr @stFindFile
			.until	(eax ==	FALSE) || (dwOption & F_STOP)
			invoke	FindClose,@hFindFile
		.endif
		popad
		ret

_FindFile	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcThread	proc	uses ebx ecx edx esi edi,lParam
		local	@szBuffer[256]:byte

;********************************************************************
; ���ñ�־λ�����һ����������ť��·��������
;********************************************************************
		and	dwOption,not F_STOP
		or	dwOption,F_SEARCHING
		invoke	GetDlgItem,hWinMain,IDC_PATH
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,hWinMain,IDC_BROWSE
		invoke	EnableWindow,eax,FALSE
		invoke	SetDlgItemText,hWinMain,IDOK,addr szStop
		xor	eax,eax
		mov	dwFileSizeHigh,eax
		mov	dwFileSizeLow,eax
		mov	dwFileCount,eax
		mov	dwFolderCount,eax

		invoke	_FindFile,addr szPath
;********************************************************************
; �˳�ʱ��ʾ�ҵ��ļ����ܴ�С
;********************************************************************
		mov	edx,dwFileSizeHigh
		mov	eax,dwFileSizeLow
		mov	ecx,1000
		div	ecx
		invoke	wsprintf,addr @szBuffer,addr szSearchInfo,dwFolderCount,dwFileCount,eax
		invoke	SetDlgItemText,hWinMain,IDC_NOWFILE,addr @szBuffer
;********************************************************************
; ���ñ�־λ�������á��������ť��·��������
;********************************************************************
		invoke	GetDlgItem,hWinMain,IDC_BROWSE
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,hWinMain,IDC_PATH
		invoke	EnableWindow,eax,TRUE
		invoke	SetDlgItemText,hWinMain,IDOK,addr szStart
		invoke	SetDlgItemText,hWinMain,IDC_PATH,addr szPath
		and	dwOption,not F_SEARCHING
		ret

_ProcThread	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@dwTemp,@szBuffer[MAX_PATH]:byte

		mov	eax,wMsg
		.if	eax ==	WM_CLOSE
			.if	! (dwOption & F_SEARCHING)
				invoke	EndDialog,hWnd,NULL
			.endif
;********************************************************************
		.elseif	eax ==	WM_INITDIALOG
			push	hWnd
			pop	hWinMain
			invoke	LoadIcon,hInstance,ICO_MAIN
			invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
			invoke	SendDlgItemMessage,hWnd,IDC_PATH,EM_SETLIMITTEXT,MAX_PATH,0
;********************************************************************
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
			.if	ax ==	IDC_BROWSE
				invoke	_BrowseFolder,hWnd,addr szPath
				.if	eax
					invoke	SetDlgItemText,hWnd,IDC_PATH,addr szPath
				.endif
			.elseif	ax ==	IDC_PATH
				invoke	GetDlgItemText,hWnd,IDC_PATH,addr @szBuffer,MAX_PATH
				mov	ebx,eax
				invoke	GetDlgItem,hWnd,IDOK
				invoke	EnableWindow,eax,ebx
;********************************************************************
; ���¿�ʼ��ť�������Ѱ����������ֹͣ��־
; ���û�п�ʼѰ������һ��Ѱ���ļ����߳�
;********************************************************************
			.elseif	ax ==	IDOK
				.if	dwOption & F_SEARCHING
					or	dwOption,F_STOP
				.else
					invoke	GetDlgItemText,hWnd,IDC_PATH,addr szPath,MAX_PATH
					invoke	CreateThread,NULL,0,offset _ProcThread,NULL,\
						NULL,addr @dwTemp
					invoke	CloseHandle,eax
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
