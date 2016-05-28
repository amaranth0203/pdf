;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; MsgWindow.asm (MsgWindows02)
; 实验代码：去掉消息循环中 DispatchMessage 函数以测试是否有消息
; 并不经过消息循环。
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff MsgWindow.asm
; Link /subsystem:windows MsgWindow.obj
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.386
		.model flat,stdcall
		option casemap:none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include 文件定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		gdi32.inc
includelib	gdi32.lib
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?

hInstance	dd	?
hWinMain	dd	?

		.const

szClassName	db	'MyClass',0
szCaptionMain	db	'Message Tester',0
;********************************************************************
; 消息ID列表
;********************************************************************
dwMsgTable	dd	WM_NULL
		dd	WM_CREATE
		dd	WM_DESTROY
		dd	WM_MOVE
		dd	WM_SIZE
		dd	WM_ACTIVATE
		dd	WM_SETFOCUS
		dd	WM_KILLFOCUS
		dd	WM_ENABLE
		dd	WM_SETREDRAW
		dd	WM_SETTEXT
		dd	WM_GETTEXT
		dd	WM_GETTEXTLENGTH
		dd	WM_PAINT
		dd	WM_CLOSE
		dd	WM_QUERYENDSESSION
		dd	WM_QUIT
		dd	WM_QUERYOPEN
		dd	WM_ERASEBKGND
		dd	WM_SYSCOLORCHANGE
		dd	WM_ENDSESSION
		dd	WM_SHOWWINDOW
		dd	WM_WININICHANGE
		dd	WM_DEVMODECHANGE
		dd	WM_ACTIVATEAPP
		dd	WM_FONTCHANGE
		dd	WM_TIMECHANGE
		dd	WM_CANCELMODE
		dd	WM_SETCURSOR
		dd	WM_MOUSEACTIVATE
		dd	WM_CHILDACTIVATE
		dd	WM_QUEUESYNC
		dd	WM_GETMINMAXINFO
		dd	WM_PAINTICON
		dd	WM_ICONERASEBKGND
		dd	WM_NEXTDLGCTL
		dd	WM_SPOOLERSTATUS
		dd	WM_DRAWITEM
		dd	WM_MEASUREITEM
		dd	WM_DELETEITEM
		dd	WM_VKEYTOITEM
		dd	WM_CHARTOITEM
		dd	WM_SETFONT
		dd	WM_GETFONT
		dd	WM_SETHOTKEY
		dd	WM_GETHOTKEY
		dd	WM_QUERYDRAGICON
		dd	WM_COMPAREITEM
		dd	WM_GETOBJECT
		dd	WM_COMPACTING
		dd	WM_OTHERWINDOWCREATED
		dd	WM_OTHERWINDOWDESTROYED
		dd	WM_COMMNOTIFY
		dd	WM_WINDOWPOSCHANGING
		dd	WM_WINDOWPOSCHANGED
		dd	WM_POWER
		dd	WM_COPYDATA
		dd	WM_CANCELJOURNAL
		dd	WM_NOTIFY
		dd	WM_INPUTLANGCHANGEREQUEST
		dd	WM_INPUTLANGCHANGE
		dd	WM_TCARD
		dd	WM_HELP
		dd	WM_USERCHANGED
		dd	WM_NOTIFYFORMAT
		dd	WM_CONTEXTMENU
		dd	WM_STYLECHANGING
		dd	WM_STYLECHANGED
		dd	WM_DISPLAYCHANGE
		dd	WM_GETICON
		dd	WM_SETICON
		dd	WM_NCCREATE
		dd	WM_NCDESTROY
		dd	WM_NCCALCSIZE
		dd	WM_NCHITTEST
		dd	WM_NCPAINT
		dd	WM_NCACTIVATE
		dd	WM_GETDLGCODE
		dd	WM_SYNCPAINT
		dd	WM_NCMOUSEMOVE
		dd	WM_NCLBUTTONDOWN
		dd	WM_NCLBUTTONUP
		dd	WM_NCLBUTTONDBLCLK
		dd	WM_NCRBUTTONDOWN
		dd	WM_NCRBUTTONUP
		dd	WM_NCRBUTTONDBLCLK
		dd	WM_NCMBUTTONDOWN
		dd	WM_NCMBUTTONUP
		dd	WM_NCMBUTTONDBLCLK
		dd	WM_KEYDOWN
		dd	WM_KEYUP
		dd	WM_CHAR
		dd	WM_DEADCHAR
		dd	WM_SYSKEYDOWN
		dd	WM_SYSKEYUP
		dd	WM_SYSCHAR
		dd	WM_SYSDEADCHAR
		dd	WM_KEYLAST
		dd	WM_INITDIALOG
		dd	WM_COMMAND
		dd	WM_SYSCOMMAND
		dd	WM_TIMER
		dd	WM_HSCROLL
		dd	WM_VSCROLL
		dd	WM_INITMENU
		dd	WM_INITMENUPOPUP
		dd	WM_MENUSELECT
		dd	WM_MENUCHAR
		dd	WM_ENTERIDLE
		dd	WM_CTLCOLORMSGBOX
		dd	WM_CTLCOLOREDIT
		dd	WM_CTLCOLORLISTBOX
		dd	WM_CTLCOLORBTN
		dd	WM_CTLCOLORDLG
		dd	WM_CTLCOLORSCROLLBAR
		dd	WM_CTLCOLORSTATIC
		dd	WM_MOUSEMOVE
		dd	WM_LBUTTONDOWN
		dd	WM_LBUTTONUP
		dd	WM_LBUTTONDBLCLK
		dd	WM_RBUTTONDOWN
		dd	WM_RBUTTONUP
		dd	WM_RBUTTONDBLCLK
		dd	WM_MBUTTONDOWN
		dd	WM_MBUTTONUP
		dd	WM_MBUTTONDBLCLK
		dd	WM_MOUSELAST
		dd	WM_PARENTNOTIFY
		dd	WM_ENTERMENULOOP
		dd	WM_EXITMENULOOP
		dd	WM_MDICREATE
		dd	WM_MDIDESTROY
		dd	WM_MDIACTIVATE
		dd	WM_MDIRESTORE
		dd	WM_MDINEXT
		dd	WM_MDIMAXIMIZE
		dd	WM_MDITILE
		dd	WM_MDICASCADE
		dd	WM_MDIICONARRANGE
		dd	WM_MDIGETACTIVE
		dd	WM_MDISETMENU
		dd	WM_DROPFILES
		dd	WM_MDIREFRESHMENU
		dd	WM_CUT
		dd	WM_COPY
		dd	WM_PASTE
		dd	WM_CLEAR
		dd	WM_UNDO
		dd	WM_RENDERFORMAT
		dd	WM_RENDERALLFORMATS
		dd	WM_DESTROYCLIPBOARD
		dd	WM_DRAWCLIPBOARD
		dd	WM_PAINTCLIPBOARD
		dd	WM_VSCROLLCLIPBOARD
		dd	WM_SIZECLIPBOARD
		dd	WM_ASKCBFORMATNAME
		dd	WM_CHANGECBCHAIN
		dd	WM_HSCROLLCLIPBOARD
		dd	WM_QUERYNEWPALETTE
		dd	WM_PALETTEISCHANGING
		dd	WM_PALETTECHANGED
		dd	WM_HOTKEY
		dd	WM_PRINT
		dd	WM_PRINTCLIENT
		dd	WM_PENWINFIRST
		dd	WM_PENWINLAST
		dd	WM_MENURBUTTONUP
		dd	WM_MENUDRAG
		dd	WM_MENUGETOBJECT
		dd	WM_UNINITMENUPOPUP
		dd	WM_MENUCOMMAND
		dd	WM_NEXTMENU
		dd	WM_SIZING
		dd	WM_CAPTURECHANGED
		dd	WM_MOVING
		dd	WM_POWERBROADCAST
		dd	WM_DEVICECHANGE
		dd	WM_ENTERSIZEMOVE
		dd	WM_EXITSIZEMOVE
