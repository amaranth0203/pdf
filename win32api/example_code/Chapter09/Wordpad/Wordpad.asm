;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Wordpad.asm
; 文本编辑器例子 —— 综合使用Richedit、工具栏、状态栏控件
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff Wordpad.asm
; rc Wordpad.rc
; Link /subsystem:windows Wordpad.obj Wordpad.res
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.386
		.model flat, stdcall
		option casemap :none
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Include 文件定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
include		comctl32.inc
includelib	comctl32.lib
include		comdlg32.inc
includelib	comdlg32.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equ 等值定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN	equ	1000
IDA_MAIN	equ	2000
IDM_MAIN	equ	2000
IDM_NEW		equ	2101
IDM_OPEN	equ	2102
IDM_SAVE	equ	2103
IDM_SAVEAS	equ	2104
IDM_PAGESETUP	equ	2105
IDM_EXIT	equ	2106
IDM_UNDO	equ	2201
IDM_REDO	equ	2202
IDM_SELALL	equ	2203
IDM_COPY	equ	2204
IDM_CUT		equ	2205
IDM_PASTE	equ	2206
IDM_FIND	equ	2207
IDM_FINDPREV	equ	2208
IDM_FINDNEXT	equ	2209
IDM_FONT	equ	2301
IDM_BKCOLOR	equ	2302
IDM_TOOLBAR	equ	2303
IDM_STATUSBAR	equ	2304
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
hInstance	dd	?
hWinMain	dd	?
hMenu		dd	?
hWinStatus	dd	?
hWinToolbar	dd	?
hWinEdit	dd	?
hFile		dd	?
hFindDialog	dd	?
dwFontColor	dd	?
dwBackColor	dd	?
idFindMessage	dd	?
dwCustColors	dd	16 dup (?)
szFileName	db	MAX_PATH dup (?)
szFindText	db	100 dup (?)
stLogFont	LOGFONT		<?>
stFind		FINDREPLACE	<?>
dwOption	dd	?
F_STATUSBAR	equ	00000001h
F_TOOLBAR	equ	00000002h

		.const
FINDMSGSTRING	db	'commdlg_FindReplace',0
szClassName	db	'Wordpad',0
szCaptionMain	db	'记事本',0
szDllEdit	db	'RichEd20.dll',0
szClassEdit	db	'RichEdit20A',0
dwStatusWidth	dd	50,100,200,300,350,-1
szFontFace	db	'宋体',0
szCharsFormat	db	'总长度:%d',0
szLinesFormat	db	'总行数:%d',0
szLineFormat	db	'行:%d',0
szColFormat	db	'列:%d',0
szTitleFormat	db	'记事本 - [%s]',0
szNotFound	db	'字符串未找到!',0
szNoName	db	'未命名的文件',0
szFilter	db	'Text Files(*.txt)',0,'*.txt',0,'All Files(*.*)',0,'*.*',0,0
szDefExt	db	'txt',0
szErrOpenFile	db	'无法打开文件!',0
szErrCreateFile	db	'无法建立文件!',0
szModify	db	'文件已修改，是否保存?',0
szHasModify	db	'已修改',0
szNotModify	db	'未修改',0
szCaption	db	'提问',0
szSaveCaption	db	'请输入保存的文件名',0
stToolbar	equ	this byte
TBBUTTON	<STD_FILENEW,IDM_NEW,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,-1>
TBBUTTON	<STD_FILEOPEN,IDM_OPEN,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,-1>
TBBUTTON	<STD_FILESAVE,IDM_SAVE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,-1>
TBBUTTON	<0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0,-1>
TBBUTTON	<STD_COPY,IDM_COPY,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,-1>
TBBUTTON	<STD_CUT,IDM_CUT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,-1>
TBBUTTON	<STD_PASTE,IDM_PASTE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,-1>
TBBUTTON	<0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0,-1>
TBBUTTON	<STD_UNDO,IDM_UNDO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,-1>
TBBUTTON	<STD_REDOW,IDM_REDO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,-1>
TBBUTTON	<0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0,-1>
TBBUTTON	<STD_FIND,IDM_FIND,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,-1>
TBBUTTON	<0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0,-1>
NUM_BUTTONS	EQU	13
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 允许继续操作则返回TRUE
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_CheckModify	proc

		invoke	SendMessage,hWinEdit,EM_GETMODIFY,0,0
		.if	eax
			invoke	MessageBox,hWinMain,addr szModify,addr szCaption,\
				MB_YESNOCANCEL or MB_ICONQUESTION
			.if	eax ==	IDYES
				call	_SaveFile
			.elseif	eax ==	IDNO
				mov	eax,TRUE
			.elseif	eax ==	IDCANCEL
				xor	eax,eax
			.endif
		.else
			mov	eax,TRUE
		.endif
		ret

