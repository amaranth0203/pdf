;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ����ģ�飺_GetKernel.asm
; ���ݳ��򱻵��õ�ʱ���ջ���и����� Ret �ĵ�ַָ�� Kernel32.dll
; �����ڴ���ɨ�貢��ȡ Kernel32.dll �Ļ�ַ
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;
;
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���� Handler
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
; ���ڴ���ɨ�� Kernel32.dll �Ļ�ַ
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_GetKernelBase	proc	_dwKernelRet
		local	@dwReturn

		pushad
		mov	@dwReturn,0
;********************************************************************
; �ض�λ
;********************************************************************
		call	@F
		@@:
		pop	ebx
		sub	ebx,offset @B
;********************************************************************
; �������ڴ������ SEH �ṹ
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
; ���� Kernel32.dll �Ļ���ַ
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
; ���ڴ���ģ��ĵ������л�ȡĳ�� API ����ڵ�ַ
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_GetApi		proc	_hModule,_lpszApi
		local	@dwReturn,@dwStringLength

		pushad
		mov	@dwReturn,0
;********************************************************************
; �ض�λ
;********************************************************************
		call	@F
		@@:
		pop	ebx
		sub	ebx,offset @B
;********************************************************************
; �������ڴ������ SEH �ṹ
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
; ���� API �ַ����ĳ��ȣ���β����0��
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
; �� PE �ļ�ͷ������Ŀ¼��ȡ�������ַ
;********************************************************************
		mov	esi,_hModule
		add	esi,[esi + 3ch]
		assume	esi:ptr IMAGE_NT_HEADERS
		mov	esi,[esi].OptionalHeader.DataDirectory.VirtualAddress
		add	esi,_hModule
		assume	esi:ptr IMAGE_EXPORT_DIRECTORY
;********************************************************************
; ���ҷ������Ƶĵ���������
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
; API�������� --> ������� --> ��ַ����
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
; �ӵ�ַ��õ�����������ַ
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
