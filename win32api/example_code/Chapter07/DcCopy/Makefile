NAME = DcCopy
OBJS = $(NAME).obj
RES  = $(NAME).res

LINK_FLAG = /subsystem:windows
ML_FLAG = /c /coff

$(NAME).exe: $(OBJS)
	Link $(LINK_FLAG) $(OBJS)

.asm.obj:
	ml $(ML_FLAG) $<

clean:
	del *.obj
