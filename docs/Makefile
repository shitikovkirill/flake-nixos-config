# Makefile for Sphinx documentation

.PHONY: help clean html dirhtml singlehtml pickle json htmlhelp qthelp devhelp epub latex latexpdf latexpdfja text man texinfo info gettext changes linkcheck doctest coverage livehtml

SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
PAPER         ?=
BUILDDIR      ?= _build

# User-friendly check for sphinx-build
ifeq ($(shell which $(SPHINXBUILD) >/dev/null 2>&1; echo $$?), 1)
$(error The '$(SPHINXBUILD)' command was not found. Make sure you have Sphinx installed, then set the SPHINXBUILD environment variable to point to the full path of the $(SPHINXBUILD) executable. Alternatively you can add a directory to the PATH environment variable so that the Sphinx executable is found by the Python interpreter.)
endif

# Internal variables
PAPEROPT_a4     = -D latex_paper_size=a4
PAPEROPT_letter = -D latex_paper_size=letter
ALLSPHINXOPTS   = -d $(BUILDDIR)/doctrees $(PAPEROPT_$(PAPER)) $(SPHINXOPTS)
I18N_SPHINXOPTS  = $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) .

help:
	@$(SPHINXBUILD) -M help "$(CURDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.DEFAULT: Makefile

clean:
	rm -rf $(BUILDDIR)/*

html:
	$(SPHINXBUILD) -b html $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/html"
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/html."

dirhtml:
	$(SPHINXBUILD) -b dirhtml $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/dirhtml"
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/dirhtml."

singlehtml:
	$(SPHINXBUILD) -b singlehtml $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/singlehtml"
	@echo
	@echo "Build finished. The HTML pages are in $(BUILDDIR)/singlehtml."

pickle:
	$(SPHINXBUILD) -b pickle $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/pickle"
	@echo
	@echo "Build finished; now you can process the pickle files."

json:
	$(SPHINXBUILD) -b json $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/json"
	@echo
	@echo "Build finished; now you can process the json files."

htmlhelp:
	$(SPHINXBUILD) -b htmlhelp $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/htmlhelp"
	@echo
	@echo "Build finished; now you can process the HTML help files."

qthelp:
	$(SPHINXBUILD) -b qthelp $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/qthelp"
	@echo
	@echo "Build finished; now you can process the qthelp files."

devhelp:
	$(SPHINXBUILD) -b devhelp $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/devhelp"
	@echo
	@echo "Build finished; now you can process the devhelp files."

epub:
	$(SPHINXBUILD) -b epub $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/epub"
	@echo
	@echo "Build finished. The epub file is in $(BUILDDIR)/epub."

latex:
	$(SPHINXBUILD) -b latex $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/latex"
	@echo
	@echo "Build finished; the LaTeX files are in $(BUILDDIR)/latex."

latexpdf:
	$(SPHINXBUILD) -b latexpdf $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/latex"
	@echo
	@echo "Build finished; the PDF files are in $(BUILDDIR)/latex."

latexpdfja:
	$(SPHINXBUILD) -b latexpdfja $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/latex"
	@echo
	@echo "Build finished; the PDF files are in $(BUILDDIR)/latex."

text:
	$(SPHINXBUILD) -b text $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/text"
	@echo
	@echo "Build finished. The text files are in $(BUILDDIR)/text."

man:
	$(SPHINXBUILD) -b man $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/man"
	@echo
	@echo "Build finished. The man pages are in $(BUILDDIR)/man."

texinfo:
	$(SPHINXBUILD) -b texinfo $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/texinfo"
	@echo
	@echo "Build finished. The texinfo files are in $(BUILDDIR)/texinfo."

info:
	$(SPHINXBUILD) -b texinfo $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/texinfo"
	@echo
	@echo "Build finished. The texinfo files are in $(BUILDDIR)/texinfo."
	@if test -d "$(BUILDDIR)/texinfo"; then \
		make -C "$(BUILDDIR)/texinfo" info; \
		@echo "Run \`make' in the build directory to run these through (pdf)makeinfo."; \
	fi

gettext:
	$(SPHINXBUILD) -b gettext $(I18N_SPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/gettext"
	@echo
	@echo "Build finished. The pot files are in $(BUILDDIR)/gettext."

changes:
	$(SPHINXBUILD) -b changes $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/changes"
	@echo
	@echo "The overview file is in $(BUILDDIR)/changes."

linkcheck:
	$(SPHINXBUILD) -b linkcheck $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/linkcheck"
	@echo
	@echo "Link check complete; look for any errors in the above output or in $(BUILDDIR)/linkcheck/output.txt."

doctest:
	$(SPHINXBUILD) -b doctest $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/doctest"
	@echo
	@echo "Testing of doctests in the sources finished, look at the results in $(BUILDDIR)/doctest/doctest.log."

coverage:
	$(SPHINXBUILD) -b coverage $(ALLSPHINXOPTS) "$(CURDIR)" "$(BUILDDIR)/coverage"
	@echo
	@echo "Testing of coverage in the sources finished, look at the results in $(BUILDDIR)/coverage/python.txt."

%: Makefile
	@$(SPHINXBUILD) -M $@ "$(CURDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
