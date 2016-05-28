;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ����ģʽ��ʹ�õĳ����ӳ���
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �ڹ涨��ʱ���ڵȴ����ݵ���
; ���룺dwTime = ��Ҫ�ȴ���ʱ�䣨΢�룩
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_WaitData	proc	_hSocket,_dwTime
		local	@stFdSet:fd_set,@stTimeval:timeval

		mov	@stFdSet.fd_count,1
		push	_hSocket
		pop	@stFdSet.fd_array
		push	_dwTime
		pop	@stTimeval.tv_usec
		mov	@stTimeval.tv_sec,0
		invoke	select,0,addr @stFdSet,NULL,NULL,addr @stTimeval
		ret

_WaitData	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ���չ涨�ֽڵ����ݣ�����������е����ݲ�����ȴ�
; ���أ�eax = TRUE�������жϻ�������
;	eax = FALSE���ɹ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RecvData	proc	_hSocket,_lpData,_dwSize
		local	@dwStartTime

		mov	esi,_lpData
		mov	ebx,_dwSize
		invoke	GetTickCount
		mov	@dwStartTime,eax
;********************************************************************
		@@:
		invoke	GetTickCount			;�鿴�Ƿ�ʱ
		sub	eax,@dwStartTime
		cmp	eax,10 * 1000
		jge	_Err
;********************************************************************
		invoke	_WaitData,_hSocket,100*1000	;�ȴ�����100ms
		cmp	eax,SOCKET_ERROR
		jz	_Err
		or	eax,eax
		jz	@B
		invoke	recv,_hSocket,esi,ebx,0
		.if	(eax == SOCKET_ERROR) || ! eax
_Err:
			xor	eax,eax
			inc	eax
			ret
		.endif
		.if	eax <	ebx
			add	esi,eax
			sub	ebx,eax
			jmp	@B
		.endif
		xor	eax,eax
		ret

_RecvData	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ����һ�����Ϲ淶�����ݰ�
; ���أ�eax = TRUE ��ʧ�ܣ�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_RecvPacket	proc	_hSocket,_lpBuffer,_dwSize
		local	@dwReturn

		pushad
		mov	@dwReturn,TRUE
		mov	esi,_lpBuffer
		assume	esi:ptr MSG_STRUCT
;********************************************************************
; �������ݰ�ͷ������������Ƿ�����
;********************************************************************
		invoke	_RecvData,_hSocket,esi,sizeof MSG_HEAD
		or	eax,eax
		jnz	_Ret
		mov	ecx,[esi].MsgHead.dwLength
		cmp	ecx,sizeof MSG_HEAD
		jb	_Ret
		cmp	ecx,_dwSize
		ja	_Ret
;********************************************************************
; �������µ�����
;********************************************************************
		sub	ecx,sizeof MSG_HEAD
		add	esi,sizeof MSG_HEAD
		.if	ecx
			invoke	_RecvData,_hSocket,esi,ecx
		.else
			xor	eax,eax
		.endif
		mov	@dwReturn,eax
_Ret:
		popad
		assume	esi:nothing
		mov	eax,@dwReturn
		ret

_RecvPacket	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
