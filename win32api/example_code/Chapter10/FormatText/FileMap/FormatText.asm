;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; FormatText.asm
; 文件读写例子 —— 将 Unix 格式的文本文件（以0ah换行）转换成 PC 格式
; 的文本文件（以0dh,0ah换行），读写文件操作使用内存映射文件函数。
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff FormatText.asm
; rc FormatText.rc
; Link /subsystem:windows FormatText.obj FormatText.res
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
include		comdlg32.inc
includelib	comdlg32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equ 等值定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN	equ		1000
DLG_MAIN	equ		100
IDC_FILE	equ		101
IDC_BROWSE	equ		102
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?

hInstance	dd	?
hWinMain	dd	?
szFileName	db	MAX_PATH dup (?)

		.const
szFileExt	db	'文本文件',0,'*.txt',0,0
szNewFile	db	'.new.txt',0
szErrOpenFile	db	'无法打开源文件!',0
szErrCreateFile	db	'无法创建新的文本文件!',0
szSuccees	db	'文件转换成功，新的文本文件保存为',0dh,0ah,'%s',0
szSucceesCap	db	'提示',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 在缓冲区中找出一行数据，处理换行并保存
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
		cmp	al,0dh		;遇到0dh则丢弃
		jz	_LoopBegin
		cmp	al,0ah		;遇到0ah则扩展为0dh,0ah
		jz	_LineEnd
		stosb
		inc	edx
		cmp	edx,sizeof @szBuffer-2
		jae	_WriteLine	;行缓冲区满则保存
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
		local	@hFile,@hFileNew,@hFileMap,@lpMemory,@dwFileSize
		local	@szNewFile[MAX_PATH]:byte
		local	@szBuffer[512]:byte

;********************************************************************
; 打开文件
;********************************************************************
		invoke	CreateFile,addr szFileName,GENERIC_READ,FILE_SHARE_READ,0,\
			OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
		.if	eax ==	INVALID_HANDLE_VALUE
			invoke	MessageBox,hWinMain,addr szErrOpenFile,NULL,MB_OK or MB_ICONEXCLAMATION
			ret
		.endif
		mov	@hFile,eax
		invoke	GetFileSize,@hFile,NULL
		mov	@dwFileSize,eax
;********************************************************************
; 建立内存映射文件
;********************************************************************
		invoke	CreateFileMapping,@hFile,NULL,PAGE_READONLY,0,0,NULL
		.if	! eax
			invoke	MessageBox,hWinMain,addr szErrOpenFile,NULL,MB_OK or MB_ICONEXCLAMATION
			jmp	_Ret1
		.endif
		mov	@hFileMap,eax
		invoke	MapViewOfFile,eax,FILE_MAP_READ,0,0,0
		.if	! eax
			invoke	MessageBox,hWinMain,addr szErrOpenFile,NULL,MB_OK or MB_ICONEXCLAMATION
			jmp	_Ret2
		.endif
		mov	@lpMemory,eax
;********************************************************************
; 创建输出文件
;********************************************************************
		invoke	lstrcpy,addr @szNewFile,addr szFileName
		invoke	lstrcat,addr @szNewFile,addr szNewFile
		invoke	CreateFile,addr @szNewFile,GENERIC_WRITE,FILE_SHARE_READ,\
			0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if	eax ==	INVALID_HANDLE_VALUE
			invoke	MessageBox,hWinMain,addr szErrCreateFile,NULL,MB_OK or MB_ICONEXCLAMATION
			jmp	_Ret3
		.endif
		mov	@hFileNew,eax
;********************************************************************
; 在映射的内存中处理文件
;********************************************************************
		invoke	_FormatText,@lpMemory,@dwFileSize,@hFileNew

		invoke	CloseHandle,@hFileNew
		invoke	wsprintf,addr @szBuffer,addr szSuccees,addr @szNewFile
		invoke	MessageBox,hWinMain,addr @szBuffer,addr szSucceesCap,MB_OK
_Ret3:
		invoke	UnmapViewOfFile,@lpMemory
_Ret2:
		invoke	CloseHandle,@hFileMap
_Ret1:
		invoke	CloseHandle,@hFile
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
