;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; TcpEcho.asm
; �������˳������� ���� ���յ����ַ����ظ��ͻ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff TcpEcho.asm
; rc TcpEcho.rc
; Link /subsystem:windows TcpEcho.obj TcpEcho.res
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
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ͨѶ�����̣߳�ÿ���ͻ��˵�¼�����ӽ�����һ���߳�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ServiceThread	proc	_hSocket
		local	@stFdSet:fd_set,@stTimeval:timeval
		local	@szBuffer[512]:byte

		inc	dwThreadCounter
		invoke	SetDlgItemInt,hWinMain,IDC_COUNT,dwThreadCounter,FALSE
		.while	! (dwFlag & F_STOP)
			mov	@stFdSet.fd_count,1
			push	_hSocket
			pop	@stFdSet.fd_array
			mov	@stTimeval.tv_usec,200 * 1000	;200ms
			mov	@stTimeval.tv_sec,0
			invoke	select,0,addr @stFdSet,NULL,NULL,addr @stTimeval
			.break	.if eax == SOCKET_ERROR
			.if	eax
				invoke	recv,_hSocket,addr @szBuffer,sizeof @szBuffer,0
				.break	.if eax == SOCKET_ERROR
				.break	.if ! eax
				invoke	send,_hSocket,addr @szBuffer,eax,0
				.break	.if eax == SOCKET_ERROR
			.endif
		.endw
		invoke	closesocket,_hSocket
		dec	dwThreadCounter
		invoke	SetDlgItemInt,hWinMain,IDC_COUNT,dwThreadCounter,FALSE
		ret

_ServiceThread	endp
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
