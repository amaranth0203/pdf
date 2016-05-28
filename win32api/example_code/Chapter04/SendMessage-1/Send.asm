;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; SendMessage.asm
; 从一个程序向另一个窗口程序发送消息 之 发送程序
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff SendMessage.asm
; Link /subsystem:windows SendMessage.obj
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
hWnd		dd	?
szBuffer	db	512 dup (?)
stCopyData	COPYDATASTRUCT <>

szCaption	db	'SendMessage',0
szStart		db	'Press OK to start SendMessage, text address: %08x!',0
szReturn	db	'SendMessage returned!',0
szDestClass	db	'MyClass',0	;目标窗口的窗口类
szText		db	'Text send to other windows',0
szNotFound	db	'Receive Message Window not found!',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
start:
		invoke	FindWindow,addr szDestClass,NULL
		.if	eax
			mov	hWnd,eax	;找到目标窗口则发送消息
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
