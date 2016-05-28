;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Client.asm
; ʹ�� TCP Э������������ӳ��� ���� �ͻ���
; ������ʹ�÷�����ģʽsocket
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff Client2.asm
; rc Client.rc
; Link /subsystem:windows Client2.obj Client.res
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
WM_SOCKET       equ	WM_USER + 100
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd	?
hWinMain	dd	?
hSocket		dd	?
szServer	db	16 dup (?)
szUserName	db	12 dup (?)
szPassword	db	12 dup (?)
szText		db	256 dup (?)

szSendMsg	MSG_STRUCT 10 dup (<>)
szRecvMsg	MSG_STRUCT 10 dup (<>)
dwSendBufSize	dd	?
dwRecvBufSize	dd	?
dbStep		db	?

		.const
szErrIP		db	'��Ч�ķ�����IP��ַ!',0
szErrConnect	db	'�޷����ӵ�������!',0
szErrLogin	db	'�޷���¼���������������û�������!',0
szSpar		db	' : ',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	�����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �Ͽ�����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_DisConnect	proc

		invoke	GetDlgItem,hWinMain,IDC_TEXT
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,hWinMain,IDC_LOGOUT
		invoke	EnableWindow,eax,FALSE

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
		ret

_DisConnect	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ӵ�������
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Connect	proc
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
		xor	eax,eax
		mov	dbStep,al
		mov	dwSendBufSize,eax
		mov	dwRecvBufSize,eax
;********************************************************************
; ���� socket
;********************************************************************
		invoke	RtlZeroMemory,addr @stSin,sizeof @stSin
		invoke	inet_addr,addr szServer
		.if	eax ==	INADDR_NONE
			invoke	MessageBox,hWinMain,addr szErrIP,NULL,MB_OK or MB_ICONSTOP
			jmp	_Err
		.endif
		mov	@stSin.sin_addr,eax
		mov	@stSin.sin_family,AF_INET
		invoke	htons,TCP_PORT
		mov	@stSin.sin_port,ax

		invoke	socket,AF_INET,SOCK_STREAM,0
		mov	hSocket,eax
;********************************************************************
; ��socket����Ϊ������ģʽ�����ӵ�������
;********************************************************************
		invoke	WSAAsyncSelect,hSocket,hWinMain,WM_SOCKET,FD_CONNECT or FD_READ or FD_CLOSE or FD_WRITE
		invoke	connect,hSocket,addr @stSin,sizeof @stSin
		.if	eax ==	SOCKET_ERROR
			invoke	WSAGetLastError
			.if eax != WSAEWOULDBLOCK
				invoke	MessageBox,hWinMain,addr szErrConnect,NULL,MB_OK or MB_ICONSTOP
				jmp	_Err
			.endif
		.endif
		ret
_Err:
		invoke	_DisConnect
		ret

_Connect	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ͻ������е����ݣ��ϴε������п���δ�����꣬��ÿ�η���ǰ��
; �Ƚ����ͻ������ϲ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_SendData	proc	_lpData,_dwSize

		pushad
;********************************************************************
; ��Ҫ���͵����ݼӵ���������β��
;********************************************************************
		mov	esi,_lpData
		mov	ecx,_dwSize
		.if	esi && ecx
			push	ecx
			mov	edi,offset szSendMsg
			add	edi,dwSendBufSize
			cld
			rep	movsb
			pop	ecx
			add	dwSendBufSize,ecx
		.endif
;********************************************************************
; ���ͻ�����
;********************************************************************
		@@:
		mov	esi,offset szSendMsg
		mov	ebx,dwSendBufSize
		or	ebx,ebx
		jz	_Ret
		invoke	send,hSocket,esi,ebx,0
		.if	eax ==	SOCKET_ERROR
			invoke	WSAGetLastError
			.if	eax ==	WSAEWOULDBLOCK
				invoke	GetDlgItem,hWinMain,IDC_TEXT
				invoke	EnableWindow,eax,FALSE
				invoke	GetDlgItem,hWinMain,IDOK
				invoke	EnableWindow,eax,FALSE
			.else
				invoke	_DisConnect
			.endif
			jmp	_Ret
		.endif
		sub	dwSendBufSize,eax
		mov	ecx,dwSendBufSize
		mov	edi,offset szSendMsg
		lea	esi,[edi+eax]
		.if	ecx && (edi != esi)
			cld
			rep	movsb
			jmp	@B
		.endif
_Ret:
		popad
		ret

