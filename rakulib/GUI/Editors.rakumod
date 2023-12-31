unit module GUI::Editors:ver<0.1.12>:auth<Francis Grizzly Smit (grizzly@smit.id.au)>;

=begin pod

=head1 GUI::Editors

=begin head2

Table of Contents

=end head2

=item1 L<NAME|#name>
=item1 L<AUTHOR|#author>
=item1 L<VERSION|#version>
=item1 L<TITLE|#title>
=item1 L<SUBTITLE|#subtitle>
=item1 L<COPYRIGHT|#copyright>
=item1 L<Introduction|#introduction>
=item1 L<$editor-config|#editor-config>
=item1 L<@config-files|#config-files>
=item1 L<grammar Editors & action class EditorsActions|#grammar-editors--action-class-editorsactions>
=item1 L<grammar EditorLine & class EditorLineActions|#grammar-editorline--class-editorlineactions>
=item1 L<grammar OverrideGUIEditor & actions class OverrideGUIEditorActions|#grammar-overrideguieditor--actions-class-overrideguieditoractions>
=item1 L<Some useful variables|#some-useful-variables>
=item2 L<$GUI_EDITOR|#gui_editor>
=item3 L<$GUI_EDITOR|#gui-editor>
=item2 L<$VISUAL|#visual>
=item2 L<$EDITOR|#editor>
=item2 L<@GUIEDITORS|#guieditors-2>
=item2 L<@gui-editors|#gui-editors>
=item2 L<@default-editors|#default-editors>
=item2 L<@override-gui_editor|#override-gui_editor> or L<on raku.land @override-gui_editor|#override-gui-editor>
=item2 L<$override-GUI_EDITOR|#override-gui_editor-1> or L<on raku.land $override-GUI_EDITOR|#override-gui-editor-1>
=item3 L<In B«C«init-gui-editors»»|#in-init-gui-editors>
=item2 L<$editor|#editor-1>
=item1 L<edit-configs()|#edit-configs>
=item1 L<Editor functions|#editor-functions>
=item2 L<list-editors(…)|#list-editors>
=item2 L<editors-stats(…)|#editors-stats>
=item2 L<BadEditor|#badeditor>
=item2 L<set-editor|#set-editor>
=item2 L<add-gui-editor(…)|#add-gui-editor>
=item2 L<set-override-GUI_EDITOR(…)|#set-override-gui_editor> or L<on raku.land set-override-GUI_EDITOR(…)|#set-override-gui-editor>
=item2 L<backup-editors(…)|#backup-editors>
=item2 L<restore-editors(…)|#restore-editors>
=item2 L<list-editors-backups(…)|#list-editors-backups>
=item2 L<backups-menu-restore-editors(…)|#backups-menu-restore-editors>
=item2 L<edit-files(…)|#edit-files>

=NAME GUI::Editors 
=AUTHOR Francis Grizzly Smit (grizzly@smit.id.au)
=VERSION 0.1.12
=TITLE GUI::Editors
=SUBTITLE A Raku module for managing the users GUI Editor preferences in a variety of programs.

=COPYRIGHT
LGPL V3.0+ L<LICENSE|https://github.com/grizzlysmit/GUI-Editors/blob/main/LICENSE>

L<Top of Document|#table-of-contents>

=head1 Introduction

A B<Raku> module for managing the users GUI Editor preferences in a variety of programs. 

=end pod

use Terminal::ANSI::OO :t;
use Terminal::Width;
use Terminal::WCWidth;
use Term::termios;
use Parse::Paths;
use Display::Listings;
use File::Utils;

INIT my $debug = False;
####################################
#                                  #
#  To turn On or Off debuggging    #
#  Comment or Uncomment this       #
#  following line.                 #
#                                  #
####################################
#INIT $debug = True; use Grammar::Debugger;

#use Grammar::Tracer;
INIT "Grammar::Debugger is on".say if $debug;

use Gzz::Text::Utils;
use Syntax::Highlighters;

# the home dir #
constant $home = %*ENV<HOME>.Str();

=begin pod

=head2 $editor-config

A constant which contains the location of the users editors file

=begin code :lang<raku>

# the home dir #
constant $home = %*ENV<HOME>.Str();

# config files
constant $editor-config is export = "$home/.local/share/gui-editors";

=end code

B<NB: the C<$home> is the value of the users HOME environment variable.>

L<Top of Document|#table-of-contents>

=end pod

# config files
constant $editor-config is export = "$home/.local/share/gui-editors";

if $editor-config.IO !~~ :d {
    $editor-config.IO.mkdir();
}

=begin pod

=head2 @config-files

An array containing the configuration files of the program, by default it
is set to contain B<editors> the editors configuration file the remainder
should be added by B«C«init-gui-editors(...)»» the initialization procedure
for the module.

=begin code :lang<raku>

# The config files to test for #
my Str:D @config-files = qw{editors};

sub config-files( --> Array[Str:D]) is export {
    return @config-files;
}

=end code

=end pod

# The config files to test for #
my Str:D @config-files = qw{editors};

sub config-files( --> Array[Str:D]) is export {
    return @config-files;
}

=begin pod

=head2 @guieditors

An array of known B<GUI> editors. 

=begin code :lang<raku>

my Str:D @guieditors;

sub guieditors( --> Array[Str:D]) is export {
    return @guieditors;
}

=end code

L<Top of Document|#table-of-contents>

=end pod

my Str:D @guieditors;

sub guieditors( --> Array[Str:D]) is export {
    return @guieditors;
}

my &generate-local-configs;

my &client-check;

my Str $client-config;

