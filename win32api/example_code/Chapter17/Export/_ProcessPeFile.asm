;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Export���ӵ� PE�ļ�����ģ��
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const

szMsg		db	'�ļ����� %s',0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'�����������Ľڣ�%s',0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'ԭʼ�ļ���          %s',0dh,0ah
		db	'nBase               %08X',0dh,0ah
		db	'NumberOfFunctions   %08X',0dh,0ah
		db	'NumberOfNames       %08X',0dh,0ah
		db	'AddressOfFunctions  %08X',0dh,0ah
		db	'AddressOfNames      %08X',0dh,0ah
		db	'AddressOfNameOrd    %08X',0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'�������  �����ַ  ������������',0dh,0ah
		db	'------------------------------------------------',0dh,0ah,0
szMsgName	db	'%08X  %08X  %s',0dh,0ah,0
szExportByOrd	db	'(������ŵ���)',0
szErrNoExport	db	'����ļ���û�е�������!',0

		.code
include		_RvaToFileOffset.asm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcessPeFile	proc	_lpFile,_lpPeHead,_dwSize
		local	@szBuffer[1024]:byte,@szSectionName[16]:byte
		local	@dwIndex,@lpAddressOfNames,@lpAddressOfNameOrdinals

		pushad
		mov	esi,_lpPeHead
		assume	esi:ptr IMAGE_NT_HEADERS
;********************************************************************
; ������Ŀ¼�л�ȡ�������λ��
;********************************************************************
		mov	eax,[esi].OptionalHeader.DataDirectory.VirtualAddress
		.if	! eax
			invoke	MessageBox,hWinMain,addr szErrNoExport,NULL,MB_OK
			jmp	_Ret
		.endif
		invoke	_RVAToOffset,_lpFile,eax
		add	eax,_lpFile
		mov	edi,eax
;********************************************************************
; ��ʾһЩ���õ���Ϣ
;********************************************************************
		assume	edi:ptr IMAGE_EXPORT_DIRECTORY
		invoke	_RVAToOffset,_lpFile,[edi].nName
		add	eax,_lpFile
		mov	ecx,eax
		invoke	_GetRVASection,_lpFile,[edi].nName
		invoke	wsprintf,addr @szBuffer,addr szMsg,addr szFileName,eax,ecx,[edi].nBase,\
			[edi].NumberOfFunctions,[edi].NumberOfNames,[edi].AddressOfFunctions,\
			[edi].AddressOfNames,[edi].AddressOfNameOrdinals
		invoke	SetWindowText,hWinEdit,addr @szBuffer
;********************************************************************
		invoke	_RVAToOffset,_lpFile,[edi].AddressOfNames
		add	eax,_lpFile
		mov	@lpAddressOfNames,eax
		invoke	_RVAToOffset,_lpFile,[edi].AddressOfNameOrdinals
		add	eax,_lpFile
		mov	@lpAddressOfNameOrdinals,eax
		invoke	_RVAToOffset,_lpFile,[edi].AddressOfFunctions
		add	eax,_lpFile
		mov	esi,eax		;esi --> ������ַ��
;********************************************************************
; ѭ����ʾ������������Ϣ
;********************************************************************
		mov	ecx,[edi].NumberOfFunctions
		mov	@dwIndex,0
		@@:
			pushad
;********************************************************************
; �ڰ����Ƶ�������������
;********************************************************************
			mov	eax,@dwIndex
			push	edi
			mov	ecx,[edi].NumberOfNames
			cld
			mov	edi,@lpAddressOfNameOrdinals
			repnz	scasw
			.if	ZERO?	;�ҵ���������
				sub	edi,@lpAddressOfNameOrdinals
				sub	edi,2
				shl	edi,1
				add	edi,@lpAddressOfNames
				invoke	_RVAToOffset,_lpFile,dword ptr [edi]
				add	eax,_lpFile
			.else
				mov	eax,offset szExportByOrd
			.endif
			pop	edi
;********************************************************************
; ��� --> ecx
;********************************************************************
			mov	ecx,@dwIndex
			add	ecx,[edi].nBase
			invoke	wsprintf,addr @szBuffer,addr szMsgName,\
				ecx,dword ptr [esi],eax
			invoke	_AppendInfo,addr @szBuffer
			popad
			add	esi,4
			inc	@dwIndex
		loop	@B
_Ret:
		assume	esi:nothing
		assume	edi:nothing
		popad
		ret

_ProcessPeFile	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
