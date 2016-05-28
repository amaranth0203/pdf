;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; RemoteThread.asm
; 向 Explorer.exe 进程中嵌入一段远程执行的代码
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff RemoteThread.asm
; rc RemoteThread.rc
; Link /subsystem:windows RemoteThread.obj RemoteThread.res
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
include		Macro.inc
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
lpLoadLibrary	dd	?
lpGetProcAddress dd	?
lpGetModuleHandle dd	?
dwProcessID	dd	?
dwThreadID	dd	?
hProcess	dd	?
lpRemoteCode	dd	?

		.const
szErrOpen	db	'无法打开远程线程!',0
szDesktopClass	db	'Progman',0
szDesktopWindow	db	'Program Manager',0
szDllKernel	db	'Kernel32.dll',0
szLoadLibrary	db	'LoadLibraryA',0
szGetProcAddress db	'GetProcAddress',0
szGetModuleHandle db	'GetModuleHandleA',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

include		RemoteCode.asm

start:
		invoke	GetModuleHandle,addr szDllKernel
		mov	ebx,eax
		invoke	GetProcAddress,ebx,offset szLoadLibrary
		mov	lpLoadLibrary,eax
		invoke	GetProcAddress,ebx,offset szGetProcAddress
		mov	lpGetProcAddress,eax
		invoke	GetProcAddress,ebx,offset szGetModuleHandle
		mov	lpGetModuleHandle,eax
;********************************************************************
; 查找文件管理器窗口并获取进程ID，然后打开进程
;********************************************************************
		invoke	FindWindow,addr szDesktopClass,addr szDesktopWindow
		invoke	GetWindowThreadProcessId,eax,offset dwProcessID
		mov	dwThreadID,eax
		invoke	OpenProcess,PROCESS_CREATE_THREAD or PROCESS_VM_OPERATION or \
			PROCESS_VM_WRITE,FALSE,dwProcessID
		.if	eax
			mov	hProcess,eax
;********************************************************************
; 在进程中分配空间并将执行代码拷贝过去，然后创建一个远程线程
;********************************************************************
			invoke	VirtualAllocEx,hProcess,NULL,REMOTE_CODE_LENGTH,MEM_COMMIT,PAGE_EXECUTE_READWRITE
			.if	eax
				mov	lpRemoteCode,eax
				invoke	WriteProcessMemory,hProcess,lpRemoteCode,\
					offset REMOTE_CODE_START,REMOTE_CODE_LENGTH,NULL
				invoke	WriteProcessMemory,hProcess,lpRemoteCode,\
					offset lpLoadLibrary,sizeof dword * 3,NULL
				mov	eax,lpRemoteCode
				add	eax,offset _RemoteThread - offset REMOTE_CODE_START
				invoke	CreateRemoteThread,hProcess,NULL,0,eax,0,0,NULL
				invoke	CloseHandle,eax
			.endif
			invoke	CloseHandle,hProcess
		.else
			invoke	MessageBox,NULL,addr szErrOpen,NULL,MB_OK or MB_ICONWARNING
		.endif
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
