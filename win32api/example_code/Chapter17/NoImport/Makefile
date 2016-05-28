NAME = NoImport
OBJS = $(NAME).obj

LINK_FLAG = /subsystem:windows
ML_FLAG = /c /coff

$(NAME).exe: $(OBJS)
	Link $(LINK_FLAG) $(OBJS)
$(OBJS): _GetKernel.asm
	ml $(ML_FLAG) $(NAME).asm

clean:
	del *.obj
