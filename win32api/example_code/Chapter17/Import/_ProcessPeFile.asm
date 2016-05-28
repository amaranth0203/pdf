;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Import ���ӵ� PE�ļ�����ģ��
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const

szMsg		db	'�ļ����� %s',0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'����������Ľڣ�%s',0dh,0ah,0
szMsgImport	db	0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'����⣺ %s',0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'OriginalFirstThunk %08X',0dh,0ah
		db	'TimeDateStamp      %08X',0dh,0ah
		db	'ForwarderChain     %08X',0dh,0ah
		db	'FirstThunk         %08X',0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'�������  ���뺯������',0dh,0ah
		db	'------------------------------------------------',0dh,0ah,0
szMsgName	db	'%8u  %s',0dh,0ah,0
szMsgOrdinal	db	'%8u  (����ŵ���)',0dh,0ah,0
szErrNoImport	db	'����ļ���ʹ���κε��뺯��',0

		.code
include		_RvaToFileOffset.asm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcessPeFile	proc	_lpFile,_lpPeHead,_dwSize
		local	@szBuffer[1024]:byte,@szSectionName[16]:byte

		pushad
		mov	edi,_lpPeHead
		assume	edi:ptr IMAGE_NT_HEADERS
;********************************************************************
		mov	eax,[edi].OptionalHeader.DataDirectory[8].VirtualAddress
		.if	! eax
			invoke	MessageBox,hWinMain,addr szErrNoImport,NULL,MB_OK
			jmp	_Ret
		.endif
		invoke	_RVAToOffset,_lpFile,eax
		add	eax,_lpFile
		mov	edi,eax
		assume	edi:ptr IMAGE_IMPORT_DESCRIPTOR
;********************************************************************
; ��ʾ PE �ļ���
;********************************************************************
		invoke	_GetRVASection,_lpFile,[edi].OriginalFirstThunk
		invoke	wsprintf,addr @szBuffer,addr szMsg,addr szFileName,eax
		invoke	SetWindowText,hWinEdit,addr @szBuffer
;********************************************************************
; ѭ������ IMAGE_IMPORT_DESCRIPTOR ֱ������ȫ��������
;********************************************************************
		.while	[edi].OriginalFirstThunk || [edi].TimeDateStamp || \
			[edi].ForwarderChain || [edi].Name1 || [edi].FirstThunk
			invoke	_RVAToOffset,_lpFile,[edi].Name1
			add	eax,_lpFile
			invoke 	wsprintf,addr @szBuffer,addr szMsgImport,eax,\
				[edi].OriginalFirstThunk,[edi].TimeDateStamp,\
				[edi].ForwarderChain,[edi].FirstThunk
			invoke	_AppendInfo,addr @szBuffer
;********************************************************************
; ��ȡ IMAGE_THUNK_DATA �б��ַ ---> ebx
;********************************************************************
			.if	[edi].OriginalFirstThunk
				mov	eax,[edi].OriginalFirstThunk
			.else
				mov	eax,[edi].FirstThunk
			.endif
			invoke	_RVAToOffset,_lpFile,eax
			add	eax,_lpFile
			mov	ebx,eax
;********************************************************************
; ѭ���������е� IMAGE_THUNK_DATA
;********************************************************************
			.while	dword ptr [ebx]
;********************************************************************
; ����ŵ���
;********************************************************************
				.if	dword ptr [ebx] & IMAGE_ORDINAL_FLAG32
					mov	eax,dword ptr [ebx]
					and	eax,0FFFFh
					invoke	wsprintf,addr @szBuffer,addr szMsgOrdinal,eax
				.else
;********************************************************************
; ������������
;********************************************************************
					invoke	_RVAToOffset,_lpFile,dword ptr [ebx]
					add	eax,_lpFile
					assume	eax:ptr IMAGE_IMPORT_BY_NAME
					movzx	ecx,[eax].Hint
					invoke	wsprintf,addr @szBuffer,\
						addr szMsgName,ecx,addr [eax].Name1
					assume	eax:nothing
				.endif
				invoke	_AppendInfo,addr @szBuffer
				add	ebx,4
			.endw
			add	edi,sizeof IMAGE_IMPORT_DESCRIPTOR
		.endw
_Ret:
		assume	edi:nothing
		popad
		ret

_ProcessPeFile	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
