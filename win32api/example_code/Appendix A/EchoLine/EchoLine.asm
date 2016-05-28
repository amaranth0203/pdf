;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; EchoLine.asm
; ����̨�������� -- ��������ַ�ԭ�ⲻ����ʾ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
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
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hStdIn		dd	?		;����̨������
hStdOut		dd	?		;����̨������
szBuffer	db	1024 dup (?)
dwBytesRead	dd	?
dwBytesWrite	dd	?
		.const
szTitle		db	'EchoLine����',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ����̨ Ctrl-C ��������
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
; ��ȡ����̨��������þ������
;********************************************************************
		invoke	GetStdHandle,STD_INPUT_HANDLE
		mov	hStdIn,eax
		invoke	GetStdHandle,STD_OUTPUT_HANDLE
		mov	hStdOut,eax
		invoke	SetConsoleMode,hStdIn,ENABLE_LINE_INPUT or ENABLE_ECHO_INPUT or ENABLE_PROCESSED_INPUT
		invoke	SetConsoleCtrlHandler,addr _CtrlHandler,TRUE

		invoke	SetConsoleTitle,addr szTitle
;********************************************************************
; ѭ����ȡ����̨���벢��ʾ
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
