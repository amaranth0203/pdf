;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Patch2.asm
; ʹ�öϵ�͵����������� Test.exe �ϵ�ѹ����Ǵ��룬�ٽ����ڴ油��
; �����ӳ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff Patch2.asm
; rc Patch2.rc
; Link /subsystem:windows Patch2.obj Patch2.res
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.586
		.model flat, stdcall
		option casemap :none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		user32.inc
include		kernel32.inc
includelib	user32.lib
includelib	kernel32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
BREAK_POINT1	equ	00405120h
BREAK_POINT2	equ	00401000h
PATCH_POSITION	equ	00401004h
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
align		dword
stCT		CONTEXT		<?>
stDE		DEBUG_EVENT	<?>
stStartUp	STARTUPINFO		<>
stProcInfo	PROCESS_INFORMATION	<>
szBuffer	db	1024 dup (?)

		.const
dbPatched	db	90h,90h
dbInt3		db	0cch
dbOldByte	db	60h
szExecFilename	db	'Test.exe',0
szErrExec	db	'�޷�װ��ִ���ļ�!',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
Start:
;********************************************************************
; ��������
;********************************************************************
		invoke	GetStartupInfo,addr stStartUp
		invoke	CreateProcess,offset szExecFilename,NULL,NULL,NULL,NULL,\
			DEBUG_PROCESS or DEBUG_ONLY_THIS_PROCESS,NULL,NULL,\
			offset stStartUp,offset stProcInfo
		.if	!eax
			invoke	MessageBox,NULL,addr szErrExec,NULL,MB_OK or MB_ICONSTOP
			invoke	ExitProcess,NULL
		.endif
;********************************************************************
; ���Խ���
;********************************************************************
		.while	TRUE
			invoke	WaitForDebugEvent,addr stDE,INFINITE
			.break	.if stDE.dwDebugEventCode == EXIT_PROCESS_DEBUG_EVENT
;********************************************************************
; ������̿�ʼ������ڵ�ַ���Ĵ����Ϊ int 3 �ϵ��ж�
;********************************************************************
			.if	stDE.dwDebugEventCode == CREATE_PROCESS_DEBUG_EVENT
				invoke	WriteProcessMemory,stProcInfo.hProcess,\
					BREAK_POINT1,addr dbInt3,1,NULL
;********************************************************************
; ��������ϵ��жϣ���ָ��ϵ㴦���벢���õ����ж�
;********************************************************************
			.elseif	stDE.dwDebugEventCode == EXCEPTION_DEBUG_EVENT
				.if	stDE.u.Exception.pExceptionRecord.ExceptionCode == EXCEPTION_BREAKPOINT
					mov	stCT.ContextFlags,CONTEXT_FULL
					invoke	GetThreadContext,stProcInfo.hThread,addr stCT
					.if	stCT.regEip == BREAK_POINT1 + 1
						dec	stCT.regEip
						invoke	WriteProcessMemory,stProcInfo.hProcess,\
							BREAK_POINT1,addr dbOldByte,1,NULL
						or	stCT.regFlag,100h
						invoke	SetThreadContext,stProcInfo.hThread,addr stCT
					.endif
;********************************************************************
; ��������жϵ���ָ��λ�ã�������ڴ油��
;********************************************************************
				.elseif	stDE.u.Exception.pExceptionRecord.ExceptionCode == EXCEPTION_SINGLE_STEP
					mov	stCT.ContextFlags,CONTEXT_FULL
					invoke	GetThreadContext,stProcInfo.hThread,addr stCT
					.if	stCT.regEip == BREAK_POINT2
						invoke	WriteProcessMemory,stProcInfo.hProcess,\
							PATCH_POSITION,addr dbPatched,sizeof dbPatched,NULL
					.else
						or	stCT.regFlag,100h
						invoke	SetThreadContext,stProcInfo.hThread,addr stCT
					.endif
				.endif
			.endif
			invoke	ContinueDebugEvent,stDE.dwProcessId,stDE.dwThreadId,DBG_CONTINUE
		.endw
		invoke	CloseHandle,stProcInfo.hProcess
		invoke	CloseHandle,stProcInfo.hThread
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	Start
