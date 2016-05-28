;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Patch1.asm
; 内存补丁例子一：对 Test.exe 进行内存补丁
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff Patch1.asm
; rc Patch1.rc
; Link /subsystem:windows Patch1.obj Patch1.res
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.386
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
PATCH_POSITION	equ	00401004h
PATCH_BYTES	equ	2
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
dbOldBytes	db	PATCH_BYTES dup (?)
stStartUp	STARTUPINFO		<?>
stProcInfo	PROCESS_INFORMATION	<?>

		.const
dbPatch		db	74h,15h
dbPatched	db	90h,90h
szExecFilename	db	'Test.exe',0
szErrExec	db	'无法装载执行文件!',0
szErrVersion	db	'执行文件的版本不正确，无法修正!',0
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
			NORMAL_PRIORITY_CLASS or CREATE_SUSPENDED,NULL,NULL,\
			offset stStartUp,offset stProcInfo
		.if	eax
;********************************************************************
; 读进程内存并验证内容是否正确
;********************************************************************
			invoke	ReadProcessMemory,stProcInfo.hProcess,PATCH_POSITION,\
				addr dbOldBytes,PATCH_BYTES,NULL
			.if	eax
				mov	ax,word ptr dbOldBytes
				.if	ax ==	word ptr dbPatch
					invoke	WriteProcessMemory,stProcInfo.hProcess,\
						PATCH_POSITION,addr dbPatched,PATCH_BYTES,NULL
					invoke	ResumeThread,stProcInfo.hThread
				.else
					invoke	TerminateProcess,stProcInfo.hProcess,-1
					invoke	MessageBox,NULL,addr szErrVersion,NULL,MB_OK or MB_ICONSTOP
				.endif
			.endif
			invoke	CloseHandle,stProcInfo.hProcess
			invoke	CloseHandle,stProcInfo.hThread
		.else
			invoke	MessageBox,NULL,addr szErrExec,NULL,MB_OK or MB_ICONSTOP
		.endif
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	Start
