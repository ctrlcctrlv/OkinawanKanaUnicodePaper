SUFFIX = ''

.PHONY:
all:
	xelatex oki${SUFFIX}.tex
	inkscape --export-filename=oki${SUFFIX}.svg --pdf-poppler oki${SUFFIX}.pdf
	cairosvg -f svg oki${SUFFIX}.svg > oki2${SUFFIX}.svg
	sed -e 's/\.[[:digit:]]\+\%/\%/g' -i oki2${SUFFIX}.svg
