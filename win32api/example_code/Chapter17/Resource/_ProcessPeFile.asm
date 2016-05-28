;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Resource例子的 PE文件处理模块
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const

szMsg		db	'文件名： %s',0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'资源所处的节：%s',0dh,0ah,0
szErrNoRes	db	'这个文件中没有包含资源!',0
szLevel1	db	0dh,0ah
		db	'------------------------------------------------',0dh,0ah
		db	'资源类型：%s',0dh,0ah
		db	'------------------------------------------------',0dh,0ah,0
szLevel1byID	db	'%d (自定义编号)',0
szLevel2byID	db	'  ID: %d',0dh,0ah,0
szLevel2byName	db	'  Name: %s',0dh,0ah,0
szResData	db	'     文件偏移：%08X (代码页=%04X, 长度%d字节)',0dh,0ah,0
szType		db	'光标        ',0	;1
		db	'位图        ',0	;2
		db	'图标        ',0	;3
		db	'菜单        ',0	;4
		db	'对话框      ',0	;5
		db	'字符串      ',0	;6
		db	'字体目录    ',0	;7
		db	'字体        ',0	;8
		db	'加速键      ',0	;9
		db	'未格式化资源',0	;10
		db	'消息表      ',0	;11
		db	'光标组      ',0	;12
		db	'未知类型    ',0	;13
		db	'图标组      ',0	;14
		db	'未知类型    ',0	;15
		db	'版本信息    ',0	;16

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
; 检查资源目录表，得到资源目录项的数量
;********************************************************************
		mov	esi,_lpResDir
		assume	esi:ptr IMAGE_RESOURCE_DIRECTORY
		mov	cx,[esi].NumberOfNamedEntries
		add	cx,[esi].NumberOfIdEntries
		movzx	ecx,cx
		add	esi,sizeof IMAGE_RESOURCE_DIRECTORY
		assume	esi:ptr IMAGE_RESOURCE_DIRECTORY_ENTRY
;********************************************************************
; 循环处理每个资源目录项
;********************************************************************
		.while	ecx >	0
			push	ecx
			mov	ebx,[esi].OffsetToData
			.if	ebx & 80000000h
				and	ebx,7fffffffh
				add	ebx,_lpRes
				.if	_dwLevel == 1
;********************************************************************
; 第一层：资源类型
;********************************************************************
					mov	eax,[esi].Name1
					.if	eax & 80000000h
						and	eax,7fffffffh
						add	eax,_lpRes
						movzx	ecx,word ptr [eax]	;IMAGE_RESOURCE_DIR_STRING_U结构
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
; 第二层：资源ID（或名称）
;********************************************************************
				.elseif	_dwLevel == 2
					mov	edx,[esi].Name1
					.if	edx & 80000000h
;********************************************************************
; 资源以字符串方式命名
;********************************************************************
						and	edx,7fffffffh
						add	edx,_lpRes	;IMAGE_RESOURCE_DIR_STRING_U结构
						movzx	ecx,word ptr [edx]
						add	edx,2
						invoke	WideCharToMultiByte,CP_ACP,WC_COMPOSITECHECK,\
							edx,ecx,addr @szResName,sizeof @szResName,\
							NULL,NULL
						invoke	wsprintf,addr @szBuffer,\
							addr szLevel2byName,addr @szResName
					.else
;********************************************************************
; 资源以 ID 命名
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
; 不是资源目录则显示资源详细信息
;********************************************************************
			.else
				add	ebx,_lpRes
				mov	ecx,[esi].Name1		;代码页
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
; 检测是否存在资源
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
