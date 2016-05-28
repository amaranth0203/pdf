;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Server.asm
; ʹ�� TCP Э������������ӳ��� ���� ��������
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff Server.asm
; rc Server.rc
; Link /subsystem:windows Server.obj Server.res
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.386
		.model flat, stdcall
		option casemap :none   ; case sensitive
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
include		wsock32.inc
includelib	wsock32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; equ ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN	equ	1000
DLG_MAIN	equ	2000
IDC_COUNT	equ	2001
TCP_PORT	equ	9999
;********************************************************************
; �ͻ��˻Ự��Ϣ
;********************************************************************
SESSION		struct
  szUserName	db	12 dup (?)	; �û���
  dwMessageId	dd	?		; �Ѿ��·�����Ϣ���
  dwLastTime	dd	?		; ��·���һ�λ��ʱ��
SESSION		ends
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd	?
hWinMain	dd	?
hListenSocket	dd	?
dwThreadCounter	dd	?
dwFlag		dd	?
F_STOP		equ	0001h

		.const
szErrBind	db	'�޷��󶨵�TCP�˿�9999�������Ƿ�������������ʹ��!',0
szSysInfo	db	'ϵͳ��Ϣ',0
szUserLogin	db	' ������������!',0
szUserLogout	db	' �˳���������!',0

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
include		_Message.inc
include		_SocketRoute.asm
include		_MsgQueue.asm

		assume	esi:ptr MSG_STRUCT,edi:ptr SESSION
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ѭ��ȡ��Ϣ�����е�������䲢���͵��ͻ��ˣ�ֱ��ȫ����Ϣ�������
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
; �����·�����һ�λʱ��
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_LinkCheck	proc	uses esi edi _hSocket,_lpBuffer,_lpSession

;********************************************************************
; �鿴�Ƿ���Ҫ�����·��30����û������ͨ��������·������
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
; ͨѶ�����̣߳�ÿ���ͻ��˵�¼�����ӽ�����һ���߳�
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
; �û����������⣬Ϊ�˼򻯳������ڿ���ʹ�������û���������
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
; �㲥��xxx ������������
;********************************************************************
		invoke	lstrcpy,esi,addr [edi].szUserName
		invoke	lstrcat,esi,addr szUserLogin
		invoke	_InsertMsgQueue,addr szSysInfo,esi
		invoke	GetTickCount
		mov	[edi].dwLastTime,eax
;********************************************************************
; ѭ��������Ϣ
;********************************************************************
		.while	! (dwFlag & F_STOP)
			invoke	_SendMsgQueue,_hSocket,esi,edi
			.break	.if eax
			invoke	_LinkCheck,_hSocket,esi,edi
			.break	.if eax
			.break	.if dwFlag & F_STOP
;********************************************************************
; ʹ�� select �����ȴ� 200ms�����û�н��յ����ݰ���ѭ��
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
; �㲥��xxx �˳���������
;********************************************************************
		invoke	lstrcpy,esi,addr [edi].szUserName
		invoke	lstrcat,esi,addr szUserLogout
		invoke	_InsertMsgQueue,addr szSysInfo,addr @szBuffer
;********************************************************************
; �ر� socket
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
; �����߳�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ListenThread	proc	_lParam
		local	@stSin:sockaddr_in

;********************************************************************
; ���� socket
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
; ��ʼ�������ȴ����ӽ��벢Ϊÿ�����Ӵ���һ���߳�
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
; �����ڳ���
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
; ����ʼ
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		invoke	DialogBoxParam,eax,DLG_MAIN,NULL,offset _ProcDlgMain,0
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
