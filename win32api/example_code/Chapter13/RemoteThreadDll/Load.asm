;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Load.asm
; 利用远程进程函数将一个 dll 文件嵌入远程进程中执行
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff Load.asm
; rc Load.rc
; Link  /subsystem:windows Load.obj Load.res
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
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
dwProcessID	dd	?
dwThreadID	dd	?
hProcess	dd	?
lpLoadLibrary	dd	?
lpDllName	dd	?
szMyDllFull	db	MAX_PATH dup (?)

		.const
szErrOpen	db	'无法打开远程线程!',0
szDesktopClass	db	'Progman',0
szDesktopWindow	db	'Program Manager',0
szDllKernel	db	'Kernel32.dll',0
szLoadLibrary	db	'LoadLibraryA',0
szMyDll		db	'\Dll.dll',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
;********************************************************************
; 准备工作：获取dll的全路径文件名、获取LoadLibrary函数地址等
;********************************************************************
		invoke	GetCurrentDirectory,MAX_PATH,addr szMyDllFull
		invoke	lstrcat,addr szMyDllFull,addr szMyDll
		invoke	GetModuleHandle,addr szDllKernel
		invoke	GetProcAddress,eax,offset szLoadLibrary
		mov	lpLoadLibrary,eax
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
; 在进程中分配空间并将DLL文件名拷贝过去，然后创建一个LoadLibrary线程
;********************************************************************
			invoke	VirtualAllocEx,hProcess,NULL,MAX_PATH,MEM_COMMIT,PAGE_READWRITE
			.if	eax
				mov	lpDllName,eax
				invoke	WriteProcessMemory,hProcess,\
					eax,offset szMyDllFull,MAX_PATH,NULL
				invoke	CreateRemoteThread,hProcess,NULL,0,lpLoadLibrary,\
					lpDllName,0,NULL
				invoke	CloseHandle,eax
			.endif
			invoke	CloseHandle,hProcess
		.else
			invoke	MessageBox,NULL,addr szErrOpen,NULL,MB_OK or MB_ICONWARNING
		.endif
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
