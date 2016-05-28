;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���ڲ���ListView�ؼ���ͨ���ӳ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ��ListView������һ����
; ���룺_dwColumn = ���ӵ��б��
;	_dwWidth = �еĿ��
;	_lpszHead = �еı����ַ���
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
; ��ListView������һ�У����޸�һ����ĳ���ֶε�����
; ���룺_dwItem = Ҫ�޸ĵ��еı��
;	_dwSubItem = Ҫ�޸ĵ��ֶεı�ţ�-1��ʾ�����µ��У�>=1��ʾ�ֶεı��
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
; ���ListView�е�����
; ɾ�����е��к����е���
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