_CheckModify	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Richedit的流操作
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
; 设置字体及字体颜色
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_SetFont	proc	_lpszFont,_dwFontSize,_dwColor
		local	@stCf:CHARFORMAT

		invoke	RtlZeroMemory,addr @stCf,sizeof @stCf
		mov	@stCf.cbSize,sizeof @stCf
		mov	@stCf.dwMask,CFM_SIZE or CFM_FACE or CFM_BOLD or CFM_COLOR
		push	_dwFontSize
		pop	@stCf.yHeight
		push	_dwColor
		pop	@stCf.crTextColor
		mov	@stCf.dwEffects,0
		invoke	lstrcpy,addr @stCf.szFaceName,_lpszFont
		invoke	SendMessage,hWinEdit,EM_SETTEXTMODE,1,0
		invoke	SendMessage,hWinEdit,EM_SETCHARFORMAT,SCF_ALL,addr @stCf
		ret

_SetFont	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 查找文字
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_FindText	proc
		local	@stFindText:FINDTEXTEX

;********************************************************************
; 设置查找范围
;********************************************************************
		invoke	SendMessage,hWinEdit,EM_EXGETSEL,0,addr @stFindText.chrg
		.if	stFind.Flags & FR_DOWN
			push	@stFindText.chrg.cpMax
			pop	@stFindText.chrg.cpMin
		.endif
		mov	@stFindText.chrg.cpMax,-1
;********************************************************************
; 设置查找选项
;********************************************************************
		mov	@stFindText.lpstrText,offset szFindText
		mov	ecx,stFind.Flags
		and	ecx,FR_MATCHCASE or FR_DOWN or FR_WHOLEWORD
;********************************************************************
; 查找并把光标设置到找到的文本上
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
; 页面设置对话框
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_PageSetup	proc
		local	@stPS:PAGESETUPDLG

		invoke	RtlZeroMemory,addr @stPS,sizeof @stPS
		mov	@stPS.lStructSize,sizeof @stPS
		mov	@stPS.Flags,PSD_DISABLEMARGINS or PSD_DISABLEORIENTATION or PSD_DISABLEPAGEPAINTING
		push	hWinMain
		pop	@stPS.hwndOwner
		invoke	PageSetupDlg,addr @stPS
		ret

_PageSetup	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 保存文件，如果没有打开或创建文件则调用“另存为”子程序
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_SaveFile	proc
		local	@stES:EDITSTREAM

		.if	! hFile
			call	_SaveAs
			.if	! eax
				ret
			.endif
		.endif
		invoke	SetFilePointer,hFile,0,0,FILE_BEGIN
		invoke	SetEndOfFile,hFile

		mov	@stES.dwCookie,FALSE
		mov	@stES.dwError,NULL
		mov	@stES.pfnCallback,offset _ProcStream
		invoke	SendMessage,hWinEdit,EM_STREAMOUT,SF_TEXT,addr @stES
		invoke	SendMessage,hWinEdit,EM_SETMODIFY,FALSE,0
		mov	eax,TRUE
		ret

_SaveFile	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 另存为
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_SaveAs		proc
		local	@stOF:OPENFILENAME
		local	@stES:EDITSTREAM

		invoke	RtlZeroMemory,addr @stOF,sizeof @stOF
;********************************************************************
; 显示“保存文件”对话框
;********************************************************************
		mov	@stOF.lStructSize,sizeof @stOF
		push	hWinMain
		pop	@stOF.hwndOwner
		mov	@stOF.lpstrFilter,offset szFilter
		mov	@stOF.lpstrFile,offset szFileName
		mov	@stOF.nMaxFile,MAX_PATH
		mov	@stOF.Flags,OFN_PATHMUSTEXIST
		mov	@stOF.lpstrDefExt,offset szDefExt
		mov	@stOF.lpstrTitle,offset szSaveCaption
		invoke	GetSaveFileName,addr @stOF
		.if	eax