MSG_TABLE_LEN	equ	($ - dwMsgTable)/sizeof dword
;********************************************************************
; 消息名称字符串列表
;********************************************************************
MSG_STRING_LEN	equ	sizeof szStringTable
szStringTable	db	'WM_NULL                  ',0
		db	'WM_CREATE                ',0
		db	'WM_DESTROY               ',0
		db	'WM_MOVE                  ',0
		db	'WM_SIZE                  ',0
		db	'WM_ACTIVATE              ',0
		db	'WM_SETFOCUS              ',0
		db	'WM_KILLFOCUS             ',0
		db	'WM_ENABLE                ',0
		db	'WM_SETREDRAW             ',0
		db	'WM_SETTEXT               ',0
		db	'WM_GETTEXT               ',0
		db	'WM_GETTEXTLENGTH         ',0
		db	'WM_PAINT                 ',0
		db	'WM_CLOSE                 ',0
		db	'WM_QUERYENDSESSION       ',0
		db	'WM_QUIT                  ',0
		db	'WM_QUERYOPEN             ',0
		db	'WM_ERASEBKGND            ',0
		db	'WM_SYSCOLORCHANGE        ',0
		db	'WM_ENDSESSION            ',0
		db	'WM_SHOWWINDOW            ',0
		db	'WM_WININICHANGE          ',0
		db	'WM_DEVMODECHANGE         ',0
		db	'WM_ACTIVATEAPP           ',0
		db	'WM_FONTCHANGE            ',0
		db	'WM_TIMECHANGE            ',0
		db	'WM_CANCELMODE            ',0
		db	'WM_SETCURSOR             ',0
		db	'WM_MOUSEACTIVATE         ',0
		db	'WM_CHILDACTIVATE         ',0
		db	'WM_QUEUESYNC             ',0
		db	'WM_GETMINMAXINFO         ',0
		db	'WM_PAINTICON             ',0
		db	'WM_ICONERASEBKGND        ',0
		db	'WM_NEXTDLGCTL            ',0
		db	'WM_SPOOLERSTATUS         ',0
		db	'WM_DRAWITEM              ',0
		db	'WM_MEASUREITEM           ',0
		db	'WM_DELETEITEM            ',0
		db	'WM_VKEYTOITEM            ',0
		db	'WM_CHARTOITEM            ',0
		db	'WM_SETFONT               ',0
		db	'WM_GETFONT               ',0
		db	'WM_SETHOTKEY             ',0
		db	'WM_GETHOTKEY             ',0
		db	'WM_QUERYDRAGICON         ',0
		db	'WM_COMPAREITEM           ',0
		db	'WM_GETOBJECT             ',0
		db	'WM_COMPACTING            ',0
		db	'WM_OTHERWINDOWCREATED    ',0
		db	'WM_OTHERWINDOWDESTROYED  ',0
		db	'WM_COMMNOTIFY            ',0
		db	'WM_WINDOWPOSCHANGING     ',0
		db	'WM_WINDOWPOSCHANGED      ',0
		db	'WM_POWER                 ',0
		db	'WM_COPYDATA              ',0
		db	'WM_CANCELJOURNAL         ',0
		db	'WM_NOTIFY                ',0
		db	'WM_INPUTLANGCHANGEREQUEST',0
		db	'WM_INPUTLANGCHANGE       ',0
		db	'WM_TCARD                 ',0
		db	'WM_HELP                  ',0
		db	'WM_USERCHANGED           ',0
		db	'WM_NOTIFYFORMAT          ',0
		db	'WM_CONTEXTMENU           ',0
		db	'WM_STYLECHANGING         ',0
		db	'WM_STYLECHANGED          ',0
		db	'WM_DISPLAYCHANGE         ',0
		db	'WM_GETICON               ',0
		db	'WM_SETICON               ',0
		db	'WM_NCCREATE              ',0
		db	'WM_NCDESTROY             ',0
		db	'WM_NCCALCSIZE            ',0
		db	'WM_NCHITTEST             ',0
		db	'WM_NCPAINT               ',0
		db	'WM_NCACTIVATE            ',0
		db	'WM_GETDLGCODE            ',0
		db	'WM_SYNCPAINT             ',0
		db	'WM_NCMOUSEMOVE           ',0
		db	'WM_NCLBUTTONDOWN         ',0
		db	'WM_NCLBUTTONUP           ',0
		db	'WM_NCLBUTTONDBLCLK       ',0
		db	'WM_NCRBUTTONDOWN         ',0
		db	'WM_NCRBUTTONUP           ',0
		db	'WM_NCRBUTTONDBLCLK       ',0
		db	'WM_NCMBUTTONDOWN         ',0
		db	'WM_NCMBUTTONUP           ',0
		db	'WM_NCMBUTTONDBLCLK       ',0
		db	'WM_KEYDOWN               ',0
		db	'WM_KEYUP                 ',0
		db	'WM_CHAR                  ',0
		db	'WM_DEADCHAR              ',0
		db	'WM_SYSKEYDOWN            ',0
		db	'WM_SYSKEYUP              ',0
		db	'WM_SYSCHAR               ',0
		db	'WM_SYSDEADCHAR           ',0
		db	'WM_KEYLAST               ',0
		db	'WM_INITDIALOG            ',0
		db	'WM_COMMAND               ',0
		db	'WM_SYSCOMMAND            ',0
		db	'WM_TIMER                 ',0
		db	'WM_HSCROLL               ',0
		db	'WM_VSCROLL               ',0
		db	'WM_INITMENU              ',0
		db	'WM_INITMENUPOPUP         ',0
		db	'WM_MENUSELECT            ',0
		db	'WM_MENUCHAR              ',0
		db	'WM_ENTERIDLE             ',0
		db	'WM_CTLCOLORMSGBOX        ',0
		db	'WM_CTLCOLOREDIT          ',0
		db	'WM_CTLCOLORLISTBOX       ',0
		db	'WM_CTLCOLORBTN           ',0
		db	'WM_CTLCOLORDLG           ',0
		db	'WM_CTLCOLORSCROLLBAR     ',0
		db	'WM_CTLCOLORSTATIC        ',0
		db	'WM_MOUSEMOVE             ',0
		db	'WM_LBUTTONDOWN           ',0
		db	'WM_LBUTTONUP             ',0
		db	'WM_LBUTTONDBLCLK         ',0
		db	'WM_RBUTTONDOWN           ',0
		db	'WM_RBUTTONUP             ',0
		db	'WM_RBUTTONDBLCLK         ',0
		db	'WM_MBUTTONDOWN           ',0
		db	'WM_MBUTTONUP             ',0
		db	'WM_MBUTTONDBLCLK         ',0
		db	'WM_MOUSELAST             ',0
		db	'WM_PARENTNOTIFY          ',0
		db	'WM_ENTERMENULOOP         ',0
		db	'WM_EXITMENULOOP          ',0
		db	'WM_MDICREATE             ',0
		db	'WM_MDIDESTROY            ',0
		db	'WM_MDIACTIVATE           ',0
		db	'WM_MDIRESTORE            ',0
		db	'WM_MDINEXT               ',0
		db	'WM_MDIMAXIMIZE           ',0
		db	'WM_MDITILE               ',0
		db	'WM_MDICASCADE            ',0
		db	'WM_MDIICONARRANGE        ',0
		db	'WM_MDIGETACTIVE          ',0
		db	'WM_MDISETMENU            ',0
		db	'WM_DROPFILES             ',0
		db	'WM_MDIREFRESHMENU        ',0
		db	'WM_CUT                   ',0
		db	'WM_COPY                  ',0
		db	'WM_PASTE                 ',0
		db	'WM_CLEAR                 ',0
		db	'WM_UNDO                  ',0
		db	'WM_RENDERFORMAT          ',0
		db	'WM_RENDERALLFORMATS      ',0
		db	'WM_DESTROYCLIPBOARD      ',0
		db	'WM_DRAWCLIPBOARD         ',0
		db	'WM_PAINTCLIPBOARD        ',0
		db	'WM_VSCROLLCLIPBOARD      ',0
		db	'WM_SIZECLIPBOARD         ',0
		db	'WM_ASKCBFORMATNAME       ',0
		db	'WM_CHANGECBCHAIN         ',0
		db	'WM_HSCROLLCLIPBOARD      ',0
		db	'WM_QUERYNEWPALETTE       ',0
		db	'WM_PALETTEISCHANGING     ',0
		db	'WM_PALETTECHANGED        ',0
		db	'WM_HOTKEY                ',0
		db	'WM_PRINT                 ',0
		db	'WM_PRINTCLIENT           ',0
		db	'WM_PENWINFIRST           ',0
		db	'WM_PENWINLAST            ',0
		db	'WM_MENURBUTTONUP         ',0
		db	'WM_MENUDRAG              ',0
		db	'WM_MENUGETOBJECT         ',0
		db	'WM_UNINITMENUPOPUP       ',0
		db	'WM_MENUCOMMAND           ',0
		db	'WM_NEXTMENU              ',0
		db	'WM_SIZING                ',0
		db	'WM_CAPTURECHANGED        ',0
		db	'WM_MOVING                ',0
		db	'WM_POWERBROADCAST        ',0
		db	'WM_DEVICECHANGE          ',0
		db	'WM_ENTERSIZEMOVE         ',0
		db	'WM_EXITSIZEMOVE          ',0
