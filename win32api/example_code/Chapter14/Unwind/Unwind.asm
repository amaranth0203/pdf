;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Unwind.asm
;   ��ʾ SEH ���Ļؾ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff Unwind.asm
; Link /subsystem:windows Unwind.obj
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
szMsg1		db	'��������쳣������򣨽������쳣��',0dh,0ah
		db	'�쳣����λ�ã�%08X���쳣���룺%08X����־��%08X',0
szMsg2		db	'�����ڲ��쳣������򣨶��쳣�����д���',0dh,0ah
		db	'�쳣����λ�ã�%08X���쳣���룺%08X����־��%08X',0
szCaption	db	'��ʾ��Ϣ',0
szBeforeUnwind	db	'���ڽ���ʼ Unwind����ǰ�� FS:[0] = %08X',0
szAfterUnwind	db	'Unwind ���أ���ǰ�� FS:[0] = %08X',0
szSafe1		db	'�ص�������ӳ���İ�ȫλ��!',0
szSafe2		db	'�ص����ڲ��ӳ���İ�ȫλ��!',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ������ Handler���������쳣
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
; �� EIP ָ��ȫ��λ�ò��ָ���ջ
;********************************************************************
		mov	eax,_lpSEH
		push	[eax + 8]
		pop	[edi].regEip
		push	_lpSEH
		pop	[edi].regEsp
;********************************************************************
; ��ǰ��� Handler ���� Unwind ����
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
; �ڲ���� Handler���������쳣
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
; �������쳣��ָ��
;********************************************************************
		pushad
		xor	eax,eax
		mov	dword ptr [eax],0
		popad		;��һ�佫�޷���ִ��
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