;********************************************************************
; 创建新文件
;********************************************************************
			invoke	CreateFile,addr szFileName,GENERIC_READ or GENERIC_WRITE,\
				FILE_SHARE_READ,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
			.if	eax !=	INVALID_HANDLE_VALUE
				push	eax
				.if	hFile
					invoke	CloseHandle,hFile
				.endif
				pop	eax
;********************************************************************
; 保存文件
;********************************************************************
				mov	hFile,eax
				call	_SaveFile
				call	_SetCaption
				call	_SetStatus
				mov	eax,TRUE
				ret
			.else
				invoke	MessageBox,hWinMain,addr szErrCreateFile,NULL,MB_OK or MB_ICONERROR
			.endif
		.endif
		mov	eax,FALSE
		ret

_SaveAs		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 打开及输入文件
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_OpenFile	proc
		local	@stOF:OPENFILENAME
		local	@stES:EDITSTREAM

;********************************************************************
; 显示“打开文件”对话框
;********************************************************************
		invoke	RtlZeroMemory,addr @stOF,sizeof @stOF
		mov	@stOF.lStructSize,sizeof @stOF
		push	hWinMain
		pop	@stOF.hwndOwner
		mov	@stOF.lpstrFilter,offset szFilter
		mov	@stOF.lpstrFile,offset szFileName
		mov	@stOF.nMaxFile,MAX_PATH
		mov	@stOF.Flags,OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
		invoke	GetOpenFileName,addr @stOF
		.if	eax
;********************************************************************
; 创建文件
;********************************************************************
			invoke	CreateFile,addr szFileName,GENERIC_READ or GENERIC_WRITE,\
				FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
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
; 读入文件
;********************************************************************
			mov	@stES.dwCookie,TRUE
			mov	@stES.dwError,NULL
			mov	@stES.pfnCallback,offset _ProcStream
			invoke	SendMessage,hWinEdit,EM_STREAMIN,SF_TEXT,addr @stES
			invoke	SendMessage,hWinEdit,EM_SETMODIFY,FALSE,0
			call	_SetCaption
			call	_SetStatus
		.endif
		ret

_OpenFile	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 选择背景色
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ChooseColor	proc
		local	@stCC:CHOOSECOLOR

		invoke	RtlZeroMemory,addr @stCC,sizeof @stCC
		mov	@stCC.lStructSize,sizeof @stCC
		push	hWinMain
		pop	@stCC.hwndOwner
		push	dwBackColor
		pop	@stCC.rgbResult
		mov	@stCC.Flags,CC_RGBINIT or CC_FULLOPEN
		mov	@stCC.lpCustColors,offset dwCustColors
		invoke	ChooseColor,addr @stCC
		.if	eax
			push	@stCC.rgbResult
			pop	dwBackColor
			invoke	SendMessage,hWinEdit,EM_SETBKGNDCOLOR,0,dwBackColor
		.endif
		ret

_ChooseColor	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 选择字体
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ChooseFont	proc
		local	@stCF:CHOOSEFONT

		invoke	RtlZeroMemory,addr @stCF,sizeof @stCF
		mov	@stCF.lStructSize,sizeof @stCF
		push	hWinMain
		pop	@stCF.hwndOwner
		mov	@stCF.lpLogFont,offset stLogFont
		push	dwFontColor
		pop	@stCF.rgbColors
		mov	@stCF.Flags,CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT or CF_EFFECTS
		invoke	ChooseFont,addr @stCF
		.if	eax
			push	@stCF.rgbColors
			pop	dwFontColor
			mov	eax,@stCF.iPointSize
			shl	eax,1
			invoke	_SetFont,addr stLogFont.lfFaceName,eax,@stCF.rgbColors
		.endif
		ret

