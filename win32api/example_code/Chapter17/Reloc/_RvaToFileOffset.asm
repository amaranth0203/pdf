;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const
szNotFound	db	'�޷�����',0
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �� RVA ת����ʵ�ʵ�����λ��
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
; ɨ��ÿ���������ж� RVA �Ƿ�λ�����������
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
; ���� RVA ���ڵĽ���
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
; ɨ��ÿ���������ж� RVA �Ƿ�λ�����������
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
