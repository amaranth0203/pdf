OBJS = $(NAME).obj
RES  = $(NAME).res

LINK_FLAG = /subsystem:windows
ML_FLAG = /c /coff

Server.exe Client1.exe Client2.exe:

Server.exe: Server.obj Server.res
	Link $(LINK_FLAG) Server.obj Server.res
Client1.exe: Client1.obj Client.res
	Link $(LINK_FLAG) Client1.obj Client.res
Client2.exe: Client2.obj Client.res
	Link $(LINK_FLAG) Client2.obj Client.res

.asm.obj:
	ml $(ML_FLAG) $<
.rc.res:
	rc $<

clean:
	del *.obj
	del *.res
