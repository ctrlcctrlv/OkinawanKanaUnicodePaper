all:
	xelatex oki.tex
	inkscape --export-filename=oki.svg --pdf-poppler oki.pdf
	cairosvg -f svg oki.svg > oki2.svg
	sed -e 's/\.[[:digit:]]\+\%/\%/g' -i oki2.svg
