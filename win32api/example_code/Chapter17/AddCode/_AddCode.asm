;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 要被添加到目标文件后面的执行代码
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 一些函数的原形定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProtoGetProcAddress	typedef	proto	:dword,:dword
_ProtoLoadLibrary	typedef	proto	:dword
_ProtoMessageBox	typedef	proto	:dword,:dword,:dword,:dword
_ApiGetProcAddress	typedef	ptr	_ProtoGetProcAddress
_ApiLoadLibrary		typedef	ptr	_ProtoLoadLibrary
_ApiMessageBox		typedef	ptr	_ProtoMessageBox
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;
APPEND_CODE	equ	this byte
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 被添加到目标文件中的代码从这里开始
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		_GetKernel.asm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
hDllKernel32	dd	?
hDllUser32	dd	?
_GetProcAddress	_ApiGetProcAddress	?
_LoadLibrary	_ApiLoadLibrary		?
_MessageBox	_ApiMessageBox		?
szLoadLibrary	db	'LoadLibraryA',0
szGetProcAddress db	'GetProcAddress',0
szUser32	db	'user32',0
szMessageBox	db	'MessageBoxA',0
szCaption	db	'问题提示',0
szText		db	'你一定要运行这个程序吗?',0
;********************************************************************
; 新的入口地址
;********************************************************************
_NewEntry:
;********************************************************************
; 重定位并获取一些 API 的入口地址
;********************************************************************
		call	@F
		@@:
		pop	ebx
		sub	ebx,offset @B
;********************************************************************
		invoke	_GetKernelBase,[esp]	;获取Kernel32.dll基址
		.if	! eax
			jmp	_ToOldEntry
		.endif
		mov	[ebx+hDllKernel32],eax	;获取GetProcAddress入口
		lea	eax,[ebx+szGetProcAddress]
		invoke	_GetApi,[ebx+hDllKernel32],eax
		.if	! eax
			jmp	_ToOldEntry
		.endif
		mov	[ebx+_GetProcAddress],eax
;********************************************************************
		lea	eax,[ebx+szLoadLibrary]	;获取LoadLibrary入口
		invoke	[ebx+_GetProcAddress],[ebx+hDllKernel32],eax
		mov	[ebx+_LoadLibrary],eax
		lea	eax,[ebx+szUser32]	;获取User32.dll基址
		invoke	[ebx+_LoadLibrary],eax
		mov	[ebx+hDllUser32],eax
		lea	eax,[ebx+szMessageBox]	;获取MessageBox入口
		invoke	[ebx+_GetProcAddress],[ebx+hDllUser32],eax
		mov	[ebx+_MessageBox],eax
;********************************************************************
		lea	ecx,[ebx+szText]
		lea	eax,[ebx+szCaption]
		invoke	[ebx+_MessageBox],NULL,ecx,eax,MB_YESNO or MB_ICONQUESTION
		.if	eax !=	IDYES
			ret
		.endif
;********************************************************************
; 执行原来的文件
;********************************************************************
_ToOldEntry:
		db	0e9h	;0e9h是jmp xxxxxxxx的机器码
_dwOldEntry:
		dd	?	;用来填入原来的入口地址
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
APPEND_CODE_END	equ	this byte
