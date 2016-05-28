;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; TopHandler.asm
; ��߲��쳣����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff TopHandler.asm
; Link /subsystem:windows TopHandler.obj
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.386
		.model flat,stdcall
		option casemap:none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include �ļ�����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data
lpOldHandler	dd	?

		.const

szMsg		db	'�쳣����λ�ã�%08X���쳣���룺%08X����־��%08X',0
szSafe		db	'�ص��˰�ȫ�ĵط�!',0
szCaption	db	'ɸѡ���쳣���������',0

		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Exception Handler �쳣�������
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
; �������쳣��ָ��
;********************************************************************
		xor	eax,eax
		mov	dword ptr [eax],0	;�����쳣��Ȼ��_Handler������
;		...
; ������м���ָ���Щָ����ᱻִ��!
;		...
_SafePlace:
		invoke	MessageBox,NULL,addr szSafe,addr szCaption,MB_OK
		invoke	SetUnhandledExceptionFilter,lpOldHandler
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
