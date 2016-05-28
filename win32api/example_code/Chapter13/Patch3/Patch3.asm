;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Patch3.asm
; 使用单步跟踪跳过 Test.exe 上的压缩外壳代码，再进行内存补丁的例子程序
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff Patch3.asm
; rc Patch3.rc
; Link /subsystem:windows Patch3.obj Patch3.res
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.586
		.model flat, stdcall
		option casemap :none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include 数据
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		user32.inc
include		kernel32.inc
includelib	user32.lib
includelib	kernel32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
BREAK_POINT1	equ	0040526Eh
PATCH_POSITION	equ	00401004h
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
align		dword
stCT		CONTEXT		<?>
stDE		DEBUG_EVENT	<?>
stStartUp	STARTUPINFO		<>
stProcInfo	PROCESS_INFORMATION	<>
dwTemp		dd	?
szBuffer	db	1024 dup (?)

		.const
dbPatched	db	90h,90h
dbInt3		db	0cch
dbOldByte	db	61h
szExecFilename	db	'Test.exe',0
szErrExec	db	'无法装载执行文件!',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
Start:
;********************************************************************
; 创建进程
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
; 调试进程
;********************************************************************
		.while	TRUE
			invoke	WaitForDebugEvent,addr stDE,INFINITE
			.break	.if stDE.dwDebugEventCode == EXIT_PROCESS_DEBUG_EVENT
;********************************************************************
; 如果进程开始，则将入口地址处的代码改为 int 3 断点中断
;********************************************************************
			.if	stDE.dwDebugEventCode == CREATE_PROCESS_DEBUG_EVENT
				invoke	WriteProcessMemory,stProcInfo.hProcess,\
					BREAK_POINT1,addr dbInt3,1,addr dwTemp
;********************************************************************
; 如果发生断点中断，则恢复断点处代码并进行内存补丁
;********************************************************************
			.elseif	stDE.dwDebugEventCode == EXCEPTION_DEBUG_EVENT
				.if	stDE.u.Exception.pExceptionRecord.ExceptionCode == EXCEPTION_BREAKPOINT
					mov	stCT.ContextFlags,CONTEXT_FULL
					invoke	GetThreadContext,stProcInfo.hThread,addr stCT
					.if	stCT.regEip == BREAK_POINT1 + 1
						dec	stCT.regEip
						invoke	WriteProcessMemory,stProcInfo.hProcess,\
							BREAK_POINT1,addr dbOldByte,1,addr dwTemp
						invoke	SetThreadContext,stProcInfo.hThread,addr stCT
						invoke	WriteProcessMemory,stProcInfo.hProcess,\
							PATCH_POSITION,addr dbPatched,sizeof dbPatched,addr dwTemp
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
