;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Richedit.asm
; ���ḻ�༭���ؼ���ʹ������
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ʹ�� nmake ������������б��������:
; ml /c /coff Richedit.asm
; rc Richedit.rc
; Link /subsystem:windows Richedit.obj Richedit.res
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
IDA_MAIN	equ	2000
IDM_MAIN	equ	2000
IDM_OPEN	equ	2101
IDM_SAVE	equ	2102
IDM_EXIT	equ	2103
IDM_UNDO	equ	2201
IDM_REDO	equ	2202
IDM_SELALL	equ	2203
IDM_COPY	equ	2204
IDM_CUT		equ	2205
IDM_PASTE	equ	2206
IDM_FIND	equ	2207
IDM_FINDPREV	equ	2208
IDM_FINDNEXT	equ	2209
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ݶ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd	?
hWinMain	dd	?
hMenu		dd	?
hWinEdit	dd	?
hFile		dd	?
hFindDialog	dd	?
idFindMessage	dd	?
szFileName	db	MAX_PATH dup (?)
szFindText	db	100 dup (?)

		.data
stFind		FINDREPLACE <sizeof FINDREPLACE,0,0,FR_DOWN,szFindText,\
		0,sizeof szFindText,0,0,0,0>

		.const
FINDMSGSTRING	db	'commdlg_FindReplace',0
szClassName	db	'Wordpad',0
szCaptionMain	db	'���±�',0
szDllEdit	db	'RichEd20.dll',0
szClassEdit	db	'RichEdit20A',0
szNotFound	db	'�ַ���δ�ҵ�!',0
szFilter	db	'Text Files(*.txt)',0,'*.txt',0
		db	'All Files(*.*)',0,'*.*',0,0
szDefaultExt	db	'txt',0
szErrOpenFile	db	'�޷����ļ�!',0
szModify	db	'�ļ����޸ģ��Ƿ񱣴�?',0
szFont		db	'����',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Richedit��������
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcStream	proc uses ebx edi esi _dwCookie,_lpBuffer,_dwBytes,_lpBytes

		.if	_dwCookie
			invoke	ReadFile,hFile,_lpBuffer,_dwBytes,_lpBytes,0
		.else
			invoke	WriteFile,hFile,_lpBuffer,_dwBytes,_lpBytes,0
		.endif
		xor	eax,eax
		ret

_ProcStream	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �����ļ������û�д򿪻򴴽��ļ�����á����Ϊ���ӳ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_SaveFile	proc
		local	@stES:EDITSTREAM

		invoke	SetFilePointer,hFile,0,0,FILE_BEGIN
		invoke	SetEndOfFile,hFile
		mov	@stES.dwCookie,FALSE
		mov	@stES.pfnCallback,offset _ProcStream
		invoke	SendMessage,hWinEdit,EM_STREAMOUT,SF_TEXT,addr @stES
		invoke	SendMessage,hWinEdit,EM_SETMODIFY,FALSE,0
		ret

_SaveFile	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �򿪼������ļ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_OpenFile	proc
		local	@stOF:OPENFILENAME
		local	@stES:EDITSTREAM

;********************************************************************
; ��ʾ�����ļ����Ի���
;********************************************************************
		invoke	RtlZeroMemory,addr @stOF,sizeof @stOF
		mov	@stOF.lStructSize,sizeof @stOF
		push	hWinMain
		pop	@stOF.hwndOwner
		mov	@stOF.lpstrFilter,offset szFilter
		mov	@stOF.lpstrFile,offset szFileName
		mov	@stOF.nMaxFile,MAX_PATH
		mov	@stOF.Flags,OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
		mov	@stOF.lpstrDefExt,offset szDefaultExt
		invoke	GetOpenFileName,addr @stOF
		.if	eax
;********************************************************************
; �����ļ�
;********************************************************************
			invoke	CreateFile,addr szFileName,GENERIC_READ or GENERIC_WRITE,\
				FILE_SHARE_READ or FILE_SHARE_WRITE,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
			.if	eax ==	INVALID_HANDLE_VALUE
				invoke	MessageBox,hWinMain,addr szErrOpenFile,NULL,MB_OK or MB_ICONSTOP
				ret
			.endif
			push	eax
			.if	hFile
				invoke	CloseHandle,hFile
			.endif
			pop	eax
			mov	hFile,eax
