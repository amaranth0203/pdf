;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Odbc.asm
; ��Odbc�������ݿ������
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff Odbc.asm
; rc Odbc.rc
; Link /subsystem:windows Odbc.obj Odbc.res
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
include		comctl32.inc
includelib	comctl32.lib
include		odbc32.inc
includelib	odbc32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; equ ����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN	equ	1000
DLG_MAIN	equ	2000
IDC_CONN_STR	equ	2001
IDC_CONN	equ	2002
IDC_DISCONN	equ	2003
IDC_SQL		equ	2004
IDC_EXEC	equ	2005
IDC_LIST	equ	2006
IDC_INFO	equ	2007
IDC_COMMIT	equ	2008
IDC_ROLLBACK	equ	2009
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd	?
hWinMain	dd	?		;�Ի�����
hListView	dd	?		;�б����
hEnv		dd	?		;ODBC�������
hConn		dd	?		;ODBC���Ӿ��
szConnString	db	1024 dup (?)	;ODBC�����ַ���
szFullString	db	1024 dup (?)	;���Ӻ󷵻ص�ȫ�ַ���
szSQL		db	1024 dup (?)	;�����׼��ִ�е�SQL���

		.const
szDefConnStr	db	"Driver={Microsoft Access Driver (*.mdb)};dbq=test.mdb",0
szErrConn	db	'�޷����ӵ����ݿ�!',0
szOkCaption	db	'�ɹ����ӵ����ݿ⣬�����������ַ������£�',0
szErrDDL	db	'DDL/DCL ����ѳɹ�ִ�С�',0
szErrDML	db	'DML ����ѳɹ�ִ�У�Insert/Update/Delete��������%d��',0
szErrDQL	db	'��ѯ����Ѿ��ɹ�ִ�У��õ��Ľ�������£�',0

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
include		_ListView.asm
include		_RecordSet.asm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ִ��SQL���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Execute	proc
		local	@dwTemp,@dwErrCode
		local	@szSQLState[8]:byte,@szMsg[SQL_MAX_MESSAGE_LENGTH]:byte
		local	@dwRecordCols,@dwResultRows
		local	@szName[128]:byte,@dwNameSize,@dwType,@dwSize,@dwSize1,@dwNullable
		local	@stRs:ODBC_RS,@hStmt

		invoke	SetDlgItemText,hWinMain,IDC_INFO,NULL
		invoke	ShowWindow,hListView,SW_HIDE
		invoke	_ListViewClear,hListView

		invoke	SQLAllocHandle,SQL_HANDLE_STMT,hConn,addr @hStmt
		.if	ax != SQL_SUCCESS && ax != SQL_SUCCESS_WITH_INFO
			ret
		.endif
		invoke	SQLSetStmtAttr,@hStmt,SQL_ATTR_CURSOR_TYPE,SQL_CURSOR_STATIC,0
;********************************************************************
; ִ�� SQL ���
;********************************************************************
		invoke	lstrlen,addr szSQL
		invoke	SQLExecDirect,@hStmt,addr szSQL,eax
		.if	ax != SQL_SUCCESS && ax != SQL_SUCCESS_WITH_INFO && ax != SQL_NO_DATA
			mov	@szMsg,0
			invoke	SQLGetDiagRec,SQL_HANDLE_STMT,@hStmt,1,\
				addr @szSQLState,addr @dwErrCode,addr @szMsg,\
				sizeof @szMsg,addr @dwTemp
			invoke	SetDlgItemText,hWinMain,IDC_INFO,addr @szMsg
			jmp	_FreeStmt
		.endif
;********************************************************************
; ���ִ�гɹ��������DML��䣬����ʾ���Ӱ�������
;********************************************************************
		invoke	SQLNumResultCols,@hStmt,addr @dwRecordCols
		and	@dwRecordCols,0ffffh
		.if	! @dwRecordCols
			invoke	SQLRowCount,@hStmt,addr @dwResultRows
			.if	@dwResultRows == -1	;DDL��DCL���
				invoke	SetDlgItemText,hWinMain,IDC_INFO,addr szErrDDL
			.else				;DML���
				invoke	wsprintf,addr @szMsg,addr szErrDML,@dwResultRows
				invoke	SetDlgItemText,hWinMain,IDC_INFO,addr @szMsg
			.endif
			jmp	_FreeStmt
		.endif
