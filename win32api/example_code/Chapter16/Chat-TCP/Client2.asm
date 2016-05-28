;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Client.asm
; 使用 TCP 协议的聊天室例子程序 —— 客户端
; 本例子使用非阻塞模式socket
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff Client2.asm
; rc Client.rc
; Link /subsystem:windows Client2.obj Client.res
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.386
		.model flat, stdcall
		option casemap :none   ; case sensitive
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	Include 数据
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
;	equ 数据
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
;	数据段
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
szErrIP		db	'无效的服务器IP地址!',0
szErrConnect	db	'无法连接到服务器!',0
szErrLogin	db	'无法登录到服务器，请检查用户名密码!',0
szSpar		db	' : ',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 断开连接
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
; 连接到服务器
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
; 创建 socket
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
; 将socket设置为非阻塞模式，连接到服务器
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
; 发送缓冲区中的数据，上次的数据有可能未发送完，故每次发送前，
; 先将发送缓冲区合并
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_SendData	proc	_lpData,_dwSize

		pushad
;********************************************************************
; 将要发送的内容加到缓冲区的尾部
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
; 发送缓冲区
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
; 处理消息
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
; 接收数据包
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RecvData	proc

		pushad
		mov	esi,offset szRecvMsg
		mov	ecx,dwRecvBufSize
		add	esi,ecx
;********************************************************************
; 如果缓冲区里数据小于数据包头长度：则先接收数据包头部
; 大于数据包头部，则接收的总长度由数据包头部里的dwLength指定
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
; 如果整个数据包接收完毕，则进行处理
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
; 主窗口程序
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@stWsa:WSADATA,@stMsg:MSG_STRUCT

		mov	eax,wMsg
;********************************************************************
		.if	eax ==	WM_SOCKET
;********************************************************************
; 处理 Socket 消息
;********************************************************************
			mov	eax,lParam
			.if	ax ==	FD_READ
				invoke	_RecvData
			.elseif	ax ==	FD_WRITE
				invoke	GetDlgItem,hWinMain,IDC_TEXT
				invoke	EnableWindow,eax,TRUE
				invoke	GetDlgItem,hWinMain,IDOK
				invoke	EnableWindow,eax,TRUE
				invoke	_SendData,0,0	;继续发送缓冲区数据
			.elseif	ax ==	FD_CONNECT
				shr	eax,16
				.if	ax ==	NULL	;连接成功则登录
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
; 程序开始
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		invoke	DialogBoxParam,eax,DLG_MAIN,NULL,offset _ProcDlgMain,0
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