_ChooseFont	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_SetCaption	proc
		local	@szBuffer[1024]:byte

		.if	szFileName
			mov	eax,offset szFileName
		.else
			mov	eax,offset szNoName
		.endif
		invoke	wsprintf,addr @szBuffer,addr szTitleFormat,eax
		invoke	SetWindowText,hWinMain,addr @szBuffer
		ret

_SetCaption	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 设置菜单项、工具栏、状态栏的状态和信息
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_SetStatus	proc
		local	@stRange:CHARRANGE
		local	@dwLines,@dwLine,@dwLineStart
		local	@szBuffer[256]:byte

;********************************************************************
; 在状态栏显示行、列信息
;********************************************************************
		invoke	GetWindowTextLength,hWinEdit
		invoke	wsprintf,addr @szBuffer,addr szCharsFormat,eax
		invoke	SendMessage,hWinStatus,SB_SETTEXT,3,addr @szBuffer
		invoke	SendMessage,hWinEdit,EM_GETLINECOUNT,0,0
		invoke	wsprintf,addr @szBuffer,addr szLinesFormat,eax
		invoke	SendMessage,hWinStatus,SB_SETTEXT,2,addr @szBuffer
		invoke	SendMessage,hWinEdit,EM_EXGETSEL,0,addr @stRange
		invoke	SendMessage,hWinEdit,EM_EXLINEFROMCHAR,0,-1
		mov	@dwLine,eax
		invoke	SendMessage,hWinEdit,EM_LINEINDEX,eax,0
		mov	ecx,@stRange.cpMin
		sub	ecx,eax
		inc	ecx
		invoke	wsprintf,addr @szBuffer,addr szColFormat,ecx
		invoke	SendMessage,hWinStatus,SB_SETTEXT,1,addr @szBuffer
		inc	@dwLine
		invoke	wsprintf,addr @szBuffer,addr szLineFormat,@dwLine
		invoke	SendMessage,hWinStatus,SB_SETTEXT,0,addr @szBuffer
;********************************************************************
; 根据选择情况改变菜单项、工具栏按钮状态
;********************************************************************
		mov	eax,@stRange.cpMin
		.if	eax ==	@stRange.cpMax
			invoke	EnableMenuItem,hMenu,IDM_COPY,MF_GRAYED
			invoke	EnableMenuItem,hMenu,IDM_CUT,MF_GRAYED
			invoke	SendMessage,hWinToolbar,TB_ENABLEBUTTON,IDM_COPY,FALSE
			invoke	SendMessage,hWinToolbar,TB_ENABLEBUTTON,IDM_CUT,FALSE
		.else
			invoke	EnableMenuItem,hMenu,IDM_COPY,MF_ENABLED
			invoke	EnableMenuItem,hMenu,IDM_CUT,MF_ENABLED
			invoke	SendMessage,hWinToolbar,TB_ENABLEBUTTON,IDM_COPY,TRUE
			invoke	SendMessage,hWinToolbar,TB_ENABLEBUTTON,IDM_CUT,TRUE
		.endif
;********************************************************************
		invoke	IsClipboardFormatAvailable,CF_TEXT
		.if	eax
			invoke	EnableMenuItem,hMenu,IDM_PASTE,MF_ENABLED
			invoke	SendMessage,hWinToolbar,TB_ENABLEBUTTON,IDM_PASTE,TRUE
		.else
			invoke	EnableMenuItem,hMenu,IDM_PASTE,MF_GRAYED
			invoke	SendMessage,hWinToolbar,TB_ENABLEBUTTON,IDM_PASTE,FALSE
		.endif
;********************************************************************
		invoke	SendMessage,hWinEdit,EM_CANREDO,0,0
		.if	eax
			invoke	EnableMenuItem,hMenu,IDM_REDO,MF_ENABLED
			invoke	SendMessage,hWinToolbar,TB_ENABLEBUTTON,IDM_REDO,TRUE
		.else
			invoke	EnableMenuItem,hMenu,IDM_REDO,MF_GRAYED
			invoke	SendMessage,hWinToolbar,TB_ENABLEBUTTON,IDM_REDO,FALSE
		.endif
