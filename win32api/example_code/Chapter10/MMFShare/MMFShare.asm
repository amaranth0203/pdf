;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; MMFShare.asm
; 使用内存映射文件进行进程间数据共享
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff MMFShare.asm
; rc MMFShare.rc
; Link /subsystem:windows MMFShare.obj MMFShare.res
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
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equ 等值定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN	equ		1000
DLG_MAIN	equ		100
IDC_TXT		equ		101
IDC_INFO	equ		102
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?

hInstance	dd	?
hWinMain	dd	?
hFileMap	dd	?
lpMemory	dd	?

		.const
szErr		db	'无法建立内存共享文件',0
szMMFName	db	'MMF_Share_Example',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_CreateMMF	proc

		invoke	OpenFileMapping,FILE_MAP_READ or FILE_MAP_WRITE,0,addr szMMFName
		.if	! eax
			invoke	CreateFileMapping,-1,NULL,PAGE_READWRITE,0,4096,addr szMMFName
			.if	! eax
				jmp	@F
			.endif
		.endif
		mov	hFileMap,eax
		invoke	MapViewOfFile,eax,FILE_MAP_READ or FILE_MAP_WRITE,0,0,0
		.if	eax
			mov	lpMemory,eax
			mov	dword ptr [eax],0
			ret
		.endif
		invoke	CloseHandle,hFileMap
@@:
		invoke	MessageBox,hWinMain,addr szErr,NULL,MB_OK
		invoke	EndDialog,hWinMain,-1
		ret

_CreateMMF	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_CloseMMF	proc

		invoke	UnmapViewOfFile,lpMemory
		invoke	CloseHandle,hFileMap
		mov	lpMemory,0
		mov	hFileMap,0
		ret

_CloseMMF	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@szBuffer[4096]:byte

		mov	eax,wMsg
		.if	eax ==	WM_TIMER
			invoke	SetDlgItemText,hWnd,IDC_INFO,lpMemory
		.elseif	eax ==	WM_CLOSE
			invoke	KillTimer,hWnd,1
			invoke	_CloseMMF
			invoke	EndDialog,hWinMain,0
;********************************************************************
		.elseif	eax ==	WM_INITDIALOG
			push	hWnd
			pop	hWinMain
			invoke	LoadIcon,hInstance,ICO_MAIN
			invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
			invoke	SendDlgItemMessage,hWnd,IDC_TXT,EM_SETLIMITTEXT,100,0
			invoke	_CreateMMF
			invoke	SetTimer,hWnd,1,200,NULL
;********************************************************************
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
			.if	ax ==	IDC_TXT && lpMemory
				invoke	GetDlgItemText,hWnd,IDC_TXT,lpMemory,4096
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
