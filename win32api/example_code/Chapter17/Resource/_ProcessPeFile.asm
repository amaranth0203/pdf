;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Resource���ӵ� PE�ļ�����ģ��
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const

szMsg		db	'�ļ����� %s',0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'��Դ�����Ľڣ�%s',0dh,0ah,0
szErrNoRes	db	'����ļ���û�а�����Դ!',0
szLevel1	db	0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'��Դ���ͣ�%s',0dh,0ah
		db	'------------------------------------------------',0dh,0ah,0
szLevel1byID	db	'%d (�Զ�����)',0
szLevel2byID	db	'  ID: %d',0dh,0ah,0
szLevel2byName	db	'  Name: %s',0dh,0ah,0
szResData	db	'     �ļ�ƫ�ƣ�%08X (����ҳ=%04X, ����%d�ֽ�)',0dh,0ah,0
szType		db	'���        ',0	;1
		db	'λͼ        ',0	;2
		db	'ͼ��        ',0	;3
		db	'�˵�        ',0	;4
		db	'�Ի���      ',0	;5
		db	'�ַ���      ',0	;6
		db	'����Ŀ¼    ',0	;7
		db	'����        ',0	;8
		db	'���ټ�      ',0	;9
		db	'δ��ʽ����Դ',0	;10
		db	'��Ϣ��      ',0	;11
		db	'�����      ',0	;12
		db	'δ֪����    ',0	;13
		db	'ͼ����      ',0	;14
		db	'δ֪����    ',0	;15
		db	'�汾��Ϣ    ',0	;16

		.code
include		_RvaToFileOffset.asm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcessRes	proc	_lpFile,_lpRes,_lpResDir,_dwLevel
		local	@dwNextLevel,@szBuffer[1024]:byte
		local	@szResName[256]:byte

		pushad
		mov	eax,_dwLevel
		inc	eax
		mov	@dwNextLevel,eax

;********************************************************************
; �����ԴĿ¼���õ���ԴĿ¼�������
;********************************************************************
		mov	esi,_lpResDir
		assume	esi:ptr IMAGE_RESOURCE_DIRECTORY
		mov	cx,[esi].NumberOfNamedEntries
		add	cx,[esi].NumberOfIdEntries
		movzx	ecx,cx
		add	esi,sizeof IMAGE_RESOURCE_DIRECTORY
		assume	esi:ptr IMAGE_RESOURCE_DIRECTORY_ENTRY
;********************************************************************
; ѭ������ÿ����ԴĿ¼��
;********************************************************************
		.while	ecx >	0
			push	ecx
			mov	ebx,[esi].OffsetToData
			.if	ebx & 80000000h
				and	ebx,7fffffffh
				add	ebx,_lpRes
				.if	_dwLevel == 1
;********************************************************************
; ��һ�㣺��Դ����
;********************************************************************
					mov	eax,[esi].Name1
					.if	eax & 80000000h
						and	eax,7fffffffh
						add	eax,_lpRes
						movzx	ecx,word ptr [eax]	;IMAGE_RESOURCE_DIR_STRING_U�ṹ
						add	eax,2
						mov	edx,eax
						invoke	WideCharToMultiByte,CP_ACP,WC_COMPOSITECHECK,\
							edx,ecx,addr @szResName,sizeof @szResName,\
							NULL,NULL
						lea	eax,@szResName
					.else
						.if	eax <=	10h
							dec	eax
							mov	ecx,sizeof szType
							mul	ecx
							add	eax,offset szType
						.else
							invoke	wsprintf,addr @szResName,addr szLevel1byID,eax
							lea	eax,@szResName
						.endif
					.endif
					invoke	wsprintf,addr @szBuffer,addr szLevel1,eax
;********************************************************************
; �ڶ��㣺��ԴID�������ƣ�
;********************************************************************
				.elseif	_dwLevel == 2
					mov	edx,[esi].Name1
					.if	edx & 80000000h
;********************************************************************
; ��Դ���ַ�����ʽ����
;********************************************************************
						and	edx,7fffffffh
						add	edx,_lpRes	;IMAGE_RESOURCE_DIR_STRING_U�ṹ
						movzx	ecx,word ptr [edx]
						add	edx,2
						invoke	WideCharToMultiByte,CP_ACP,WC_COMPOSITECHECK,\
							edx,ecx,addr @szResName,sizeof @szResName,\
							NULL,NULL
						invoke	wsprintf,addr @szBuffer,\
							addr szLevel2byName,addr @szResName
					.else
;********************************************************************
; ��Դ�� ID ����
;********************************************************************
						invoke	wsprintf,addr @szBuffer,\
							addr szLevel2byID,edx
					.endif
				.else
					.break
				.endif
				invoke	_AppendInfo,addr @szBuffer
				invoke	_ProcessRes,_lpFile,_lpRes,ebx,@dwNextLevel
;********************************************************************
; ������ԴĿ¼����ʾ��Դ��ϸ��Ϣ
;********************************************************************
			.else
				add	ebx,_lpRes
				mov	ecx,[esi].Name1		;����ҳ
				assume	ebx:ptr IMAGE_RESOURCE_DATA_ENTRY
				mov	eax,[ebx].OffsetToData
				invoke	_RVAToOffset,_lpFile,eax
				invoke	wsprintf,addr @szBuffer,addr szResData,\
					eax,ecx,[ebx].Size1
				invoke	_AppendInfo,addr @szBuffer
			.endif
			add	esi,sizeof IMAGE_RESOURCE_DIRECTORY_ENTRY
			pop	ecx
			dec	ecx
		.endw
_Ret:
		assume	esi:nothing
		assume	ebx:nothing
		popad
		ret

_ProcessRes	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcessPeFile	proc	_lpFile,_lpPeHead,_dwSize
		local	@szBuffer[1024]:byte,@szSectionName[16]:byte

		pushad
		mov	esi,_lpPeHead
		assume	esi:ptr IMAGE_NT_HEADERS
;********************************************************************
; ����Ƿ������Դ
;********************************************************************
		mov	eax,[esi].OptionalHeader.DataDirectory[8*2].VirtualAddress
		.if	! eax
			invoke	MessageBox,hWinMain,addr szErrNoRes,NULL,MB_OK
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
		invoke	_ProcessRes,_lpFile,esi,esi,1
_Ret:
		assume	esi:nothing
		popad
		ret

_ProcessPeFile	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
