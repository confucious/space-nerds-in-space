# To compile withaudio, WITHAUDIO=yes, 
# for no audio support, change to WITHAUDIO=no, 
WITHAUDIO=yes
# WITHAUDIO=no

PREFIX=/usr
DATADIR=${PREFIX}/share/space-nerds-in-space

CC=gcc

ifeq (${WITHAUDIO},yes)
SNDLIBS=`pkg-config --libs portaudio-2.0 vorbisfile`
SNDFLAGS=-DWITHAUDIOSUPPORT `pkg-config --cflags portaudio-2.0` -DDATADIR=\"${DATADIR}\"
OGGOBJ=ogg_to_pcm.o
SNDOBJS=wwviaudio.o
else
SNDLIBS=
SNDFLAGS=-DWWVIAUDIO_STUBS_ONLY
OGGOBJ=
SNDOBJS=wwviaudio.o
endif

ifeq (${E},1)
STOP_ON_WARN=-Werror
else
STOP_ON_WARN=
endif

ifeq (${O},1)
DEBUGFLAG=
OPTIMIZEFLAG=-O3
else
DEBUGFLAG=-g
OPTIMIZEFLAG=
endif



COMMONOBJS=mathutils.o snis_alloc.o snis_socket_io.o snis_marshal.o \
		bline.o shield_strength.o stacktrace.o
SERVEROBJS=${COMMONOBJS} snis_server.o names.o starbase-comms.o infinite-taunt.o \
		power-model.o

CLIENTOBJS=${COMMONOBJS} ${OGGOBJ} ${SNDOBJS} snis_ui_element.o snis_graph.o \
	snis_client.o snis_font.o snis_text_input.o \
	snis_typeface.o snis_gauge.o snis_button.o snis_label.o snis_sliders.o snis_text_window.o \
	snis_damcon_systems.o mesh.o \
	stl_parser.o entity.o matrix.o my_point.o liang-barsky.o joystick.o
SSGL=ssgl/libssglclient.a
LIBS=-Lssgl -lssglclient -lrt -lm

PROGS=snis_server snis_client

MODELS=freighter.stl laser.stl planet.stl spaceship.stl starbase.stl torpedo.stl \
	tanker.stl destroyer.stl transport.stl battlestar.stl cruiser.stl tetrahedron.stl \
	flat-tetrahedron.stl big-flat-tetrahedron.stl asteroid.stl asteroid2.stl asteroid3.stl \
	asteroid4.stl wormhole.stl starbase2.stl starbase3.stl starbase4.stl spacemonster.stl \
	asteroid-miner.stl spaceship2.stl spaceship3.stl planet1.stl planet2.stl planet3.stl

MYCFLAGS=${DEBUGFLAG} ${OPTIMIZEFLAG} --pedantic -Wall ${STOP_ON_WARN} -pthread -std=gnu99 -rdynamic
GTKCFLAGS=`pkg-config --cflags gtk+-2.0`
GTKLDFLAGS=`pkg-config --libs gtk+-2.0` \
        `pkg-config --libs gthread-2.0`
VORBISFLAGS=`pkg-config --cflags vorbisfile`

ifeq (${V},1)
Q=
ECHO=true
else
Q=@
ECHO=echo
endif

COMPILE=$(CC) ${MYCFLAGS} -c -o $@ $< ; $(ECHO) '  COMPILE' $<
GTKCOMPILE=$(CC) ${MYCFLAGS} ${GTKCFLAGS} -c -o $@ $< ; $(ECHO) '  COMPILE' $<
VORBISCOMPILE=$(CC) ${MYCFLAGS} ${VORBISFLAGS} ${SNDFLAGS} -c -o $@ $< ; $(ECHO) '  COMPILE' $<

CLIENTLINK=$(CC) ${MYCFLAGS} ${SNDFLAGS} -o $@ ${GTKCFLAGS}  ${CLIENTOBJS} ${GTKLDFLAGS} ${LIBS} ${SNDLIBS} ; $(ECHO) '  LINK' $@
SERVERLINK=$(CC) ${MYCFLAGS} -o $@ ${GTKCFLAGS} ${SERVEROBJS} ${GTKLDFLAGS} ${LIBS} ; $(ECHO) '  LINK' $@
OPENSCAD=openscad -o $@ $< ; $(ECHO) '  OPENSCAD' $<

all:	${COMMONOBJS} ${SERVEROBJS} ${CLIENTOBJS} ${PROGS} ${MODELS}

starbase.stl:	starbase.scad wedge.scad
	$(Q)$(OPENSCAD)

%.stl:	%.scad
	$(Q)$(OPENSCAD)

my_point.o:   my_point.c my_point.h Makefile
	$(Q)$(COMPILE)

mesh.o:   mesh.c mesh.h Makefile
	$(Q)$(COMPILE)

power-model.o:   power-model.c power-model.h Makefile
	$(Q)$(COMPILE)

stacktrace.o:   stacktrace.c stacktrace.h Makefile
	$(Q)$(COMPILE)

liang-barsky.o:   liang-barsky.c liang-barsky.h Makefile
	$(Q)$(COMPILE)

