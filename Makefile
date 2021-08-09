.PHONY: all clean web

BOARDS = flashpi
GITREPO = https://github.com/neg2led/flashpi.git
JLCFAB_IGNORE = JSPI1,SPI1,JI2C1,I2C1,J1,H1,H2,H3,H4

BOARDSFILES = $(addprefix build/, $(BOARDS:=.kicad_pcb))
SCHFILES = $(addprefix build/, $(BOARDS:=.sch))
GERBERS = $(addprefix build/, $(BOARDS:=-gerber.zip))
JLCGERBERS = $(addprefix build/, $(BOARDS:=-jlcpcb.zip))

RADIUS=1

all: $(GERBERS) $(JLCGERBERS) build/web/index.html

build/flashpi.kicad_pcb: flashpi/flashpi.kicad_pcb build
	kikit panelize extractboard -s 125 75 65 57 $< $@

build/flashpi.sch: flashpi/flashpi.kicad_pcb build
	cp flashpi/flashpi.sch $@

%-gerber: %.kicad_pcb
	kikit export gerber $< $@

%-gerber.zip: %-gerber
	zip -j $@ `find $<`

%-jlcpcb: %.sch %.kicad_pcb
	kikit fab jlcpcb --assembly --ignore $(JLCFAB_IGNORE) --schematic $^ $@

%-jlcpcb.zip: %-jlcpcb
	zip -j $@ `find $<`

web: build/web/index.html

build:
	mkdir -p build

build/web: build
	mkdir -p build/web

build/web/index.html: build/web $(BOARDSFILES)
	kikit present boardpage \
		-d README.md \
		--name "Pi SPI/I2C ROM flasher HAT" \
		-b "Pi SPI/I2C ROM flasher HAT" "Board" build/flashpi.kicad_pcb  \
		-r "assets/flashpi.png" \
		--repository "$(GITREPO)"\
		build/web

clean:
	rm -r build
