PKGDIR  := ./packages
EMACS_COMMAND   ?= emacs
EVAL := $(EMACS_COMMAND)

## Check for needing to initialize CL-LIB from ELPA
NEED_CL-LIB := $(shell $(EMACS_COMMAND) --no-site-file --batch --eval '(prin1 (version< emacs-version "24.3"))')
ifeq ($(NEED_CL-LIB), t)
	EMACS_COMMAND := $(EMACS_COMMAND) --eval "(package-initialize)"
endif

EMACS_BATCH := $(EMACS_COMMAND) --no-site-file --batch 

all: mirror

mirror:
	$(EMACS_BATCH) -l elpa-mirror.el --eval '(elpa-mirror)'
	@echo " • Updating $@ ..."
	$(EMACS_BATCH) -l package-build.el --eval '(package-build-dump-archive-contents)'
