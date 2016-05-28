;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Sample code for < Win32ASM Programming 2nd Edition>
; by ���Ʊ�, http://asm.yeah.net
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; FIFO��First in, first out����Ϣ���е�ʵ��
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
QUEUE_SIZE	equ	100		;��Ϣ���еĳ���
MSG_QUEUE_ITEM	struct			;�����е�����Ϣ�ĸ�ʽ����
  dwMessageId	dd	?		;��Ϣ���
  szSender	db	12 dup (?)	;������
  szContent	db	256 dup (?)	;��������
MSG_QUEUE_ITEM	ends
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.data?

stCS		CRITICAL_SECTION <?>
stMsgQueue	MSG_QUEUE_ITEM QUEUE_SIZE dup (<?>)
dwMsgCount	dd	?		;�����е�ǰ��Ϣ����

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

		.data

dwSequence	dd	1	;��Ϣ��ţ���1��ʼ

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �ڶ����м���һ����Ϣ
; -- ��������Ѿ����ˣ�����������ǰ��һ��λ�ã��൱���������Ϣ������
;    Ȼ���ڶ���β���ճ���λ�ü�������Ϣ
; -- �������δ�������ڶ��е�����������Ϣ
; -- ��Ϣ��Ŵ�1��ʼ������������֤�����и���Ϣ�ı����������
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ��ڣ�_lpszSender = ָ�������ַ�����ָ��
;	_lpszContent = ָ��������������ַ�����ָ��
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_InsertMsgQueue	proc	_lpszSender,_lpszContent

		pushad
		invoke	EnterCriticalSection,addr stCS
		mov	eax,dwMsgCount
;********************************************************************
; ��������������ƶ����У����ڶ���β���������Ϣ
;********************************************************************
		.if	eax >= QUEUE_SIZE
			mov	edi,offset stMsgQueue
			mov	esi,offset stMsgQueue + sizeof MSG_QUEUE_ITEM
			mov	ecx,(QUEUE_SIZE-1) * sizeof MSG_QUEUE_ITEM
			mov	eax,ecx
			cld
			rep	movsb
;********************************************************************
; ����ֱ����ӵ�����β��
;********************************************************************
		.else
			inc	dwMsgCount
			mov	ecx,sizeof MSG_QUEUE_ITEM
			mul	ecx
		.endif
;********************************************************************
; ǰ������ִ����Ϻ�eaxָ������п�λ�õ�ƫ����
;********************************************************************
		lea	esi,[stMsgQueue+eax]
		assume	esi:ptr MSG_QUEUE_ITEM
		invoke	lstrcpy,addr [esi].szSender,_lpszSender
		invoke	lstrcpy,addr [esi].szContent,_lpszContent
		inc	dwSequence
		mov	eax,dwSequence
		mov	[esi].dwMessageId,eax
		assume	esi:nothing
		invoke	LeaveCriticalSection,addr stCS
		popad
		ret

_InsertMsgQueue	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; �Ӷ��л�ȡָ����ŵ���Ϣ
; -- ���ָ����ŵ���Ϣ�Ѿ����������Ϣ���У��򷵻ر����С��һ����Ϣ
;    ���������ٶȹ����Ŀͻ��˷���Ϣ���ٶȱȲ�����Ϣ��������ٶȣ����м�
;    ����Ϣ���ڱ����ԣ��������Ա�֤������·����Ӱ�������·
; -- ��������е�������Ϣ�ı�Ŷ���ָ�����С����ζ����Щ��Ϣ��ǰ������ȡ����
;    ��ô�������κ���Ϣ
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ��ڣ�_dwMessageId = ��Ҫ��ȡ����Ϣ���
;	_lpszSender = ���ڷ�����Ϣ�з������ַ����Ļ�����ָ��
;	_lpszSender = ���ڷ�����Ϣ�����������ַ����Ļ�����ָ��
; ���أ�eax = 0������Ϊ�գ����߶�����û��С�ڵ���ָ����ŵ���Ϣ��
;	eax <> 0���Ѿ���ȡ��һ����Ϣ����ȡ����Ϣ��ŷ��ص�eax�У�
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_GetMsgFromQueue	proc	_dwMessageId,_lpszSender,_lpszContent
			local	@dwReturn

		pushad
		invoke	EnterCriticalSection,addr stCS
		xor	eax,eax
		mov	@dwReturn,eax
		cmp	dwMsgCount,eax
		jz	_Ret

		mov	esi,offset stMsgQueue
		assume	esi:ptr MSG_QUEUE_ITEM
;********************************************************************
; esi ָ�����ͷ��������������Ϣ�ı�ž�����С���
; ����ţ���С��ţ����г��ȣ�1
;********************************************************************
		mov	ecx,[esi].dwMessageId	;ecx=�����е���С��Ϣ���
		mov	edx,dwMsgCount
		lea	edx,[edx+ecx-1]		;edx=�����е������Ϣ���
;********************************************************************
; ���ָ����� < ��С��ţ��򷵻���С��ŵ���Ϣ
; ���ָ����� > ����ţ��򲻷����κ���Ϣ
;********************************************************************
		mov	eax,_dwMessageId
		cmp	eax,ecx
		jae	@F
		mov	eax,ecx
		@@:
		cmp	eax,edx
		ja	_Ret
		mov	@dwReturn,eax
;********************************************************************
; Ҫ��ȡ����Ϣ�ڶ����е�λ�� = ָ����Ϣ��ţ���С��Ϣ���
;********************************************************************
		sub	eax,ecx
		mov	ecx,sizeof MSG_QUEUE_ITEM
		mul	ecx
		lea	esi,[esi+eax]
		invoke	lstrcpy,_lpszSender,addr [esi].szSender
		invoke	lstrcpy,_lpszContent,addr [esi].szContent
;********************************************************************
		assume	esi:nothing
_Ret:
		invoke	LeaveCriticalSection,addr stCS
		popad
		mov	eax,@dwReturn
		ret

_GetMsgFromQueue	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