;********************************************************************
; �����Select��䣬����ݽ������ʼ��ListView�ı��⣬�Ա���ʾ
;********************************************************************
		invoke	SetDlgItemText,hWinMain,IDC_INFO,addr szErrDQL
		invoke	ShowWindow,hListView,SW_SHOW
		xor	ebx,ebx
		.while	ebx <	@dwRecordCols
			inc	ebx
			invoke	SQLDescribeCol,@hStmt,ebx,\
				addr @szName,sizeof @szName,addr @dwNameSize,\
				addr @dwType,addr @dwSize,addr @dwSize1,addr @dwNullable
			mov	eax,@dwSize	;�п��=�ַ���*8����
			mov	ecx,8
			mul	ecx
			.if	eax >	300	;��󲻳���300����
				mov	eax,300
			.endif
			.if	eax <	40	;��С��С��40����
				mov	eax,40
			.endif
			lea	ecx,@szName	;�������Ʋ����б��
			invoke	_ListViewAddColumn,hListView,ebx,eax,ecx
		.endw
;********************************************************************
; ���������д��ListView��
;********************************************************************
		invoke	_RsOpen,addr @stRs,@hStmt
		xor	esi,esi
		.while	TRUE
			invoke	_RsMoveNext,addr @stRs
			.break	.if eax
			invoke	_ListViewSetItem,hListView,esi,-1,0	;�����µ�һ��
			mov	esi,eax
			xor	ebx,ebx		;ѭ����ʾһ���е�������
			.while	ebx <	@dwRecordCols
				invoke	_RsGetField,addr @stRs,ebx
				.if	eax
					invoke	_ListViewSetItem,hListView,esi,ebx,eax
				.endif
				inc	ebx
			.endw
			inc	esi		;�кż�1
		.endw
		invoke	_RsClose,addr @stRs
		invoke	SQLCloseCursor,@hStmt
;********************************************************************
_FreeStmt:
		invoke	SQLFreeHandle,SQL_HANDLE_STMT,@hStmt
		ret

_Execute	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �Ͽ������ݿ������
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_DisConnect	proc

		.if	hConn
			invoke	SQLEndTran,SQL_HANDLE_DBC,hConn,SQL_COMMIT
			invoke	SQLDisconnect,hConn
			invoke	SQLFreeHandle,SQL_HANDLE_DBC,hConn
		.endif
		.if	hEnv
			invoke	SQLFreeHandle,SQL_HANDLE_ENV,hEnv
		.endif
		xor	eax,eax
		mov	hConn,eax
		mov	hEnv,eax
		invoke	SetDlgItemText,hWinMain,IDC_INFO,NULL
		invoke	SetDlgItemText,hWinMain,IDC_SQL,NULL
		invoke	ShowWindow,hListView,SW_HIDE

		invoke	GetDlgItem,hWinMain,IDC_CONN_STR
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,hWinMain,IDC_CONN
		invoke	EnableWindow,eax,TRUE
		invoke	GetDlgItem,hWinMain,IDC_SQL
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,hWinMain,IDC_DISCONN
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,hWinMain,IDC_COMMIT
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,hWinMain,IDC_ROLLBACK
		invoke	EnableWindow,eax,FALSE
		ret

_DisConnect	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ӵ����ݿ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Connect	proc
		local	@dwTemp

		invoke	GetDlgItem,hWinMain,IDC_CONN_STR
		invoke	EnableWindow,eax,FALSE
		invoke	GetDlgItem,hWinMain,IDC_CONN
		invoke	EnableWindow,eax,FALSE
;********************************************************************
; ���뻷����������Ӿ��
;********************************************************************
		invoke	SQLAllocHandle,SQL_HANDLE_ENV,SQL_NULL_HANDLE,addr hEnv
		.if	ax != SQL_SUCCESS && ax != SQL_SUCCESS_WITH_INFO
			jmp	_Error
		.endif
		invoke	SQLSetEnvAttr,hEnv,SQL_ATTR_ODBC_VERSION,SQL_OV_ODBC3,0
		.if	ax != SQL_SUCCESS && ax != SQL_SUCCESS_WITH_INFO
			jmp	_Error
		.endif
		invoke	SQLAllocHandle,SQL_HANDLE_DBC,hEnv,addr hConn
		.if	ax != SQL_SUCCESS && ax != SQL_SUCCESS_WITH_INFO
			jmp	_Error
		.endif
		invoke	SQLSetConnectAttr,hConn,SQL_ATTR_AUTOCOMMIT,SQL_AUTOCOMMIT_OFF,0