;********************************************************************
; �����ļ�
;********************************************************************
			mov	@stES.dwCookie,TRUE
			mov	@stES.pfnCallback,offset _ProcStream
			invoke	SendMessage,hWinEdit,EM_STREAMIN,SF_TEXT,addr @stES
			invoke	SendMessage,hWinEdit,EM_SETMODIFY,FALSE,0
		.endif
		ret

_OpenFile	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ������������򷵻�TRUE
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_CheckModify	proc
		local	@dwReturn

		mov	@dwReturn,TRUE
		invoke	SendMessage,hWinEdit,EM_GETMODIFY,0,0
		.if	eax && hFile
			invoke	MessageBox,hWinMain,addr szModify,addr szCaptionMain,\
				MB_YESNOCANCEL or MB_ICONQUESTION
			.if	eax ==	IDYES
				call	_SaveFile
			.elseif	eax ==	IDCANCEL
				mov	@dwReturn,FALSE
			.endif
		.endif
		mov	eax,@dwReturn
		ret

_CheckModify	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ��������
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_FindText	proc
		local	@stFindText:FINDTEXTEX

;********************************************************************
; ���ò��ҷ�Χ
;********************************************************************
		invoke	SendMessage,hWinEdit,EM_EXGETSEL,0,addr @stFindText.chrg
		.if	stFind.Flags & FR_DOWN
			push	@stFindText.chrg.cpMax
			pop	@stFindText.chrg.cpMin
		.endif
		mov	@stFindText.chrg.cpMax,-1
;********************************************************************
; ���ò���ѡ��
;********************************************************************
		mov	@stFindText.lpstrText,offset szFindText
		mov	ecx,stFind.Flags
		and	ecx,FR_MATCHCASE or FR_DOWN or FR_WHOLEWORD
;********************************************************************
; ���Ҳ��ѹ�����õ��ҵ����ı���
;********************************************************************
		invoke	SendMessage,hWinEdit,EM_FINDTEXTEX,ecx,addr @stFindText
		.if	eax ==	-1
			mov	ecx,hWinMain
			.if	hFindDialog
				mov	ecx,hFindDialog
			.endif
			invoke	MessageBox,ecx,addr szNotFound,NULL,MB_OK or MB_ICONINFORMATION
			ret
		.endif
		invoke	SendMessage,hWinEdit,EM_EXSETSEL,0,addr @stFindText.chrgText
		invoke	SendMessage,hWinEdit,EM_SCROLLCARET,NULL,NULL
		ret

_FindText	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ��������ı�˵���״̬
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_SetStatus	proc
		local	@stRange:CHARRANGE

		invoke	SendMessage,hWinEdit,EM_EXGETSEL,0,addr @stRange
;********************************************************************
		mov	eax,@stRange.cpMin
		.if	eax ==	@stRange.cpMax
			invoke	EnableMenuItem,hMenu,IDM_COPY,MF_GRAYED
			invoke	EnableMenuItem,hMenu,IDM_CUT,MF_GRAYED
		.else
			invoke	EnableMenuItem,hMenu,IDM_COPY,MF_ENABLED
			invoke	EnableMenuItem,hMenu,IDM_CUT,MF_ENABLED
		.endif
;********************************************************************
		invoke	SendMessage,hWinEdit,EM_CANPASTE,0,0
		.if	eax
			invoke	EnableMenuItem,hMenu,IDM_PASTE,MF_ENABLED
		.else
			invoke	EnableMenuItem,hMenu,IDM_PASTE,MF_GRAYED
		.endif
;********************************************************************
		invoke	SendMessage,hWinEdit,EM_CANREDO,0,0
		.if	eax
			invoke	EnableMenuItem,hMenu,IDM_REDO,MF_ENABLED
		.else
			invoke	EnableMenuItem,hMenu,IDM_REDO,MF_GRAYED
		.endif
;********************************************************************
		invoke	SendMessage,hWinEdit,EM_CANUNDO,0,0
		.if	eax
			invoke	EnableMenuItem,hMenu,IDM_UNDO,MF_ENABLED
		.else
			invoke	EnableMenuItem,hMenu,IDM_UNDO,MF_GRAYED
		.endif
