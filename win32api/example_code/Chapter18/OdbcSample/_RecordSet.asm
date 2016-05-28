;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by 罗云彬, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 模拟结果集操作的通用子程序
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ODBC_RS		struct
  hStmt		dd	?		;执行语句用的 StateMent 句柄
  dwCols	dd	?		;当前结果集中的列数
  lpField	dd	100 dup (?)	;预留100个列缓冲区的指针
  dwTemp	dd	?
ODBC_RS		ends
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		assume	esi:ptr ODBC_RS
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 释放“结果集”——释放为各字段申请的缓冲区内存
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RsClose	proc	uses esi ebx _lpRs

		mov	esi,_lpRs
		xor	ebx,ebx
		.while	ebx <	[esi].dwCols
			lea	eax,[esi+ebx*4+ODBC_RS.lpField]
			mov	eax,[eax]
			.if	eax
				invoke	GlobalFree,eax
			.endif
			inc	ebx
		.endw
		invoke	RtlZeroMemory,esi,sizeof ODBC_RS
		ret

_RsClose	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 创建“结果集”——为每个字段预先申请缓冲区，并Bind到语句句柄上
; 返回：eax = 0，失败；eax = TRUE，则成功
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RsOpen		proc	_lpRs,_hStmt
		local	@szName[128]:byte,@dwNameSize,@dwType
		local	@dwSize,@dwSize1,@dwNullable

		pushad
		mov	esi,_lpRs
		invoke	RtlZeroMemory,esi,sizeof ODBC_RS
		invoke	SQLNumResultCols,_hStmt,addr [esi].dwCols
		mov	eax,_hStmt
		mov	[esi].hStmt,eax
;********************************************************************
; 没有结果集则退出，如果超过100个列则只处理前面100个列
;********************************************************************
		and	[esi].dwCols,0ffffh
		cmp	[esi].dwCols,0
		jz	_Ret
		.if	[esi].dwCols >	100
			mov	[esi].dwCols,100
		.endif
;********************************************************************
; 为每个列申请内存并绑定到 statement 句柄
;********************************************************************
		xor	ebx,ebx
		.while	ebx <	[esi].dwCols
			inc	ebx
			invoke	SQLDescribeCol,_hStmt,ebx,\
				addr @szName,sizeof @szName,addr @dwNameSize,\
				addr @dwType,addr @dwSize,addr @dwSize1,addr @dwNullable
			mov	eax,@dwSize
			shl	eax,1
			inc	eax	; eax=字段长度*2+1
			push	eax
			invoke	GlobalAlloc,GPTR,eax
			pop	edx	; edx=字段长度*2+1,eax=缓冲区指针
			or	eax,eax
			jz	_Err
			lea	ecx,[esi+ebx*4+ODBC_RS.lpField-4]
			mov	[ecx],eax
			lea	ecx,[esi].dwTemp
			invoke	SQLBindCol,_hStmt,ebx,SQL_C_CHAR,eax,edx,ecx
		.endw
_Ret:
		popad
		ret
_Err:
		invoke	_RsClose,esi
		jmp	_Ret

_RsOpen		endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 获取结果集缓冲区中指定编号字段的内容
; 返回：eax = 0，失败
;	eax > 0，则eax为指向字段内容字符串的指针
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RsGetField	proc	uses esi _lpRs,_dwFieldId

		mov	esi,_lpRs
		mov	eax,_dwFieldId
		.if	eax <	[esi].dwCols
			lea	eax,[esi+eax*4+ODBC_RS.lpField]
			mov	eax,[eax]
		.else
			xor	eax,eax
		.endif
		ret

_RsGetField	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 返回：eax = TRUE，结果集已经到末尾
;	eax = FALSE，成功
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RsMoveNext	proc	uses esi ebx _lpRs

		mov	esi,_lpRs
;********************************************************************
; 预先清除的缓冲区，否则遇到空字段的时候SQLFetchScroll可能不返回数据，
; 这样缓冲区中是错误的上一条记录的内容
;********************************************************************
		xor	ebx,ebx
		.while	ebx <	[esi].dwCols
			lea	eax,[esi+ebx*4+ODBC_RS.lpField]
			mov	eax,[eax]
			.if	eax
				mov	byte ptr [eax],0
			.endif
			inc	ebx
		.endw
;********************************************************************
; 将游标移动到下一条记录，并将内容获取到字段缓冲区中
;********************************************************************
		invoke	SQLFetchScroll,[esi].hStmt,SQL_FETCH_NEXT,0
		.if	ax == SQL_SUCCESS || ax == SQL_SUCCESS_WITH_INFO
			xor	eax,eax
		.else
			xor	eax,eax
			inc	eax
		.endif
		ret

_RsMoveNext	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		assume	esi:nothing