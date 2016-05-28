EXE = Test.exe		#指定输出文件
OBJS = Test.obj		#需要的目标文件
RES = Test.res		#需要的资源文件

LINK_FLAG = /subsystem:windows	#连接选项
ML_FLAG = /c /coff		#编译选项

$(EXE): $(OBJS) $(RES)
	Link $(LINK_FLAG) $(OBJS) $(RES)

.asm.obj:
	ml $(ML_FLAG) $<
.rc.res:
	rc $<

clean:
	del *.obj
	del *.res
