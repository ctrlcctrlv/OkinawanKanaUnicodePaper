SUFFIX = ''

.PHONY:
all:
	xelatex oki${SUFFIX}.tex
	inkscape \
		--actions='select-all;'"$$(for i in `seq 1 100`; do echo 'selection-ungroup;'; done)"';select-all;object-to-path'\
		--export-filename=oki${SUFFIX}.svg --pdf-poppler oki${SUFFIX}.pdf
	cairosvg -f svg oki${SUFFIX}.svg > oki2${SUFFIX}.svg
	sed -e 's/\.[[:digit:]]\+\%/\%/g' -i oki2${SUFFIX}.svg
	$(NOSILE) || sile okana.sil
