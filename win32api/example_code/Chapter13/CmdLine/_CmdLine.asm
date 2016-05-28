;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; _CmdLine.asm
; 命令行参数分析的通用子程序
; 功能：
; _argc ---> 对命令行参数进行数量统计
; _argv ---> 取某个命令行参数
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
CHAR_BLANK	equ	20h	;定义空格
CHAR_DELI	equ	'"'	;定义分隔符
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 取命令行参数个数 (arg count)
; 参数个数必定大于等于 1, 参数 1 为当前执行文件名
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_argc		proc
		local	@dwArgc

		pushad
		mov	@dwArgc,0
		invoke	GetCommandLine
		mov	esi,eax
		cld
_argc_loop:
;********************************************************************
; 忽略参数之间的空格
;********************************************************************
		lodsb
		or	al,al
		jz	_argc_end
		cmp	al,CHAR_BLANK
		jz	_argc_loop
;********************************************************************
; 一个参数开始
;********************************************************************
		dec	esi
		inc	@dwArgc
_argc_loop1:
		lodsb
		or	al,al
		jz	_argc_end
		cmp	al,CHAR_BLANK
		jz	_argc_loop		;参数结束
		cmp	al,CHAR_DELI
		jnz	_argc_loop1		;继续处理参数内容
;********************************************************************
; 如果一个参数中的一部分有空格,则用 " " 包括
;********************************************************************
		@@:
		lodsb
		or	al,al
		jz	_argc_end
		cmp	al,CHAR_DELI
		jnz	@B
		jmp	_argc_loop1
_argc_end:
		popad
		mov	eax,@dwArgc
		ret

_argc		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 取指定位置的命令行参数
;  argv 0 = 执行文件名
;  argv 1 = 参数1 ...
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_argv		proc	_dwArgv,_lpReturn,_dwSize
		local	@dwArgv,@dwFlag

		pushad
		inc	_dwArgv
		mov	@dwArgv,0
		mov	edi,_lpReturn

		invoke	GetCommandLine
		mov	esi,eax
		cld
_argv_loop:
;********************************************************************
; 忽略参数之间的空格
;********************************************************************
		lodsb
		or	al,al
		jz	_argv_end
		cmp	al,CHAR_BLANK
		jz	_argv_loop
;********************************************************************
; 一个参数开始
; 如果和要求的参数符合,则开始复制到返回缓冲区
;********************************************************************
		dec	esi
		inc	@dwArgv
		mov	@dwFlag,FALSE
		mov	eax,_dwArgv
		cmp	eax,@dwArgv
		jnz	@F
		mov	@dwFlag,TRUE
		@@:
_argv_loop1:
		lodsb
		or	al,al
		jz	_argv_end
		cmp	al,CHAR_BLANK
		jz	_argv_loop		;参数结束
		cmp	al,CHAR_DELI
		jz	_argv_loop2
		cmp	_dwSize,1
		jle	@F
		cmp	@dwFlag,TRUE
		jne	@F
		stosb
		dec	_dwSize
		@@:
		jmp	_argv_loop1		;继续处理参数内容

_argv_loop2:
		lodsb
		or	al,al
		jz	_argv_end
		cmp	al,CHAR_DELI
		jz	_argv_loop1
		cmp	_dwSize,1
		jle	@F
		cmp	@dwFlag,TRUE
		jne	@F
		stosb
		dec	_dwSize
		@@:
		jmp	_argv_loop2
_argv_end:
		xor	al,al
		stosb
		popad
		ret

_argv		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
