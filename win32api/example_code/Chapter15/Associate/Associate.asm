;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Associate.asm
; ����ע��� *.test �ļ�����������
; ����� Cmdline.asm �޸Ķ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff Associate.asm
; Link /subsystem:windows Associate.obj
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
include		Advapi32.inc
includelib	Advapi32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
szBuffer1	db	4096 dup (?)
szBuffer2	db	4096 dup (?)
szOutput	db	8192 dup (?)

		.const
szCaption	db	'�����в���',0
szFormat1	db	'*.test �ļ��Ĺ��������õ�������',0dh,0ah
		db	'��˫��Ŀ¼�е�Hello.test�ļ����в���! ��ע������Ĳ���[1]',0dh,0ah,0ah
		db	'��ִ���ļ����ƣ�',0dh,0ah,'%s',0dh,0ah,0ah
		db	'����������%d',0dh,0ah,0
szFormat2	db	'����[%d]��%s',0dh,0ah,0
szKeyEnter	db	'testfile',0
szKeyExt1	db	'.test',0
szKeyExt2	db	'testfile\shell\open\command',0
szParam		db	' "%1"',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code

include		_Cmdline.asm

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_SetExt		proc
		local	@hKey
		local	@szFileName[MAX_PATH]:byte

	invoke	RegCreateKey,HKEY_CLASSES_ROOT,addr szKeyExt1,addr @hKey
	.if	eax == ERROR_SUCCESS
		invoke	RegSetValueEx,@hKey,NULL,NULL,\
			REG_SZ,addr szKeyEnter,sizeof szKeyEnter
		invoke	RegCloseKey,@hKey
	.endif
	invoke	RegCreateKey,HKEY_CLASSES_ROOT,addr szKeyExt2,addr @hKey
	.if	eax == ERROR_SUCCESS
		invoke	GetModuleFileName,NULL,addr @szFileName,MAX_PATH
		invoke	lstrcat,addr @szFileName,addr szParam
		invoke	lstrlen,addr @szFileName
		inc	eax
		invoke	RegSetValueEx,@hKey,NULL,NULL,\
			REG_EXPAND_SZ,addr @szFileName,eax
		invoke	RegCloseKey,@hKey
	.endif
	ret

_SetExt		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		invoke	_SetExt
		invoke	GetModuleFileName,NULL,offset szBuffer1,sizeof szBuffer1
		invoke	_argc
		mov	ebx,eax
		invoke	wsprintf,addr szOutput,addr szFormat1,addr szBuffer1,eax

		xor	esi,esi
		.while	esi < ebx
			invoke	_argv,esi,addr szBuffer2,sizeof szBuffer2
			invoke	wsprintf,addr szBuffer1,addr szFormat2,esi,addr szBuffer2
			invoke	lstrcat,addr szOutput,addr szBuffer1
			inc	esi
		.endw
		invoke	MessageBox,NULL,addr szOutput,addr szCaption,MB_OK
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