;********************************************************************
szDestClass	db	'Notepad',0
szFormat	db	'WndProc: [%04x]%s %08x %08x',0dh,0
szCreateWindow1	db	'Creating Window...',0dh,0
szCreateWindow2	db	'CreateWindow end',0dh,0
szShowWindow1	db	'Showing Window...',0dh,0
szShowWindow2	db	'ShowWindow end',0dh,0
szUpdateWindow1	db	'Updating Window...',0dh,0
szUpdateWindow2	db	'UpdateWindow end',0dh,0
szGetMsg1	db	'Getting Message...',0dh,0
szGetMsg2	db	'[%04x]Message gotten',0dh,0
szDispatchMsg1	db	'Dispatching Message...',0dh,0
szDispatchMsg2	db	'DispatchMessage end',0dh,0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_SendtoNotepad	proc	_lpsz
		local	@hWinNotepad

		pushad
		invoke	FindWindow,addr szDestClass,NULL
		.if	eax
			mov	ecx,eax
			invoke	ChildWindowFromPoint,ecx,20,20
		.endif
		.if	eax
			mov	@hWinNotepad,eax
			mov	esi,_lpsz
			@@:
			lodsb
			or	al,al
			jz	@F
			movzx	eax,al
			invoke	PostMessage,@hWinNotepad,WM_CHAR,eax,1
			jmp	@B
			@@:
		.endif
		popad
		ret

