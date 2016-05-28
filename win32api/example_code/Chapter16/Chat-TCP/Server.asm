;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Server.asm
; 使用 TCP 协议的聊天室例子程序 —— 服务器端
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff Server.asm
; rc Server.rc
; Link /subsystem:windows Server.obj Server.res
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.386
		.model flat, stdcall
		option casemap :none   ; case sensitive
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include 数据
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
include		wsock32.inc
includelib	wsock32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; equ 数据
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN	equ	1000
DLG_MAIN	equ	2000
IDC_COUNT	equ	2001
TCP_PORT	equ	9999
;********************************************************************
; 客户端会话信息
;********************************************************************
SESSION		struct
  szUserName	db	12 dup (?)	; 用户名
  dwMessageId	dd	?		; 已经下发的消息编号
  dwLastTime	dd	?		; 链路最近一次活动的时间
SESSION		ends
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd	?
hWinMain	dd	?
hListenSocket	dd	?
dwThreadCounter	dd	?
dwFlag		dd	?
F_STOP		equ	0001h

		.const
szErrBind	db	'无法绑定到TCP端口9999，请检查是否有其它程序在使用!',0
szSysInfo	db	'系统消息',0
szUserLogin	db	' 进入了聊天室!',0
szUserLogout	db	' 退出了聊天室!',0

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
include		_Message.inc
include		_SocketRoute.asm
include		_MsgQueue.asm

		assume	esi:ptr MSG_STRUCT,edi:ptr SESSION
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 循环取消息队列中的聊天语句并发送到客户端，直到全部消息发送完毕
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_SendMsgQueue	proc	uses esi edi _hSocket,_lpBuffer,_lpSession
		local	@stMsg:MSG_STRUCT

		mov	esi,_lpBuffer
		mov	edi,_lpSession
		.while	! (dwFlag & F_STOP)
			mov	ecx,[edi].dwMessageId
			inc	ecx
			invoke	_GetMsgFromQueue,ecx,addr [esi].MsgDown.szSender,addr [esi].MsgDown.szContent
			.break	.if ! eax
			mov	[edi].dwMessageId,eax
			invoke	lstrlen,addr [esi].MsgDown.szContent
			inc	eax
			mov	[esi].MsgDown.dwLength,eax
			add	eax,sizeof MSG_HEAD+MSG_DOWN.szContent
			mov	[esi].MsgHead.dwLength,eax
			mov	[esi].MsgHead.dwCmdId,CMD_MSG_DOWN
			invoke	send,_hSocket,esi,[esi].MsgHead.dwLength,0
			.break	.if eax == SOCKET_ERROR
			invoke	GetTickCount
			mov	[edi].dwLastTime,eax
;********************************************************************
			invoke	_WaitData,_hSocket,0
			.break	.if eax == SOCKET_ERROR
			.if	eax
				xor	eax,eax
				.break
			.endif
;********************************************************************
		.endw
		ret

_SendMsgQueue	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 检测链路的最后一次活动时间
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_LinkCheck	proc	uses esi edi _hSocket,_lpBuffer,_lpSession

;********************************************************************
; 查看是否需要检测链路（30秒内没有数据通信则发送链路检测包）
;********************************************************************
		invoke	GetTickCount
		push	eax
		sub	eax,[edi].dwLastTime
		cmp	eax,30 * 1000
		pop	eax
		jb	_Ret
		@@:
		mov	[edi].dwLastTime,eax
		mov	[esi].MsgHead.dwCmdId,CMD_CHECK_LINK
		mov	[esi].MsgHead.dwLength,sizeof MSG_HEAD
		invoke	send,_hSocket,esi,[esi].MsgHead.dwLength,0
		cmp	eax,SOCKET_ERROR
		jnz	_Ret
		ret
_Ret:
		xor	eax,eax
		ret

_LinkCheck	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 通讯服务线程：每个客户端登录的连接将产生一个线程
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ServiceThread	proc	_hSocket
		local	@stSession:SESSION,@szBuffer[512]:byte

		pushad
		inc	dwThreadCounter
		invoke	SetDlgItemInt,hWinMain,IDC_COUNT,dwThreadCounter,FALSE

		lea	esi,@szBuffer
		lea	edi,@stSession
		invoke	RtlZeroMemory,edi,sizeof @stSession
		mov	eax,dwSequence
		mov	[edi].dwMessageId,eax