;********************************************************************
		invoke	GetWindowTextLength,hWinEdit
		.if	eax
			invoke	EnableMenuItem,hMenu,IDM_SELALL,MF_ENABLED
		.else
			invoke	EnableMenuItem,hMenu,IDM_SELALL,MF_GRAYED
		.endif
;********************************************************************
		invoke	SendMessage,hWinEdit,EM_GETMODIFY,0,0
		.if	eax && hFile
			invoke	EnableMenuItem,hMenu,IDM_SAVE,MF_ENABLED
		.else
			invoke	EnableMenuItem,hMenu,IDM_SAVE,MF_GRAYED
		.endif
;********************************************************************
		.if	szFindText
			invoke	EnableMenuItem,hMenu,IDM_FINDNEXT,MF_ENABLED
			invoke	EnableMenuItem,hMenu,IDM_FINDPREV,MF_ENABLED
		.else
			invoke	EnableMenuItem,hMenu,IDM_FINDNEXT,MF_GRAYED
			invoke	EnableMenuItem,hMenu,IDM_FINDPREV,MF_GRAYED
		.endif
;********************************************************************
		ret

_SetStatus	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Init		proc
		local	@stCf:CHARFORMAT

;********************************************************************
; ע�ᡰ���ҡ��Ի�����Ϣ����ʼ�������ҡ��Ի���Ľṹ
;********************************************************************
		push	hWinMain
		pop	stFind.hwndOwner
		invoke	RegisterWindowMessage,addr FINDMSGSTRING
		mov	idFindMessage,eax
;********************************************************************
; ��������ı�����
;********************************************************************
		invoke	CreateWindowEx,WS_EX_CLIENTEDGE,offset szClassEdit,NULL,\
			WS_CHILD OR WS_VISIBLE OR WS_VSCROLL OR	WS_HSCROLL \
			OR ES_MULTILINE or ES_NOHIDESEL,\
			0,0,0,0,\
			hWinMain,0,hInstance,NULL
		mov	hWinEdit,eax

		invoke	SendMessage,hWinEdit,EM_SETTEXTMODE,TM_PLAINTEXT,0
		invoke	RtlZeroMemory,addr @stCf,sizeof @stCf
		mov	@stCf.cbSize,sizeof @stCf
		mov	@stCf.yHeight,9 * 20
		mov	@stCf.dwMask,CFM_FACE or CFM_SIZE or CFM_BOLD
		invoke	lstrcpy,addr @stCf.szFaceName,addr szFont
		invoke	SendMessage,hWinEdit,EM_SETCHARFORMAT,0,addr @stCf
		invoke	SendMessage,hWinEdit,EM_EXLIMITTEXT,0,-1
		ret

_Init		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Quit		proc

		invoke	_CheckModify
		.if	eax
			invoke	DestroyWindow,hWinMain
			invoke	PostQuitMessage,NULL
			.if	hFile
				invoke	CloseHandle,hFile
			.endif
		.endif
		ret

_Quit		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcWinMain	proc	uses ebx edi esi hWnd,uMsg,wParam,lParam
		local	@stRange:CHARRANGE
		local	@stRect:RECT

		mov	eax,uMsg
		.if	eax ==	WM_SIZE
			invoke	GetClientRect,hWinMain,addr @stRect
			invoke	MoveWindow,hWinEdit,0,0,@stRect.right,@stRect.bottom,TRUE
