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

  * [grammar Editors](#grammar-editors)

  * [Some useful variables](#some-useful-variables)

    * [$GUI_EDITOR](#gui_editor)

    * [$VISUAL](#visual)

    * [$EDITOR](#editor)

    * [@GUIEDITORS](#guieditors-2)

    * [@gui-editors](#gui-editors)

    * [@default-editors](#default-editors)

    * [@override-gui_editor](#override-gui_editor)

    * [$override-GUI_EDITOR](#override-gui_editor-1)

      * [In **`init-gui-editors`**](#in-init-gui-editors)

    * [$editor](#editor-1)

  * [edit-configs()](#edit-configs)

  * [Editor functions](#editor-functions)

    * [list-editors(…)](#list-editors)

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

Some useful variables
---------------------

**NB: All these variables are available outside of the module as a sub of the same name. That way I can give read only access to them.**

### $GUI_EDITOR

The value of the **`%*ENV«GUI_EDITOR»`** environment variable or **`''`** if not set.

### $VISUAL

The value of the **`%*ENV«VISUAL»`** environment variable or **`''`** if not set.

### $EDITOR

The value of the **`%*ENV«EDITOR»`** environment variable or **`''`** if not set.

```raku
my Str:D $GUI_EDITOR = ((%*ENV<GUI_EDITOR>:exists) ?? ~%*ENV<GUI_EDITOR> !! '');
my Str:D $VISUAL     = ((%*ENV<VISUAL>:exists) ?? ~%*ENV<VISUAL> !! '');
my Str:D $EDITOR     = ((%*ENV<EDITOR>:exists) ?? ~%*ENV<EDITOR> !! '');

sub GUI_EDITOR( --> Str:D) is export {
    return $GUI_EDITOR;
}

sub VISUAL( --> Str:D) is export {
    return $VISUAL;
}

sub EDITOR( --> Str:D) is export {
    return $EDITOR;
}
```

[Top of Document](#table-of-contents)

### @GUIEDITORS

The Array of Hashes that the **`Editors`** grammar and **`EditorsActions`** generate from parsing the **editors** file.

### @gui-editors

The Array of GUI Editors defined in the **editors** file.

### @default-editors

The array of **editors** selected in the file should have only **one** element otherwise the file is miss configured.

```raku
my Hash @GUIEDITORS;
my Str:D @gui-editors;
my Str:D @default-editors;

sub GUIEDITORS( --> Array[Hash]) is export {
    return @GUIEDITORS;
}

sub gui-editors( --> Array[Str:D]) is export {
    return @gui-editors;
}

sub default-editors( --> Array[Str:D]) is export {
    return @default-editors;
}
```

[Top of Document](#table-of-contents)

### @override-gui_editor

An array of **True** values one for each of the times the **`override GUI_EDITOR`** directive appears in the **editors** file, it is an error for it to appear more than once, (it's a zero or one rule).

### $override-GUI_EDITOR

True if the **`override GUI_EDITOR`** directive is present in the **editors** file. If **True** then the setting in the file overrides the **`%*ENV«GUI_EDITOR»`** variable, otherwise **`%*ENV«GUI_EDITOR»`** wins.

```raku
my Bool:D @override-gui_editor;

sub override-gui_editor( --> Array[Bool:D]) is export {
    return @override-gui_editor;
}

my Bool:D $override-GUI_EDITOR = False;

sub override-GUI_EDITOR( --> Bool:D) is export {
    return $override-GUI_EDITOR;
}
```

[Top of Document](#table-of-contents)

#### In **`init-gui-editors`** 

```raku
sub init-gui-editors(Str:D @client-config-files, Str:D $client-config-path,
                              &gen-configs:(Str:D, Str:D --> Bool:D),
                                  &check:(Str:D @cfg-files, Str:D $config --> Bool:D)
                                                                    --> Bool:D) is  export
```

...

...

...

```raku
@GUIEDITORS = Editors.parse(@editors-file.join("\x0A"), :enc('UTF-8'), :$actions).made;
@gui-editors = @GUIEDITORS.grep( -> %l { %l«type» eq 'config-line' } ).map: -> %ln { %ln«value»; };
@default-editors = @GUIEDITORS.grep( -> %l { %l«type» eq 'editor-to-use' } ).map: -> %ln { %ln«value»; };
if @default-editors > 1 {
    $*ERR.say: "Error: file $editor-config/editors is miss configured  more than one editor defined should be 0 or 1";
}
@override-gui_editor = @GUIEDITORS.grep( -> %l { %l«type» eq 'override-gui_editor' } ).map: -> %ln { %ln«value»; };
if @override-gui_editor > 1 {
    my Int:D $elems = @override-gui_editor.elems;
    $*ERR.say: qq[Make up your mind only one "override GUI_EDITOR" is required, you supplied $elems are you insane???];
    $override-GUI_EDITOR = True;
} elsif @override-gui_editor == 1 {
    $override-GUI_EDITOR = True;
}
if @gui-editors {
    #@gui-editors.raku.say;
    for @gui-editors -> $geditor {
        if !@guieditors.grep: { $geditor } {
            my Str $guieditor = $geditor;
            $guieditor .=trim;
            @guieditors.append($guieditor);
        }
    }
}

if $override-GUI_EDITOR && @default-editors {
    $editor = @default-editors[@default-editors - 1];
}elsif %*ENV<GUI_EDITOR>:exists {
    my Str $guieditor = ~%*ENV<GUI_EDITOR>;
    if ! @guieditors.grep( { $_ eq $guieditor.IO.basename } ) {
        @guieditors.prepend($guieditor.IO.basename);
    }
} elsif $editor-guessed && @default-editors {
    $editor = @default-editors[@default-editors - 1];
}
```

[Top of Document](#table-of-contents)

### $editor

The editor the user has chosen.

```raku
# the editor to use #
my Str:D $editor = '';

sub editor( --> Str:D) is export {
    return $editor;
}
```

edit-configs()
--------------

A function to open the users configuration files in their chosen editor.

```raku
sub edit-configs() returns Bool:D is export {
    if $editor {
        my $option = '';
        my @args;
        my $edbase = $editor.IO.basename;
        if $edbase eq 'gvim' {
            $option = '-p';
            @args.append('-p');
        }
        for @config-files -> $file {
            if $file eq 'editors' {
                @args.append("$editor-config/$file");
            } else {
                @args.append("$client-config/$file");
            }
        }
        my $proc = run($editor, |@args);
        return $proc.exitcode == 0 || $proc.exitcode == -1;
    } else {
        $*ERR.say: "no editor found please set GUI_EDITOR, VISUAL or EDITOR to your preferred editor.";
        $*ERR.say: "e.g. export GUI_EDITOR=/usr/bin/gvim";
        $*ERR.say: "or set editor in the $editor-config/editors file this can be done with the set editor command.";
        $*ERR.say: qq[NB: the editor will be set by first checking GUI_EDITOR then VISUAL then EDITOR and
                    finally editor in the config file so GUI_EDITOR will win over all.
                    Unless you supply the "override GUI_EDITOR" directive in the $editor-config/editors file
                    and also supplied the "editor := <editor>" directive];
        return False;
    }
}
```

[Top of Document](#table-of-contents)

Editor functions
----------------

### list-editors(…)

List all known GUI Editors, flagging the selected editor with **'*'** note if none is flagged either **`$editor`** is set to a none GUI Editor or **`$editor`** is set to the empty string.

