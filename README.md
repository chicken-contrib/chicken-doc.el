## About

Easy documentation lookup for [CHICKEN Scheme] in Emacs.

## Installation

Make sure that [chicken-doc] is installed first.  Install the package
manually for the time being.

## Usage

Add the following to your init file:

    (with-eval-after-load 'scheme
      (define-key scheme-mode-map (kbd "C-c C-d") 'chicken-doc-describe))

You can now look up documentation in Scheme files with `C-c C-d`.  Use
the prefix argument for regexp matches.

## Customization

If `chicken-doc` cannot be found on `PATH`, consider customizing
`chicken-doc-command`.

## Alternatives

The basic functionality is contained in [chicken.el].

[CHICKEN Scheme]: https://call-cc.org
[chicken-doc]: https://wiki.call-cc.org/eggref/5/chicken-doc
[chicken.el]: http://code.call-cc.org/cgi-bin/gitweb.cgi?p=chicken-core.git;a=blob_plain;f=misc/chicken.el;hb=HEAD