;********************************************************************
; ����˵������ټ�����������Ϣ
;********************************************************************
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
			movzx	eax,ax
			.if	eax ==	IDM_OPEN
				invoke	_CheckModify
				.if	eax
					call	_OpenFile
				.endif
			.elseif	eax ==	IDM_SAVE
				call	_SaveFile
			.elseif	eax ==	IDM_EXIT
				invoke	_Quit
			.elseif	eax ==	IDM_UNDO
				invoke	SendMessage,hWinEdit,EM_UNDO,0,0
			.elseif	eax ==	IDM_REDO
				invoke	SendMessage,hWinEdit,EM_REDO,0,0
			.elseif	eax ==	IDM_SELALL
				mov	@stRange.cpMin,0
				mov	@stRange.cpMax,-1
				invoke	SendMessage,hWinEdit,EM_EXSETSEL,0,addr @stRange
			.elseif	eax ==	IDM_COPY
				invoke	SendMessage,hWinEdit,WM_COPY,0,0
			.elseif	eax ==	IDM_CUT
				invoke	SendMessage,hWinEdit,WM_CUT,0,0
			.elseif	eax ==	IDM_PASTE
				invoke	SendMessage,hWinEdit,WM_PASTE,0,0
			.elseif	eax ==	IDM_FIND
				and	stFind.Flags,not FR_DIALOGTERM
				invoke	FindText,addr stFind
				.if	eax
					mov	hFindDialog,eax
				.endif
			.elseif	eax ==	IDM_FINDPREV
				and	stFind.Flags,not FR_DOWN
				invoke	_FindText
			.elseif	eax ==	IDM_FINDNEXT
				or	stFind.Flags,FR_DOWN
				invoke	_FindText
			.endif
;********************************************************************
		.elseif	eax ==	WM_INITMENU
			call	_SetStatus
		.elseif	eax ==	idFindMessage
			.if	stFind.Flags & FR_DIALOGTERM
				mov	hFindDialog,0
			.else
				invoke	_FindText
			.endif
;********************************************************************
		.elseif	eax ==	WM_ACTIVATE
			mov	eax,wParam
			.if	(ax ==	WA_CLICKACTIVE ) || (ax == WA_ACTIVE)
				invoke	SetFocus,hWinEdit
			.endif
;********************************************************************
		.elseif	eax ==	WM_CREATE
			push	hWnd
			pop	hWinMain
			invoke	_Init
;********************************************************************
		.elseif	eax ==	WM_CLOSE
			call	_Quit
;********************************************************************
		.else
			invoke	DefWindowProc,hWnd,uMsg,wParam,lParam
			ret
		.endif
;********************************************************************
		xor	eax,eax
		ret

_ProcWinMain	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_WinMain	proc
		local	@stWndClass:WNDCLASSEX
		local	@stMsg:MSG
		local	@hAccelerator,@hRichEdit

		invoke	LoadLibrary,offset szDllEdit
		mov	@hRichEdit,eax
		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		invoke	LoadMenu,hInstance,IDM_MAIN
		mov	hMenu,eax
		invoke	LoadAccelerators,hInstance,IDA_MAIN
		mov	@hAccelerator,eax
;********************************************************************
; ע�ᴰ����
;********************************************************************
		invoke	RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
		invoke	LoadIcon,hInstance,ICO_MAIN
		mov	@stWndClass.hIcon,eax
		mov	@stWndClass.hIconSm,eax
		invoke	LoadCursor,0,IDC_ARROW
		mov	@stWndClass.hCursor,eax
		push	hInstance
		pop	@stWndClass.hInstance
		mov	@stWndClass.cbSize,sizeof WNDCLASSEX
		mov	@stWndClass.style,CS_HREDRAW or CS_VREDRAW
		mov	@stWndClass.lpfnWndProc,offset _ProcWinMain
		mov	@stWndClass.hbrBackground,COLOR_BTNFACE+1
		mov	@stWndClass.lpszClassName,offset szClassName
		invoke	RegisterClassEx,addr @stWndClass
;********************************************************************
; ��������ʾ����
;********************************************************************
		invoke	CreateWindowEx,NULL,\
			offset szClassName,offset szCaptionMain,\
			WS_OVERLAPPEDWINDOW,\
			CW_USEDEFAULT,CW_USEDEFAULT,700,500,\
			NULL,hMenu,hInstance,NULL
		mov	hWinMain,eax
		invoke	ShowWindow,hWinMain,SW_SHOWNORMAL
		invoke	UpdateWindow,hWinMain
;********************************************************************
; ��Ϣѭ��
;********************************************************************
		.while	TRUE
			invoke	GetMessage,addr @stMsg,NULL,0,0
			.break	.if eax	== 0
			invoke	TranslateAccelerator,hWinMain,@hAccelerator,addr @stMsg
			.if	eax == 0
				invoke	TranslateMessage,addr @stMsg
				invoke	DispatchMessage,addr @stMsg
			.endif
		.endw
		invoke	FreeLibrary,@hRichEdit
		ret

_WinMain	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		call	_WinMain
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
