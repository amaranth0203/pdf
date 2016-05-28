;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Reg.asm
; ע������������
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff Reg.asm
; rc Reg.rc
; Link  /subsystem:windows Reg.obj Reg.res
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.386
		.model flat, stdcall
		option casemap :none
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
; Equ ��ֵ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN		equ 1000
DLG_MAIN		equ 1000
IDC_KEY			equ 1001
IDC_VALUENAME		equ 1002
IDC_VALUE		equ 1003
IDC_TYPE		equ 1004
IDC_KEYLIST		equ 1005
IDC_SUBKEY		equ 1006
IDC_REMOVE_VALUE	equ 1007
IDC_GET_VALUE		equ 1008
IDC_SET_VALUE		equ 1009
IDC_CREATE_SUBKEY	equ 1010
IDC_REMOVE_SUBKEY	equ 1011
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd	?
hWinMain	dd	?
		.const
szTypeSz	db	'REG_SZ',0
szTypeDw	db	'REG_DWORD',0
szFmtSubkey	db	'���Ӽ���%s',0dh,0ah,0
szFmtSz		db	'����ֵ��%s=%s (REG_SZ ����)',0dh,0ah,0
szFmtDw		db	'����ֵ��%s=%08X (REG_DWORD ����)',0dh,0ah,0
szFmtValue	db	'����ֵ��%s (��������)',0dh,0ah,0
szNotSupport	db	'�����ݲ���ʾ�������͵ļ�ֵ!',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
include		_Reg.asm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_EnumKey	proc	_lpKey
		local	@hKey,@dwIndex,@dwLastTime:FILETIME
		local	@szBuffer1[512]:byte
		local	@szBuffer[256]:byte
		local	@szValue[256]:byte
		local	@dwSize,@dwSize1,@dwType

		mov	@dwIndex,0
		invoke	SetDlgItemText,hWinMain,IDC_KEYLIST,NULL
;********************************************************************
; ö���Ӽ�
;********************************************************************
		invoke	RegOpenKeyEx,HKEY_LOCAL_MACHINE,_lpKey,NULL,\
			KEY_ENUMERATE_SUB_KEYS,addr @hKey
		.if	eax == ERROR_SUCCESS
			.while	TRUE
				mov	@dwSize,sizeof @szBuffer
				invoke	RegEnumKeyEx,@hKey,@dwIndex,addr @szBuffer,addr @dwSize,\
					NULL,NULL,NULL,NULL
				.break	.if eax == ERROR_NO_MORE_ITEMS
				invoke	wsprintf,addr @szBuffer1,addr szFmtSubkey,addr @szBuffer
				invoke	SendDlgItemMessage,hWinMain,IDC_KEYLIST,EM_REPLACESEL,0,addr @szBuffer1
				inc	@dwIndex
			.endw
			invoke	RegCloseKey,@hKey
		.endif
;********************************************************************
; ö�ټ�ֵ
;********************************************************************
		mov	@dwIndex,0
		invoke	RegOpenKeyEx,HKEY_LOCAL_MACHINE,_lpKey,NULL,\
			KEY_QUERY_VALUE,addr @hKey
		.if	eax == ERROR_SUCCESS
			.while	TRUE
				mov	@dwSize,sizeof @szBuffer
				mov	@dwSize1,sizeof @szValue
				invoke	RegEnumValue,@hKey,@dwIndex,addr @szBuffer,addr @dwSize,\
					NULL,addr @dwType,addr @szValue,addr @dwSize1
				.break	.if eax == ERROR_NO_MORE_ITEMS
				mov	eax,@dwType
				.if	eax ==	REG_SZ
					invoke	wsprintf,addr @szBuffer1,addr szFmtSz,addr @szBuffer,addr @szValue
				.elseif	eax ==	REG_DWORD
					invoke	wsprintf,addr @szBuffer1,addr szFmtDw,addr @szBuffer,dword ptr @szValue
				.else
					invoke	wsprintf,addr @szBuffer1,addr szFmtValue,addr @szBuffer
				.endif
				invoke	SendDlgItemMessage,hWinMain,IDC_KEYLIST,EM_REPLACESEL,0,addr @szBuffer1
				inc	@dwIndex
			.endw
			invoke	RegCloseKey,@hKey
		.endif
		ret

