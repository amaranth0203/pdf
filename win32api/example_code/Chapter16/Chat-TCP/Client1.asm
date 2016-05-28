;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Client.asm
; ʹ�� TCP Э������������ӳ��� ���� �ͻ���
; ������ʹ������ģʽsocket
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff Client1.asm
; rc Client.rc
; Link /subsystem:windows Client1.obj Client.res
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.386
		.model flat, stdcall
		option casemap :none   ; case sensitive
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	Include ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
include		wsock32.inc
includelib	wsock32.lib
include		_Message.inc
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	equ ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN	equ	1000
DLG_MAIN	equ	2000
IDC_SERVER	equ	2001
IDC_USER	equ	2002
IDC_PASS	equ	2003
IDC_LOGIN	equ	2004
IDC_LOGOUT	equ	2005
IDC_INFO	equ	2006
IDC_TEXT	equ	2007
TCP_PORT	equ	9999
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd	?
hWinMain	dd	?
hSocket		dd	?
dwLastTime	dd	?
szServer	db	16 dup (?)
szUserName	db	12 dup (?)
szPassword	db	12 dup (?)
szText		db	256 dup (?)

		.const
szErrIP		db	'��Ч�ķ�����IP��ַ!',0
szErrConnect	db	'�޷����ӵ�������!',0
szErrLogin	db	'�޷���¼���������������û�������!',0
szSpar		db	' : ',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	�����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
include		_SocketRoute.asm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ͨѶ�߳�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_WorkThread	proc	_lParam
		local	@stSin:sockaddr_in,@stMsg:MSG_STRUCT
		local	@szBuffer[512]:byte

		pushad
		invoke	GetDlgItem,hWinMain,IDC_SERVER
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,hWinMain,IDC_USER
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,hWinMain,IDC_PASS
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,hWinMain,IDC_LOGIN
		invoke	EnableWindow,eax,FALSE

;********************************************************************
; ���� socket
;********************************************************************
		invoke	RtlZeroMemory,addr @stSin,sizeof @stSin
		invoke	inet_addr,addr szServer
		.if	eax ==	INADDR_NONE
			invoke	MessageBox,hWinMain,addr szErrIP,NULL,MB_OK or MB_ICONSTOP
			jmp	_Ret
		.endif
		mov	@stSin.sin_addr,eax
		mov	@stSin.sin_family,AF_INET
		invoke	htons,TCP_PORT
		mov	@stSin.sin_port,ax

		invoke	socket,AF_INET,SOCK_STREAM,0
		mov	hSocket,eax
;********************************************************************
; ���ӵ�������
;********************************************************************
		invoke	connect,hSocket,addr @stSin,sizeof @stSin
		.if	eax ==	SOCKET_ERROR
			invoke	MessageBox,hWinMain,addr szErrConnect,NULL,MB_OK or MB_ICONSTOP
			jmp	_Ret
		.endif
;********************************************************************
; ��¼��������
;********************************************************************
		invoke	lstrcpy,addr @stMsg.Login.szUserName,addr szUserName
		invoke	lstrcpy,addr @stMsg.Login.szPassword,addr szPassword
		mov	@stMsg.MsgHead.dwLength,sizeof MSG_HEAD+sizeof MSG_LOGIN
		mov	@stMsg.MsgHead.dwCmdId,CMD_LOGIN
		invoke	send,hSocket,addr @stMsg,@stMsg.MsgHead.dwLength,0
		cmp	eax,SOCKET_ERROR
		jz	@F
		invoke	_RecvPacket,hSocket,addr @stMsg,sizeof @stMsg
		or	eax,eax
		jnz	@F
		cmp	@stMsg.MsgHead.dwCmdId,CMD_LOGIN_RESP
		jnz	@F
		.if	@stMsg.LoginResp.dbResult
			@@:
			invoke	MessageBox,hWinMain,addr szErrLogin,NULL,MB_OK or MB_ICONSTOP
			jmp	_Ret
		.endif

		invoke	GetDlgItem,hWinMain,IDC_LOGOUT
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,hWinMain,IDC_TEXT
		invoke	EnableWindow,eax,TRUE
		invoke	GetTickCount
		mov	dwLastTime,eax
;********************************************************************
; ѭ��������Ϣ
;********************************************************************
		.while	hSocket
			invoke	GetTickCount
			sub	eax,dwLastTime
			.break	.if eax >= 60 * 1000
			invoke	_WaitData,hSocket,200 * 1000
			.break	.if eax == SOCKET_ERROR
			.if	eax
				invoke	_RecvPacket,hSocket,addr @stMsg,sizeof @stMsg
				.break	.if eax
				.if	@stMsg.MsgHead.dwCmdId == CMD_MSG_DOWN
					invoke	lstrcpy,addr @szBuffer,addr @stMsg.MsgDown.szSender
					invoke	lstrcat,addr @szBuffer,addr szSpar
					invoke	lstrcat,addr @szBuffer,addr @stMsg.MsgDown.szContent
					invoke	SendDlgItemMessage,hWinMain,IDC_INFO,LB_INSERTSTRING,0,addr @szBuffer
				.endif
				invoke	GetTickCount
				mov	dwLastTime,eax
			.endif
		.endw

		invoke	GetDlgItem,hWinMain,IDOK
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,hWinMain,IDC_TEXT
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,hWinMain,IDC_LOGOUT
		invoke	EnableWindow,eax,FALSE