joystick.o:   joystick.c joystick.h compat.h Makefile 
	$(Q)$(COMPILE)

ogg_to_pcm.o:   ogg_to_pcm.c ogg_to_pcm.h Makefile
	$(Q)$(VORBISCOMPILE)

bline.o:	bline.c bline.h
	$(Q)$(COMPILE)

wwviaudio.o:    wwviaudio.c wwviaudio.h ogg_to_pcm.h my_point.h Makefile
	$(Q)$(VORBISCOMPILE)

shield_strength.o:	shield_strength.c shield_strength.h
	$(Q)$(COMPILE)

snis_server.o:	snis_server.c snis.h snis_packet.h snis_marshal.h sounds.h starbase-comms.h
	$(Q)$(COMPILE)

snis_client.o:	snis_client.c snis.h snis_font.h my_point.h snis_packet.h snis_marshal.h sounds.h wwviaudio.h snis-logo.h placeholder-system-points.h
	$(Q)$(GTKCOMPILE)

snis_socket_io.o:	snis_socket_io.c snis_socket_io.h
	$(Q)$(COMPILE)

snis_marshal.o:	snis_marshal.c snis_marshal.h
	$(Q)$(COMPILE)

snis_font.o:	snis_font.c snis_font.h my_point.h
	$(Q)$(COMPILE)

mathutils.o:	mathutils.c mathutils.h
	$(Q)$(COMPILE)

snis_alloc.o:	snis_alloc.c snis_alloc.h
	$(Q)$(COMPILE)

snis_damcon_systems.o:	snis_damcon_systems.c snis_damcon_systems.h
	$(Q)$(COMPILE)

# snis_server:	${SERVEROBJS} ${SSGL}
#	$(CC) ${MYCFLAGS} -o snis_server ${GTKCFLAGS} ${SERVEROBJS} ${GTKLDFLAGS} ${LIBS}

snis_server:	${SERVEROBJS} ${SSGL}
	$(Q)$(SERVERLINK)

snis_client:	${CLIENTOBJS} ${SSGL}
	$(Q)$(CLIENTLINK)

#	$(CC) ${MYCFLAGS} ${SNDFLAGS} -o snis_client ${GTKCFLAGS}  ${CLIENTOBJS} ${GTKLDFLAGS} ${LIBS} ${SNDLIBS}

starbase-comms.o:	starbase-comms.c starbase-comms.h
	$(Q)$(COMPILE)	

infinite-taunt.o:	infinite-taunt.c infinite-taunt.h
	$(Q)$(COMPILE)

infinite-taunt:	infinite-taunt.c infinite-taunt.h
	$(CC) -DTEST_TAUNT -o infinite-taunt ${MYCFLAGS} infinite-taunt.c

names:	names.c names.h
	$(CC) -DTEST_NAMES -o names ${MYCFLAGS} ${GTKCFLAGS} names.c

snis_graph.o:	snis_graph.c snis_graph.h
	$(Q)$(GTKCOMPILE)

snis_typeface.o:	snis_typeface.c snis_typeface.h
	$(Q)$(GTKCOMPILE)

snis_gauge.o:	snis_gauge.c snis_gauge.h snis_graph.h
	$(Q)$(GTKCOMPILE)

snis_button.o:	snis_button.c snis_button.h snis_graph.h
	$(Q)$(GTKCOMPILE)

snis_label.o:	snis_label.c snis_label.h snis_graph.h
	$(Q)$(GTKCOMPILE)

snis_sliders.o:	snis_sliders.c snis_sliders.h snis_graph.h
	$(Q)$(GTKCOMPILE)

snis_text_window.o:	snis_text_window.c snis_text_window.h snis_graph.h \
			snis_font.h snis_typeface.h
	$(Q)$(GTKCOMPILE)

snis_ui_element.o:	snis_ui_element.c snis_ui_element.h
	$(Q)$(GTKCOMPILE)

snis_text_input.o:	snis_text_input.c snis_text_input.h
	$(Q)$(GTKCOMPILE)

matrix.o:	matrix.c matrix.h
	$(Q)$(COMPILE)

stl_parser.o:	stl_parser.c stl_parser.h vertex.h triangle.h mesh.h
	$(Q)$(COMPILE)

stl_parser:	stl_parser.o stl_parser.h vertex.h triangle.h mesh.h
	$(CC) -DTEST_STL_PARSER ${MYCFLAGS} ${GTKCFLAGS} -o stl_parser stl_parser.c -lm

entity.o:	entity.c entity.h mathutils.h vertex.h triangle.h mesh.h stl_parser.h snis_alloc.h
	$(Q)$(GTKCOMPILE)

names.o:	names.c names.h
	$(Q)$(COMPILE)

test_matrix:	matrix.c matrix.h
	$(CC) ${MYCFLAGS} ${GTKCFLAGS} -DTEST_MATRIX -o test_matrix matrix.c -lm

${SSGL}:
	(cd ssgl ; make )

clean:
	rm -f ${SERVEROBJS} ${CLIENTOBJS} ${PROGS} ${SSGL} stl_parser ${MODELS} 
	( cd ssgl; make clean )

