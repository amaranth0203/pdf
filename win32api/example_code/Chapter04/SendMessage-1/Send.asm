;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; SendMessage.asm
; ��һ����������һ�����ڳ�������Ϣ ֮ ���ͳ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff SendMessage.asm
; Link /subsystem:windows SendMessage.obj
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
hWnd		dd	?
szBuffer	db	512 dup (?)
stCopyData	COPYDATASTRUCT <>

szCaption	db	'SendMessage',0
szStart		db	'Press OK to start SendMessage, text address: %08x!',0
szReturn	db	'SendMessage returned!',0
szDestClass	db	'MyClass',0	;Ŀ�괰�ڵĴ�����
szText		db	'Text send to other windows',0
szNotFound	db	'Receive Message Window not found!',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
start:
		invoke	FindWindow,addr szDestClass,NULL
		.if	eax
			mov	hWnd,eax	;�ҵ�Ŀ�괰��������Ϣ
			invoke	wsprintf,addr szBuffer,addr szStart,addr szText
			invoke	MessageBox,NULL,offset szBuffer,offset szCaption,MB_OK
			mov	stCopyData.cbData,sizeof szText
			mov	stCopyData.lpData,offset szText
			invoke	SendMessage,hWnd,WM_COPYDATA,0,addr stCopyData
			invoke	MessageBox,NULL,offset szReturn,offset szCaption,MB_OK
		.else
			invoke	MessageBox,NULL,offset szNotFound,offset szCaption,MB_OK
		.endif
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
