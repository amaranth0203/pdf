×××××××××××××××××××××××××××
×  《Windows 环境下32位汇编程序设计（第2版）》    ×
×                  附书代码说明                    ×
×               http://asm.yeah.net                ×
×××××××××××××××××××××××××××

1. 编译器和链接器

    本附书代码全部采用 MASM 格式编写，推荐使用 MASM32 软
件包作为编译环境，MASM32 软件包可以在以下地址下载：

    MASM32官方站点：      http://www.movsd.com
    作者的MASM编程站点：  http://asm.yeah.net

安装完成以后请将本光盘根目录下的环境设置批处理文件 Var.bat
拷贝到 Masm32\bin 目录下，并根据 MASM32 的安装位置编辑修改
Var.bat 文件中的相关目录名称。

2. 代码维护工具

    每个例子都包括了描述编译、链接方法的 makefile 文件，
使用 nmake 工具可以自动根据此文件进行编译链接，nmake 工
具可以从 Visual C++ 的 bin 目录中找到，也可以从作者的网
站中下载。

3. 编译环境和编译方法

    建议使用命令行方式进行编译，以编译 Chapter02\Test
目录中 Test.asm 为例，步骤是：

   I.    打开一个“命令提示符”窗口。
   II.   进入环境设置批处理文件 Var.bat 所在目录并执行
         它，以后就可以使用这个“命令提示符”窗口编译
         文件了。

         x:                          <切换到MASM32安装的驱动器>
         cd \masm32\bin              <进入MASM32的执行目录>
         var                         <执行Var.bat设置环境变量>

   III.  进入源代码目录：

         cd \chapter02\test

   IV.   使用 nmake 工具进行编译链接：

         nmake

   V.    执行编译好的可执行文件。

    如果需要对源代码进行修改，不必关闭“命令提示符”窗口，
只要切换到编辑器窗口，在修改 *.asm 文件后重复进行第 IV 和
第 V 步骤即可。

＃ 特别注意：将光盘中的代码拷贝到硬盘后，必须将文件的只读属性去除！

4. 关于联机帮助文档

   Win32 汇编编程涉及很多 API 的使用，使用 .hlp、.chm 等
格式的联机帮助文件查找这些 API 的使用说明是很方便的，作者
的网站上提供了很详尽的联机文档下载，具体请访问：

   http://asm.yeah.net

5. 本光盘所包含目录的说明

根目录下的 *.pdf                   ;附录A、B、C的电子版文档

Chapter02\Test                     ;测试编译环境

Chapter03\HelloWorld               ;Hello World

Chapter04\FirstWindow              ;用Win32汇编写第一个窗口
Chapter04\FirstWindow-1            ;用Win32汇编写第一个窗口
Chapter04\SendMessage              ;窗口间的消息互发
Chapter04\SendMessage-1            ;窗口间的消息互发

Chapter05\Menu                     ;使用资源 - 使用菜单
Chapter05\Icon                     ;使用资源 - 使用图标
Chapter05\Dialog                   ;使用资源 - 使用对话框
Chapter05\Listbox                  ;使用资源 - 使用列表框
Chapter05\Control                  ;使用资源 - 使用子窗口控件
Chapter05\ShowVersionInfo          ;使用资源 - 显示版本信息资源的程序
Chapter05\VersionInfo              ;使用资源 - 使用版本信息资源

Chapter06\Timer                    ;定时器的使用

Chapter07\DcCopy                   ;在两个窗口的 DC 间互相拷贝屏幕
Chapter07\Clock                    ;模拟时钟程序
Chapter07\BmpClock                 ;用 Bitmap 图片做背景的模拟时钟程序
Chapter07\TestObject               ;一些常见的绘图操作

Chapter08\CommDlg                  ;使用通用对话框

Chapter09\Toolbar                  ;使用工具栏
Chapter09\StatusBar                ;使用状态栏
Chapter09\Richedit                 ;使用丰富编辑控件
Chapter09\Wordpad                  ;一个完整的文本编辑器例子
Chapter09\SubClass                 ;窗口的子类化例子
Chapter09\SuperClass               ;窗口的超类化例子

