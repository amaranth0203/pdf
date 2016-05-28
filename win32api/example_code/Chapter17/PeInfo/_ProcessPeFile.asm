;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Peinfo 例子的 PE文件处理模块
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const
szMsg		db	'文件名：%s',0dh,0ah
		db	'----------------------------------------------------------',0dh,0ah
		db	'运行平台：          0x%04X',0dh,0ah
		db	'节区数量：          %d',0dh,0ah
		db	'文件标记：          0x%04X',0dh,0ah
		db	'建议装入地址：      0x%08X',0dh,0ah,0ah,0
szMsgSection	db	'----------------------------------------------------------',0dh,0ah
		db	'节区名称  节区大小  虚拟地址  Raw_尺寸  Raw_偏移  节区属性',0dh,0ah
		db	'----------------------------------------------------------',0dh,0ah,0
szFmtSection	db	'%s  %08X  %08X  %08X  %08X  %08X',0dh,0ah,0

		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcessPeFile	proc	_lpFile,_lpPeHead,_dwSize
		local	@szBuffer[1024]:byte,@szSectionName[16]:byte

		pushad
		mov	edi,_lpPeHead
		assume	edi:ptr IMAGE_NT_HEADERS
;********************************************************************
; 显示 PE 文件头中的一些信息
;********************************************************************
		movzx	ecx,[edi].FileHeader.Machine
		movzx	edx,[edi].FileHeader.NumberOfSections
		movzx	ebx,[edi].FileHeader.Characteristics
		invoke	wsprintf,addr @szBuffer,addr szMsg,\
			addr szFileName,ecx,edx,ebx,\
			[edi].OptionalHeader.ImageBase
		invoke	SetWindowText,hWinEdit,addr @szBuffer
;********************************************************************
; 循环显示每个节区的信息
;********************************************************************
		invoke	_AppendInfo,addr szMsgSection
		movzx	ecx,[edi].FileHeader.NumberOfSections
		add	edi,sizeof IMAGE_NT_HEADERS
		assume	edi:ptr IMAGE_SECTION_HEADER
		.repeat
			push	ecx
;********************************************************************
; 节区名称
;********************************************************************
			invoke	RtlZeroMemory,addr @szSectionName,sizeof @szSectionName
			push	esi
			push	edi
			mov	ecx,8
			mov	esi,edi
			lea	edi,@szSectionName
			cld
			@@:
			lodsb
			.if	! al
				mov	al,' '
			.endif
			stosb
			loop	@B
			pop	edi
			pop	esi
;********************************************************************
			invoke	wsprintf,addr @szBuffer,addr szFmtSection,\
				addr @szSectionName,[edi].Misc.VirtualSize,\
				[edi].VirtualAddress,[edi].SizeOfRawData,\
				[edi].PointerToRawData,[edi].Characteristics
			invoke	_AppendInfo,addr @szBuffer
			add	edi,sizeof IMAGE_SECTION_HEADER
;********************************************************************
			pop	ecx
		.untilcxz
		assume	edi:nothing
		popad
		ret

_ProcessPeFile	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