sub generate-configs(Str $file) returns Bool:D {
    my Bool $result = True;
    CATCH {
        default { 
                $*ERR.say: .message; 
                $*ERR.say: "some kind of IO exception was caught!"; 
                my Str $content;
                given $file {
                    when 'editors' {
                        $content = q:to/END/;
                            # these editors are gui editors
                            # you can define multiple lines like these 
                            # and the system will add to an array of strings 
                            # to treat as guieditors (+= is prefered but = can be used).  
                            guieditors  +=  gvim
                            guieditors  +=  xemacs
                            guieditors  +=  gedit
                            guieditors  +=  kate
                            
                            
                            
                            # define the editor to use here probably better to use
                            # GUI_EDITOR or VISUAL or EDITOR environmet variables 
                            # either := or = maybe used here but := is preferred.
                            # note also defined as a member of guieditors so that
                            # it will be called correctly
                            editor      :=  gvim  # is a also guieditor see above.

                        END
                        for <gvim xemacs kate gedit> -> $guieditor {
                            @guieditors.append($guieditor);
                        }
                        for @guieditors -> $guieditor {
                            $content ~= "\n        guieditors  +=  $guieditor";
                        }
                    } # when 'editors' #
                    default {
                        with &generate-local-configs {
                            return &generate-local-configs($file, $client-config);
                        } else {
                            return True;
                        }
                    } # default #
                } # given $file #
                $content .=trim-trailing;
                if "$editor-config/$file".IO !~~ :e || "$editor-config/$file".IO.s == 0 {
                    "$editor-config/$file".IO.spurt: $content, :append;
                }
                return True;
           }
    }
    my IO::CatHandle $fd = "$editor-config/$file".IO.open: :w;
    given $file {
        when 'editors' {
            my Str $content = q:to/END/;
                # these editors are gui editors
                # you can define multiple lines like these 
                # and the system will add to an array of strings 
                # to treat as guieditors (+= is prefered but = can be used).  
                guieditors  +=  gvim
                guieditors  +=  xemacs
                guieditors  +=  gedit
                guieditors  +=  kate

            END
            $content .=trim-trailing;
            for <gvim xemacs kate gedit> -> $guieditor {
                @guieditors.append($guieditor);
            }
            for @guieditors -> $guieditor {
                $content ~= "\n        guieditors  +=  $guieditor";
            }
            my Bool $r = $fd.put: $content;
            "could not write $editor-config/$file".say if ! $r;
            $result ?&= $r;
        } # when 'editors' #
        default {
            with &generate-local-configs {
                return &generate-local-configs($file, $client-config);
            } else {
                return True;
            }
        } # default #
    } # given $file #
    my Bool $r = $fd.close;
    "error closing file: $editor-config/$file".say if ! $r;
    $result ?&= $r;
    return $result;
} # sub generate-configs(Str $file) returns Bool:D #

=begin pod

=head2 grammar Editors & action class EditorsActions

=begin code :lang<raku>

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

=end code

L<Top of Document|#table-of-contents>

=end pod

#`«««
    ###############################################################################
    #                                                                             #
    #            grammars for parsing the `editors` configuration file            #
    #                                                                             #
    ###############################################################################
#»»»

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

=begin pod

=head3 grammar EditorLine & class EditorLineActions

A grammar and associated action class to parse and recognise the B<C<editor := value # comment>> lines in the B<editors> file.

=begin code :lang<raku>

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

=end code

L<Top of Document|#table-of-contents>

=end pod

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

=begin pod

=head3 grammar OverrideGUIEditor & actions class OverrideGUIEditorActions

A grammar to parse/recognise the B<C<override GUI_EDITOR # comment>> line.

=begin code :lang<raku>

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

=end code

L<Top of Document|#table-of-contents>

=end pod

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

=begin pod

=head2 Some useful variables

B<NB: All these variables are available outside of the module as a sub of the same name.
That way I can give read only access to them.>

=head3 $GUI_EDITOR

The value of the B<C<%*ENV«GUI_EDITOR»>> environment variable or B<C<''>> if not set.

=head3 $VISUAL

The value of the B<C<%*ENV«VISUAL»>> environment variable or B<C<''>> if not set.

=head3 $EDITOR

The value of the B<C<%*ENV«EDITOR»>> environment variable or B<C<''>> if not set.

=begin code :lang<raku>

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

=end code

L<Top of Document|#table-of-contents>

=head3 @GUIEDITORS

The Array of Hashes that the B<C<Editors>> grammar and B<C<EditorsActions>> generate from parsing the B<editors> file.

=head3 @gui-editors

The Array of GUI Editors defined in the B<editors> file.

=head3 @default-editors

The array of B<editors> selected in the file should have only B<one> element otherwise the file is miss configured.

=begin code :lang<raku>

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

=end code

L<Top of Document|#table-of-contents>

=end pod

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

my Bool:D $please-edit = False;

=begin pod

=head3 @override-gui_editor

