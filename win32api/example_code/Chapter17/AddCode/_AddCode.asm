;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Ҫ����ӵ�Ŀ���ļ������ִ�д���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; һЩ������ԭ�ζ���
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
; ����ӵ�Ŀ���ļ��еĴ�������￪ʼ
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
szCaption	db	'������ʾ',0
szText		db	'��һ��Ҫ�������������?',0
;********************************************************************
; �µ���ڵ�ַ
;********************************************************************
_NewEntry:
;********************************************************************
; �ض�λ����ȡһЩ API ����ڵ�ַ
;********************************************************************
		call	@F
		@@:
		pop	ebx
		sub	ebx,offset @B
;********************************************************************
		invoke	_GetKernelBase,[esp]	;��ȡKernel32.dll��ַ
		.if	! eax
			jmp	_ToOldEntry
		.endif
		mov	[ebx+hDllKernel32],eax	;��ȡGetProcAddress���
		lea	eax,[ebx+szGetProcAddress]
		invoke	_GetApi,[ebx+hDllKernel32],eax
		.if	! eax
			jmp	_ToOldEntry
		.endif
		mov	[ebx+_GetProcAddress],eax
;********************************************************************
		lea	eax,[ebx+szLoadLibrary]	;��ȡLoadLibrary���
		invoke	[ebx+_GetProcAddress],[ebx+hDllKernel32],eax
		mov	[ebx+_LoadLibrary],eax
		lea	eax,[ebx+szUser32]	;��ȡUser32.dll��ַ
		invoke	[ebx+_LoadLibrary],eax
		mov	[ebx+hDllUser32],eax
		lea	eax,[ebx+szMessageBox]	;��ȡMessageBox���
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
; ִ��ԭ�����ļ�
;********************************************************************
_ToOldEntry:
		db	0e9h	;0e9h��jmp xxxxxxxx�Ļ�����
_dwOldEntry:
		dd	?	;��������ԭ������ڵ�ַ
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
APPEND_CODE_END	equ	this byte
