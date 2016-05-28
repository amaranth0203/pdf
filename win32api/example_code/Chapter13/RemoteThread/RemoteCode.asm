;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; RemoteCode.asm
; 一段自定位的代码，可以用来创建一个窗口
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
REMOTE_CODE_START	equ this byte

_lpLoadLibrary		dd	?	;导入函数地址表
_lpGetProcAddress	dd	?
_lpGetModuleHandle	dd	?

_lpDestroyWindow	dd	?
_lpPostQuitMessage	dd	?
_lpDefWindowProc	dd	?
_lpLoadCursor		dd	?
_lpRegisterClassEx	dd	?
_lpCreateWindowEx	dd	?
_lpShowWindow		dd	?
_lpUpdateWindow		dd	?
_lpGetMessage		dd	?
_lpTranslateMessage	dd	?
_lpDispatchMessage	dd	?

_hInstance	dd	?
_hWinMain	dd	?
_szClassName	db	'RemoteClass',0
_szCaptionMain	db	'RemoteWindow',0
_szDllUser		db	'User32.dll',0
_szDestroyWindow	db	'DestroyWindow',0
_szPostQuitMessage	db	'PostQuitMessage',0
_szDefWindowProc	db	'DefWindowProcA',0
_szLoadCursor		db	'LoadCursorA',0
_szRegisterClassEx	db	'RegisterClassExA',0
_szCreateWindowEx	db	'CreateWindowExA',0
_szShowWindow		db	'ShowWindow',0
_szUpdateWindow		db	'UpdateWindow',0
_szGetMessage		db	'GetMessageA',0
_szTranslateMessage	db	'TranslateMessage',0
_szDispatchMessage	db	'DispatchMessageA',0,0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RemoteThread	proc	uses ebx edi esi lParam
		local	@hModule

		call	@F
		@@:
		pop	ebx
		sub	ebx,offset @B
;********************************************************************
		_invoke	[ebx + _lpGetModuleHandle],NULL
		mov	[ebx + _hInstance],eax
		lea	eax,[ebx + offset _szDllUser]
		_invoke	[ebx + _lpGetModuleHandle],eax
		mov	@hModule,eax
		lea	esi,[ebx + offset _szDestroyWindow]
		lea	edi,[ebx + offset _lpDestroyWindow]
		.while	TRUE
			_invoke	[ebx + _lpGetProcAddress],@hModule,esi
			mov	[edi],eax
			add	edi,4
			@@:
			lodsb
			or	al,al
			jnz	@B
			.break	.if ! byte ptr [esi]
		.endw
;********************************************************************
		call	_WinMain
		ret

_RemoteThread	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcWinMain	proc	uses ebx edi esi,hWnd,uMsg,wParam,lParam

		call	@F
		@@:
		pop	ebx
		sub	ebx,offset @B
;********************************************************************
		mov	eax,uMsg
		.if	eax ==	WM_CLOSE
			_invoke	[ebx + _lpDestroyWindow],hWnd
			_invoke	[ebx + _lpPostQuitMessage],NULL
;********************************************************************
		.else
			_invoke	[ebx + _lpDefWindowProc],hWnd,uMsg,wParam,lParam
			ret
		.endif
;********************************************************************
		xor	eax,eax
		ret

_ProcWinMain	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ZeroMemory	proc	_lpDest,_dwSize

		push	edi
		mov	edi,_lpDest
		mov	ecx,_dwSize
		xor	eax,eax
		cld
		rep	stosb
		pop	edi
		ret

_ZeroMemory	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_WinMain	proc	uses ebx esi edi _lParam
		local	@stWndClass:WNDCLASSEX
		local	@stMsg:MSG

		call	@F
		@@:
		pop	ebx
		sub	ebx,offset @B
;********************************************************************
		invoke	_ZeroMemory,addr @stWndClass,sizeof @stWndClass
		_invoke	[ebx + _lpLoadCursor],0,IDC_ARROW
		mov	@stWndClass.hCursor,eax
		push	[ebx + _hInstance]
		pop	@stWndClass.hInstance
		mov	@stWndClass.cbSize,sizeof WNDCLASSEX
		mov	@stWndClass.style,CS_HREDRAW or CS_VREDRAW
		lea	eax,[ebx +  offset _ProcWinMain]
		mov	@stWndClass.lpfnWndProc,eax
		mov	@stWndClass.hbrBackground,COLOR_WINDOW + 1
		lea	eax,[ebx + offset _szClassName]
		mov	@stWndClass.lpszClassName,eax
		lea	eax,@stWndClass
		_invoke	[ebx + _lpRegisterClassEx],eax
;********************************************************************
; 建立并显示窗口
;********************************************************************
		lea	eax,[ebx + offset _szClassName]
		lea	ecx,[ebx + offset _szCaptionMain]
		_invoke	[ebx + _lpCreateWindowEx],WS_EX_CLIENTEDGE,eax,ecx,\
			WS_OVERLAPPEDWINDOW,\
			100,100,600,400,\
			NULL,NULL,[ebx + _hInstance],NULL
		mov	[ebx + _hWinMain],eax
		_invoke	[ebx + _lpShowWindow],[ebx + _hWinMain],SW_SHOWNORMAL
		_invoke	[ebx + _lpUpdateWindow],[ebx + _hWinMain]
;********************************************************************
; 消息循环
;********************************************************************
		.while	TRUE
			lea	eax,@stMsg
			_invoke	[ebx + _lpGetMessage],eax,NULL,0,0
			.break	.if eax	== 0
			lea	eax,@stMsg
			_invoke	[ebx + _lpTranslateMessage],eax
			lea	eax,@stMsg
			_invoke	[ebx + _lpDispatchMessage],eax
		.endw
		ret

_WinMain	endp
REMOTE_CODE_END		equ this byte
REMOTE_CODE_LENGTH	equ offset REMOTE_CODE_END - offset REMOTE_CODE_START
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
