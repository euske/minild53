# Makefile
RSYNC=/usr/bin/rsync \
	--exclude NOBACKUP/ \
	--exclude LOCAL/ \
	--exclude local/ \
	--exclude tmp/ \
	--exclude obj/ \
	--exclude screenshots/ \
	--exclude Makefile \
	--exclude '.??*' \
	--exclude '*.bak' \
	--exclude '*~'

WWWBASE=tabesugi:public/file/ludumdare.tabesugi.net/minild53

all: 

upload: bin
	$(RSYNC) -rutv bin/ $(WWWBASE)/