An array of B<True> values one for each of the times the B<C<override GUI_EDITOR>>
directive appears in the B<editors> file, it is an error for it to appear more than
once, (it's a zero or one rule).

=head3 $override-GUI_EDITOR

True if the B<C<override GUI_EDITOR>> directive is present in the B<editors> file.
If B<True> then the setting in the file overrides the B<C<%*ENV«GUI_EDITOR»>> variable, 
otherwise B<C<%*ENV«GUI_EDITOR»>> wins.

=begin code :lang<raku>

my Bool:D @override-gui_editor;

sub override-gui_editor( --> Array[Bool:D]) is export {
    return @override-gui_editor;
}

my Bool:D $override-GUI_EDITOR = False;

sub override-GUI_EDITOR( --> Bool:D) is export {
    return $override-GUI_EDITOR;
}

=end code

L<Top of Document|#table-of-contents>

=head4 In B«C«init-gui-editors»» 

=begin code :lang<raku>

sub init-gui-editors(Str:D @client-config-files, Str:D $client-config-path,
                              &gen-configs:(Str:D, Str:D --> Bool:D),
                                  &check:(Str:D @cfg-files, Str:D $config --> Bool:D)
                                                                    --> Bool:D) is  export

=end code
...

...

...

=begin code :lang<raku>
 
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

=end code

L<Top of Document|#table-of-contents>

=head3 $editor

The editor the user has chosen.

=begin code :lang<raku>

# the editor to use #
my Str:D $editor = '';

sub editor( --> Str:D) is export {
    return $editor;
}

=end code

=end pod

my Bool:D @override-gui_editor;

sub override-gui_editor( --> Array[Bool:D]) is export {
    return @override-gui_editor;
}

my Bool:D $override-GUI_EDITOR = False;

sub override-GUI_EDITOR( --> Bool:D) is export {
    return $override-GUI_EDITOR;
}

# the editor to use #
my Str:D $editor = '';

sub editor( --> Str:D) is export {
    return $editor;
}

my Bool:D $editor-guessed = False;
if %*ENV<GUI_EDITOR>:exists {
    $editor = %*ENV<GUI_EDITOR>.Str();
} elsif %*ENV<VISUAL>:exists {
    $editor = %*ENV<VISUAL>.Str();
} elsif %*ENV<EDITOR>:exists {
    $editor = %*ENV<EDITOR>.Str();
} else {
    my Str $gvim = qx{/usr/bin/which gvim 2> /dev/null };
    my Str $vim  = qx{/usr/bin/which vim  2> /dev/null };
    my Str $vi   = qx{/usr/bin/which vi   2> /dev/null };
    if $gvim.chomp {
        $editor = $gvim.chomp;
        $editor-guessed = True;
    } elsif $vim.chomp {
        $editor = $vim.chomp;
        $editor-guessed = True;
    } elsif $vi.chomp {
        $editor = $vi.chomp;
        $editor-guessed = True;
    }
}
if $please-edit {
    edit-configs();
    exit 0;
}

=begin pod

=head2 edit-configs()

A function to open the users configuration files in their chosen editor.

=begin code :lang<raku>

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

=end code

L<Top of Document|#table-of-contents>

=end pod

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

sub init-gui-editors(Str:D @client-config-files, Str:D $client-config-path, &gen-configs:(Str:D, Str:D --> Bool:D),
                                                            &check:(Str:D @cfg-files, Str:D $config --> Bool:D) --> Bool:D) is  export {
    @config-files.append(|@client-config-files);
    $client-config = $client-config-path;
    &generate-local-configs = &gen-configs;
    &client-check = &check;
    my Bool $result = True;
    for @config-files -> $file {
        if $file eq 'editors' {
            if "$editor-config/$file".IO !~~ :e || "$editor-config/$file".IO.s == 0 {
                $please-edit = True;
                if "/etc/skel/.local/share/gui-editors/$file".IO ~~ :f {
                    try {
                        CATCH {
                            when X::IO::Copy { 
                                $*ERR.say: "could not copy /etc/skel/.local/share/gui-editors/$file -> $editor-config/$file";
                                my Bool $r = generate-configs($file); 
                                $result ?&= $r;
                            }
                        }
                        my Bool $r = "/etc/skel/.local/share/gui-editors/$file".IO.copy("$editor-config/$file".IO, :createonly);
                        if $r {
                            $*ERR.say: "copied /etc/skel/.local/share/gui-editors/$file -> $editor-config/$file";
                        } else {
                            $*ERR.say: "could not copy /etc/skel/.local/share/gui-editors/$file -> $editor-config/$file";
                        }
                        $result ?&= $r;
                    }
                } else {
                    my Bool $r = generate-configs($file);
                    $*ERR.say: "generated $editor-config/$file" if $r;
                    $result ?&= $r;
                }
            }
        } elsif !&client-check(@client-config-files, $client-config) {
            $result ?&= &generate-local-configs($file, $client-config);
        }
    } # for @config-files -> $file # 

    # The default name of the gui editor #
    my $actions = EditorsActions;
    my @editors-file = "$editor-config/editors".IO.slurp.split("\n");
    #dd @editors-file;
    #my $edtest = Editors.parse(@editors-file.join("\x0A"), :enc('UTF-8'), :$actions).made;
    #dd $edtest;
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
    #my Str @gui-editors = slurp("$editor-config/editors").split("\n").map( { my Str $e = $_; $e ~~ s/ '#' .* $$ //; $e } ).map( { $_.trim() } ).grep: { !rx/ [ ^^ \s* '#' .* $$ || ^^ \s* $$ ] / };
    #my Str @guieditors;
    #@gui-editors.raku.say;
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
    return $result;
} #`««« sub init-gui-editors(Str:D @client-config-files, Str:D $client-config-path, &gen-configs:(Str:D, Str:D --> Bool:D),
                                                            &check:(Str:D @cfg-files, Str:D $config --> Bool:D) --> Bool:D) is  export »»»

#`«««
    ##################################
    #********************************#
    #*                              *#
    #*       Editor functions       *#
    #*                              *#
    #********************************#
    ##################################
#»»»

=begin pod

=head2 Editor functions

=head3 list-editors(…)

List all known GUI Editors, flagging the selected editor with B<'*'>
note if none is flagged either B<C<$editor>> is set to a non GUI Editor 
or B<C<$editor>> is set to the empty string.

=begin code :lang<raku>

sub list-editors(Str:D $prefix,
                 Bool:D $colour,
                 Bool:D $syntax,
                 Int:D $page-length,
                 Regex:D $pattern --> Bool) is export 

=end code

=end pod

