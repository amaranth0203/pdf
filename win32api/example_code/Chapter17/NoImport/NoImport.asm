;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; NoImport.asm
; 以从内存中动态获取的办法使用 API
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff NoImport.asm
; Link /subsystem:windows NoImport.com
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.386
		.model flat,stdcall
		option casemap:none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc

_ProtoGetProcAddress	typedef	proto	:dword,:dword
_ProtoLoadLibrary	typedef	proto	:dword
_ProtoMessageBox	typedef	proto	:dword,:dword,:dword,:dword
_ApiGetProcAddress	typedef	ptr	_ProtoGetProcAddress
_ApiLoadLibrary		typedef	ptr	_ProtoLoadLibrary
_ApiMessageBox		typedef	ptr	_ProtoMessageBox
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hDllKernel32	dd	?
hDllUser32	dd	?
_GetProcAddress	_ApiGetProcAddress	?
_LoadLibrary	_ApiLoadLibrary		?
_MessageBox	_ApiMessageBox		?

		.const
szLoadLibrary	db	'LoadLibraryA',0
szGetProcAddress db	'GetProcAddress',0
szUser32	db	'user32',0
szMessageBox	db	'MessageBoxA',0

szCaption	db	'A MessageBox !',0
szText		db	'Hello, World !',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
include		_GetKernel.asm
start:
;********************************************************************
; 从堆栈中的 Ret 地址转换 Kernel32.dll 的基址，并在 Kernel32.dll
; 的导出表中查找 GetProcAddress 函数的入口地址
;********************************************************************
		invoke	_GetKernelBase,[esp]
		.if	eax
			mov	hDllKernel32,eax
			invoke	_GetApi,hDllKernel32,addr szGetProcAddress
			mov	_GetProcAddress,eax
		.endif
;********************************************************************
; 用得到的 GetProcAddress 函数得到 LoadLibrary 函数地址并装入其他 Dll
;********************************************************************
		.if	_GetProcAddress
			invoke	_GetProcAddress,hDllKernel32,addr szLoadLibrary
			mov	_LoadLibrary,eax
			.if	eax
				invoke	_LoadLibrary,addr szUser32
				mov	hDllUser32,eax
				invoke	_GetProcAddress,hDllUser32,addr szMessageBox
				mov	_MessageBox,eax
			.endif
		.endif
;********************************************************************
		.if	_MessageBox
			invoke	_MessageBox,NULL,offset szText,offset szCaption,MB_OK
		.endif
		ret
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
