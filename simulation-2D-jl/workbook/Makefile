CHAPTERS = 01_euler 02_rk4 03_atmosphere 04_physics_2d 05_gravity_turn 06_staging 07_visualization

all: $(foreach ch,$(CHAPTERS),$(ch)/theory.pdf)

%/theory.pdf: %/theory.tex preamble.tex
	cd $* && pdflatex -interaction=nonstopmode theory.tex > /dev/null 2>&1
	cd $* && pdflatex -interaction=nonstopmode theory.tex > /dev/null 2>&1
	@echo "  ✓  $@"

clean:
	for ch in $(CHAPTERS); do \
	  rm -f $$ch/theory.aux $$ch/theory.log $$ch/theory.out $$ch/theory.toc; \
	done

distclean: clean
	for ch in $(CHAPTERS); do rm -f $$ch/theory.pdf; done

.PHONY: all clean distclean
