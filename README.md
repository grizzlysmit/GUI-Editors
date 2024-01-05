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

  * [grammar Editors & action class EditorsActions](#grammar-editors--action-class-editorsactions)

  * [grammar EditorLine & class EditorLineActions](#grammar-editorline--class-editorlineactions)

  * [grammar OverrideGUIEditor & actions class OverrideGUIEditorActions](#grammar-overrideguieditor--actions-class-overrideguieditoractions)

  * [Some useful variables](#some-useful-variables)

    * [$GUI_EDITOR](#gui_editor)

      * [$GUI_EDITOR](#gui-editor)

    * [$VISUAL](#visual)

    * [$EDITOR](#editor)

    * [@GUIEDITORS](#guieditors-2)

    * [@gui-editors](#gui-editors)

    * [@default-editors](#default-editors)

    * [@override-gui_editor](#override-gui_editor) or [on raku.land @override-gui_editor](#override-gui-editor)

    * [$override-GUI_EDITOR](#override-gui_editor-1) or [on raku.land $override-GUI_EDITOR](#override-gui-editor-1)

      * [In **`init-gui-editors`**](#in-init-gui-editors)

    * [$editor](#editor-1)

  * [edit-configs()](#edit-configs)

  * [Editor functions](#editor-functions)

    * [list-editors(…)](#list-editors)

    * [editors-stats(…)](#editors-stats)

    * [BadEditor](#badeditor)

    * [set-editor](#set-editor)

    * [add-gui-editor(…)](#add-gui-editor)

    * [set-override-GUI_EDITOR(…)](#set-override-gui_editor) or [on raku.land set-override-GUI_EDITOR(…)](#set-override-gui-editor)

    * [backup-editors(…)](#backup-editors)

    * [restore-editors(…)](#restore-editors)

    * [list-editors-backups(…)](#list-editors-backups)

    * [backups-menu-restore-editors(…)](#backups-menu-restore-editors)

    * [edit-files(…)](#edit-files)

NAME
====

GUI::Editors 

AUTHOR
======

Francis Grizzly Smit (grizzly@smit.id.au)

VERSION
=======

0.1.12

TITLE
=====

GUI::Editors

SUBTITLE
========

A Raku module for managing the users GUI Editor preferences in a variety of programs.

COPYRIGHT
=========

LGPL V3.0+ [LICENSE](https://github.com/grizzlysmit/GUI-Editors/blob/main/LICENSE)

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

grammar Editors & action class EditorsActions
---------------------------------------------

```raku
grammar Editors is BasePaths is export {
    regex TOP                 { [ <line> [ \v+ <line> ]* \v* ]? }
    regex line                { [ <white-space-line> || <override-gui_editor> || <config-line> || <editor-to-use> || <comment-line> ] }
    regex white-space-line    { ^^ \h* $$ }
    regex override-gui_editor { ^^ \h* 'override' \h+ 'GUI_EDITOR' [ \h+ '#' <comment> ]? \h* $$ }
    regex comment-line        { ^^ \h* '#' <-[\v]>* $$ }
    regex config-line         { ^^ \h* 'guieditors' \h* '+'? '=' \h* <editor> \h* [ '#' <comment> \h* ]? $$ }
    regex editor-to-use       { ^^ \h* 'editor' \h* ':'? '=' \h* <editor> \h* [ '#' <comment> \h* ]? $$ }
    regex editor              { <editor-name> || <base-path> <editor-name> }
    regex comment             { <-[\n]>* }
    token editor-name         { <with-other-stuff> }
}

class EditorsActions does BasePathsActions is export {
    method white-space-line($/) {
        my %wspln = type => 'white-space-line', value => ~$/;
        make %wspln;
    }
    method comment-line($/) {
        my %comln = type => 'comment-line', value => ~$/;
        make %comln;
    }
    #token editor-name         { <with-other-stuff> }
    method editor-name($/) {
        my $edname = $/<with-other-stuff>.made;
        make $edname;
    }
    method editor($/) {
        my $ed-name;
        if $/<base-path> {
            $ed-name = $/<base-path>.made ~ $/<editor-name>.made;
        } else {
            $ed-name = $/<editor-name>.made;
        }
        make $ed-name;
    }
    method comment($/) {
        my $comm = (~$/).trim;
        make $comm;
    }
    method config-line($/) {
        my %cfg-line = type => 'config-line', value => $/<editor>.made;
        if $/<comment> {
            my $com = $/<comment>.made;
            %cfg-line«comment» = $com;
        }
        make %cfg-line;
    }
    method editor-to-use($/) {
        my %editor-to-use = type => 'editor-to-use', value => $/<editor>.made;
        if $/<comment> {
            my $com = $/<comment>.made;
            %editor-to-use«comment» = $com;
        }
        make %editor-to-use;
    }
    method override-gui_editor($/) {
        my %override-gui_editor = type => 'override-gui_editor', :value;
        if $/<comment> {
            my $com = $/<comment>.made;
            %override-gui_editor«comment» = $com;
        }
        make %override-gui_editor;
    }
    method line($/) {
        my %ln;
        if $/<white-space-line> {
            %ln = $/<white-space-line>.made;
        } elsif $/<comment-line> {
            %ln = $/<comment-line>.made;
        } elsif $/<config-line> {
            %ln = $/<config-line>.made;
        } elsif $/<editor-to-use> {
            %ln = $/<editor-to-use>.made;
        } elsif $/<override-gui_editor> {
            %ln = $/<override-gui_editor>.made;
        }
        make %ln;
    }
    method TOP($made) {
        my @top = $made<line>».made;
        $made.make: @top;
    }
} # class EditorsActions does BasePathsActions is export #
```

[Top of Document](#table-of-contents)

### grammar EditorLine & class EditorLineActions

A grammar and associated action class to parse and recognise the **`editor := value # comment`** lines in the **editors** file.

```raku
grammar EditorLine is BasePaths is export {
    regex TOP                 { ^ \h* 'editor' \h* ':'? '=' \h* <editor> \h* [ '#' <comment> \h* ]? $ }
    regex editor              { <editor-name> || <base-path> <editor-name> }
    regex comment             { <-[\n]>* }
    token editor-name         { <with-other-stuff> }
}

class EditorLineActions does BasePathsActions is export {
    #token editor-name         { <with-other-stuff> }
    method editor-name($/) {
        my $edname = $/<with-other-stuff>.made;
        make $edname;
    }
    method editor($/) {
        my $ed-name;
        if $/<base-path> {
            $ed-name = $/<base-path>.made ~ '/' ~ $/<editor-name>.made;
        } else {
            $ed-name = $/<editor-name>.made;
        }
        make $ed-name;
    }
    method comment($/) {
        my $comm = (~$/).trim;
        make $comm;
    }
    method config-line($/) {
        my %cfg-line = type => 'config-line', value => $/<editor>.made;
        if $/<comment> {
            my $com = $/<comment>.made;
            %cfg-line«comment» = $com;
        }
        make %cfg-line;
    }
    method TOP($made) {
        my %top = type => 'editor-to-use', value => $made<editor>.made;
        if $made<comment> {
            my $com = $made<comment>.made;
            %top«comment» = $com;
        }
        $made.make: %top;
    }
} # class EditorLineActions does BasePathsActions is export #
```

[Top of Document](#table-of-contents)

### grammar OverrideGUIEditor & actions class OverrideGUIEditorActions

A grammar to parse/recognise the **`override GUI_EDITOR # comment`** line.

```raku
grammar OverrideGUIEditor is export {
    regex TOP     { ^ \h* [ <commented> \h* ]? 'override' \h+ 'GUI_EDITOR' [ \h+ '#' <comment> ]? \h* $ }
    regex comment { <-[\n]>* }
    token commented { '#' }
}

class OverrideGUIEditorActions is export {
    method comment($/) {
        my $comment = (~$/).trim;
        make $comment;
    }
    method commented($/) {
        my $commented = (~$/).trim;
        make $commented;
    }
    method TOP($made) {
        my %top = type => 'override-gui_editor', :value;
        if $made<commented> {
            %top«value» = False;
        }
        if $made<comment> {
            my $com = $made<comment>.made;
            %top«comment» = $com;
        }
        $made.make: %top;
    }
} # class OverrideGUIEditorActions #
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

List all known GUI Editors, flagging the selected editor with **'*'** note if none is flagged either **`$editor`** is set to a non GUI Editor or **`$editor`** is set to the empty string.

```raku
sub list-editors(Str:D $prefix,
                 Bool:D $colour,
                 Bool:D $syntax,
                 Int:D $page-length,
                 Regex:D $pattern --> Bool) is export
```

### editors-stats(…)

Show the values of some editors parameters.

```raku
sub editors-stats(Str:D $prefix,
                  Bool:D $colour,
                  Bool:D $syntax,
                  Int:D $page-length,
                  Regex:D $pattern --> Bool) is export
```

[Top of Document](#table-of-contents)

### BadEditor

**`BadEditor`** is an Exception class for the **`GUI::Editors`** module.

```raku
class BadEditor is Exception is export {
    has Str:D $.msg = 'Error: bad editor specified';
    method message( --> Str:D) {
        $!msg;
    }
}
```

### set-editor(…)

A function to set the editor of choice.

```raku
sub set-editor(Str:D $editor, Str $comment = Str --> Bool:D) is export
```

**NB: this will still be overridden by `%*ENV«GUI_EDITOR»` unless you set **override GUI_EDITOR****.

### add-gui-editor(…)

Add an editor to the list of known GUI Editors.

```raku
sub add-gui-editor(Str:D $editor, Str $comment = Str --> Bool:D) is export
```

**NB: please make sure it really is a GUI Editor otherwise this module will not work correctly. You are completely free to set the chosen editor to what ever you like.**

### set-override-GUI_EDITOR(…)

Set or unset the **override GUI_EDITOR** flag.

```raku
sub set-override-GUI_EDITOR(Bool:D $value, Str $comment = Str --> Bool:D) is export
```

If set then the file always wins else **`%*ENV«GUI_EDITOR»`** always wins if set.

[Top of Document](#table-of-contents)

### backup-editors(…)

Backup the editors file.

```raku
sub backup-editors(Bool:D $use-windows-formatting --> Bool) is export
```

**NB: if $use-windows-formatting is true or the program is running on windows then `.` will become `·` and `:` will become `.`, this is to avoid problems with the special meaning of `:` on windows.**

[Top of Document](#table-of-contents)

### restore-editors(…)

Restore the editors file from a backup.

```raku
sub restore-editors(IO::Path $restore-from --> Bool) is export
```

If **`$restore-from`** is relative and not found from the current directory **`$editor-config/$restore-from`** will be tried. 

### list-editors-backups(…)

List all the available backups in the **`$editor-config`**.

```raku
sub list-editors-backups(Str:D $prefix,
                         Bool:D $colour is copy,
                         Bool:D $syntax,
                         Regex:D $pattern,
                         Int:D $page-length --> Bool:D) is export
```

  * Where

    * **`$prefix`** a filter only files starting with this are included in the result.

    * **`$colour`** colour the output.

    * **`$syntax`** syntax highlight the results colour on steroids.

    * **`$pattern`** a regex to filter the results by only files matching this will be included in the results.

    * **`$page-length`** set the length of the pages before it repeats the header.

[Top of Document](#table-of-contents)

### backups-menu-restore-editors(…)

Presents a menu so you can choose which backup to restore from.

```raku
sub backups-menu-restore-editors(Bool:D $colour,
                                 Bool:D $syntax,
                                 Str:D $message = "" --> Bool:D) is export
```

  * Where:

    * **`$colour`** if **`True`** represents the menu in colours.

    * **`$syntax`** if **`True`** represents the menu syntax highlighted.

      * basically colour on steroids.

        * uses the **`Gzz::Text::Utils::menu(…)`**, which uses the **`Gzz::Text::Utils::dropdown(…)`** function for colour and syntax.

[Top of Document](#table-of-contents)

### edit-files(…)

Edit arbitrary files using chosen editor.

```raku
sub edit-files(Str:D @files --> Bool:D) is export
```

  * Where

    * **`@files`** a list of files to open in the chosen GUI editor.

[Top of Document](#table-of-contents)