_EnumKey	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@szKey[256]:byte,@szSubkey[256]:byte
		local	@szValueName[256]:byte,@szValue[256]:byte
		local	@dwType,@dwSize

		mov	eax,wMsg
;********************************************************************
		.if	eax ==	WM_CLOSE
			invoke	EndDialog,hWnd,NULL
;********************************************************************
		.elseif	eax ==	WM_INITDIALOG
			push	hWnd
			pop	hWinMain
			invoke	LoadIcon,hInstance,ICO_MAIN
			invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
			invoke	SendDlgItemMessage,hWnd,IDC_TYPE,CB_ADDSTRING,0,addr szTypeSz
			invoke	SendDlgItemMessage,hWnd,IDC_TYPE,CB_ADDSTRING,0,addr szTypeDw
			invoke	SendDlgItemMessage,hWnd,IDC_TYPE,CB_SETCURSEL,0,0
			invoke	_EnumKey,NULL
;********************************************************************
		.elseif	eax ==	WM_COMMAND
			invoke	GetDlgItemText,hWnd,IDC_KEY,addr @szKey,256
			invoke	GetDlgItemText,hWnd,IDC_SUBKEY,addr @szSubkey,256
			invoke	GetDlgItemText,hWnd,IDC_VALUENAME,addr @szValueName,256
			mov	eax,wParam
			.if	ax >=	IDC_KEY && ax <= IDC_SUBKEY
				mov	eax,TRUE
				ret
			.elseif	ax ==	IDC_REMOVE_VALUE
				invoke	_RegDelValue,addr @szKey,addr @szValueName
			.elseif	ax ==	IDC_GET_VALUE
;********************************************************************
; ��ȡ��ֵ
;********************************************************************
				mov	@dwSize,sizeof @szValue
				invoke	RtlZeroMemory,addr @szValue,@dwSize
				invoke	_RegQueryValue,addr @szKey,addr @szValueName,\
					addr @szValue,addr @dwSize,addr @dwType
				.if	eax ==	ERROR_SUCCESS
					mov	eax,@dwType
					.if	eax ==	REG_SZ
						invoke	SetDlgItemText,hWnd,IDC_VALUE,addr @szValue
						invoke	SendDlgItemMessage,hWnd,IDC_TYPE,CB_SETCURSEL,0,0
					.elseif	eax ==	REG_DWORD
						invoke	SendDlgItemMessage,hWnd,IDC_TYPE,CB_SETCURSEL,1,0
						invoke	SetDlgItemInt,hWnd,IDC_VALUE,dword ptr @szValue,FALSE
					.else
						invoke	SetDlgItemText,hWnd,IDC_VALUE,addr szNotSupport
					.endif
				.else
					invoke	SetDlgItemText,hWnd,IDC_VALUE,NULL
				.endif
;********************************************************************
; ���ü�ֵ
;********************************************************************
			.elseif	ax ==	IDC_SET_VALUE
				invoke	SendDlgItemMessage,hWnd,IDC_TYPE,CB_GETCURSEL,0,0
				.if	! eax
					invoke	GetDlgItemText,hWnd,IDC_VALUE,addr @szValue,256
					invoke	lstrlen,addr @szValue
					inc	eax
					invoke	_RegSetValue,addr @szKey,addr @szValueName,\
						addr @szValue,REG_SZ,eax
				.else
					invoke	GetDlgItemInt,hWnd,IDC_VALUE,NULL,FALSE
					mov	dword ptr @szValue,eax
					invoke	_RegSetValue,addr @szKey,addr @szValueName,\
						addr @szValue,REG_DWORD,4
				.endif
			.elseif	ax ==	IDC_CREATE_SUBKEY
				invoke	_RegCreateKey,addr @szKey,addr @szSubkey
			.elseif	ax ==	IDC_REMOVE_SUBKEY
				invoke	_RegDelSubKey,addr @szKey,addr @szSubkey
			.endif
			invoke	_EnumKey,addr @szKey
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
