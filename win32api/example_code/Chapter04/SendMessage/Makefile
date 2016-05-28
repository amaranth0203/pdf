LINK_FLAG = /subsystem:windows
ML_FLAG = /c /coff

all: Send.exe Receive.exe

Send.exe: Send.obj
	Link $(LINK_FLAG) Send.obj
Receive.exe: Receive.obj
	Link $(LINK_FLAG) Receive.obj

.asm.obj:
	ml $(ML_FLAG) $<

clean:
	del *.obj
