GUI::Editors
============

Table of Contents
-----------------

  * [NAME](#name)

  * [AUTHOR](#author)

  * [VERSION](#version)

  * [TITLE](#title)

  * [SUBTITLE](#subtitle)

  * [COPYRIGHT](#copyright)

  * [Introduction](#introduction)

  * [$editor-config](#editor-config)

  * [@config-files](#config-files)

  * [Introduction](#introduction)

  * [Introduction](#introduction)

  * [Introduction](#introduction)

  * [Introduction](#introduction)

NAME
====

GUI::Editors 

AUTHOR
======

Francis Grizzly Smit (grizzly@smit.id.au)

VERSION
=======

0.1.0

TITLE
=====

GUI::Editors

SUBTITLE
========

A Raku module for managing the users GUI Editor preferences in a variety of programs.

[Top of Document](#table-of-contents)

Introduction
============

A **Raku** module for managing the users GUI Editor preferences in a variety of programs. 

$editor-config
--------------

A constant which contains the location of the users editors file

```raku
# the home dir #
constant $home = %*ENV<HOME>.Str();

# config files
constant $editor-config is export = "$home/.local/share/gui-editors";
```

**NB: the `$home` is the value of the users HOME environment variable.**

[Top of Document](#table-of-contents)

@config-files
-------------

An array containing the configuration files of the program, by default it is set to contain **editors** the editors configuration file the remainder should be added by **`init-gui-editors(...)`** the initialization procedure for the module.

```raku
# The config files to test for #
my Str:D @config-files = qw{editors};

sub config-files( --> Array[Str:D]) is export {
    return @config-files;
}
```

@guieditors
-----------

An array of known **GUI** editors. 

```raku
my Str:D @guieditors;

sub guieditors( --> Array[Str:D]) is export {
    return @guieditors;
}
```

[Top of Document](#table-of-contents)

grammar Editors
---------------

```raku
grammar Editors is export {
    regex TOP                 { [ <line> [ \v+ <line> ]* \v* ]? }
    regex line                { [ <white-space-line> || <override-gui_editor> || <config-line> || <editor-to-use> || <comment-line> ] }
    regex white-space-line    { ^^ \h* $$ }
    regex override-gui_editor { ^^ \h* 'override' \h+ 'GUI_EDITOR' \h* $$ }
    regex comment-line        { ^^ \h* '#' <-[\v]>* $$ }
    regex config-line         { ^^ \h* 'guieditors' \h* '+'? '=' \h* <editor> \h* [ '#' <comment> \h* ]? $$ }
    regex editor-to-use       { ^^ \h* 'editor' \h* ':'? '=' \h* <editor> \h* [ '#' <comment> \h* ]? $$ }
    regex editor              { <editor-name> || <path> <editor-name> }
    regex comment             { <-[\n]>* }
    regex path                { <lead-in>  <path-segments>? }
    regex lead-in             { [ '/' | '~' | '~/' ] }
    regex path-segments       { <path-segment> [ '/' <path-segment> ]* '/' }
    token path-segment        { [ <with-space-in-it> || <with-other-stuff> ] }
    token with-space-in-it    { \w+ [ ' ' \w+ ]* }
    token with-other-stuff    { <start-other-stuff> <tail-other-stuff>* }
    token start-other-stuff   { \w+ }
    token tail-other-stuff    { <other-stuff>+ <tails-tail>? }
    token tails-tail          { \w+ }
    token other-stuff         { [ '-' || '+' || ':' || '@' || '=' || ',' || '&' || '%' || '.' ] }
    token editor-name         { <with-other-stuff> }
}

class EditorsActions is export {
    ...
    ...
    ...
    method TOP($made) {
        my @top = $made<line>».made;
        $made.make: @top;
    }
} # class EditorsActions #
```

[Top of Document](#table-of-contents)

