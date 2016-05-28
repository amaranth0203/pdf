;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; TestObject.asm
; GDI对象使用的例子
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 使用 nmake 或下列命令进行编译和链接:
; ml /c /coff TestObject.asm
; rc TestObject.rc
; Link /subsystem:windows TestObject.obj TestObject.res
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
IDB_BACK	equ	100
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.data?

hInstance	dd	?
hWinMain	dd	?
dwCount		dd	?
dwPointArray	dd	10 dup (?)
		.data


		.const

szClassName	db	'Test',0
szCaptionMain	db	'Stock Object Test',0
dwPointConst	dd	10,90,70,150,75,105,25,155,75,140

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.code

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_AdjustPoint	proc

		pushad
		mov	esi,offset dwPointArray
		inc	dwCount
		.if	dwCount == 6
			mov	dwCount,0
			add	dword ptr [esi+4],70
			add	dword ptr [esi+4*3],70
			add	dword ptr [esi+4*5],70
			add	dword ptr [esi+4*7],70
			add	dword ptr [esi+4*9],70

			sub	dword ptr [esi],350
			sub	dword ptr [esi+4*2],350
			sub	dword ptr [esi+4*4],350
			sub	dword ptr [esi+4*6],350
			sub	dword ptr [esi+4*8],350
		.else
			add	dword ptr [esi],70
			add	dword ptr [esi+4*2],70
			add	dword ptr [esi+4*4],70
			add	dword ptr [esi+4*6],70
			add	dword ptr [esi+4*8],70
		.endif
		popad
		ret

_AdjustPoint	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_DrawLine	proc	_hDC,_dwPen,_dwPenWidth,_dwColor,_dwStartX,_dwEndX,_dwY

		invoke	CreatePen,_dwPen,_dwPenWidth,_dwColor
		invoke	SelectObject,_hDC,eax
		invoke	DeleteObject,eax
		invoke	MoveToEx,_hDC,_dwStartX,_dwY,NULL
		invoke	LineTo,_hDC,_dwEndX,_dwY
		ret

_DrawLine	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_TestPen	proc	_hDC
		local	@hBrush,@stRect:RECT

		mov	esi,offset dwPointConst
		mov	edi,offset dwPointArray
		push	edi
		mov	ecx,10
		cld
		rep	movsd
		pop	esi
		mov	dwCount,0
;********************************************************************
; 测试画笔
;********************************************************************
		invoke	SetBkColor,_hDC,255*100h
		invoke	_DrawLine,_hDC,PS_SOLID,1,0,10,420,10
		invoke	_DrawLine,_hDC,PS_INSIDEFRAME,1,0,10,420,20

		invoke	SetBkMode,_hDC,OPAQUE
		invoke	_DrawLine,_hDC,PS_DASH,1,0,10,420,30
		invoke	_DrawLine,_hDC,PS_DOT,1,0,10,420,40

		invoke	SetBkMode,_hDC,TRANSPARENT
		invoke	_DrawLine,_hDC,PS_DASHDOT,1,0,10,420,50
		invoke	_DrawLine,_hDC,PS_DASHDOTDOT,1,0,10,420,60
;********************************************************************
; 测试画线函数
;********************************************************************
		invoke	GetStockObject,BLACK_PEN
		invoke	SelectObject,_hDC,eax
		invoke	DeleteObject,eax
		invoke	GetStockObject,LTGRAY_BRUSH
		mov	@hBrush,eax
		invoke	SelectObject,_hDC,eax
		invoke	DeleteObject,eax

		invoke	PolylineTo,_hDC,addr dwPointArray,5
		invoke	_AdjustPoint

		invoke	PolyBezierTo,_hDC,addr dwPointArray,3
		invoke	_AdjustPoint

		invoke	ArcTo,_hDC,[esi],[esi+4],[esi+4*2],[esi+4*3],\
			[esi+4*4],[esi+4*5],[esi+4*6],[esi+4*7]
		invoke	_AdjustPoint

		invoke	Polyline,_hDC,addr dwPointArray,5
		invoke	_AdjustPoint

		invoke	PolyBezier,_hDC,addr dwPointArray,4
		invoke	_AdjustPoint

		invoke	Arc,_hDC,[esi],[esi+4],[esi+4*2],[esi+4*3],\
			[esi+4*4],[esi+4*5],[esi+4*6],[esi+4*7]
		invoke	_AdjustPoint
;********************************************************************
; 测试填充函数
;********************************************************************
		invoke	Chord,_hDC,[esi],[esi+4],[esi+4*2],[esi+4*3],\
			[esi+4*4],[esi+4*5],[esi+4*6],[esi+4*7]
		invoke	_AdjustPoint

		invoke	Pie,_hDC,[esi],[esi+4],[esi+4*2],[esi+4*3],\
			[esi+4*4],[esi+4*5],[esi+4*6],[esi+4*7]
		invoke	_AdjustPoint

		invoke	Ellipse,_hDC,[esi],[esi+4],[esi+4*2],[esi+4*3]
		invoke	_AdjustPoint

		invoke	SetPolyFillMode,_hDC,ALTERNATE
		invoke	Polygon,_hDC,addr dwPointArray,5
		invoke	_AdjustPoint

		invoke	SetPolyFillMode,_hDC,WINDING
		invoke	Polygon,_hDC,addr dwPointArray,5
		invoke	_AdjustPoint
		invoke	_AdjustPoint