sub list-editors(Str:D $prefix,
                 Bool:D $colour,
                 Bool:D $syntax,
                 Int:D $page-length,
                 Regex:D $pattern --> Bool) is export {
    my Int:D $cnt = 0;
    my Str:D $mark = '';
    my @all-guieditors;
    for (|@guieditors, |@gui-editors) -> $ed {
        my %row = editor => $ed, mark => (($editor.trim.IO.basename eq $ed.trim.IO.basename) ?? '*' !! '');
        @all-guieditors.push: %row if !@all-guieditors.grep: -> %row { $ed eq %row«editor» };
    }
    my Str:D @fields     = 'editor', 'mark';
    my Str:D %fancynames = editor => 'Editors', mark => 'Actual Editor';
    my       %defaults;
    my Str:D %flags      = editor => '-', mark => '';
    sub include-row(Str:D $prefix, Regex:D $pattern, Int:D $idx, Str:D @fields, %row --> Bool:D) {
        my Str:D $ed = ~%row«editor»;
        return True if $ed.starts-with($prefix, :ignorecase) && $ed ~~ $pattern;
        return False;
    } # sub include-row(Str:D $prefix, Regex:D $pattern, Int:D $idx, Str:D @fields, %row --> Bool:D) #
    sub head-value(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) {
        if $syntax {
            return t.color(0, 255, 255) ~ %fancynames{$field};
        } elsif $colour {
            return t.color(0, 255, 255) ~ %fancynames{$field};
        } else {
            return ~%fancynames{$field};
        }
    } # sub head-value(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) #
    sub head-between(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) {
        if $field eq 'editor' {
            if $syntax {
                return t.bright-blue ~ ' | ';
            } elsif $colour {
                return t.bright-blue ~ ' | ';
            } else {
                return ' | ';
            }
        } else {
            return '  ';
        }
    } # sub head-between(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) #
    sub field-value(Int:D $idx, Str:D $field, $value, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) {
        if $syntax {
            given $field {
                when 'editor' { return t.color(0,255,0) ~ ~$value; }
                when 'mark'   { return t.color(255,0,0) ~ ~$value; }
                default       { return t.color(255,0,0) ~ '';      }
            }
        } elsif $colour {
            return t.color(0,0,255) ~ ~$value;
        } else {
            return ~$value
        }
    } # sub field-value(Int:D $idx, Str:D $field, $value, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) #
    sub between(Int:D $idx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) {
        if $field eq 'editor' {
            if $syntax {
                return t.bright-blue ~ ' | ';
            } elsif $colour {
                return t.bright-blue ~ ' | ';
            } else {
                return ' | ';
            }
        } else {
            return '  ';
        }
    } # sub between(Int:D $idx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) #
    sub row-formatting(Int:D $cnt, Bool:D $colour, Bool:D $syntax --> Str:D) {
        if $colour {
            if $syntax { 
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -3; # three heading lines. #
                return t.bg-color(0, 0, 127) ~ t.bold ~ t.bright-blue if $cnt == -2;
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -1;
                return (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,195,0)) ~ t.bold ~ t.bright-blue;
            } else {
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -3;
                return t.bg-color(0, 0, 127) ~ t.bold ~ t.bright-blue if $cnt == -2;
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -1;
                return (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,195,0)) ~ t.bold ~ t.bright-blue;
            }
        } else {
            return '';
        }
    } # sub row-formatting(Int:D $cnt, Bool:D $colour, Bool:D $syntax --> Str:D) #
    return list-by($prefix, $colour, $syntax, $page-length,
                  $pattern, @fields, %defaults, @all-guieditors,
                  :%flags, 
                  :&include-row, 
                  :&head-value, 
                  :&head-between,
                  :&field-value, 
                  :&between,
                  :&row-formatting);
} #`««« sub list-editors(Str:D $prefix,
                 Bool:D $colour,
                 Bool:D $syntax,
                 Int:D $page-length,
                 Regex:D $pattern --> Bool) is export »»»

=begin pod

=head3 editors-stats(…)

Show the values of some editors parameters.

=begin code :lang<raku>

sub editors-stats(Str:D $prefix,
                  Bool:D $colour,
                  Bool:D $syntax,
                  Int:D $page-length,
                  Regex:D $pattern --> Bool) is export 

=end code

L<Top of Document|#table-of-contents>

=end pod

sub editors-stats(Str:D $prefix,
                  Bool:D $colour,
                  Bool:D $syntax,
                  Int:D $page-length,
                  Regex:D $pattern --> Bool) is export {
    my Int:D $cnt = 0;
    my %editors = '%*ENV«GUI_EDITOR»' => $GUI_EDITOR,
                  '%*ENV<VISUAL>' => $VISUAL,
                  '%*ENV<EDITOR>' => $EDITOR,
                  '$editor' => $editor,
                  '$override-GUI_EDITOR' => $override-GUI_EDITOR,
                  '@default-editors' => '[ ' ~ ((@default-editors) ?? '"' ~ @default-editors.join('", "') ~ '"' !! '') ~ ' ]', 
                  '@override-gui_editor' => '[' ~ @override-gui_editor.join(', ') ~ ']';
    my @rows;
    for %editors.kv -> $var, $value {
        my %h = var => $var, value => $value;
        @rows.push: %h;
    } # for %editors.kv -> $var, $value #
    my Str:D @fields     = 'var', 'value';
    my Str:D %fancynames = var => 'Variable', value => 'Value';
    my       %defaults;
    my Str:D %flags      = var => '-', value => '';
    sub include-row(Str:D $prefix, Regex:D $pattern, Int:D $idx, Str:D @fields, %row --> Bool:D) {
        for @fields -> $field {
            my Str:D $value = ~%row{$field};
            return True if $value.starts-with($prefix, :ignorecase) && $value ~~ $pattern;
        }
        return False;
    } # sub include-row(Str:D $prefix, Regex:D $pattern, Int:D $idx, Str:D @fields, %row --> Bool:D) #
    sub head-value(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) {
        if $syntax {
            return t.color(0, 255, 255) ~ %fancynames{$field};
        } elsif $colour {
            return t.color(0, 255, 255) ~ %fancynames{$field};
        } else {
            return ~%fancynames{$field};
        }
    } # sub head-value(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) #
    sub head-between(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) {
        if $field eq 'var' {
            if $syntax {
                return t.bright-blue ~ '   |   ';
            } elsif $colour {
                return t.bright-blue ~ '   |   ';
            } else {
                return '   |   ';
            }
        } else {
            return '  ';
        }
    } # sub head-between(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) #
    sub field-value(Int:D $idx, Str:D $field, $value, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) {
        if $syntax {
            given $field {
                when 'var'   { return highlight-var(~$value); }
                when 'value' { return highlight-val(~$value); }
                default      { return '';      }
            }
        } elsif $colour {
            return t.color(0,0,255) ~ ~$value;
        } else {
            return ~$value
        }
    } # sub field-value(Int:D $idx, Str:D $field, $value, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) #
    sub between(Int:D $idx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) {
        if $field eq 'var' {
            if $syntax {
                return t.bright-blue ~ '   |   ';
            } elsif $colour {
                return t.bright-blue ~ '   |   ';
            } else {
                return '   |   ';
            }
        } else {
            return '  ';
        }
    } # sub between(Int:D $idx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) #
    sub row-formatting(Int:D $cnt, Bool:D $colour, Bool:D $syntax --> Str:D) {
        if $colour {
            if $syntax { 
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -3; # three heading lines. #
                return t.bg-color(0, 0, 127) ~ t.bold ~ t.bright-blue if $cnt == -2;
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -1;
                return (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,195,0)) ~ t.bold ~ t.bright-blue;
            } else {
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -3;
                return t.bg-color(0, 0, 127) ~ t.bold ~ t.bright-blue if $cnt == -2;
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -1;
                return (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,195,0)) ~ t.bold ~ t.bright-blue;
            }
        } else {
            return '';
        }
    } # sub row-formatting(Int:D $cnt, Bool:D $colour, Bool:D $syntax --> Str:D) #
    return list-by($prefix, $colour, $syntax, $page-length,
                  $pattern, @fields, %defaults, @rows,
                  :%flags, 
                  :&include-row, 
                  :&head-value, 
                  :&head-between,
                  :&field-value, 
                  :&between,
                  :&row-formatting);
} #`««« sub editors-stats(Str:D $prefix,
                  Bool:D $colour,
                  Bool:D $syntax,
                  Int:D $page-length,
                  Regex:D $pattern --> Bool) is export »»»

