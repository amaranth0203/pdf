;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Ini.asm
; Ini 文件操作的例子
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff Ini.asm
; rc Ini.rc
; Link  /subsystem:windows Ini.obj Ini.res
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.386
		.model flat, stdcall
		option casemap :none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include 文件定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equ 等值定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN	equ	1000
DLG_MAIN	equ	1000
IDC_SEC		equ	1001
IDC_KEY		equ	1002
IDC_VALUE	equ	1003
IDC_INI		equ	1004
IDC_DEL_SEC	equ	1005
IDC_DEL_KEY	equ	1006
IDC_GET_KEY	equ	1007
IDC_SET_KEY	equ	1008
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd	?
hWinMain	dd	?
szProfileName	dd	MAX_PATH dup (?)
szBuffer1	db	32760 dup (?)
szBuffer2	db	32760 dup (?)
		.const
szFileName	db	'\Option.ini',0
szSecPos	db	'Windows Position',0
szKeyX		db	'X',0
szKeyY		db	'Y',0
szFmt1		db	'%d',0
szFmtSection	db	'[%s]'
szCrLf		db	0dh,0ah,0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 枚举全部 Section 和全部 Key
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_EnumINI	proc
		local	@szBuffer[256]:byte

		invoke	SetDlgItemText,hWinMain,IDC_INI,NULL
;********************************************************************
; 读取 Section 列表并循环处理
;********************************************************************
		invoke	GetPrivateProfileSectionNames,addr szBuffer1,\
			sizeof szBuffer1,addr szProfileName
		mov	esi,offset szBuffer1
		.while	byte ptr [esi]
			invoke	wsprintf,addr @szBuffer,addr szFmtSection,esi
			invoke	SendDlgItemMessage,hWinMain,IDC_INI,EM_REPLACESEL,FALSE,addr @szBuffer
;********************************************************************
; 读取 Key 列表并循环显示
;********************************************************************
			invoke	GetPrivateProfileSection,esi,addr szBuffer2,\
				sizeof szBuffer2,addr szProfileName
			mov	edi,offset szBuffer2
			.while	byte ptr [edi]
				invoke	SendDlgItemMessage,hWinMain,IDC_INI,EM_REPLACESEL,FALSE,edi
				invoke	SendDlgItemMessage,hWinMain,IDC_INI,EM_REPLACESEL,FALSE,addr szCrLf
				invoke	lstrlen,edi
				add	edi,eax
				inc	edi
			.endw
			invoke	lstrlen,esi
			add	esi,eax
			inc	esi
		.endw
		ret

_EnumINI	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_GetPosition	proc
		local	@szBuffer[512]:byte
;********************************************************************
; 将当前路径和 ini 文件名组合起来
;********************************************************************
		invoke	GetCurrentDirectory,MAX_PATH,addr szProfileName
		mov	esi,offset szProfileName
		invoke	lstrlen,esi
		mov	ecx,offset szFileName
		.if	byte ptr [esi+eax-1] == '\'
			inc	ecx
		.endif
		invoke	lstrcat,esi,ecx
;********************************************************************
; 读存放在 ini 文件中的数据
;********************************************************************
		invoke	GetPrivateProfileInt,addr szSecPos,\
			addr szKeyX,50,addr szProfileName
		push	eax
		invoke	GetPrivateProfileInt,addr szSecPos,\
			addr szKeyY,50,addr szProfileName
		pop	ecx
		invoke	SetWindowPos,hWinMain,HWND_TOP,ecx,eax,0,0,SWP_NOSIZE
		ret

_GetPosition	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_SavePosition	proc
		local	@szBuffer[512]:byte,@szRect:RECT

		invoke	GetWindowRect,hWinMain,addr @szRect
		invoke	wsprintf,addr @szBuffer,addr szFmt1,@szRect.left
		invoke	WritePrivateProfileString,addr szSecPos,addr szKeyX,\
			addr @szBuffer,addr szProfileName
		invoke	wsprintf,addr @szBuffer,addr szFmt1,@szRect.top
		invoke	WritePrivateProfileString,addr szSecPos,addr szKeyY,\
			addr @szBuffer,addr szProfileName
		ret

_SavePosition	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@szSection[256]:byte
		local	@szKey[256]:byte
		local	@szValue[256]:byte
		local	@szBuffer[256]:byte

		mov	eax,wMsg
;********************************************************************
		.if	eax ==	WM_CLOSE
			invoke	_SavePosition
			invoke	EndDialog,hWnd,NULL
;********************************************************************
		.elseif	eax ==	WM_INITDIALOG
			push	hWnd
			pop	hWinMain
			invoke	LoadIcon,hInstance,ICO_MAIN
			invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
			invoke	_GetPosition
			invoke	_EnumINI
;********************************************************************
		.elseif	eax ==	WM_COMMAND
			invoke	GetDlgItemText,hWnd,IDC_SEC,addr @szSection,sizeof @szSection
			invoke	GetDlgItemText,hWnd,IDC_KEY,addr @szKey,sizeof @szKey
			invoke	GetDlgItemText,hWnd,IDC_VALUE,addr @szValue,sizeof @szValue
			mov	eax,wParam
			.if	ax >=	IDC_SEC && ax <= IDC_INI
				mov	eax,TRUE
				ret
			.elseif	ax ==	IDC_DEL_SEC
				invoke	WritePrivateProfileString,addr @szSection,\
					NULL,NULL,addr szProfileName
			.elseif	ax ==	IDC_DEL_KEY
				invoke	WritePrivateProfileString,addr @szSection,\
					addr @szKey,NULL,addr szProfileName
			.elseif	ax ==	IDC_SET_KEY
				invoke	WritePrivateProfileString,addr @szSection,\
					addr @szKey,addr @szValue,addr szProfileName
			.elseif	ax ==	IDC_GET_KEY
				invoke	GetPrivateProfileString,addr @szSection,\
					addr @szKey,NULL,addr @szBuffer,\
					sizeof @szBuffer,addr szProfileName
				invoke	SetDlgItemText,hWnd,IDC_VALUE,addr @szBuffer
			.endif
			invoke	_EnumINI
;********************************************************************
		.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
		ret

_ProcDlgMain	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		invoke	DialogBoxParam,eax,DLG_MAIN,NULL,offset _ProcDlgMain,NULL
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
