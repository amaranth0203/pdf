;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Unwind.asm
;   演示 SEH 链的回卷操作
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff Unwind.asm
; Link /subsystem:windows Unwind.obj
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
szMsg1		db	'这是外层异常处理程序（将处理异常）',0dh,0ah
		db	'异常发生位置：%08X，异常代码：%08X，标志：%08X',0
szMsg2		db	'这是内层异常处理程序（对异常不进行处理）',0dh,0ah
		db	'异常发生位置：%08X，异常代码：%08X，标志：%08X',0
szCaption	db	'提示信息',0
szBeforeUnwind	db	'现在将开始 Unwind，当前的 FS:[0] = %08X',0
szAfterUnwind	db	'Unwind 返回，当前的 FS:[0] = %08X',0
szSafe1		db	'回到了外层子程序的安全位置!',0
szSafe2		db	'回到了内层子程序的安全位置!',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 外层错误 Handler，将处理异常
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Handler1	proc	C _lpExceptionRecord,_lpSEH,_lpContext,_lpDispatcherContext
		local	@szBuffer[256]:byte

		pushad
		mov	esi,_lpExceptionRecord
		mov	edi,_lpContext
		assume	esi:ptr EXCEPTION_RECORD,edi:ptr CONTEXT,fs:nothing
		invoke	wsprintf,addr @szBuffer,addr szMsg1,\
			[edi].regEip,[esi].ExceptionCode,[esi].ExceptionFlags
		invoke	MessageBox,NULL,addr @szBuffer,NULL,MB_OK
;********************************************************************
; 将 EIP 指向安全的位置并恢复堆栈
;********************************************************************
		mov	eax,_lpSEH
		push	[eax + 8]
		pop	[edi].regEip
		push	_lpSEH
		pop	[edi].regEsp
;********************************************************************
; 对前面的 Handler 进行 Unwind 操作
;********************************************************************
		invoke	wsprintf,addr @szBuffer,addr szBeforeUnwind,dword ptr fs:[0]
		invoke	MessageBox,NULL,addr @szBuffer,addr szCaption,MB_OK

		invoke	RtlUnwind,_lpSEH,NULL,NULL,NULL

		invoke	wsprintf,addr @szBuffer,addr szAfterUnwind,dword ptr fs:[0]
		invoke	MessageBox,NULL,addr @szBuffer,addr szCaption,MB_OK
;********************************************************************
		assume	esi:nothing,edi:nothing
		popad
		mov	eax,ExceptionContinueExecution
		ret

_Handler1	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 内层错误 Handler，不处理异常
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Handler2	proc	C _lpExceptionRecord,_lpSEH,_lpContext,_lpDispatcherContext
		local	@szBuffer[256]:byte

		pushad
		mov	esi,_lpExceptionRecord
		mov	edi,_lpContext
		assume	esi:ptr EXCEPTION_RECORD,edi:ptr CONTEXT
		invoke	wsprintf,addr @szBuffer,addr szMsg2,\
			[edi].regEip,[esi].ExceptionCode,[esi].ExceptionFlags
		invoke	MessageBox,NULL,addr @szBuffer,NULL,MB_OK
		assume	esi:nothing,edi:nothing
		popad
		mov	eax,ExceptionContinueSearch
		ret

_Handler2	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Test2		proc

		assume	fs:nothing
		push	offset _SafePlace
		push	offset _Handler2
		push	fs:[0]
		mov	fs:[0],esp
;********************************************************************
; 会引发异常的指令
;********************************************************************
		pushad
		xor	eax,eax
		mov	dword ptr [eax],0
		popad		;这一句将无法被执行
_SafePlace:
		invoke	MessageBox,NULL,addr szSafe2,addr szCaption,MB_OK
		pop	fs:[0]
		add	esp,8
		ret

_Test2		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Test1		proc

		assume	fs:nothing
		push	offset _SafePlace
		push	offset _Handler1
		push	fs:[0]
		mov	fs:[0],esp
		invoke	_Test2
_SafePlace:
		invoke	MessageBox,NULL,addr szSafe1,addr szCaption,MB_OK
		pop	fs:[0]
		add	esp,8
		ret

_Test1		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		invoke	_Test1
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