;********************************************************************
_Ret:
		.if	hSocket
			invoke	closesocket,hSocket
			xor	eax,eax
			mov	hSocket,eax
		.endif

		invoke	GetDlgItem,hWinMain,IDC_SERVER
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,hWinMain,IDC_USER
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,hWinMain,IDC_PASS
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,hWinMain,IDC_LOGIN
		invoke	EnableWindow,eax,TRUE
		popad
		ret

_WorkThread	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����ڳ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@stWsa:WSADATA,@stMsg:MSG_STRUCT

		mov	eax,wMsg
;********************************************************************
		.if	eax ==	WM_COMMAND
			mov	eax,wParam
;********************************************************************
; ȫ������IP��ַ���û�����������򼤻�"��¼"��ť
;********************************************************************
			.if	(ax == IDC_SERVER) || (ax == IDC_USER) || (ax == IDC_PASS)
				invoke	GetDlgItemText,hWinMain,IDC_SERVER,addr szServer,sizeof szServer
				invoke	GetDlgItemText,hWinMain,IDC_USER,addr szUserName,sizeof szUserName
				invoke	GetDlgItemText,hWinMain,IDC_PASS,addr szPassword,sizeof szPassword
				invoke	GetDlgItem,hWinMain,IDC_LOGIN
				.if	szServer && szUserName && szPassword && !hSocket
					invoke	EnableWindow,eax,TRUE
				.else
					invoke	EnableWindow,eax,FALSE
				.endif
;********************************************************************
; ��¼�ɹ���������������ż���"����"��ť
;********************************************************************
			.elseif	ax ==	IDC_TEXT
				invoke	GetDlgItemText,hWinMain,IDC_TEXT,addr szText,sizeof szText
				invoke	GetDlgItem,hWinMain,IDOK
				.if	szText && hSocket
					invoke	EnableWindow,eax,TRUE
				.else
					invoke	EnableWindow,eax,FALSE
				.endif
;********************************************************************
			.elseif	ax ==	IDC_LOGIN
				push	ecx
				invoke	CreateThread,NULL,0,offset _WorkThread,0,NULL,esp
				pop	ecx
				invoke	CloseHandle,eax
;********************************************************************
			.elseif	ax ==	IDC_LOGOUT
				@@:
				.if	hSocket
					invoke	closesocket,hSocket
					xor	eax,eax
					mov	hSocket,eax
				.endif
;********************************************************************
			.elseif	ax ==	IDOK
				invoke	lstrcpy,addr @stMsg.MsgUp.szContent,addr szText
				invoke	lstrlen,addr @stMsg.MsgUp.szContent
				inc	eax
				mov	@stMsg.MsgUp.dwLength,eax
				add	eax,sizeof MSG_HEAD+MSG_UP.szContent
				mov	@stMsg.MsgHead.dwLength,eax
				mov	@stMsg.MsgHead.dwCmdId,CMD_MSG_UP
				invoke	send,hSocket,addr @stMsg,@stMsg.MsgHead.dwLength,0
				cmp	eax,SOCKET_ERROR
				jz	@B
				invoke	GetTickCount
				mov	dwLastTime,eax
				invoke	SetDlgItemText,hWinMain,IDC_TEXT,NULL
				invoke	GetDlgItem,hWinMain,IDC_TEXT
				invoke	SetFocus,eax
			.endif
;********************************************************************
		.elseif	eax ==	WM_CLOSE
			.if	! hSocket
				invoke	WSACleanup
				invoke	EndDialog,hWinMain,NULL
			.endif
;********************************************************************
		.elseif	eax ==	WM_INITDIALOG
			push	hWnd
			pop	hWinMain
			invoke	LoadIcon,hInstance,ICO_MAIN
			invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
			invoke	WSAStartup,101h,addr @stWsa
			invoke	SendDlgItemMessage,hWinMain,IDC_SERVER,EM_SETLIMITTEXT,15,0
			invoke	SendDlgItemMessage,hWinMain,IDC_USER,EM_SETLIMITTEXT,11,0
			invoke	SendDlgItemMessage,hWinMain,IDC_PASS,EM_SETLIMITTEXT,11,0
			invoke	SendDlgItemMessage,hWinMain,IDC_TEXT,EM_SETLIMITTEXT,250,0
;********************************************************************
		.else
			mov	eax,FALSE
			ret
		.endif
		mov	eax,TRUE
		ret

_ProcDlgMain	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ����ʼ
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		invoke	DialogBoxParam,eax,DLG_MAIN,NULL,offset _ProcDlgMain,0
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