_SendData	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ������Ϣ
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcMessage	proc
		local	@szBuffer[512]:byte

		mov	ax,szRecvMsg.MsgHead.dwCmdId
		.if	ax ==	CMD_LOGIN_RESP
			.if	szRecvMsg.LoginResp.dbResult
				invoke	MessageBox,hWinMain,addr szErrLogin,NULL,MB_OK or MB_ICONSTOP
				invoke	_DisConnect
			.else
				mov	dbStep,1
				invoke	GetDlgItem,hWinMain,IDOK
				invoke	EnableWindow,eax,FALSE
				invoke	GetDlgItem,hWinMain,IDC_LOGOUT
				invoke	EnableWindow,eax,TRUE
				invoke	GetDlgItem,hWinMain,IDC_TEXT
				invoke	EnableWindow,eax,TRUE
			.endif
		.elseif	ax ==	CMD_MSG_DOWN
			.if	dbStep < 1
				invoke	_DisConnect
			.else
				invoke	lstrcpy,addr @szBuffer,addr szRecvMsg.MsgDown.szSender
				invoke	lstrcat,addr @szBuffer,addr szSpar
				invoke	lstrcat,addr @szBuffer,addr szRecvMsg.MsgDown.szContent
				invoke	SendDlgItemMessage,hWinMain,IDC_INFO,LB_INSERTSTRING,0,addr @szBuffer
			.endif
		.endif
		ret

_ProcMessage	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �������ݰ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RecvData	proc

		pushad
		mov	esi,offset szRecvMsg
		mov	ecx,dwRecvBufSize
		add	esi,ecx
;********************************************************************
; ���������������С�����ݰ�ͷ���ȣ����Ƚ������ݰ�ͷ��
; �������ݰ�ͷ��������յ��ܳ��������ݰ�ͷ�����dwLengthָ��
;********************************************************************
		.if	ecx <	sizeof MSG_HEAD
			mov	eax,sizeof MSG_HEAD
		.else
			mov	eax,szRecvMsg.MsgHead.dwLength
			.if	eax < MSG_HEAD || eax > MSG_STRUCT
				mov	dwRecvBufSize,0
				invoke	_DisConnect
				jmp	_Ret
			.endif
		.endif
;********************************************************************
		sub	eax,ecx
		.if	eax
			invoke	recv,hSocket,esi,eax,NULL
			.if	eax ==	SOCKET_ERROR
				invoke	WSAGetLastError
				.if	eax !=	WSAEWOULDBLOCK
					invoke	_DisConnect
				.endif
				jmp	_Ret
			.endif
			add	dwRecvBufSize,eax
		.endif
		mov	eax,dwRecvBufSize
;********************************************************************
; ����������ݰ�������ϣ�����д���
;********************************************************************
		.if	eax >=	sizeof MSG_HEAD
			.if	eax ==	szRecvMsg.MsgHead.dwLength
				invoke	_ProcMessage
				mov	dwRecvBufSize,0
			.endif
		.endif
;********************************************************************
_Ret:
		popad
		ret

_RecvData	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����ڳ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@stWsa:WSADATA,@stMsg:MSG_STRUCT

		mov	eax,wMsg
;********************************************************************
		.if	eax ==	WM_SOCKET
;********************************************************************
; ���� Socket ��Ϣ
;********************************************************************
			mov	eax,lParam
			.if	ax ==	FD_READ
				invoke	_RecvData
			.elseif	ax ==	FD_WRITE
				invoke	GetDlgItem,hWinMain,IDC_TEXT
				invoke	EnableWindow,eax,TRUE
				invoke	GetDlgItem,hWinMain,IDOK
				invoke	EnableWindow,eax,TRUE
				invoke	_SendData,0,0	;�������ͻ���������
			.elseif	ax ==	FD_CONNECT
				shr	eax,16
				.if	ax ==	NULL	;���ӳɹ����¼
					invoke	lstrcpy,addr @stMsg.Login.szUserName,addr szUserName
					invoke	lstrcpy,addr @stMsg.Login.szPassword,addr szPassword
					mov	@stMsg.MsgHead.dwLength,sizeof MSG_HEAD+sizeof MSG_LOGIN
					mov	@stMsg.MsgHead.dwCmdId,CMD_LOGIN
					invoke	_SendData,addr @stMsg,@stMsg.MsgHead.dwLength
				.else
					invoke	MessageBox,hWinMain,addr szErrConnect,NULL,MB_OK or MB_ICONSTOP
					invoke	_DisConnect
				.endif
			.elseif	ax ==	FD_CLOSE
				call	_DisConnect
			.endif
;********************************************************************
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
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
				invoke	_Connect
;********************************************************************
			.elseif	ax ==	IDC_LOGOUT
				invoke	_DisConnect
;********************************************************************
			.elseif	ax ==	IDOK
				.if	szText
					invoke	lstrcpy,addr @stMsg.MsgUp.szContent,addr szText
					invoke	lstrlen,addr @stMsg.MsgUp.szContent
					inc	eax
					mov	@stMsg.MsgUp.dwLength,eax
					add	eax,sizeof MSG_HEAD+MSG_UP.szContent
					mov	@stMsg.MsgHead.dwLength,eax
					mov	@stMsg.MsgHead.dwCmdId,CMD_MSG_UP
					invoke	_SendData,addr @stMsg,@stMsg.MsgHead.dwLength
					invoke	SetDlgItemText,hWinMain,IDC_TEXT,NULL
					invoke	GetDlgItem,hWinMain,IDC_TEXT
					invoke	SetFocus,eax
				.endif
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