;********************************************************************
		invoke	SendMessage,hWinEdit,EM_CANUNDO,0,0
		.if	eax
			invoke	EnableMenuItem,hMenu,IDM_UNDO,MF_ENABLED
			invoke	SendMessage,hWinToolbar,TB_ENABLEBUTTON,IDM_UNDO,TRUE
		.else
			invoke	EnableMenuItem,hMenu,IDM_UNDO,MF_GRAYED
			invoke	SendMessage,hWinToolbar,TB_ENABLEBUTTON,IDM_UNDO,FALSE
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
		.if	eax
			invoke	EnableMenuItem,hMenu,IDM_SAVE,MF_ENABLED
			invoke	SendMessage,hWinToolbar,TB_ENABLEBUTTON,IDM_SAVE,TRUE
			invoke	SendMessage,hWinStatus,SB_SETTEXT,4,addr szHasModify
		.else
			invoke	EnableMenuItem,hMenu,IDM_SAVE,MF_GRAYED
			invoke	SendMessage,hWinToolbar,TB_ENABLEBUTTON,IDM_SAVE,FALSE
			invoke	SendMessage,hWinStatus,SB_SETTEXT,4,addr szNotModify
		.endif
;********************************************************************
		.if	szFindText
			invoke	EnableMenuItem,hMenu,IDM_FINDNEXT,MF_ENABLED
			invoke	EnableMenuItem,hMenu,IDM_FINDPREV,MF_ENABLED
			invoke	SendMessage,hWinToolbar,TB_ENABLEBUTTON,IDM_FINDNEXT,TRUE
			invoke	SendMessage,hWinToolbar,TB_ENABLEBUTTON,IDM_FINDPREV,TRUE
		.else
			invoke	EnableMenuItem,hMenu,IDM_FINDNEXT,MF_GRAYED
			invoke	EnableMenuItem,hMenu,IDM_FINDPREV,MF_GRAYED
			invoke	SendMessage,hWinToolbar,TB_ENABLEBUTTON,IDM_FINDNEXT,FALSE
			invoke	SendMessage,hWinToolbar,TB_ENABLEBUTTON,IDM_FINDPREV,FALSE
		.endif
;********************************************************************
		.if	dwOption & F_STATUSBAR
			invoke	CheckMenuItem,hMenu,IDM_STATUSBAR,MF_CHECKED
		.else
			invoke	CheckMenuItem,hMenu,IDM_STATUSBAR,MF_UNCHECKED
		.endif
;********************************************************************
		.if	dwOption & F_TOOLBAR
			invoke	CheckMenuItem,hMenu,IDM_TOOLBAR,MF_CHECKED
		.else
			invoke	CheckMenuItem,hMenu,IDM_TOOLBAR,MF_UNCHECKED
		.endif
		ret

_SetStatus	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 重新排列窗口位置
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ResizeWindow	proc
		local	@stRect:RECT
		local	@stRectTemp:RECT
		local	@dwWidth,@dwHeight

		invoke	GetClientRect,hWinMain,addr @stRect
		mov	eax,@stRect.right
		sub	eax,@stRect.left
		mov	@dwWidth,eax
		mov	eax,@stRect.bottom
		sub	eax,@stRect.top
		mov	@dwHeight,eax
;********************************************************************
; 计算及调整状态栏
;********************************************************************
		.if	dwOption & F_STATUSBAR
			invoke	ShowWindow,hWinStatus,SW_SHOW
			invoke	MoveWindow,hWinStatus,0,0,0,0,TRUE
			invoke	GetWindowRect,hWinStatus,addr @stRectTemp
			mov	eax,@stRectTemp.bottom
			sub	eax,@stRectTemp.top
			sub	@dwHeight,eax
		.else
			invoke	ShowWindow,hWinStatus,SW_HIDE
		.endif
;********************************************************************
; 计算及调整工具栏
;********************************************************************
		.if	dwOption & F_TOOLBAR
			invoke	ShowWindow,hWinToolbar,SW_SHOW
			invoke	GetWindowRect,hWinToolbar,addr @stRectTemp
			mov	eax,@stRectTemp.bottom
			sub	eax,@stRectTemp.top
			push	eax
			invoke	MoveWindow,hWinToolbar,0,0,@dwWidth,eax,TRUE
			pop	eax
			sub	@dwHeight,eax
			mov	@stRect.top,eax
		.else
			invoke	ShowWindow,hWinToolbar,SW_HIDE
		.endif