=begin pod

=head3 BadEditor

B<C<BadEditor>> is an Exception class for the B<C<GUI::Editors>> module.

=begin code :lang<raku>

class BadEditor is Exception is export {
    has Str:D $.msg = 'Error: bad editor specified';
    method message( --> Str:D) {
        $!msg;
    }
}

=end code

=end pod

class BadEditor is Exception is export {
    has Str:D $.msg = 'Error: bad editor specified';
    method message( --> Str:D) {
        $!msg;
    }
}

=begin pod

=head3 set-editor(…)

A function to set the editor of choice.

=begin code :lang<raku>

sub set-editor(Str:D $editor, Str $comment = Str --> Bool:D) is export 

=end code

B<NB: this will still be overridden by C<%*ENV«GUI_EDITOR»> unless you set B<override GUI_EDITOR>>.

=end pod

sub set-editor(Str:D $editor, Str $comment = Str --> Bool:D) is export {
    if @default-editors.elems == 1 && (@default-editors[0] eq $editor) {
        return True; # Already set to this value #
    }
    my Str:D $line = "        editor      :=  $editor";
    with $comment {
        $line ~= " # $comment";
    }
    my $actions = EditorLineActions;
    my IO::Handle:D $input  = "$editor-config/editors".IO.open:     :r, :nl-in("\n")   :chomp;
    my IO::Handle:D $output = "$editor-config/editors.new".IO.open: :w, :nl-out("\n"), :chomp;
    my Bool:D $unset = True;
    my Str $ln;
    $ln = $input.get;
    while !$input.eof {
        my $ed-line = EditorLine.parse($ln, :enc('UTF-8'), :$actions).made;
        if $ed-line {
            if $unset {
                $output.say: $line;
                $unset = False;
            }
        } else {
            $output.say: $ln;
        }
        $ln = $input.get;
    } # while !$input.eof #
    if $ln { # last line in file #
        my $ed-line = EditorLine.parse($ln, :enc('UTF-8'), :$actions).made;
        if $ed-line {
            if $unset {
                $output.say: $line;
                $unset = False;
            }
        } else {
            $output.say: $ln;
        }
    } # if $ln #
    if $unset { # can happen if editor was not set before #
        $output.say: $line;
        $unset = False;
    }
    $input.close;
    $output.close;
    if $unset {
        $*ERR.say: qq[Error: editors: $editor "not set"];
        return "$editor-config/editors.new".IO.unlink;
    } elsif "$editor-config/editors.new".IO.move: "$editor-config/editors" {
        return True;
    } else {
        BadEditor.new(:msg("move failed")).throw;
    }
    return !$unset; # should never be reached #
} #`««« sub set-editor(Str:D $editor, Str $comment = Str --> Bool:D) is export »»»

=begin pod

=head3 add-gui-editor(…)

Add an editor to the list of known GUI Editors.

=begin code :lang<raku>

sub add-gui-editor(Str:D $editor, Str $comment = Str --> Bool:D) is export 

=end code

B<NB: please make sure it really is a GUI Editor otherwise this module will
not work correctly. You are completely free to set the chosen editor to what
ever you like.>

=end pod

sub add-gui-editor(Str:D $editor, Str $comment = Str --> Bool:D) is export {
    if @gui-editors.grep( -> $ged { $ged eq $editor }) {
        return True; # already in there. #
    }
    my Str:D $line = "        guieditors  +=  $editor";
    with $comment {
        $line ~= " # $comment";
    }
    my IO::Handle:D $output  = "$editor-config/editors".IO.open:     :a, :nl-in("\n")   :chomp;
    $output.say: $line;
    return $output.close;
} #`««« sub add-gui-editor(Str:D $editor --> Bool:D) is export »»»

=begin pod

=head3 set-override-GUI_EDITOR(…)

Set or unset the B<override GUI_EDITOR> flag.

=begin code :lang<raku>

sub set-override-GUI_EDITOR(Bool:D $value, Str $comment = Str --> Bool:D) is export 

=end code

If set then the file always wins else B<C<%*ENV«GUI_EDITOR»>> always wins if set.

L<Top of Document|#table-of-contents>

=end pod

