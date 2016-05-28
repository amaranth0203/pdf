;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Reloc例子的 PE文件处理模块
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const

szMsg		db	'文件名： %s',0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'重定位表所处的节：%s',0dh,0ah,0
szMsgRelocBlk	db	0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'重定位基地址：     %08X',0dh,0ah
		db	'重定位项数量：     %d',0dh,0ah
		db	'------------------------------------------------',0dh,0ah,0
		db	'需要重定位的地址列表',0dh,0ah
		db	'------------------------------------------------',0dh,0ah,0
szMsgReloc	db	'%08X  ',0
szCrLf		db	0dh,0ah,0
szErrNoReloc	db	'这个文件中不包括重定位信息!',0

		.code
include		_RvaToFileOffset.asm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcessPeFile	proc	_lpFile,_lpPeHead,_dwSize
		local	@szBuffer[1024]:byte,@szSectionName[16]:byte

		pushad
		mov	esi,_lpPeHead
		assume	esi:ptr IMAGE_NT_HEADERS
;********************************************************************
; 根据 IMAGE_DIRECTORY_ENTRY_BASERELOC 目录表找到重定位表位置
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
; 循环处理每个重定位块
;********************************************************************
		.while	[esi].VirtualAddress
			cld
			lodsd			;eax = [esi].VirtualAddress
			mov	ebx,eax
			lodsd			;eax = [esi].SizeOfBlock
			sub	eax,sizeof IMAGE_BASE_RELOCATION
			shr	eax,1
			push	eax		;eax = 重定位项数量
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
; 仅处理 IMAGE_REL_BASED_HIGHLOW 类型的重定位项
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
				.if	edi ==	4	;每显示4个项目换行
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
