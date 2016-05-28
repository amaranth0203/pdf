;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 公用模块：_GetKernel.asm
; 根据程序被调用的时候堆栈中有个用于 Ret 的地址指向 Kernel32.dll
; 而从内存中扫描并获取 Kernel32.dll 的基址
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;
;
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 错误 Handler
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_SEHHandler	proc	C _lpExceptionRecord,_lpSEH,_lpContext,_lpDispatcherContext

		pushad
		mov	esi,_lpExceptionRecord
		mov	edi,_lpContext
		assume	esi:ptr EXCEPTION_RECORD,edi:ptr CONTEXT
		mov	eax,_lpSEH
		push	[eax + 0ch]
		pop	[edi].regEbp
		push	[eax + 8]
		pop	[edi].regEip
		push	eax
		pop	[edi].regEsp
		assume	esi:nothing,edi:nothing
		popad
		mov	eax,ExceptionContinueExecution
		ret

_SEHHandler	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 在内存中扫描 Kernel32.dll 的基址
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_GetKernelBase	proc	_dwKernelRet
		local	@dwReturn

		pushad
		mov	@dwReturn,0
;********************************************************************
; 重定位
;********************************************************************
		call	@F
		@@:
		pop	ebx
		sub	ebx,offset @B
;********************************************************************
; 创建用于错误处理的 SEH 结构
;********************************************************************
		assume	fs:nothing
		push	ebp
		lea	eax,[ebx + offset _PageError]
		push	eax
		lea	eax,[ebx + offset _SEHHandler]
		push	eax
		push	fs:[0]
		mov	fs:[0],esp
;********************************************************************
; 查找 Kernel32.dll 的基地址
;********************************************************************
		mov	edi,_dwKernelRet
		and	edi,0ffff0000h
		.while	TRUE
			.if	word ptr [edi] == IMAGE_DOS_SIGNATURE
				mov	esi,edi
				add	esi,[esi+003ch]
				.if word ptr [esi] == IMAGE_NT_SIGNATURE
					mov	@dwReturn,edi
					.break
				.endif
			.endif
			_PageError:
			sub	edi,010000h
			.break	.if edi < 070000000h
		.endw
		pop	fs:[0]
		add	esp,0ch
		popad
		mov	eax,@dwReturn
		ret

_GetKernelBase	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 从内存中模块的导出表中获取某个 API 的入口地址
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_GetApi		proc	_hModule,_lpszApi
		local	@dwReturn,@dwStringLength

		pushad
		mov	@dwReturn,0
;********************************************************************
; 重定位
;********************************************************************
		call	@F
		@@:
		pop	ebx
		sub	ebx,offset @B
;********************************************************************
; 创建用于错误处理的 SEH 结构
;********************************************************************
		assume	fs:nothing
		push	ebp
		lea	eax,[ebx + offset _Error]
		push	eax
		lea	eax,[ebx + offset _SEHHandler]
		push	eax
		push	fs:[0]
		mov	fs:[0],esp
;********************************************************************
; 计算 API 字符串的长度（带尾部的0）
;********************************************************************
		mov	edi,_lpszApi
		mov	ecx,-1
		xor	al,al
		cld
		repnz	scasb
		mov	ecx,edi
		sub	ecx,_lpszApi
		mov	@dwStringLength,ecx
;********************************************************************
; 从 PE 文件头的数据目录获取导出表地址
;********************************************************************
		mov	esi,_hModule
		add	esi,[esi + 3ch]
		assume	esi:ptr IMAGE_NT_HEADERS
		mov	esi,[esi].OptionalHeader.DataDirectory.VirtualAddress
		add	esi,_hModule
		assume	esi:ptr IMAGE_EXPORT_DIRECTORY
;********************************************************************
; 查找符合名称的导出函数名
;********************************************************************
		mov	ebx,[esi].AddressOfNames
		add	ebx,_hModule
		xor	edx,edx
		.repeat
			push	esi
			mov	edi,[ebx]
			add	edi,_hModule
			mov	esi,_lpszApi
			mov	ecx,@dwStringLength
			repz	cmpsb
			.if	ZERO?
				pop	esi
				jmp	@F
			.endif
			pop	esi
			add	ebx,4
			inc	edx
		.until	edx >=	[esi].NumberOfNames
		jmp	_Error
@@:
;********************************************************************
; API名称索引 --> 序号索引 --> 地址索引
;********************************************************************
		sub	ebx,[esi].AddressOfNames
		sub	ebx,_hModule
		shr	ebx,1
		add	ebx,[esi].AddressOfNameOrdinals
		add	ebx,_hModule
		movzx	eax,word ptr [ebx]
		shl	eax,2
		add	eax,[esi].AddressOfFunctions
		add	eax,_hModule
;********************************************************************
; 从地址表得到导出函数地址
;********************************************************************
		mov	eax,[eax]
		add	eax,_hModule
		mov	@dwReturn,eax
_Error:
		pop	fs:[0]
		add	esp,0ch
		assume	esi:nothing
		popad
		mov	eax,@dwReturn
		ret

_GetApi		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