sub set-override-GUI_EDITOR(Bool:D $value, Str $comment = Str --> Bool:D) is export {
    if @override-gui_editor.elems == 1 && (@override-gui_editor[0] eq $editor) {
        return True; # Already set to this value #
    }
    my Str:D $line = "        override GUI_EDITOR";
    $line          = "        #override GUI_EDITOR" unless $value;
    with $comment {
        $line ~= " # $comment";
    }
    my $actions = OverrideGUIEditorActions;
    my IO::Handle:D $input  = "$editor-config/editors".IO.open:     :r, :nl-in("\n")   :chomp;
    my IO::Handle:D $output = "$editor-config/editors.new".IO.open: :w, :nl-out("\n"), :chomp;
    my Bool:D $unset = True;
    my Str $ln;
    $ln = $input.get;
    while !$input.eof {
        my $ed-line = OverrideGUIEditor.parse($ln, :enc('UTF-8'), :$actions).made;
        if $ed-line {
            if $unset {
                $output.say: $line;
                $unset = False;
            }
        } else {
            $output.say: $ln;
        }
        $ln = $input.get;
    } # while !$input.eof #
    if $ln { # last line in file #
        my $ed-line = OverrideGUIEditor.parse($ln, :enc('UTF-8'), :$actions).made;
        if $ed-line {
            if $unset {
                $output.say: $line;
                $unset = False;
            }
        } else {
            $output.say: $ln;
        }
    } # if $ln #
    if $unset { # can happen if editor was not set before #
        $output.say: $line;
        $unset = False;
    }
    $input.close;
    $output.close;
    if $unset {
        $*ERR.say: qq[Error: editors: $editor "not set"];
        return "$editor-config/editors.new".IO.unlink;
    } elsif "$editor-config/editors.new".IO.move: "$editor-config/editors" {
        return True;
    } else {
        BadEditor.new(:msg("move failed")).throw;
    }
    return !$unset; # should never be reached #
} #`««« sub set-override-GUI_EDITOR(Bool:D $value, Str $comment = Str --> Bool:D) is export »»»

=begin pod

=head3 backup-editors(…)

Backup the editors file.

=begin code :lang<raku>

sub backup-editors(Bool:D $use-windows-formatting --> Bool) is export 

=end code

B«NB: if $use-windows-formatting is true or the program is running on windows then
C<.> will become C<·> and C<:> will become C<.>, this is to avoid
problems with the special meaning of C<:> on windows.»

=end pod

sub backup-editors(Bool:D $use-windows-formatting --> Bool) is export {
    my DateTime $now = DateTime.now;
    my Str:D $time-stamp = $now.Str;
    if $*DISTRO.is-win || $use-windows-formatting {
        $time-stamp ~~ tr/./·/;
        $time-stamp ~~ tr/:/./;
    }
    return "$editor-config/editors".IO.copy("$editor-config/editors.$time-stamp".IO);
} # sub backup-editors(Bool:D $use-windows-formatting --> Bool) is export #

=begin pod

L<Top of Document|#table-of-contents>

=head3 restore-editors(…)

Restore the editors file from a backup.

=begin code :lang<raku>

sub restore-editors(IO::Path $restore-from --> Bool) is export 

=end code

If B<C<$restore-from>> is relative and not found from the current directory 
B<C<$editor-config/$restore-from>> will be tried. 

=end pod

sub restore-editors(IO::Path $restore-from is copy --> Bool) is export {
    with $restore-from {
        my $actions = EditorsActions;
        if $restore-from ~~ :f {
            my @ed-file = $restore-from.slurp.split("\n");
            return $restore-from.copy("$editor-config/editors".IO) if  Editors.parse(@ed-file.join("\x0A"), :enc('UTF-8'), :$actions).made;
        } elsif $restore-from.is-relative && "$editor-config/{$restore-from.Str}".IO ~~ :f {
            $restore-from = "$editor-config/{$restore-from.Str}".IO;
            my @ed-file = $restore-from.slurp.split("\n");
            return $restore-from.copy("$editor-config/editors".IO) if  Editors.parse(@ed-file.join("\x0A"), :enc('UTF-8'), :$actions).made;
        }
        return False;
    } else {
        return False;
    }
}

=begin pod

=head3 list-editors-backups(…)

List all the available backups in the B<C<$editor-config>>.

=begin code :lang<raku>

sub list-editors-backups(Str:D $prefix,
                         Bool:D $colour is copy,
                         Bool:D $syntax,
                         Regex:D $pattern,
                         Int:D $page-length --> Bool:D) is export

=end code

=item1 Where
=item2 B<C<$prefix>>       a filter only files starting with this are included in the result.
=item2 B<C<$colour>>       colour the output.
=item2 B<C<$syntax>>       syntax highlight the results colour on steroids.
=item2 B<C<$pattern>>      a regex to filter the results by only files matching this will be included in the results.
=item2 B<C<$page-length>>  set the length of the pages before it repeats the header.

L<Top of Document|#table-of-contents>

=end pod