;********************************************************************
		invoke	Rectangle,_hDC,[esi],[esi+4],[esi+4*2],[esi+4*3]
		invoke	_AdjustPoint

		invoke	RoundRect,_hDC,[esi],[esi+4],[esi+4*2],[esi+4*3],20,20
		invoke	_AdjustPoint

		push	dwPointArray
		pop	@stRect.left
		push	dwPointArray+4
		pop	@stRect.top
		push	dwPointArray+4*2
		pop	@stRect.right
		push	dwPointArray+4*3
		pop	@stRect.bottom
		invoke	FillRect,_hDC,addr @stRect,@hBrush
		invoke	_AdjustPoint

		push	dwPointArray
		pop	@stRect.left
		push	dwPointArray+4
		pop	@stRect.top
		push	dwPointArray+4*2
		pop	@stRect.right
		push	dwPointArray+4*3
		pop	@stRect.bottom
		invoke	FrameRect,_hDC,addr @stRect,@hBrush
		invoke	_AdjustPoint

		push	dwPointArray
		pop	@stRect.left
		push	dwPointArray+4
		pop	@stRect.top
		push	dwPointArray+4*2
		pop	@stRect.right
		push	dwPointArray+4*3
		pop	@stRect.bottom
		invoke	InvertRect,_hDC,addr @stRect
		invoke	_AdjustPoint
		invoke	_AdjustPoint
;********************************************************************
; 测试画刷
;********************************************************************
		invoke	CreateHatchBrush,HS_BDIAGONAL,0
		invoke	SelectObject,_hDC,eax
		invoke	DeleteObject,eax
		invoke	Rectangle,_hDC,[esi],[esi+4],[esi+4*2],[esi+4*3]
		invoke	_AdjustPoint

		invoke	CreateHatchBrush,HS_CROSS,0
		invoke	SelectObject,_hDC,eax
		invoke	DeleteObject,eax
		invoke	Rectangle,_hDC,[esi],[esi+4],[esi+4*2],[esi+4*3]
		invoke	_AdjustPoint

		invoke	CreateHatchBrush,HS_DIAGCROSS,0
		invoke	SelectObject,_hDC,eax
		invoke	DeleteObject,eax
		invoke	Rectangle,_hDC,[esi],[esi+4],[esi+4*2],[esi+4*3]
		invoke	_AdjustPoint

		invoke	CreateHatchBrush,HS_FDIAGONAL,0
		invoke	SelectObject,_hDC,eax
		invoke	DeleteObject,eax
		invoke	Rectangle,_hDC,[esi],[esi+4],[esi+4*2],[esi+4*3]
		invoke	_AdjustPoint

		invoke	CreateHatchBrush,HS_HORIZONTAL,0
		invoke	SelectObject,_hDC,eax
		invoke	DeleteObject,eax
		invoke	Rectangle,_hDC,[esi],[esi+4],[esi+4*2],[esi+4*3]
		invoke	_AdjustPoint

		invoke	CreateHatchBrush,HS_VERTICAL,0
		invoke	SelectObject,_hDC,eax
		invoke	DeleteObject,eax
		invoke	Rectangle,_hDC,[esi],[esi+4],[esi+4*2],[esi+4*3]
		invoke	_AdjustPoint
		ret

_TestPen	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 窗口过程
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcWinMain	proc	uses ebx edi esi,hWnd,uMsg,wParam,lParam
		local	@stPs:PAINTSTRUCT
		local	@stRect:RECT
		local	@hDc

		mov	eax,uMsg
;********************************************************************
		.if	eax ==	WM_PAINT
			invoke	BeginPaint,hWnd,addr @stPs
			invoke	_TestPen,eax
			invoke	EndPaint,hWnd,addr @stPs
;********************************************************************
		.elseif	eax ==	WM_CLOSE
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
		invoke	LoadBitmap,hInstance,IDB_BACK
		invoke	CreatePatternBrush,eax
;		invoke	GetStockObject,WHITE_BRUSH
		mov	@stWndClass.hbrBackground,eax
		mov	@stWndClass.lpszClassName,offset szClassName
		invoke	RegisterClassEx,addr @stWndClass
;********************************************************************
; 建立并显示窗口
;********************************************************************
		invoke	CreateWindowEx,WS_EX_CLIENTEDGE,offset szClassName,offset szCaptionMain,\
			WS_OVERLAPPEDWINDOW,\
			100,100,440,400,\
			NULL,NULL,hInstance,NULL
		mov	hWinMain,eax
		invoke	ShowWindow,hWinMain,SW_SHOWNORMAL
		invoke	UpdateWindow,hWinMain
;********************************************************************
; 消息循环
;********************************************************************
		.while	TRUE
			invoke	GetMessage,addr @stMsg,NULL,0,0
			.break	.if eax	== 0
			invoke	TranslateMessage,addr @stMsg
			invoke	DispatchMessage,addr @stMsg
		.endw
		ret

_WinMain	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		call	_WinMain
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
