;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; TopHandler.asm
; 最高层异常处理
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff TopHandler.asm
; Link /subsystem:windows TopHandler.obj
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.386
		.model flat,stdcall
		option casemap:none
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
		.data
lpOldHandler	dd	?

		.const

szMsg		db	'异常发生位置：%08X，异常代码：%08X，标志：%08X',0
szSafe		db	'回到了安全的地方!',0
szCaption	db	'筛选器异常处理的例子',0

		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Exception Handler 异常处理程序
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Handler	proc	_lpExceptionPoint
		local	@szBuffer[256]:byte

		pushad
		mov	esi,_lpExceptionPoint
		assume	esi:ptr EXCEPTION_POINTERS
		mov	edi,[esi].ContextRecord
		mov	esi,[esi].pExceptionRecord
		assume	esi:ptr EXCEPTION_RECORD,edi:ptr CONTEXT
		invoke	wsprintf,addr @szBuffer,addr szMsg,\
			[edi].regEip,[esi].ExceptionCode,[esi].ExceptionFlags
		invoke	MessageBox,NULL,addr @szBuffer,NULL,MB_OK
		mov	[edi].regEip,offset _SafePlace
		assume	esi:nothing,edi:nothing
		popad
		mov	eax,EXCEPTION_CONTINUE_EXECUTION
		ret

_Handler	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		invoke	SetUnhandledExceptionFilter,addr _Handler
		mov	lpOldHandler,eax
;********************************************************************
; 会引发异常的指令
;********************************************************************
		xor	eax,eax
		mov	dword ptr [eax],0	;产生异常，然后_Handler被调用
;		...
; 如果这中间有指令，这些指令将不会被执行!
;		...
_SafePlace:
		invoke	MessageBox,NULL,addr szSafe,addr szCaption,MB_OK
		invoke	SetUnhandledExceptionFilter,lpOldHandler
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