_SendtoNotepad	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ShowMessage	proc	_uMsg,_wParam,_lParam
		local	@szBuffer[128]:byte

		pushad
;********************************************************************
; 查找消息的说明字符串
;********************************************************************
		mov	eax,_uMsg
		mov	edi,offset dwMsgTable
		mov	ecx,MSG_TABLE_LEN
		cld
		repnz	scasd
		.if	ZERO?
			sub	edi,offset dwMsgTable + sizeof dword
			shr	edi,2
			mov	eax,edi
			mov	ecx,MSG_STRING_LEN
			mul	ecx
			add	eax,offset szStringTable
;********************************************************************
; 翻译格式并发送到 Notepad 窗口
;********************************************************************
			invoke	wsprintf,addr @szBuffer,addr szFormat,\
				_uMsg,eax,_wParam,_lParam
			invoke	_SendtoNotepad,addr @szBuffer
		.endif
		popad
		ret

_ShowMessage	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 窗口过程
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcWinMain	proc	uses ebx edi esi,hWnd,uMsg,wParam,lParam

		invoke	_ShowMessage,uMsg,wParam,lParam
		mov	eax,uMsg
;********************************************************************
		.if	eax ==	WM_CLOSE
			invoke	DestroyWindow,hWinMain
			invoke	PostQuitMessage,NULL
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
		local	@szBuffer[128]:byte
		local	@stWndClass:WNDCLASSEX
		local	@stMsg:MSG

		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
		invoke	RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
