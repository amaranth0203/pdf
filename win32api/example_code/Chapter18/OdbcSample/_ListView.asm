;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 用于操作ListView控件的通用子程序
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 在ListView中增加一个列
; 输入：_dwColumn = 增加的列编号
;	_dwWidth = 列的宽度
;	_lpszHead = 列的标题字符串
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ListViewAddColumn	proc	_hWinView,_dwColumn,_dwWidth,_lpszHead
			local	@stLVC:LV_COLUMN

		invoke	RtlZeroMemory,addr @stLVC,sizeof LV_COLUMN
		mov	@stLVC.imask,LVCF_TEXT or LVCF_WIDTH or LVCF_FMT
		mov	@stLVC.fmt,LVCFMT_LEFT
		push	_lpszHead
		pop	@stLVC.pszText
		push	_dwWidth
		pop	@stLVC.lx
		invoke	SendMessage,_hWinView,LVM_INSERTCOLUMN,_dwColumn,addr @stLVC
		ret

_ListViewAddColumn	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 在ListView中新增一行，或修改一行中某个字段的内容
; 输入：_dwItem = 要修改的行的编号
;	_dwSubItem = 要修改的字段的编号，-1表示插入新的行，>=1表示字段的编号
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ListViewSetItem	proc	_hWinView,_dwItem,_dwSubItem,_lpszText
			local	@stLVI:LV_ITEM

		invoke	RtlZeroMemory,addr @stLVI,sizeof LV_ITEM

		invoke	lstrlen,_lpszText
		mov	@stLVI.cchTextMax,eax
		mov	@stLVI.imask,LVIF_TEXT
		push	_lpszText
		pop	@stLVI.pszText
		push	_dwItem
		pop	@stLVI.iItem
		push	_dwSubItem
		pop	@stLVI.iSubItem

		.if	_dwSubItem == -1
			mov	@stLVI.iSubItem,0
			invoke	SendMessage,_hWinView,LVM_INSERTITEM,NULL,addr @stLVI
		.else
			invoke	SendMessage,_hWinView,LVM_SETITEM,NULL,addr @stLVI
		.endif
		ret

_ListViewSetItem	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 清除ListView中的内容
; 删除所有的行和所有的列
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_ListViewClear	proc	_hWinView

		invoke	SendMessage,_hWinView,LVM_DELETEALLITEMS,0,0
		.while	TRUE
			invoke	SendMessage,_hWinView,LVM_DELETECOLUMN,0,0
			.break	.if ! eax
		.endw
		ret

_ListViewClear	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