Chapter10\MemInfo                  ;显示当前内存的使用情况
Chapter10\Fragment                 ;内存碎片化的演示程序
Chapter10\FindFile                 ;全盘查找文件的例子
Chapter10\FormatText               ;文件读写例子
Chapter10\FormatText\FileMap       ;使用内存映射文件进行文件读写的例子
Chapter10\MMFShare                 ;使用内存映射文件进行进程间数据共享

Chapter11\Dll\Dll                  ;最简单的动态链接库例子 - 编写 DLL
Chapter11\Dll\MASM Sample          ;最简单的动态链接库例子 - 使用 DLL
Chapter11\Dll\VC++ Sample          ;最简单的动态链接库例子 - 在VC++中使用汇编编写的DLL
Chapter11\KeyHook                  ;Windows 钩子的例子 - 监听键盘动作
Chapter11\RecHook                  ;Windows 日志记录钩子的例子 - 监听键盘动作

Chapter12\Counter                  ;有问题的程序 - 一个计数程序
Chapter12\Thread                   ;用多线程的方式解决上一个程序的问题
Chapter12\Event                    ;使用事件对象
Chapter12\ThreadSynErr             ;一个存在同步问题的多线程程序
Chapter12\ThreadSyn\UseCriticalSection       ;使用临界区对象解决多线程同步问题
Chapter12\ThreadSyn\UseEvent       ;使用事件对象解决多线程同步问题
Chapter12\ThreadSyn\UseMutex       ;使用互斥对象解决多线程同步问题
Chapter12\ThreadSyn\UseSemaphore   ;使用信号灯对象解决多线程同步问题

Chapter13\CmdLine                  ;使用命令行参数
Chapter13\Process                  ;创建进程的例子
Chapter13\ProcessList              ;显示系统中运行的进程列表
Chapter13\Patch1                   ;一个内存补丁程序
Chapter13\Patch2                   ;一个内存补丁程序
Chapter13\Patch3                   ;一个内存补丁程序
Chapter13\HideProcess9x            ;Windows 9x下的进程隐藏
Chapter13\RemoteThreadDll          ;用 DLL 注入的方法实现远程进程
Chapter13\RemoteThread             ;不依靠任何外部文件实现远程进程

Chapter14\TopHandler               ;使用筛选器处理异常
Chapter14\SEH01                    ;最基本结构化异常处理例子
Chapter14\SEH02                    ;改进后的结构化异常处理例子
Chapter14\Unwind                   ;异常处理中的展开操作例子

Chapter15\Ini                      ;使用 INI 文件
Chapter15\Reg                      ;操作注册表的例子
Chapter15\Associate                ;操作注册表实现文件关联

Chapter16\TcpEcho                  ;实现 TCP 服务器端的简单例子
Chapter16\Chat-TCP                 ;用 TCP 协议实现的聊天室例子

Chapter17\PeInfo                   ;查看 PE 文件的基本信息
Chapter17\Import                   ;查看 PE 文件的导入表
Chapter17\Export                   ;查看 PE 文件的导出表
Chapter17\Resource                 ;查看 PE 文件的资源列表
Chapter17\Reloc                    ;查看 PE 文件的重定位信息
Chapter17\NoImport                 ;不使用导入表调用 API 函数
Chapter17\AddCode                  ;在 PE 文件上附加可执行代码的例子

Chapter18\OdbcSample               ;用ODBC操作数据库的例子

Appendix A\EchoLine                 ;控制台输入输出的例子

Appendix B\MsgWindow01             ;消息机制试验 1
Appendix B\MsgWindow02             ;消息机制试验 2
Appendix B\MsgWindow03             ;消息机制试验 3
Appendix B\MsgWindow04             ;消息机制试验 4

Appendix C\BrowseFolder            ;浏览目录对话框

6. 联系作者

    虽然本书中所有的例子代码都已经在Windows 98、Windows 2000
和Windows XP下测试通过，但也有存在Bug的可能，如果发现代码存
在错误或者有其它问题，请告知作者，联系方法：

    给作者发 E-mail：luoyunbin@hz.cn 或 luoyunbin@sina.com
    从作者的主页上可以找到最新有效的邮箱地址：http://asm.yeah.net


    感谢您的支持！

                                            作者：罗云彬
