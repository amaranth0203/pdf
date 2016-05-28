;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; AddCode 例子的功能模块
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const

szErrCreate	db	'创建文件错误!',0dh,0ah,0
szErrNoRoom	db	'程序中没有多余的空间可供加入代码!',0dh,0ah,0
szMySection	db	'.adata',0
szExt		db	'_new.exe',0
szSuccess	db	'在文件后附加代码成功，新文件：',0dh,0ah
		db	'%s',0dh,0ah,0

		.code

include		_AddCode.asm

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 计算按照指定值对齐后的数值
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_Align		proc	_dwSize,_dwAlign

		push	edx
		mov	eax,_dwSize
		xor	edx,edx
		div	_dwAlign
		.if	edx
			inc	eax
		.endif
		mul	_dwAlign
		pop	edx
		ret

_Align		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ProcessPeFile	proc	_lpFile,_lpPeHead,_dwSize
		local	@szNewFile[MAX_PATH]:byte
		local	@hFile,@dwTemp,@dwEntry,@lpMemory
		local	@dwAddCodeBase,@dwAddCodeFile
		local	@szBuffer[256]:byte

		pushad
;********************************************************************
; （Part 1）准备工作：1－建立新文件，2－打开文件
;********************************************************************
		invoke	lstrcpy,addr @szNewFile,addr szFileName
		invoke	lstrlen,addr @szNewFile
		lea	ecx,@szNewFile
		mov	byte ptr [ecx+eax-4],0
		invoke	lstrcat,addr @szNewFile,addr szExt
		invoke	CopyFile,addr szFileName,addr @szNewFile,FALSE

		invoke	CreateFile,addr @szNewFile,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ or \
			FILE_SHARE_WRITE,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,NULL
		.if	eax ==	INVALID_HANDLE_VALUE
			invoke	SetWindowText,hWinEdit,addr szErrCreate
			jmp	_Ret
		.endif
		mov	@hFile,eax
;********************************************************************
;（Part 2）进行一些准备工作和检测工作
; esi --> 原PeHead，edi --> 新的PeHead
; edx --> 最后一个节表，ebx --> 新加的节表
;********************************************************************
		mov	esi,_lpPeHead
		assume	esi:ptr IMAGE_NT_HEADERS,edi:ptr IMAGE_NT_HEADERS
		invoke	GlobalAlloc,GPTR,[esi].OptionalHeader.SizeOfHeaders
		mov	@lpMemory,eax
		mov	edi,eax
		invoke	RtlMoveMemory,edi,_lpFile,[esi].OptionalHeader.SizeOfHeaders
		add	edi,esi
		sub	edi,_lpFile
		movzx	eax,[esi].FileHeader.NumberOfSections
		dec	eax
		mov	ecx,sizeof IMAGE_SECTION_HEADER
		mul	ecx

		mov	edx,edi
		add	edx,eax
		add	edx,sizeof IMAGE_NT_HEADERS
		mov	ebx,edx
		add	ebx,sizeof IMAGE_SECTION_HEADER
		assume	ebx:ptr IMAGE_SECTION_HEADER,edx:ptr IMAGE_SECTION_HEADER
;********************************************************************
; （Part 2.1）检查是否有空闲的位置可供插入节表
;********************************************************************
		pushad
		mov	edi,ebx
		xor	eax,eax
		mov	ecx,IMAGE_SECTION_HEADER
		repz	scasb
		popad
		.if	! ZERO?
;********************************************************************
; （Part 3.1）如果没有新的节表空间的话，则查看现存代码节的最后
; 是否存在足够的全零空间，如果存在则在此处加入代码
;********************************************************************
			xor	eax,eax
			mov	ebx,edi
			add	ebx,sizeof IMAGE_NT_HEADERS
			.while	ax <=	[esi].FileHeader.NumberOfSections
				mov	ecx,[ebx].SizeOfRawData
				.if	ecx && ([ebx].Characteristics & IMAGE_SCN_MEM_EXECUTE)
					sub	ecx,[ebx].Misc.VirtualSize
					.if	ecx > offset APPEND_CODE_END-offset APPEND_CODE
						or	[ebx].Characteristics,IMAGE_SCN_MEM_READ or IMAGE_SCN_MEM_WRITE
						add	[ebx].Misc.VirtualSize,offset APPEND_CODE_END-offset APPEND_CODE
						jmp	@F
					.endif
				.endif
				add	ebx,IMAGE_SECTION_HEADER
				inc	ax
			.endw
			invoke	CloseHandle,@hFile
			invoke	DeleteFile,addr @szNewFile
			invoke	SetWindowText,hWinEdit,addr szErrNoRoom
			jmp	_Ret
			@@:
;********************************************************************
; 将新增代码加入代码节的空隙中
;********************************************************************
			mov	eax,[ebx].VirtualAddress
			add	eax,[ebx].Misc.VirtualSize
			mov	@dwAddCodeBase,eax
			mov	eax,[ebx].PointerToRawData
			add	eax,[ebx].Misc.VirtualSize
			mov	@dwAddCodeFile,eax
			invoke	SetFilePointer,@hFile,@dwAddCodeFile,NULL,FILE_BEGIN
			mov	ecx,offset APPEND_CODE_END-offset APPEND_CODE
			invoke	WriteFile,@hFile,offset APPEND_CODE,ecx,addr @dwTemp,NULL
		.else
;********************************************************************
; （Part 3.2）如果有新的节表空间的话，加入一个新的节
;********************************************************************
			inc	[edi].FileHeader.NumberOfSections
			mov	eax,[edx].PointerToRawData
			add	eax,[edx].SizeOfRawData
			mov	[ebx].PointerToRawData,eax
			mov	ecx,offset APPEND_CODE_END-offset APPEND_CODE
			invoke	_Align,ecx,[esi].OptionalHeader.FileAlignment
			mov	[ebx].SizeOfRawData,eax
			invoke	_Align,ecx,[esi].OptionalHeader.SectionAlignment
			add	[edi].OptionalHeader.SizeOfCode,eax	;修正SizeOfCode
			add	[edi].OptionalHeader.SizeOfImage,eax	;修正SizeOfImage
			invoke	_Align,[edx].Misc.VirtualSize,[esi].OptionalHeader.SectionAlignment
			add	eax,[edx].VirtualAddress
			mov	[ebx].VirtualAddress,eax
			mov	[ebx].Misc.VirtualSize,offset APPEND_CODE_END-offset APPEND_CODE
			mov	[ebx].Characteristics,IMAGE_SCN_CNT_CODE\
				or IMAGE_SCN_MEM_EXECUTE or IMAGE_SCN_MEM_READ or IMAGE_SCN_MEM_WRITE
			invoke	lstrcpy,addr [ebx].Name1,addr szMySection
;********************************************************************
; 将新增代码作为一个新的节写到文件尾部
;********************************************************************
			invoke	SetFilePointer,@hFile,[ebx].PointerToRawData,NULL,FILE_BEGIN
			invoke	WriteFile,@hFile,offset APPEND_CODE,[ebx].Misc.VirtualSize,\
				addr @dwTemp,NULL
			mov	eax,[ebx].PointerToRawData
			add	eax,[ebx].SizeOfRawData
			invoke	SetFilePointer,@hFile,eax,NULL,FILE_BEGIN
			invoke	SetEndOfFile,@hFile
;********************************************************************
			push	[ebx].VirtualAddress	;eax = 新加代码的基地址
			pop	@dwAddCodeBase
			push	[ebx].PointerToRawData
			pop	@dwAddCodeFile
		.endif
;********************************************************************
; （Part 4）修正文件入口指针并写入新的文件头
;********************************************************************
		mov	eax,@dwAddCodeBase
		add	eax,(offset _NewEntry-offset APPEND_CODE)
		mov	[edi].OptionalHeader.AddressOfEntryPoint,eax
		invoke	SetFilePointer,@hFile,0,NULL,FILE_BEGIN
		invoke	WriteFile,@hFile,@lpMemory,[esi].OptionalHeader.SizeOfHeaders,\
			addr @dwTemp,NULL
;********************************************************************
; （Part 5）修正新加代码中的 Jmp oldEntry 指令
;********************************************************************
		push	[esi].OptionalHeader.AddressOfEntryPoint
		pop	@dwEntry
		mov	eax,@dwAddCodeBase
		add	eax,(offset _ToOldEntry-offset APPEND_CODE+5)
		sub	@dwEntry,eax
		mov	ecx,@dwAddCodeFile
		add	ecx,(offset _dwOldEntry-offset APPEND_CODE)
		invoke	SetFilePointer,@hFile,ecx,NULL,FILE_BEGIN
		invoke	WriteFile,@hFile,addr @dwEntry,4,addr @dwTemp,NULL
;********************************************************************
; （Part 6）关闭文件
;********************************************************************
		invoke	GlobalFree,@lpMemory
		invoke	CloseHandle,@hFile
		invoke	wsprintf,addr @szBuffer,Addr szSuccess,addr @szNewFile
		invoke	SetWindowText,hWinEdit,addr @szBuffer
_Ret:
		assume	esi:nothing
		popad
		ret

_ProcessPeFile	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
