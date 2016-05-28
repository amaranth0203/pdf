;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ProcessList.asm
; 列出系统中当前运行的进程
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff ProcessList.asm
; rc ProcessList.rc
; Link /subsystem:windows ProcessList.obj ProcessList.res
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
ICO_MAIN	equ	1000
DLG_MAIN	equ	1000
IDC_PROCESS	equ 	1001
IDC_REFRESH	equ 	1002
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd	?
hWinList	dd	?

		.const
szErrTerminate	db	'无法结束指定进程!',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_GetProcessList	proc	_hWnd
		local	@stProcess:PROCESSENTRY32
		local	@hSnapShot

		invoke	RtlZeroMemory,addr @stProcess,sizeof @stProcess
		invoke	SendMessage,hWinList,LB_RESETCONTENT,0,0
		mov	@stProcess.dwSize,sizeof @stProcess
		invoke	CreateToolhelp32Snapshot,TH32CS_SNAPPROCESS,0
		mov	@hSnapShot,eax
		invoke	Process32First,@hSnapShot,addr @stProcess
		.while	eax
			invoke	SendMessage,hWinList,LB_ADDSTRING,0,addr @stProcess.szExeFile
			invoke	SendMessage,hWinList,LB_SETITEMDATA,eax,@stProcess.th32ProcessID
			invoke	Process32Next,@hSnapShot,addr @stProcess
		.endw
		invoke	CloseHandle,@hSnapShot
		invoke	GetDlgItem,_hWnd,IDOK
		invoke	EnableWindow,eax,FALSE
		ret

_GetProcessList	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam

		mov	eax,wMsg
		.if	eax == WM_CLOSE
			invoke	EndDialog,hWnd,NULL
		.elseif	eax == WM_INITDIALOG
			invoke	GetDlgItem,hWnd,IDC_PROCESS
			mov	hWinList,eax
			invoke	_GetProcessList,hWnd
;********************************************************************
		.elseif	eax == WM_COMMAND
			mov	eax,wParam
			.if	ax ==	IDOK
				invoke	SendMessage,hWinList,LB_GETCURSEL,0,0
				invoke	SendMessage,hWinList,LB_GETITEMDATA,eax,0
				invoke	OpenProcess,PROCESS_TERMINATE,FALSE,eax
				.if	eax
					mov	ebx,eax
					invoke	TerminateProcess,ebx,-1
					invoke	CloseHandle,ebx
					invoke	Sleep,200
					invoke	_GetProcessList,hWnd
					jmp	@F
				.endif
				invoke	MessageBox,hWnd,addr szErrTerminate,NULL,MB_OK or MB_ICONWARNING
				@@:
;********************************************************************
			.elseif	ax ==	IDC_REFRESH
				invoke	_GetProcessList,hWnd
;********************************************************************
			.elseif	ax ==	IDC_PROCESS
				shr	eax,16
				.if	ax ==	LBN_SELCHANGE
					invoke	GetDlgItem,hWnd,IDOK
					invoke	EnableWindow,eax,TRUE
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
