;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; RemoteThread.asm
; �� Explorer.exe ������Ƕ��һ��Զ��ִ�еĴ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff RemoteThread.asm
; rc RemoteThread.rc
; Link /subsystem:windows RemoteThread.obj RemoteThread.res
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
include		Macro.inc
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
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
szErrOpen	db	'�޷���Զ���߳�!',0
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
; �����ļ����������ڲ���ȡ����ID��Ȼ��򿪽���
;********************************************************************
		invoke	FindWindow,addr szDesktopClass,addr szDesktopWindow
		invoke	GetWindowThreadProcessId,eax,offset dwProcessID
		mov	dwThreadID,eax
		invoke	OpenProcess,PROCESS_CREATE_THREAD or PROCESS_VM_OPERATION or \
			PROCESS_VM_WRITE,FALSE,dwProcessID
		.if	eax
			mov	hProcess,eax
;********************************************************************
; �ڽ����з���ռ䲢��ִ�д��뿽����ȥ��Ȼ�󴴽�һ��Զ���߳�
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
