������������������������������������������������������
��  ��Windows ������32λ��������ƣ���2�棩��    ��
��                  �������˵��                    ��
��               http://asm.yeah.net                ��
������������������������������������������������������

1. ��������������

    ���������ȫ������ MASM ��ʽ��д���Ƽ�ʹ�� MASM32 ��
������Ϊ���뻷����MASM32 ��������������µ�ַ���أ�

    MASM32�ٷ�վ�㣺      http://www.movsd.com
    ���ߵ�MASM���վ�㣺  http://asm.yeah.net

��װ����Ժ��뽫�����̸�Ŀ¼�µĻ��������������ļ� Var.bat
������ Masm32\bin Ŀ¼�£������� MASM32 �İ�װλ�ñ༭�޸�
Var.bat �ļ��е����Ŀ¼���ơ�

2. ����ά������

    ÿ�����Ӷ��������������롢���ӷ����� makefile �ļ���
ʹ�� nmake ���߿����Զ����ݴ��ļ����б������ӣ�nmake ��
�߿��Դ� Visual C++ �� bin Ŀ¼���ҵ���Ҳ���Դ����ߵ���
վ�����ء�

3. ���뻷���ͱ��뷽��

    ����ʹ�������з�ʽ���б��룬�Ա��� Chapter02\Test
Ŀ¼�� Test.asm Ϊ���������ǣ�

   I.    ��һ����������ʾ�������ڡ�
   II.   ���뻷�������������ļ� Var.bat ����Ŀ¼��ִ��
         �����Ժ�Ϳ���ʹ�������������ʾ�������ڱ���
         �ļ��ˡ�

         x:                          <�л���MASM32��װ��������>
         cd \masm32\bin              <����MASM32��ִ��Ŀ¼>
         var                         <ִ��Var.bat���û�������>

   III.  ����Դ����Ŀ¼��

         cd \chapter02\test

   IV.   ʹ�� nmake ���߽��б������ӣ�

         nmake

   V.    ִ�б���õĿ�ִ���ļ���

    �����Ҫ��Դ��������޸ģ����عرա�������ʾ�������ڣ�
ֻҪ�л����༭�����ڣ����޸� *.asm �ļ����ظ����е� IV ��
�� V ���輴�ɡ�

�� �ر�ע�⣺�������еĴ��뿽����Ӳ�̺󣬱��뽫�ļ���ֻ������ȥ����

4. �������������ĵ�

   Win32 ������漰�ܶ� API ��ʹ�ã�ʹ�� .hlp��.chm ��
��ʽ�����������ļ�������Щ API ��ʹ��˵���Ǻܷ���ģ�����
����վ���ṩ�˺��꾡�������ĵ����أ���������ʣ�

   http://asm.yeah.net

5. ������������Ŀ¼��˵��

��Ŀ¼�µ� *.pdf                   ;��¼A��B��C�ĵ��Ӱ��ĵ�

Chapter02\Test                     ;���Ա��뻷��

Chapter03\HelloWorld               ;Hello World

Chapter04\FirstWindow              ;��Win32���д��һ������
Chapter04\FirstWindow-1            ;��Win32���д��һ������
Chapter04\SendMessage              ;���ڼ����Ϣ����
Chapter04\SendMessage-1            ;���ڼ����Ϣ����

Chapter05\Menu                     ;ʹ����Դ - ʹ�ò˵�
Chapter05\Icon                     ;ʹ����Դ - ʹ��ͼ��
Chapter05\Dialog                   ;ʹ����Դ - ʹ�öԻ���
Chapter05\Listbox                  ;ʹ����Դ - ʹ���б��
Chapter05\Control                  ;ʹ����Դ - ʹ���Ӵ��ڿؼ�
Chapter05\ShowVersionInfo          ;ʹ����Դ - ��ʾ�汾��Ϣ��Դ�ĳ���
Chapter05\VersionInfo              ;ʹ����Դ - ʹ�ð汾��Ϣ��Դ

Chapter06\Timer                    ;��ʱ����ʹ��

Chapter07\DcCopy                   ;���������ڵ� DC �以�࿽����Ļ
Chapter07\Clock                    ;ģ��ʱ�ӳ���
Chapter07\BmpClock                 ;�� Bitmap ͼƬ��������ģ��ʱ�ӳ���
Chapter07\TestObject               ;һЩ�����Ļ�ͼ����

Chapter08\CommDlg                  ;ʹ��ͨ�öԻ���

Chapter09\Toolbar                  ;ʹ�ù�����
Chapter09\StatusBar                ;ʹ��״̬��
Chapter09\Richedit                 ;ʹ�÷ḻ�༭�ؼ�
Chapter09\Wordpad                  ;һ���������ı��༭������
Chapter09\SubClass                 ;���ڵ����໯����
Chapter09\SuperClass               ;���ڵĳ��໯����

Chapter10\MemInfo                  ;��ʾ��ǰ�ڴ��ʹ�����
Chapter10\Fragment                 ;�ڴ���Ƭ������ʾ����
Chapter10\FindFile                 ;ȫ�̲����ļ�������
Chapter10\FormatText               ;�ļ���д����
Chapter10\FormatText\FileMap       ;ʹ���ڴ�ӳ���ļ������ļ���д������
Chapter10\MMFShare                 ;ʹ���ڴ�ӳ���ļ����н��̼����ݹ���

Chapter11\Dll\Dll                  ;��򵥵Ķ�̬���ӿ����� - ��д DLL
Chapter11\Dll\MASM Sample          ;��򵥵Ķ�̬���ӿ����� - ʹ�� DLL
Chapter11\Dll\VC++ Sample          ;��򵥵Ķ�̬���ӿ����� - ��VC++��ʹ�û���д��DLL
Chapter11\KeyHook                  ;Windows ���ӵ����� - �������̶���
Chapter11\RecHook                  ;Windows ��־��¼���ӵ����� - �������̶���

Chapter12\Counter                  ;������ĳ��� - һ����������
Chapter12\Thread                   ;�ö��̵߳ķ�ʽ�����һ�����������
Chapter12\Event                    ;ʹ���¼�����
Chapter12\ThreadSynErr             ;һ������ͬ������Ķ��̳߳���
Chapter12\ThreadSyn\UseCriticalSection       ;ʹ���ٽ������������߳�ͬ������
Chapter12\ThreadSyn\UseEvent       ;ʹ���¼����������߳�ͬ������
Chapter12\ThreadSyn\UseMutex       ;ʹ�û�����������߳�ͬ������
Chapter12\ThreadSyn\UseSemaphore   ;ʹ���źŵƶ��������߳�ͬ������

Chapter13\CmdLine                  ;ʹ�������в���
Chapter13\Process                  ;�������̵�����
Chapter13\ProcessList              ;��ʾϵͳ�����еĽ����б�
Chapter13\Patch1                   ;һ���ڴ油������
Chapter13\Patch2                   ;һ���ڴ油������
Chapter13\Patch3                   ;һ���ڴ油������
Chapter13\HideProcess9x            ;Windows 9x�µĽ�������
Chapter13\RemoteThreadDll          ;�� DLL ע��ķ���ʵ��Զ�̽���
Chapter13\RemoteThread             ;�������κ��ⲿ�ļ�ʵ��Զ�̽���

Chapter14\TopHandler               ;ʹ��ɸѡ�������쳣
Chapter14\SEH01                    ;������ṹ���쳣��������
Chapter14\SEH02                    ;�Ľ���Ľṹ���쳣��������
Chapter14\Unwind                   ;�쳣�����е�չ����������

Chapter15\Ini                      ;ʹ�� INI �ļ�
Chapter15\Reg                      ;����ע��������
Chapter15\Associate                ;����ע���ʵ���ļ�����

Chapter16\TcpEcho                  ;ʵ�� TCP �������˵ļ�����
Chapter16\Chat-TCP                 ;�� TCP Э��ʵ�ֵ�����������

Chapter17\PeInfo                   ;�鿴 PE �ļ��Ļ�����Ϣ
Chapter17\Import                   ;�鿴 PE �ļ��ĵ����
Chapter17\Export                   ;�鿴 PE �ļ��ĵ�����
Chapter17\Resource                 ;�鿴 PE �ļ�����Դ�б�
Chapter17\Reloc                    ;�鿴 PE �ļ����ض�λ��Ϣ
Chapter17\NoImport                 ;��ʹ�õ������� API ����
Chapter17\AddCode                  ;�� PE �ļ��ϸ��ӿ�ִ�д��������

Chapter18\OdbcSample               ;��ODBC�������ݿ������

Appendix A\EchoLine                 ;����̨�������������

Appendix B\MsgWindow01             ;��Ϣ�������� 1
Appendix B\MsgWindow02             ;��Ϣ�������� 2
Appendix B\MsgWindow03             ;��Ϣ�������� 3
Appendix B\MsgWindow04             ;��Ϣ�������� 4

Appendix C\BrowseFolder            ;���Ŀ¼�Ի���

6. ��ϵ����

    ��Ȼ���������е����Ӵ��붼�Ѿ���Windows 98��Windows 2000
��Windows XP�²���ͨ������Ҳ�д���Bug�Ŀ��ܣ�������ִ����
�ڴ���������������⣬���֪���ߣ���ϵ������

    �����߷� E-mail��luoyunbin@hz.cn �� luoyunbin@sina.com
    �����ߵ���ҳ�Ͽ����ҵ�������Ч�������ַ��http://asm.yeah.net


    ��л����֧�֣�

                                            ���ߣ����Ʊ�
