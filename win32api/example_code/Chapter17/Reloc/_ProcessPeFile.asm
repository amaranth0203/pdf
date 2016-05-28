;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Reloc���ӵ� PE�ļ�����ģ��
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const

szMsg		db	'�ļ����� %s',0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'�ض�λ�������Ľڣ�%s',0dh,0ah,0
szMsgRelocBlk	db	0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'�ض�λ����ַ��     %08X',0dh,0ah
		db	'�ض�λ��������     %d',0dh,0ah
		db	'------------------------------------------------',0dh,0ah,0
		db	'��Ҫ�ض�λ�ĵ�ַ�б�',0dh,0ah
		db	'------------------------------------------------',0dh,0ah,0
szMsgReloc	db	'%08X  ',0
szCrLf		db	0dh,0ah,0
szErrNoReloc	db	'����ļ��в������ض�λ��Ϣ!',0

		.code
include		_RvaToFileOffset.asm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcessPeFile	proc	_lpFile,_lpPeHead,_dwSize
		local	@szBuffer[1024]:byte,@szSectionName[16]:byte

		pushad
		mov	esi,_lpPeHead
		assume	esi:ptr IMAGE_NT_HEADERS
;********************************************************************
; ���� IMAGE_DIRECTORY_ENTRY_BASERELOC Ŀ¼���ҵ��ض�λ��λ��
;********************************************************************
		mov	eax,[esi].OptionalHeader.DataDirectory[8*5].VirtualAddress
		.if	! eax
			invoke	MessageBox,hWinMain,addr szErrNoReloc,NULL,MB_OK
			jmp	_Ret
		.endif
		push	eax
		invoke	_RVAToOffset,_lpFile,eax
		add	eax,_lpFile
		mov	esi,eax
		pop	eax
		invoke	_GetRVASection,_lpFile,eax
		invoke	wsprintf,addr @szBuffer,addr szMsg,addr szFileName,eax
		invoke	SetWindowText,hWinEdit,addr @szBuffer
		assume	esi:ptr IMAGE_BASE_RELOCATION
;********************************************************************
; ѭ������ÿ���ض�λ��
;********************************************************************
		.while	[esi].VirtualAddress
			cld
			lodsd			;eax = [esi].VirtualAddress
			mov	ebx,eax
			lodsd			;eax = [esi].SizeOfBlock
			sub	eax,sizeof IMAGE_BASE_RELOCATION
			shr	eax,1
			push	eax		;eax = �ض�λ������
			invoke	wsprintf,addr @szBuffer,addr szMsgRelocBlk,ebx,eax
			invoke	_AppendInfo,addr @szBuffer
			pop	ecx
			xor	edi,edi
			.repeat
				push	ecx
				lodsw
				mov	cx,ax
				and	cx,0f000h
;********************************************************************
; ������ IMAGE_REL_BASED_HIGHLOW ���͵��ض�λ��
;********************************************************************
				.if	cx ==	03000h
					and	ax,0fffh
					movzx	eax,ax
					add	eax,ebx
				.else
					mov	eax,-1
				.endif
				invoke	wsprintf,addr @szBuffer,addr szMsgReloc,eax
				inc	edi
				.if	edi ==	4	;ÿ��ʾ4����Ŀ����
					invoke	lstrcat,addr @szBuffer,addr szCrLf
					xor	edi,edi
				.endif
				invoke	_AppendInfo,addr @szBuffer
				pop	ecx
			.untilcxz
			.if	edi
				invoke	_AppendInfo,addr szCrLf
			.endif
		.endw
_Ret:
		assume	esi:nothing
		popad
		ret

_ProcessPeFile	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
