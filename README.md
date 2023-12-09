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

