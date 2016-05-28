;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; EchoLine.asm
; 控制台程序例子 -- 将输入的字符原封不动显示处理
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff EchoLine.asm
; Link /SUBSYSTEM:CONSOLE EchoLine.obj
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.386
		.model flat, stdcall
		option casemap :none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		kernel32.inc
includelib	kernel32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hStdIn		dd	?		;控制台输入句柄
hStdOut		dd	?		;控制台输出句柄
szBuffer	db	1024 dup (?)
dwBytesRead	dd	?
dwBytesWrite	dd	?
		.const
szTitle		db	'EchoLine例子',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 控制台 Ctrl-C 捕获例程
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_CtrlHandler	proc	_dwCtrlType

		pushad
		mov	eax,_dwCtrlType
		.if	eax ==	CTRL_C_EVENT || eax == CTRL_BREAK_EVENT
			invoke	CloseHandle,hStdIn
		.endif
		popad
		mov	eax,TRUE
		ret

_CtrlHandler	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
;********************************************************************
; 获取控制台句柄、设置句柄属性
;********************************************************************
		invoke	GetStdHandle,STD_INPUT_HANDLE
		mov	hStdIn,eax
		invoke	GetStdHandle,STD_OUTPUT_HANDLE
		mov	hStdOut,eax
		invoke	SetConsoleMode,hStdIn,ENABLE_LINE_INPUT or ENABLE_ECHO_INPUT or ENABLE_PROCESSED_INPUT
		invoke	SetConsoleCtrlHandler,addr _CtrlHandler,TRUE

		invoke	SetConsoleTitle,addr szTitle
;********************************************************************
; 循环读取控制台输入并显示
;********************************************************************
		.while	TRUE
			invoke	SetConsoleTextAttribute,hStdOut,FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_BLUE
			invoke	ReadConsole,hStdIn,addr szBuffer,sizeof szBuffer,\
				addr dwBytesRead,NULL
			.break	.if ! eax

			invoke	SetConsoleTextAttribute,hStdOut,FOREGROUND_BLUE or FOREGROUND_INTENSITY
			invoke	WriteConsole,hStdOut,addr szBuffer,dwBytesRead,\
				addr dwBytesWrite,NULL
		.endw
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
