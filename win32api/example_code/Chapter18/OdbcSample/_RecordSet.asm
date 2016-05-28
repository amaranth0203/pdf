;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ģ������������ͨ���ӳ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ODBC_RS		struct
  hStmt		dd	?		;ִ������õ� StateMent ���
  dwCols	dd	?		;��ǰ������е�����
  lpField	dd	100 dup (?)	;Ԥ��100���л�������ָ��
  dwTemp	dd	?
ODBC_RS		ends
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		assume	esi:ptr ODBC_RS
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �ͷš�������������ͷ�Ϊ���ֶ�����Ļ������ڴ�
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
; �����������������Ϊÿ���ֶ�Ԥ�����뻺��������Bind���������
; ���أ�eax = 0��ʧ�ܣ�eax = TRUE����ɹ�
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
; û�н�������˳����������100������ֻ����ǰ��100����
;********************************************************************
		and	[esi].dwCols,0ffffh
		cmp	[esi].dwCols,0
		jz	_Ret
		.if	[esi].dwCols >	100
			mov	[esi].dwCols,100
		.endif
;********************************************************************
; Ϊÿ���������ڴ沢�󶨵� statement ���
;********************************************************************
		xor	ebx,ebx
		.while	ebx <	[esi].dwCols
			inc	ebx
			invoke	SQLDescribeCol,_hStmt,ebx,\
				addr @szName,sizeof @szName,addr @dwNameSize,\
				addr @dwType,addr @dwSize,addr @dwSize1,addr @dwNullable
			mov	eax,@dwSize
			shl	eax,1
			inc	eax	; eax=�ֶγ���*2+1
			push	eax
			invoke	GlobalAlloc,GPTR,eax
			pop	edx	; edx=�ֶγ���*2+1,eax=������ָ��
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
; ��ȡ�������������ָ������ֶε�����
; ���أ�eax = 0��ʧ��
;	eax > 0����eaxΪָ���ֶ������ַ�����ָ��
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
; ���أ�eax = TRUE��������Ѿ���ĩβ
;	eax = FALSE���ɹ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RsMoveNext	proc	uses esi ebx _lpRs

		mov	esi,_lpRs
;********************************************************************
; Ԥ������Ļ������������������ֶε�ʱ��SQLFetchScroll���ܲ��������ݣ�
; �������������Ǵ������һ����¼������
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
; ���α��ƶ�����һ����¼���������ݻ�ȡ���ֶλ�������
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