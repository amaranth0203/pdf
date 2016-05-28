;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; _BrowseFolder.asm
; “选择目录”通用对话框子程序
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 定义几个基本的 COM 接口
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; IUnknown interface
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
externdef                    IID_IUnknown:IID
LPUNKNOWN                    typedef DWORD
LPPUNKNOWN                   typedef ptr LPUNKNOWN

IUnknown_QueryInterfaceProto typedef proto :DWORD, :DWORD, :DWORD
IUnknown_AddRefProto         typedef proto :DWORD
IUnknown_ReleaseProto        typedef proto :DWORD
IUnknown_QueryInterface      typedef ptr IUnknown_QueryInterfaceProto
IUnknown_AddRef              typedef ptr IUnknown_AddRefProto
IUnknown_Release             typedef ptr IUnknown_ReleaseProto

IUnknown struct DWORD
      QueryInterface    IUnknown_QueryInterface  ?
      AddRef            IUnknown_AddRef          ?
      Release           IUnknown_Release         ?
IUnknown ends
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;IMalloc Interface
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
externdef                    IID_IMalloc:IID
LPMALLOC                     typedef DWORD
LPPMALLOC                    typedef ptr LPMALLOC

IMalloc_AllocProto           typedef proto :DWORD, :DWORD
IMalloc_ReallocProto         typedef proto :DWORD, :DWORD, :DWORD
IMalloc_FreeProto            typedef proto :DWORD, :DWORD
IMalloc_GetSizeProto         typedef proto :DWORD, :DWORD
IMalloc_DidAllocProto        typedef proto :DWORD, :DWORD
IMalloc_HeapMinimizeProto    typedef proto :DWORD

IMalloc_Alloc                typedef ptr IMalloc_AllocProto
IMalloc_Realloc              typedef ptr IMalloc_ReallocProto
IMalloc_Free                 typedef ptr IMalloc_FreeProto
IMalloc_GetSize              typedef ptr IMalloc_GetSizeProto
IMalloc_DidAlloc             typedef ptr IMalloc_DidAllocProto
IMalloc_HeapMinimize         typedef ptr IMalloc_HeapMinimizeProto

IMalloc struct DWORD
      QueryInterface    IUnknown_QueryInterface  ?
      AddRef            IUnknown_AddRef          ?
      Release           IUnknown_Release         ?
      Alloc             IMalloc_Alloc            ?
      Realloc           IMalloc_Realloc          ?
      Free              IMalloc_Free             ?
      GetSize           IMalloc_GetSize          ?
      DidAlloc          IMalloc_DidAlloc         ?
      HeapMinimize      IMalloc_HeapMinimize     ?
IMalloc ends
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?
_BrowseFolderTmp dd	?

		.const
_szDirInfo	db	'请选择目录：',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 弹出选择目录的对话框
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_BrowseFolderCallBack	proc	hWnd,uMsg,lParam,lpData
			local	@szBuffer[260]:byte

		mov	eax,uMsg
		.if	eax ==	BFFM_INITIALIZED
			invoke	SendMessage,hWnd,BFFM_SETSELECTION,TRUE,_BrowseFolderTmp
		.elseif	eax ==	BFFM_SELCHANGED
			invoke	SHGetPathFromIDList,lParam,addr @szBuffer
			invoke	SendMessage,hWnd,BFFM_SETSTATUSTEXT,0,addr @szBuffer
		.endif
		xor	eax,eax
		ret

_BrowseFolderCallBack	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_BrowseFolder	proc	_hWnd,_lpszBuffer
		local	@stBrowseInfo:BROWSEINFO
		local	@stMalloc
		local	@pidlParent,@dwReturn

		pushad

		invoke	CoInitialize,NULL
		invoke	SHGetMalloc,addr @stMalloc
		.if	eax == E_FAIL
			mov	@dwReturn,FALSE
			jmp	@F
		.endif

		invoke	RtlZeroMemory,addr @stBrowseInfo,sizeof @stBrowseInfo
;********************************************************************
; SHBrowseForFolder 选择一个目录，把不含路径的目录名放入
; stBrowseInfo.pszDisplayName 中，SHGetPathFromIDList 把
; stBrowseInfo.pszDisplayName 转换成含全部路径的目录名
;********************************************************************
		push	_hWnd
		pop	@stBrowseInfo.hwndOwner
		push	_lpszBuffer
		pop	_BrowseFolderTmp
		mov	@stBrowseInfo.lpfn,offset _BrowseFolderCallBack
		mov	@stBrowseInfo.lpszTitle,offset _szDirInfo
		mov	@stBrowseInfo.ulFlags,BIF_RETURNONLYFSDIRS or BIF_STATUSTEXT
		invoke	SHBrowseForFolder,addr @stBrowseInfo
		mov	@pidlParent,eax
		.if	eax !=	NULL
			invoke	SHGetPathFromIDList,eax,_lpszBuffer
			mov	eax,TRUE
		.else
			mov	eax,FALSE
		.endif
		mov	@dwReturn,eax
		mov	eax,@stMalloc
		mov	eax,[eax]
		invoke	(IMalloc PTR [eax]).Free,@stMalloc,@pidlParent
		mov	eax,@stMalloc
		mov	eax,[eax]
		invoke	(IMalloc PTR [eax]).Release,@stMalloc

		@@:
		invoke	CoUninitialize
		popad
		mov	eax,@dwReturn
		ret

_BrowseFolder	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