;********************************************************************
; 注册窗口类
;********************************************************************
		invoke	LoadCursor,0,IDC_ARROW
		mov	@stWndClass.hCursor,eax
		push	hInstance
		pop	@stWndClass.hInstance
		mov	@stWndClass.cbSize,sizeof WNDCLASSEX
		mov	@stWndClass.style,CS_HREDRAW or CS_VREDRAW
		mov	@stWndClass.lpfnWndProc,offset _ProcWinMain
		mov	@stWndClass.hbrBackground,COLOR_WINDOW + 1
		mov	@stWndClass.lpszClassName,offset szClassName
		invoke	RegisterClassEx,addr @stWndClass
;********************************************************************
; 建立并显示窗口
;********************************************************************
		invoke	_SendtoNotepad,addr szCreateWindow1
		invoke	CreateWindowEx,WS_EX_CLIENTEDGE	,offset szClassName,offset szCaptionMain,\
			WS_OVERLAPPEDWINDOW,\
			50,50,100,100,\
			NULL,NULL,hInstance,NULL
		mov	hWinMain,eax
		invoke	_SendtoNotepad,addr szCreateWindow2

		invoke	_SendtoNotepad,addr szShowWindow1
		invoke	ShowWindow,hWinMain,SW_SHOWNORMAL
		invoke	_SendtoNotepad,addr szShowWindow2

		invoke	_SendtoNotepad,addr szUpdateWindow1
		invoke	UpdateWindow,hWinMain
		invoke	_SendtoNotepad,addr szUpdateWindow2
;********************************************************************
; 消息循环
;********************************************************************
		.while	TRUE
;			invoke	_SendtoNotepad,addr szGetMsg1
			invoke	GetMessage,addr @stMsg,NULL,0,0
;			push	eax
;			invoke	wsprintf,addr @szBuffer,addr szGetMsg2,@stMsg.message
;			invoke	_SendtoNotepad,addr @szBuffer
;			pop	eax
			.break	.if eax	== 0

;			invoke	TranslateMessage,addr @stMsg

;			invoke	_SendtoNotepad,addr szDispatchMsg1
;			invoke	DispatchMessage,addr @stMsg
;			invoke	_SendtoNotepad,addr szDispatchMsg2
		.endw
		ret

_WinMain	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		call	_WinMain
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