sub list-editors-backups(Str:D $prefix,
                         Bool:D $colour is copy,
                         Bool:D $syntax,
                         Regex:D $pattern,
                         Int:D $page-length --> Bool:D) is export {
    $colour = True if $syntax;
    my IO::Path @backups = $editor-config.IO.dir(:test(rx/ ^ 
                                                           'editors.' \d ** 4 '-' \d ** 2 '-' \d ** 2
                                                               [ 'T' \d **2 [ [ '.' || ':' ] \d ** 2 ] ** {0..2} [ [ '.' || '·' ] \d+ 
                                                                   [ [ '+' || '-' ] \d ** 2 [ '.' || ':' ] \d ** 2 || 'z' ]?  ]?
                                                               ]?
                                                           $
                                                         /
                                                       )
                                                );
    my $actions = EditorsActions;
    @backups .=grep: -> IO::Path $fl { 
                                my @file = $fl.slurp.split("\n");
                                Editors.parse(@file.join("\x0A"), :enc('UTF-8'), :$actions).made;
                            };
    @backups .=sort;
    my @_backups = @backups.map: -> IO::Path $f {
          my %elt = backup => $f.basename, perms => symbolic-perms($f, :$colour, :$syntax),
                      user => $f.user, group => $f.group, size => $f.s, modified => $f.modified;
          %elt;
    };
    my Str:D @fields = 'perms', 'size', 'user', 'group', 'modified', 'backup';
    my       %defaults;
    my Str:D %fancynames = perms => 'Permissions', size => 'Size',
                             user => 'User', group => 'Group',
                             modified => 'Date Modified', backup => 'Backup';
    sub include-row(Str:D $prefix, Regex:D $pattern, Int:D $idx, Str:D @fields, %row --> Bool:D) {
        my Str:D $value = ~(%row«backup» // '');
        return True if $value.starts-with($prefix, :ignorecase) && $value ~~ $pattern;
        return False;
    } # sub include-row(Str:D $prefix, Regex:D $pattern, Int:D $idx, Str:D @fields, %row --> Bool:D) #
    sub head-value(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) {
        #dd $indx, $field, $colour, $syntax, @fields;
        if $colour {
            if $syntax { 
                return t.color(0, 255, 255) ~ %fancynames{$field};
            } else {
                return t.color(0, 255, 255) ~ %fancynames{$field};
            }
        } else {
            return %fancynames{$field};
        }
    } # sub head-value(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) #
    sub head-between(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) {
        return ' ';
    } # sub head-between(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) #
    sub field-value(Int:D $idx, Str:D $field, $value, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) {
        my Str:D $val = ~($value // ''); #`««« assumming $value is a Str:D »»»
        #dd $val, $value, $field;
        if $syntax {
            given $field {
                when 'perms'    { return $val; }
                when 'size'     {
                    my Int:D $size = +$value;
                    return t.color(255, 0, 0) ~ format-bytes($size);
                }
                when 'user'     { return t.color(255, 255, 0) ~ uid2username(+$value);    }
                when 'group'    { return t.color(255, 255, 0) ~ gid2groupname(+$value);   }
                when 'modified' {
                    my Instant:D $m = +$value;
                    my DateTime:D $dt = $m.DateTime.local;
                    return t.color(0, 0, 235) ~ $dt.Str;  
                }
                when 'backup'   { return t.color(255, 0, 255) ~ $val; }
                default         { return t.color(255, 0, 0) ~ $val;   }
            } # given $field #
        } elsif $colour {
            given $field {
                when 'perms'    { return $val; }
                when 'size'     {
                    my Int:D $size = +$value;
                    return t.color(0, 0, 255) ~ format-bytes($size);
                }
                when 'user'     { return t.color(0, 0, 255) ~ uid2username(+$value);    }
                when 'group'    { return t.color(0, 0, 255) ~ gid2groupname(+$value);   }
                when 'modified' {
                    my Instant:D $m = +$value;
                    my DateTime:D $dt = $m.DateTime.local;
                    return t.color(0, 0, 255) ~ $dt.Str;  
                }
                when 'backup'   { return t.color(0, 0, 255) ~ $val;   }
                default         { return t.color(255, 0, 0) ~ $val;   }
            } # given $field #
        } else {
            given $field {
                when 'perms'    { return $val; }
                when 'size'     {
                    my Int:D $size = +$value;
                    return format-bytes($size);
                }
                when 'user'     { return uid2username(+$value);    }
                when 'group'    { return gid2groupname(+$value);   }
                when 'modified' {
                    my Instant:D $m = +$value;
                    my DateTime:D $dt = $m.DateTime.local;
                    return $dt.Str;  
                }
                when 'backup'   { return $val;   }
                default         { return $val;   }
            } # given $field #
        }
    } # sub field-value(Int:D $idx, Str:D $field, $value, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) #
    sub between(Int:D $idx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) {
        return ' ';
    } # sub between(Int:D $idx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) #
    sub row-formatting(Int:D $cnt, Bool:D $colour, Bool:D $syntax --> Str:D) {
        if $colour {
            if $syntax { 
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -3; # three heading lines. #
                return t.bg-color(0, 0, 127) ~ t.bold ~ t.bright-blue if $cnt == -2;
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -1;
                return (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,195,0)) ~ t.bold ~ t.bright-blue;
            } else {
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -3;
                return t.bg-color(0, 0, 127) ~ t.bold ~ t.bright-blue if $cnt == -2;
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -1;
                return (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,195,0)) ~ t.bold ~ t.bright-blue;
            }
        } else {
            return '';
        }
    } # sub row-formatting(Int:D $cnt, Bool:D $colour, Bool:D $syntax --> Str:D) #
    return list-by($prefix, $colour, $syntax, $page-length,
                  $pattern, @fields, %defaults, @_backups,
                  :!sort,
                  :&include-row, 
                  :&head-value, 
                  :&head-between,
                  :&field-value, 
                  :&between,
                  :&row-formatting);
} #`««« sub list-editors-backups(Str:D $prefix,
                         Bool:D $colour is copy,
                         Bool:D $syntax,
                         Regex:D $pattern,
                         Int:D $page-length --> Bool:D) is export »»»

=begin pod

=head3 backups-menu-restore-editors(…)

Presents a menu so you can choose which backup to restore from.

=begin code :lang<raku>

sub backups-menu-restore-editors(Bool:D $colour,
                                 Bool:D $syntax,
                                 Str:D $message = "" --> Bool:D) is export 

=end code

=item1 Where:
=item2 B<C<$colour>> if B<C<True>> represents the menu in colours.
=item2 B<C<$syntax>> if B<C<True>> represents the menu syntax highlighted.
=item3 basically colour on steroids.
=item4 uses the B<C<Gzz::Text::Utils::menu(…)>>, which uses the B<C<Gzz::Text::Utils::dropdown(…)>> function for colour and syntax.

L<Top of Document|#table-of-contents>

=end pod

