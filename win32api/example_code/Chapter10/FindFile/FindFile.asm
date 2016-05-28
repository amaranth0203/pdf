;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; FindFile.asm
; 全盘文件搜索程序 —— 指定一个起始目录，查找所有文件（包括子目录下
; 的文件）
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff FindFile.asm
; rc FindFile.rc
; Link /subsystem:windows FindFile.obj FindFile.res
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.386
		.model flat, stdcall
		option casemap :none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include 文件定义
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
; Equ 等值定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN	equ		1000
DLG_MAIN	equ		100
IDC_PATH	equ		101
IDC_BROWSE	equ		102
IDC_NOWFILE	equ		103
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
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
szStart		db	'开始(&S)',0
szStop		db	'停止(&S)',0
szFilter	db	'*.*',0
szSearchInfo	db	'共找到 %d 个文件夹，%d 个文件，共 %luK 字节',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code

include		_BrowseFolder.asm

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 处理找到的文件
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
		local	@szPath[MAX_PATH]:byte		;用来存放“路径\”
		local	@szSearch[MAX_PATH]:byte	;用来存放“路径\*.*”
		local	@szFindFile[MAX_PATH]:byte	;用来存放“路径\找到的文件”

		pushad
		invoke	lstrcpy,addr @szPath,_lpszPath
;********************************************************************
; 在路径后面加上\*.*
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
; 寻找文件
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
; 设置标志位，并灰化“浏览”按钮和路径输入栏
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
; 退出时显示找到文件的总大小
;********************************************************************
		mov	edx,dwFileSizeHigh
		mov	eax,dwFileSizeLow
		mov	ecx,1000
		div	ecx
		invoke	wsprintf,addr @szBuffer,addr szSearchInfo,dwFolderCount,dwFileCount,eax
		invoke	SetDlgItemText,hWinMain,IDC_NOWFILE,addr @szBuffer
;********************************************************************
; 设置标志位，并启用“浏览”按钮和路径输入栏
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
; 按下开始按钮，如果在寻找中则设置停止标志
; 如果没有开始寻找则建立一个寻找文件的线程
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
