NAME = Main
OBJS = $(NAME).obj
RES  = $(NAME).res

LINK_FLAG = /subsystem:windows
ML_FLAG = /c /coff

$(NAME).exe: $(OBJS) $(RES)
	Link $(LINK_FLAG) $(OBJS) $(RES)

$(NAME).obj: _ProcessPeFile.asm
	ml $(ML_FLAG) $(NAME).asm

.rc.res:
	rc $<

clean:
	del *.obj
	del *.res
