;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Process.asm
; ������һ�����̣����ҵȴ����Ľ�����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff Process.asm
; rc Process.rc
; Link /subsystem:windows Process.obj Process.res
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
include		comdlg32.inc
includelib	comdlg32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equ ��ֵ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN	equ	1000
DLG_MAIN	equ	1000
IDC_FILE	equ 	1001
IDC_CMDLINE	equ 	1002
IDC_BROWSE	equ 	1003
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd	?
hWinMain	dd	?
szFileName	db	MAX_PATH dup (?)
szCmdLine	db	MAX_PATH dup (?)
stStartUp	STARTUPINFO		<?>
stProcInfo	PROCESS_INFORMATION	<?>

		.const
szFileExt	db	'��ִ���ļ�(*.exe;*.com)',0,'*.exe;*.com',0,0
szErrExec	db	'�޷�ִ���ļ�!',0
szStart		db	'ִ��(&E)',0
szStop		db	'��ֹ(&T)',0
szBlank		db	' ',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcExec	proc	uses ebx esi edi _lParam
		local	@szBuffer[MAX_PATH * 2]:byte

;********************************************************************
; ���ð�ť״̬�Լ�����׼������
;********************************************************************
		invoke	GetDlgItem,hWinMain,IDC_FILE
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,hWinMain,IDC_CMDLINE
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,hWinMain,IDC_BROWSE
		invoke	EnableWindow,eax,FALSE
		invoke	SetDlgItemText,hWinMain,IDOK,addr szStop
		invoke	GetDlgItemText,hWinMain,IDC_FILE,addr szFileName,sizeof szFileName
		invoke	GetDlgItemText,hWinMain,IDC_CMDLINE,addr szCmdLine,sizeof szCmdLine
		invoke	lstrcpy,addr @szBuffer,addr szFileName
		.if	szCmdLine
			invoke	lstrcat,addr @szBuffer,addr szBlank
			invoke	lstrcat,addr @szBuffer,addr szCmdLine
		.endif
;********************************************************************
; ��������
;********************************************************************
		invoke	GetStartupInfo,addr stStartUp
		invoke	CreateProcess,NULL,addr @szBuffer,NULL,NULL,NULL,\
			NORMAL_PRIORITY_CLASS,NULL,NULL,addr stStartUp,addr stProcInfo
		.if	eax
;********************************************************************
; �ȴ����̽���
;********************************************************************
			invoke	WaitForSingleObject,stProcInfo.hProcess,INFINITE
			invoke	CloseHandle,stProcInfo.hProcess
			invoke	CloseHandle,stProcInfo.hThread
		.else
			invoke	MessageBox,hWinMain,addr szErrExec,NULL,MB_OK or MB_ICONWARNING
		.endif
;********************************************************************
; �ָ���ť״̬
;********************************************************************
		invoke	RtlZeroMemory,addr stProcInfo,sizeof stProcInfo
		invoke	GetDlgItem,hWinMain,IDC_FILE
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,hWinMain,IDC_CMDLINE
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,hWinMain,IDC_BROWSE
		invoke	EnableWindow,eax,TRUE
		invoke	SetDlgItemText,hWinMain,IDOK,addr szStart
		ret

_ProcExec	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@dwThreadID
		local	@stOF:OPENFILENAME

		mov	eax,wMsg
;********************************************************************
		.if	eax ==	WM_COMMAND
			mov	eax,wParam
			.if	ax ==	IDOK
				.if	stProcInfo.hProcess
					invoke	TerminateProcess,stProcInfo.hProcess,-1
				.else
					invoke	CreateThread,NULL,0,offset _ProcExec,NULL,\
						NULL,addr @dwThreadID
					invoke	CloseHandle,eax
				.endif
			.elseif	ax ==	IDC_BROWSE
;********************************************************************
; ����򿪵��ļ�
;********************************************************************
				invoke	RtlZeroMemory,addr @stOF,sizeof @stOF
				mov	@stOF.lStructSize,sizeof @stOF
				push	hWinMain
				pop	@stOF.hwndOwner
				mov	@stOF.lpstrFilter,offset szFileExt
				mov	@stOF.lpstrFile,offset szFileName
				mov	@stOF.nMaxFile,MAX_PATH
				mov	@stOF.Flags,OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
				invoke	GetOpenFileName,addr @stOF
				.if	eax
					invoke	SetDlgItemText,hWnd,IDC_FILE,addr szFileName
				.endif
			.elseif	ax ==	IDC_FILE
				invoke	GetWindowTextLength,lParam
				mov	ebx,eax
				invoke	GetDlgItem,hWnd,IDOK
				invoke	EnableWindow,eax,ebx
			.endif
;********************************************************************
		.elseif	eax ==	WM_CLOSE
			invoke	EndDialog,hWnd,NULL
;********************************************************************
		.elseif	eax ==	WM_INITDIALOG
			push	hWnd
			pop	hWinMain
			invoke	SendDlgItemMessage,hWnd,IDC_FILE,EM_LIMITTEXT,MAX_PATH,0
			invoke	SendDlgItemMessage,hWnd,IDC_CMDLINE,EM_LIMITTEXT,MAX_PATH,0
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