;********************************************************************
; 用户名和密码检测，为了简化程序，现在可以使用任意用户名和密码
;********************************************************************
		invoke	_RecvPacket,_hSocket,esi,sizeof @szBuffer
		or	eax,eax
		jnz	_Ret
		.if	[esi].MsgHead.dwCmdId != CMD_LOGIN
			jmp	_Ret
		.else
			invoke	lstrcpy,addr [edi].szUserName,addr [esi].Login.szUserName
			mov	[esi].LoginResp.dbResult,0
		.endif
		mov	[esi].MsgHead.dwCmdId,CMD_LOGIN_RESP
		mov	[esi].MsgHead.dwLength,sizeof MSG_HEAD+sizeof MSG_LOGIN_RESP
		invoke	send,_hSocket,esi,[esi].MsgHead.dwLength,0
		cmp	eax,SOCKET_ERROR
		jz	_Ret
		cmp	[esi].LoginResp.dbResult,0
		jnz	_Ret
;********************************************************************
; 广播：xxx 进入了聊天室
;********************************************************************
		invoke	lstrcpy,esi,addr [edi].szUserName
		invoke	lstrcat,esi,addr szUserLogin
		invoke	_InsertMsgQueue,addr szSysInfo,esi
		invoke	GetTickCount
		mov	[edi].dwLastTime,eax
;********************************************************************
; 循环处理消息
;********************************************************************
		.while	! (dwFlag & F_STOP)
			invoke	_SendMsgQueue,_hSocket,esi,edi
			.break	.if eax
			invoke	_LinkCheck,_hSocket,esi,edi
			.break	.if eax
			.break	.if dwFlag & F_STOP
;********************************************************************
; 使用 select 函数等待 200ms，如果没有接收到数据包则循环
;********************************************************************
			invoke	_WaitData,_hSocket,200 * 1000
			.break	.if eax == SOCKET_ERROR
			.if	eax
				invoke	_RecvPacket,_hSocket,esi,sizeof @szBuffer
				.break	.if eax
				invoke	GetTickCount
				mov	[edi].dwLastTime,eax
				.if	[esi].MsgHead.dwCmdId == CMD_MSG_UP
					invoke	_InsertMsgQueue,addr [edi].szUserName,addr [esi].MsgUp.szContent
				.endif
			.endif
		.endw
;********************************************************************
; 广播：xxx 退出了聊天室
;********************************************************************
		invoke	lstrcpy,esi,addr [edi].szUserName
		invoke	lstrcat,esi,addr szUserLogout
		invoke	_InsertMsgQueue,addr szSysInfo,addr @szBuffer
;********************************************************************
; 关闭 socket
;********************************************************************
_Ret:
		invoke	closesocket,_hSocket
		dec	dwThreadCounter
		invoke	SetDlgItemInt,hWinMain,IDC_COUNT,dwThreadCounter,FALSE
		popad
		ret

_ServiceThread	endp
		assume	esi:nothing,edi:nothing
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 监听线程
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ListenThread	proc	_lParam
		local	@stSin:sockaddr_in

;********************************************************************
; 创建 socket
;********************************************************************
		invoke	socket,AF_INET,SOCK_STREAM,0
		mov	hListenSocket,eax

		invoke	RtlZeroMemory,addr @stSin,sizeof @stSin
		invoke	htons,TCP_PORT
		mov	@stSin.sin_port,ax
		mov	@stSin.sin_family,AF_INET
		mov	@stSin.sin_addr,INADDR_ANY
		invoke	bind,hListenSocket,addr @stSin,sizeof @stSin
		.if	eax
			invoke	MessageBox,hWinMain,addr szErrBind,\
				NULL,MB_OK or MB_ICONSTOP
			invoke	ExitProcess,NULL
			ret
		.endif
;********************************************************************
; 开始监听，等待连接进入并为每个连接创建一个线程
;********************************************************************
		invoke	listen,hListenSocket,5
		.while	TRUE
			invoke	accept,hListenSocket,NULL,0
			.break	.if eax == INVALID_SOCKET
			push	ecx
			invoke	CreateThread,NULL,0,offset _ServiceThread,eax,NULL,esp
			pop	ecx
			invoke	CloseHandle,eax
		.endw
		invoke	closesocket,hListenSocket
		ret

_ListenThread	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 主窗口程序
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@stWsa:WSADATA

		mov	eax,wMsg
;********************************************************************
		.if	eax ==	WM_INITDIALOG
			push	hWnd
			pop	hWinMain
			invoke	LoadIcon,hInstance,ICO_MAIN
			invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
			invoke	InitializeCriticalSection,addr stCS
			invoke	WSAStartup,101h,addr @stWsa
			push	ecx
			invoke	CreateThread,NULL,0,offset _ListenThread,0,NULL,esp
			pop	ecx
			invoke	CloseHandle,eax
;********************************************************************
		.elseif	eax ==	WM_CLOSE
			invoke	closesocket,hListenSocket
			or	dwFlag,F_STOP
			.while	dwThreadCounter
			.endw
			invoke	WSACleanup
			invoke	DeleteCriticalSection,addr stCS
			invoke	EndDialog,hWinMain,NULL
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
