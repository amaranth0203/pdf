;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Associate.asm
; 设置注册表将 *.test 文件管理到本程序
; 程序从 Cmdline.asm 修改而来
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff Associate.asm
; Link /subsystem:windows Associate.obj
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
include		Advapi32.inc
includelib	Advapi32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
szBuffer1	db	4096 dup (?)
szBuffer2	db	4096 dup (?)
szOutput	db	8192 dup (?)

		.const
szCaption	db	'命令行参数',0
szFormat1	db	'*.test 文件的关联被设置到本程序',0dh,0ah
		db	'请双击目录中的Hello.test文件进行测试! 并注意下面的参数[1]',0dh,0ah,0ah
		db	'可执行文件名称：',0dh,0ah,'%s',0dh,0ah,0ah
		db	'参数总数：%d',0dh,0ah,0
szFormat2	db	'参数[%d]：%s',0dh,0ah,0
szKeyEnter	db	'testfile',0
szKeyExt1	db	'.test',0
szKeyExt2	db	'testfile\shell\open\command',0
szParam		db	' "%1"',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
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