sub backups-menu-restore-editors(Bool:D $colour,
                                 Bool:D $syntax,
                                 Str:D $message = "" --> Bool:D) is export {
    my IO::Path @backups = $editor-config.IO.dir(:test(rx/ ^ 
                                                           'editors.' \d ** 4 '-' \d ** 2 '-' \d ** 2
                                                               [ 'T' \d **2 [ [ '.' || ':' ] \d ** 2 ] ** {0..2} [ [ '.' || '·' ] \d+ 
                                                                   [ [ '+' || '-' ] \d ** 2 [ '.' || ':' ] \d ** 2 || 'z' ]?  ]?
                                                               ]?
                                                           $
                                                         /
                                                       )
                                                );
    ###############################################
    #                                             #
    #  make sure they are all valid editor files  #
    #                                             #
    ###############################################
    my $actions = EditorsActions;
    @backups .=grep: -> IO::Path $fl { 
                                my @file = $fl.slurp.split("\n");
                                Editors.parse(@file.join("\x0A"), :enc('UTF-8'), :$actions).made;
                            };
    my $highlight-bg-colour = t.bg-color(0, 0, 107) ~ t.bold;
    my $highlight-fg-colour = t.color(255, 255, 0);
    my @Backups = @backups.map: -> IO::Path $f {
          my %elt = value => $f.Str, backup => $f.basename,
                      perms => symbolic-perms($f, :$colour, :$syntax, :highlight-fg-colour(''),
                                              :fg-colour0(''), :fg-colour1('')),
                      user => uid2username($f.user), group => gid2groupname($f.group),
                      size => format-bytes($f.s), modified => $f.modified.DateTime.local.Str;
          %elt;
    };
    @Backups .=sort( -> %lhs, %rhs { %lhs«value».IO.basename cmp %rhs«value».IO.basename });
    sub row(Int:D $cnt, Int:D $pos, @array,
                                     Bool:D :$colour = False, Bool:D :$syntax = False,
                                     Str:D :$highlight-bg-colour = '',
                                     Str:D :$highlight-fg-colour = '',
                                     Str:D :$bg-colour0 = '',
                                     Str:D :$fg-colour0 = '', 
                                     Str:D :$bg-colour1 = '',
                                     Str:D :$fg-colour1 = ''  --> Str:D) {
        my %r = @array[$cnt];
        if $syntax {
            if %r«value» eq 'cancel' {
                return %r«name» if %r«name»:exists;
                return %r«value»;
            }
            my Str:D $name = %r«perms» ~ ' ';
            if $cnt == $pos {
                $name ~= $highlight-bg-colour ~ t.color(255, 0, 0)   ~ %r«size»     ~ ' ';
                $name ~= $highlight-bg-colour ~ t.color(255, 255, 0) ~ %r«user»     ~ ' ';
                $name ~= $highlight-bg-colour ~ t.color(255, 255, 0) ~ %r«group»    ~ ' ';
                $name ~= $highlight-bg-colour ~ t.color(0, 0, 255)   ~ %r«modified» ~ ' ';
                $name ~= $highlight-bg-colour ~ t.color(255, 0, 255) ~ %r«backup»   ~ ' ';
            } elsif $cnt %% 2 {
                $name ~= $bg-colour0 ~ t.color(255, 0, 0)   ~ %r«size»     ~ ' ';
                $name ~= $bg-colour0 ~ t.color(255, 255, 0) ~ %r«user»     ~ ' ';
                $name ~= $bg-colour0 ~ t.color(255, 255, 0) ~ %r«group»    ~ ' ';
                $name ~= $bg-colour0 ~ t.color(0, 0, 255)   ~ %r«modified» ~ ' ';
                $name ~= $bg-colour0 ~ t.color(255, 0, 255) ~ %r«backup»   ~ ' ';
            } else {
                $name ~= $bg-colour1 ~ t.color(255, 0, 0)   ~ %r«size»     ~ ' ';
                $name ~= $bg-colour1 ~ t.color(255, 255, 0) ~ %r«user»     ~ ' ';
                $name ~= $bg-colour1 ~ t.color(255, 255, 0) ~ %r«group»    ~ ' ';
                $name ~= $bg-colour1 ~ t.color(0, 0, 255)   ~ %r«modified» ~ ' ';
                $name ~= $bg-colour1 ~ t.color(255, 0, 255) ~ %r«backup»   ~ ' ';
            }
        } elsif $colour {
            if %r«value» eq 'cancel' {
                return %r«name» if %r«name»:exists;
                return %r«value»;
            }
            my Str:D $name = %r«size» ~ ' ' ~ %r«user» ~ ' ' ~ %r«group» ~ ' ' ~ %r«modified» ~ ' ' ~ %r«backup»;
            if $cnt == $pos {
                return $highlight-bg-colour ~ %r«perms» ~ ' ' ~ $highlight-fg-colour ~ $name;
            } elsif $cnt %% 2 {
                return $bg-colour0          ~ %r«perms» ~ ' ' ~ $fg-colour0          ~ $name;
            } else {
                return $bg-colour1          ~ %r«perms» ~ ' ' ~ $fg-colour1          ~ $name;
            }
        } else {
            if %r«value» eq 'cancel' {
                return %r«name» if %r«name»:exists;
                return %r«value»;
            }
            my Str:D $name = %r«perms» ~ ' ' ~ %r«size» ~ ' ' ~ %r«user» ~ ' ' ~ %r«group» ~ ' ' ~ %r«modified» ~ ' ' ~ %r«backup»;
            return $name;
        }
    }
    my Str $file = menu(@Backups, $message, :&row, :$colour, :$syntax, :$highlight-bg-colour, :$highlight-fg-colour, :wrap-around);
    return False without $file;
    return False if $file eq '';
    return False if $file eq 'cancel';
    return restore-editors($file.IO);
} #`««« sub backups-menu-restore-editors(Bool:D $colour,
                                 Bool:D $syntax,
                                 Str:D $message = "" --> Bool:D) is export »»»

=begin pod

=head3 edit-files(…)

Edit arbitrary files using chosen editor.

=begin code :lang<raku>

sub edit-files(Str:D @files --> Bool:D) is export 

=end code

=item1 Where
=item2 B<C<@files>> a list of files to open in the chosen GUI editor.

L<Top of Document|#table-of-contents>

=end pod

sub edit-files(Str:D @files --> Bool:D) is export {
    if $editor {
        my $option = '';
        my @args;
        my $edbase = $editor.IO.basename;
        if $edbase eq 'gvim' {
            $option = '-p';
            @args.append('-p');
        }
        @args.append(|@files);
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