;********************************************************************
; 调整Richedit控件位置
;********************************************************************
		invoke	MoveWindow,hWinEdit,@stRect.left,@stRect.top,\
			@dwWidth,@dwHeight,TRUE
		ret

_ResizeWindow	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Init		proc

;********************************************************************
; 注册“查找”对话框消息，初始化“查找”对话框的结构
;********************************************************************
		mov	stFind.lStructSize,sizeof stFind
		push	hWinMain
		pop	stFind.hwndOwner
		mov	stFind.Flags,FR_DOWN
		mov	stFind.lpstrFindWhat,offset szFindText
		mov	stFind.wFindWhatLen,sizeof szFindText
		invoke	RegisterWindowMessage,addr FINDMSGSTRING
		mov	idFindMessage,eax
;********************************************************************
; 建立工具栏
;********************************************************************
		invoke	CreateToolbarEx,hWinMain,\
			WS_VISIBLE or WS_CHILD or TBSTYLE_FLAT,\
			1,0,HINST_COMMCTRL,IDB_STD_SMALL_COLOR,offset stToolbar,\
			NUM_BUTTONS,0,0,0,0,sizeof TBBUTTON
		mov	hWinToolbar,eax
;********************************************************************
; 建立状态栏
;********************************************************************
		invoke	CreateStatusWindow,WS_CHILD OR WS_VISIBLE OR \
			SBS_SIZEGRIP,NULL,hWinMain,2
		mov	hWinStatus,eax
		invoke	SendMessage,hWinStatus,SB_SETPARTS,6,offset dwStatusWidth
;********************************************************************
; 建立输出文本窗口
;********************************************************************
		invoke	CreateWindowEx,WS_EX_CLIENTEDGE,offset szClassEdit,NULL,\
			WS_CHILD OR WS_VISIBLE OR WS_VSCROLL OR	WS_HSCROLL \
			OR ES_MULTILINE or ES_NOHIDESEL,\
			0,0,0,0,\
			hWinMain,0,hInstance,NULL
		mov	hWinEdit,eax
		or	dwOption,F_STATUSBAR or F_TOOLBAR
		invoke	_SetCaption
		invoke	_SetStatus
		invoke	_SetFont,addr szFontFace,9 * 20,0
		invoke	SendMessage,hWinEdit,EM_SETEVENTMASK,0,ENM_CHANGE or ENM_SELCHANGE
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

		mov	eax,uMsg
		.if	eax ==	WM_SIZE
			invoke	_ResizeWindow
		.elseif	eax ==	WM_NOTIFY
			mov	eax,lParam
			mov	eax,[eax + NMHDR.hwndFrom]
			.if	eax == hWinEdit
				invoke	_SetStatus
			.endif
;********************************************************************
; 处理菜单、加速键及工具栏消息
;********************************************************************
		.elseif	eax ==	WM_COMMAND
			mov	eax,wParam
			movzx	eax,ax
			.if	eax ==	IDM_OPEN
				invoke	_CheckModify
				.if	eax
					call	_OpenFile
				.endif
			.elseif	eax ==	IDM_NEW
				invoke	_CheckModify
				.if	eax
					.if	hFile
						invoke	CloseHandle,hFile
						mov	hFile,0
					.endif
					mov	szFileName,0
					invoke	SetWindowText,hWinEdit,NULL
					invoke	_SetCaption
					invoke	_SetStatus
				.endif
			.elseif	eax ==	IDM_SAVE
				call	_SaveFile
			.elseif	eax ==	IDM_SAVEAS
				call	_SaveAs
			.elseif	eax ==	IDM_PAGESETUP
				call	_PageSetup
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
			.elseif	eax ==	IDM_FONT
				invoke	_ChooseFont
			.elseif	eax ==	IDM_BKCOLOR
				invoke	_ChooseColor
			.elseif	eax ==	IDM_TOOLBAR
				xor	dwOption,F_TOOLBAR
				invoke	_ResizeWindow
			.elseif	eax ==	IDM_STATUSBAR
				xor	dwOption,F_STATUSBAR
				invoke	_ResizeWindow
			.endif
;********************************************************************
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
; 注册窗口类
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
; 建立并显示窗口
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
; 消息循环
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
