;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Peinfo ���ӵ� PE�ļ�����ģ��
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const
szMsg		db	'�ļ�����%s',0dh,0ah
		db	'----------------------------------------------------------',0dh,0ah
		db	'����ƽ̨��          0x%04X',0dh,0ah
		db	'����������          %d',0dh,0ah
		db	'�ļ���ǣ�          0x%04X',0dh,0ah
		db	'����װ���ַ��      0x%08X',0dh,0ah,0ah,0
szMsgSection	db	'----------------------------------------------------------',0dh,0ah
		db	'��������  ������С  �����ַ  Raw_�ߴ�  Raw_ƫ��  ��������',0dh,0ah
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
; ��ʾ PE �ļ�ͷ�е�һЩ��Ϣ
;********************************************************************
		movzx	ecx,[edi].FileHeader.Machine
		movzx	edx,[edi].FileHeader.NumberOfSections
		movzx	ebx,[edi].FileHeader.Characteristics
		invoke	wsprintf,addr @szBuffer,addr szMsg,\
			addr szFileName,ecx,edx,ebx,\
			[edi].OptionalHeader.ImageBase
		invoke	SetWindowText,hWinEdit,addr @szBuffer
;********************************************************************
; ѭ����ʾÿ����������Ϣ
;********************************************************************
		invoke	_AppendInfo,addr szMsgSection
		movzx	ecx,[edi].FileHeader.NumberOfSections
		add	edi,sizeof IMAGE_NT_HEADERS
		assume	edi:ptr IMAGE_SECTION_HEADER
		.repeat
			push	ecx
;********************************************************************
; ��������
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
