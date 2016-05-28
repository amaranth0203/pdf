;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const
szNotFound	db	'无法查找',0
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 将 RVA 转换成实际的数据位置
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RVAToOffset	proc	_lpFileHead,_dwRVA
		local	@dwReturn

		pushad
		mov	esi,_lpFileHead
		assume	esi:ptr IMAGE_DOS_HEADER
		add	esi,[esi].e_lfanew
		assume	esi:ptr IMAGE_NT_HEADERS
		mov	edi,_dwRVA
		mov	edx,esi
		add	edx,sizeof IMAGE_NT_HEADERS
		assume	edx:ptr IMAGE_SECTION_HEADER
		movzx	ecx,[esi].FileHeader.NumberOfSections
;********************************************************************
; 扫描每个节区并判断 RVA 是否位于这个节区内
;********************************************************************
		.repeat
			mov	eax,[edx].VirtualAddress
			add	eax,[edx].SizeOfRawData		;eax = Section End
			.if	(edi >= [edx].VirtualAddress) && (edi < eax)
				mov	eax,[edx].VirtualAddress ;eax= Section start
				sub	edi,eax			;edi = offset in section
				mov	eax,[edx].PointerToRawData
				add	eax,edi			;eax = file offset
				jmp	@F
			.endif
			add	edx,sizeof IMAGE_SECTION_HEADER
		.untilcxz
		assume	edx:nothing
		assume	esi:nothing
		mov	eax,-1
@@:
		mov	@dwReturn,eax
		popad
		mov	eax,@dwReturn
		ret

_RVAToOffset	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 查找 RVA 所在的节区
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_GetRVASection	proc	_lpFileHead,_dwRVA
		local	@dwReturn

		pushad
		mov	esi,_lpFileHead
		assume	esi:ptr IMAGE_DOS_HEADER
		add	esi,[esi].e_lfanew
		assume	esi:ptr IMAGE_NT_HEADERS
		mov	edi,_dwRVA
		mov	edx,esi
		add	edx,sizeof IMAGE_NT_HEADERS
		assume	edx:ptr IMAGE_SECTION_HEADER
		movzx	ecx,[esi].FileHeader.NumberOfSections
;********************************************************************
; 扫描每个节区并判断 RVA 是否位于这个节区内
;********************************************************************
		.repeat
			mov	eax,[edx].VirtualAddress
			add	eax,[edx].SizeOfRawData		;eax = Section End
			.if	(edi >= [edx].VirtualAddress) && (edi < eax)
				mov	eax,edx			;eax= Section Name
				jmp	@F
			.endif
			add	edx,sizeof IMAGE_SECTION_HEADER
		.untilcxz
		assume	edx:nothing
		assume	esi:nothing
		mov	eax,offset szNotFound
@@:
		mov	@dwReturn,eax
		popad
		mov	eax,@dwReturn
		ret

_GetRVASection	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