;********************************************************************
; ���ӵ����ݿ�
;********************************************************************
		invoke	lstrlen,addr szConnString
		mov	ecx,eax
		invoke	SQLDriverConnect,hConn,hWinMain,addr szConnString,ecx,\
			addr szFullString,sizeof szFullString,addr @dwTemp,SQL_DRIVER_COMPLETE
		.if	ax == SQL_SUCCESS || ax == SQL_SUCCESS_WITH_INFO
			invoke	MessageBox,hWinMain,addr szFullString,addr szOkCaption,MB_OK
			invoke	GetDlgItem,hWinMain,IDC_DISCONN
			invoke	EnableWindow,eax,TRUE
			invoke	GetDlgItem,hWinMain,IDC_COMMIT
			invoke	EnableWindow,eax,TRUE
			invoke	GetDlgItem,hWinMain,IDC_ROLLBACK
			invoke	EnableWindow,eax,TRUE
			invoke	GetDlgItem,hWinMain,IDC_SQL
			push	eax
			invoke	EnableWindow,eax,TRUE
			pop	eax
			invoke	SetFocus,eax
		.else
_Error:
			invoke	MessageBox,hWinMain,addr szErrConn,NULL,MB_ICONSTOP or MB_OK
			invoke	_DisConnect
		.endif
		ret

_Connect	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����ڳ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
		local	@stWsa:WSADATA

		mov	eax,wMsg
		.if	eax ==	WM_COMMAND
			mov	eax,wParam
;********************************************************************
; ���������ַ�����ż�����ӡ���ť
;********************************************************************
			.if	ax ==	IDC_CONN_STR
				invoke	GetDlgItemText,hWnd,IDC_CONN_STR,addr szConnString,sizeof szConnString
				invoke	GetDlgItem,hWnd,IDC_CONN
				.if	szConnString
					invoke	EnableWindow,eax,TRUE
				.else
					invoke	EnableWindow,eax,FALSE
				.endif
;********************************************************************
; ����SQL����ż��ִ�С���ť
;********************************************************************
			.elseif	ax ==	IDC_SQL
				invoke	GetDlgItemText,hWnd,IDC_SQL,addr szSQL,sizeof szSQL
				invoke	GetDlgItem,hWnd,IDC_EXEC
				.if	szSQL
					invoke	EnableWindow,eax,TRUE
				.else
					invoke	EnableWindow,eax,FALSE
				.endif
;********************************************************************
; ���ӡ��Ͽ����ӡ�ִ�а�ť�Ĵ���
;********************************************************************
			.elseif	ax ==	IDC_CONN
				invoke	_Connect
			.elseif	ax ==	IDC_DISCONN
				invoke	_DisConnect
			.elseif	ax ==	IDC_EXEC
				invoke	_Execute
				invoke	SendDlgItemMessage,hWnd,IDC_SQL,EM_SETSEL,0,-1
			.elseif	ax ==	IDC_COMMIT
				invoke	SQLEndTran,SQL_HANDLE_DBC,hConn,SQL_COMMIT
			.elseif	ax ==	IDC_ROLLBACK
				invoke	SQLEndTran,SQL_HANDLE_DBC,hConn,SQL_ROLLBACK
			.endif
;********************************************************************
		.elseif	eax ==	WM_INITDIALOG
			push	hWnd
			pop	hWinMain
			invoke	LoadIcon,hInstance,ICO_MAIN
			invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,eax

			invoke	GetDlgItem,hWnd,IDC_LIST
			mov	hListView,eax
		        invoke	SendMessage,hListView,LVM_SETEXTENDEDLISTVIEWSTYLE,\
				0,LVS_EX_GRIDLINES or LVS_EX_FULLROWSELECT
			invoke	ShowWindow,hListView,SW_HIDE

			invoke	SendDlgItemMessage,hWnd,IDC_CONN_STR,EM_SETLIMITTEXT,1024,0
			invoke	SendDlgItemMessage,hWnd,IDC_SQL,EM_SETLIMITTEXT,1024,0
			invoke	SetDlgItemText,hWnd,IDC_CONN_STR,addr szDefConnStr
;********************************************************************
		.elseif	eax ==	WM_CLOSE
			.if	! hEnv && !hConn
				invoke	EndDialog,hWinMain,NULL
			.endif
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
		invoke	InitCommonControls
		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		invoke	DialogBoxParam,eax,DLG_MAIN,NULL,offset _ProcDlgMain,0
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
