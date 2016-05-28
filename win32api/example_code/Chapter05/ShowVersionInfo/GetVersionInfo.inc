;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; GetVersionInfo.inc
; 用来获取 PE 文件资源中版本信息的子程序
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 通过 include 语句包含到其它源程序中使用
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.const

szRoot		db	'\',0
szVarInfo	db	'\VarFileInfo\Translation',0
szStrInfoFmt	db	'\StringFileInfo\%08x\',0
szArrow		db	' --> ',0
szReturn	db	0dh,0ah,0
szFixFileInfo	db	'固定版本信息属性：',0dh,0ah
		db	'FileVersion: %d.%d.%d.%d',0dh,0ah
		db	'ProductVersion: %d.%d.%d.%d',0dh,0ah
		db	'FileOS: %08x',0dh,0ah
		db	'FileType: %08x',0dh,0ah,0dh,0ah
		db	'字符串版本属性：',0dh,0ah,0
;********************************************************************
szStr1		db	'Comments',0
szStr2		db	'CompanyName',0
szStr3		db	'FileDescription',0
szStr4		db	'FileVersion',0
szStr5		db	'InternalName',0
szStr6		db	'LegalCopyright',0
szStr7		db	'LegalTrademarks',0
szStr8		db	'OriginalFilename',0
szStr9		db	'PrivateBuild',0
szStr10		db	'ProductName',0
szStr11		db	'ProductVersion',0
szStr12		db	'SpecialBuild',0
;********************************************************************
lpStr1		dd	szStr1
lpStr2		dd	szStr2
lpStr3		dd	szStr3
lpStr4		dd	szStr4
lpStr5		dd	szStr5
lpStr6		dd	szStr6
lpStr7		dd	szStr7
lpStr8		dd	szStr8
lpStr9		dd	szStr9
lpStr10		dd	szStr10
lpStr11		dd	szStr11
lpStr12		dd	szStr12

		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 获取文件版本信息
; 入口参数：文件名，返回信息缓冲区
; 返回参数：TRUE = 成功，FALSE = 失败
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_GetVersionInfo	proc	_lpFileName,_lpBuffer
		local	@dbVerInfo[4096]:byte
		local	@szStringInfo[128]:byte
		local	@szString[128]:byte
		local	@lpBuffer,@dwLen
		local	@dwVer1,@dwVer2,@dwVer3,@dwVer4
		local	@dwVer5,@dwVer6,@dwVer7,@dwVer8

		pushad
		invoke	GetFileVersionInfoSize,_lpFileName,NULL
		.if	!eax
			popad
			xor	eax,eax
			ret
		.endif
		invoke	GetFileVersionInfo,_lpFileName,NULL,sizeof @dbVerInfo,addr @dbVerInfo
;********************************************************************
; 获取固定属性
;********************************************************************
		invoke	VerQueryValue,addr @dbVerInfo,addr szRoot,addr @lpBuffer,addr @dwLen
		mov	esi,@lpBuffer
		assume	esi:ptr VS_FIXEDFILEINFO
;********************************************************************
; 计算版本号
;********************************************************************
		mov	eax,[esi].dwFileVersionMS
		movzx	ecx,ax
		mov	@dwVer2,ecx
		shr	eax,16
		mov	@dwVer1,eax

		mov	eax,[esi].dwFileVersionLS
		movzx	ecx,ax
		mov	@dwVer4,ecx
		shr	eax,16
		mov	@dwVer3,eax

		mov	eax,[esi].dwProductVersionMS
		movzx	ecx,ax
		mov	@dwVer6,ecx
		shr	eax,16
		mov	@dwVer5,eax

		mov	eax,[esi].dwProductVersionLS
		movzx	ecx,ax
		mov	@dwVer8,ecx
		shr	eax,16
		mov	@dwVer7,eax
		invoke	wsprintf,_lpBuffer,addr szFixFileInfo,\
			@dwVer1,@dwVer2,@dwVer3,@dwVer4,\
			@dwVer5,@dwVer6,@dwVer7,@dwVer8,\
			[esi].dwFileOS,[esi].dwFileType

		assume	esi:nothing
;********************************************************************
; 获取语言集
;********************************************************************
		invoke	VerQueryValue,addr @dbVerInfo,addr szVarInfo,addr @lpBuffer,addr @dwLen
		mov	eax,@lpBuffer
		mov	eax,[eax]
		ror	eax,16
		invoke	wsprintf,addr @szStringInfo,addr szStrInfoFmt,eax
;********************************************************************
; 获取字符串版本信息
;********************************************************************
		mov	ebx,offset lpStr1
		.while	ebx <=	offset lpStr12
			invoke	lstrcpy,addr @szString,addr @szStringInfo
			mov	eax,[ebx]
			invoke	lstrcat,addr @szString,eax
			mov	eax,[ebx]
			invoke	lstrcat,_lpBuffer,eax
			invoke	lstrcat,_lpBuffer,addr szArrow		;加上 -->
			invoke	VerQueryValue,addr @dbVerInfo,addr @szString,addr @lpBuffer,addr @dwLen
			.if	eax
				invoke	lstrcat,_lpBuffer,@lpBuffer	;加上获得的版本信息
			.endif
			invoke	lstrcat,_lpBuffer,addr szReturn		;加上回车
			add	ebx,4
		.endw
		popad
		mov	eax,TRUE
		ret

_GetVersionInfo	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
