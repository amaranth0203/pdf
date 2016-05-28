;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Import 例子的 PE文件处理模块
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const

szMsg		db	'文件名： %s',0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'导入表所处的节：%s',0dh,0ah,0
szMsgImport	db	0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'导入库： %s',0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'OriginalFirstThunk %08X',0dh,0ah
		db	'TimeDateStamp      %08X',0dh,0ah
		db	'ForwarderChain     %08X',0dh,0ah
		db	'FirstThunk         %08X',0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'导入序号  导入函数名称',0dh,0ah
		db	'------------------------------------------------',0dh,0ah,0
szMsgName	db	'%8u  %s',0dh,0ah,0
szMsgOrdinal	db	'%8u  (按序号导入)',0dh,0ah,0
szErrNoImport	db	'这个文件不使用任何导入函数',0

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
; 显示 PE 文件名
;********************************************************************
		invoke	_GetRVASection,_lpFile,[edi].OriginalFirstThunk
		invoke	wsprintf,addr @szBuffer,addr szMsg,addr szFileName,eax
		invoke	SetWindowText,hWinEdit,addr @szBuffer
;********************************************************************
; 循环处理 IMAGE_IMPORT_DESCRIPTOR 直到遇到全零的则结束
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
; 获取 IMAGE_THUNK_DATA 列表地址 ---> ebx
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
; 循环处理所有的 IMAGE_THUNK_DATA
;********************************************************************
			.while	dword ptr [ebx]
;********************************************************************
; 按序号导入
;********************************************************************
				.if	dword ptr [ebx] & IMAGE_ORDINAL_FLAG32
					mov	eax,dword ptr [ebx]
					and	eax,0FFFFh
					invoke	wsprintf,addr @szBuffer,addr szMsgOrdinal,eax
				.else
;********************************************************************
; 按函数名导入
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
