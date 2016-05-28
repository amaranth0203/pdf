;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Load.asm
; ����Զ�̽��̺�����һ�� dll �ļ�Ƕ��Զ�̽�����ִ��
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff Load.asm
; rc Load.rc
; Link  /subsystem:windows Load.obj Load.res
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
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
dwProcessID	dd	?
dwThreadID	dd	?
hProcess	dd	?
lpLoadLibrary	dd	?
lpDllName	dd	?
szMyDllFull	db	MAX_PATH dup (?)

		.const
szErrOpen	db	'�޷���Զ���߳�!',0
szDesktopClass	db	'Progman',0
szDesktopWindow	db	'Program Manager',0
szDllKernel	db	'Kernel32.dll',0
szLoadLibrary	db	'LoadLibraryA',0
szMyDll		db	'\Dll.dll',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
;********************************************************************
; ׼����������ȡdll��ȫ·���ļ�������ȡLoadLibrary������ַ��
;********************************************************************
		invoke	GetCurrentDirectory,MAX_PATH,addr szMyDllFull
		invoke	lstrcat,addr szMyDllFull,addr szMyDll
		invoke	GetModuleHandle,addr szDllKernel
		invoke	GetProcAddress,eax,offset szLoadLibrary
		mov	lpLoadLibrary,eax
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
; �ڽ����з���ռ䲢��DLL�ļ���������ȥ��Ȼ�󴴽�һ��LoadLibrary�߳�
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
