;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; NoImport.asm
; �Դ��ڴ��ж�̬��ȡ�İ취ʹ�� API
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
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
; ���ݶ�
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
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
include		_GetKernel.asm
start:
;********************************************************************
; �Ӷ�ջ�е� Ret ��ַת�� Kernel32.dll �Ļ�ַ������ Kernel32.dll
; �ĵ������в��� GetProcAddress ��������ڵ�ַ
;********************************************************************
		invoke	_GetKernelBase,[esp]
		.if	eax
			mov	hDllKernel32,eax
			invoke	_GetApi,hDllKernel32,addr szGetProcAddress
			mov	_GetProcAddress,eax
		.endif
;********************************************************************
; �õõ��� GetProcAddress �����õ� LoadLibrary ������ַ��װ������ Dll
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
