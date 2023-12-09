unit module GUI::Editors:ver<0.1.0>:auth<Francis Grizzly Smit (grizzly@smit.id.au)>;

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
=item1 L<grammar Editors|#grammar-editors>
=item1 L<Some useful variables|#some-useful-variables>
=item2 L<$GUI_EDITOR|#gui_editor>
=item2 L<$VISUAL|#visual>
=item2 L<$EDITOR|#editor>
=item2 L<@GUIEDITORS|#guieditors-2>
=item2 L<@gui-editors|#gui-editors>
=item2 L<@default-editors|#default-editors>
=item1 L<Introduction|#introduction>
=item1 L<Introduction|#introduction>

=NAME GUI::Editors 
=AUTHOR Francis Grizzly Smit (grizzly@smit.id.au)
=VERSION 0.1.0
=TITLE GUI::Editors
=SUBTITLE A Raku module for managing the users GUI Editor preferences in a variety of programs.

L<Top of Document|#table-of-contents>

=head1 Introduction

A B<Raku> module for managing the users GUI Editor preferences in a variety of programs. 

=end pod

use Terminal::ANSI::OO :t;
use Terminal::Width;
use Terminal::WCWidth;

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

=head2 grammar Editors

=begin code :lang<raku>

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
    method white-space-line($/) {
        my %wspln = type => 'white-space-line', value => ~$/;
        make %wspln;
    }
    method comment-line($/) {
        my %comln = type => 'comment-line', value => ~$/;
        make %comln;
    }
    #token other-stuff         { [ '-' || '+' || ':' || '@' || '=' || ',' || '%' || '.' ] }
    method other-stuff($/) {
        my $other-stuff = ~$/;
        make $other-stuff;
    }
    #token with-other-stuff    { <start-other-stuff> <tail-other-stuff>* }
    method with-other-stuff($/) {
        my @tailotherstuff;
        if $/<tail-other-stuff> {
            @tailotherstuff = $/<tail-other-stuff>».made;
        }
        my $with-other-stuff = $/<start-other-stuff>.made ~ @tailotherstuff.join();
        make $with-other-stuff;
    }
    #token editor-name         { <with-other-stuff> }
    method editor-name($/) {
        my $edname = $/<with-other-stuff>.made;
        make $edname;
    }
    method lead-in($/) {
        my $leadin = ~$/;
        make $leadin;
    }
    #token with-space-in-it    { \w+ [ ' ' \w+ ]* }
    method with-space-in-it($/) {
        my $with-space-in-it = ~$/;
        make $with-space-in-it;
    }
    #token start-other-stuff   { \w+ }
    method start-other-stuff($/) {
        my $start-other-stuff = ~$/;
        make $start-other-stuff;
    }
    #token tails-tail          { \w+ }
    method tails-tail($/) {
        my $tails-tail = ~$/;
        make $tails-tail;
    }
    #token tail-other-stuff    { <other-stuff>+ <tails-tail>? }
    method tail-other-stuff($/) {
        my @otherstuff = $/<other-stuff>».made;
        my $tail-other-stuff = @otherstuff.join();
        if $/<tails-tail> {
            $tail-other-stuff ~= $<tails-tail>.made;
        }
        make $tail-other-stuff;
    }
    #token path-segment        { [ <with-space-in-it> || <with-other-stuff> ] }
    method path-segment($/) {
        my $path-segment = ~$/;
        make $path-segment;
    }
    method path-segments($/) {
        my @path-seg = $/<path-segment>».made;
        make @path-seg.join('/');
    }
    method path($/) {
        my Str $ed-path = $/<lead-in>.made ~ $/<path-segments>.made;
        make $ed-path;
    }
    method editor($/) {
        my $ed-name;
        if $/<path> {
            $ed-name = $/<path>.made ~ '/' ~ $/<editor-name>.made;
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
} # class EditorsActions #

=begin pod

=head2 Some useful variables

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

In B«C«sub init-gui-editors(Str:D @client-config-files, Str:D $client-config-path, &gen-configs:(Str:D, Str:D --> Bool:D),
                                                            &check:(Str:D @cfg-files, Str:D $config --> Bool:D) --> Bool:D) is  export»» 

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

my Bool:D @override-gui_editor;

sub override-gui_editor( --> Array[Bool:D]) is export {
    return @override-gui_editor;
}

my Bool:D $override-GUI_EDITOR = False;

sub override-GUI_EDITOR( --> Bool:D) is export {
    return $override-GUI_EDITOR;
}

# the editor to use #
my Str $editor = '';
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

sub list-editors(Bool:D $colour is copy, Bool:D $syntax --> Bool) is export {
    $colour = True if $syntax;
    my Int:D $cnt = 0;
    my Str:D $mark = '';
    if $colour {
        if $syntax {
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-30s %-14s", 'editors', 'actual editor') ~ t.text-reset;
            $cnt++;
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-45s", '#' x 45) ~ t.text-reset;
            $cnt++;
            for @guieditors -> $ed {
                if $editor.trim.IO.basename eq $ed.trim.IO.basename {
                    $mark = '*';
                } else {
                    $mark = '';
                }
                put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,255,0) ~ sprintf("%-30s ", $ed) ~ t.color(255,0,255) ~ sprintf("%-14s", $mark) ~ t.text-reset;
                $cnt++;
            } # @guieditors -> $ed #
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-45s", '') ~ t.text-reset;
            $cnt++;
        } else { # if $syntax #
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-30s %-14s", 'editors', 'actual editor') ~ t.text-reset;
            $cnt++;
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-45s", '#' x 45) ~ t.text-reset;
            $cnt++;
            for @guieditors -> $ed {
                if $editor.trim.IO.basename eq $ed.trim.IO.basename {
                    $mark = '*';
                } else {
                    $mark = '';
                }
                put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-30s %-14s", $ed, $mark) ~ t.text-reset;
                $cnt++;
            } # @guieditors -> $ed #
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-45s", '') ~ t.text-reset;
            $cnt++;
        } # if $syntax else #
    } else { # if $colour #
        printf "%-30s %-10s\n", 'editors', 'actual editor';
        ('#' x 44).say;
        for @guieditors -> $ed {
            if $editor.trim.IO.basename eq $ed.trim.IO.basename {
                printf "%-30s %-10s\n", $ed, '*';
            } else {
                $ed.say;
            }
        } # @guieditors -> $ed #
        ''.say;
    } # if $colour else #
    return True;
} # sub list-editors(Bool:D $colour is copy, Bool:D $syntax --> Bool) is export #

sub list-editors-file(Bool:D $colour is copy, Bool:D $syntax --> Bool) is export {
    $colour = True if $syntax;
    my Int:D $cnt = 0;
    my Str:D $mark = '';
    if $colour {
        if $syntax {
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-30s %-14s", 'editors', 'actual editor') ~ t.text-reset;
            $cnt++;
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-45s", '#' x 45) ~ t.text-reset;
            $cnt++;
            for @gui-editors -> $ed {
                if $editor.trim.IO.basename eq $ed.trim.IO.basename {
                    $mark = '*';
                } else {
                    $mark = '';
                }
                put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,255,0) ~ sprintf("%-30s ", $ed) ~ t.color(255,0,0) ~ sprintf("%-14s", $mark) ~ t.text-reset;
                $cnt++;
            } # @gui-editors -> $ed #
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-45s", '') ~ t.text-reset;
            $cnt++;
        } else { # if $syntax #
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-30s %-14s", 'editors', 'actual editor') ~ t.text-reset;
            $cnt++;
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-45s", '#' x 45) ~ t.text-reset;
            $cnt++;
            for @gui-editors -> $ed {
                if $editor.trim.IO.basename eq $ed.trim.IO.basename {
                    $mark = '*';
                } else {
                    $mark = '';
                }
                put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-30s %-14s", $ed, $mark) ~ t.text-reset;
                $cnt++;
            } # @gui-editors -> $ed #
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-45s", '') ~ t.text-reset;
            $cnt++;
        } # if $syntax else #
    } else { # if $colour #
        printf "%-30s %-10s\n", 'editors', 'actual editor';
        ('#' x 44).say;
        for @gui-editors -> $ed {
            if $editor.trim.IO.basename eq $ed.trim.IO.basename {
                printf "%-30s %-10s\n", $ed, '*';
            } else {
                $ed.say;
            }
        } # @gui-editors -> $ed #
        ''.say;
    } # if $colour else #
    return True;
} # sub list-editors-file(Bool:D $colour is copy, Bool:D $syntax --> Bool) is export #

sub editors-stats(Bool:D $colour is copy, Bool:D $syntax --> Bool) is export {
    $colour = True if $syntax;
    my Int:D $cnt = 0;
    my %editors = '%*ENV«GUI_EDITOR»' => $GUI_EDITOR,
                  '%*ENV<VISUAL>' => $VISUAL,
                  '%*ENV<EDITOR>' => $EDITOR,
                  '$editor' => $editor,
                  '$override-GUI_EDITOR' => $override-GUI_EDITOR,
                  '@default-editors' => '[ "' ~ @default-editors.join('", "') ~ '" ]', 
                  '@override-gui_editor' => '[' ~ @override-gui_editor.join(', ') ~ ']';
    my Int:D $var-width        = 0;
    my Int:D $value-width      = 0;
    for %editors.kv -> $var, $value {
        $var-width         = max($var-width,     wcswidth($var));
        $value-width       = max($value-width,   wcswidth($value));
    } # for %editors.kv -> $var, $value #
    $var-width = max($var-width,  30);
    $var-width     += 2;
    $value-width   += 2;
    my Int:D $width = $var-width + $value-width + 4;
    if $colour {
        if $syntax {
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-*s => %-*s", $var-width, 'variable', $value-width, 'value') ~ t.text-reset;
            $cnt++;
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-*s", $width, '#' x $width) ~ t.text-reset;
            $cnt++;
            for %editors.keys.sort -> $var {
                my $value = %editors{$var};
                my $highlightedvar   = highlight-var($var);
                my $highlightedvalue = highlight-val($value);
                put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ left($highlightedvar, $var-width, :ref($var)) ~ t.red ~ ' => ' ~ left($highlightedvalue, $value-width, :ref("$value")) ~ t.text-reset;
                $cnt++;
            } # %editors.keys.sort -> $var #
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-*s", $width, '') ~ t.text-reset;
            $cnt++;
        } else { # if $syntax #
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-*s => %-*s", $var-width, 'variable', $value-width, 'value') ~ t.text-reset;
            $cnt++;
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-*s", $width, '#' x $width) ~ t.text-reset;
            $cnt++;
            for %editors.keys.sort -> $var {
                my $value = %editors{$var};
                put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-*s => %-*s", $var-width, $var, $value-width, $value) ~ t.text-reset;
                $cnt++;
            } # %editors.keys.sort -> $var #
            put (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,127,0)) ~ t.bold ~ t.color(0,0,255) ~ sprintf("%-*s", $width, '') ~ t.text-reset;
            $cnt++;
        } # if $syntax else #
    } else { # if $colour #
        printf "%-*s => %-*s\n", $var-width, 'variable', $value-width, 'value';
        ('#' x $width).say;
        for %editors.keys.sort -> $var {
                my $value = %editors{$var};
            printf "%-*s => %-*s\n", $var-width, $var, $value-width, $value;
        } # %editors.keys.sort -> $var #
        ''.say;
    } # if $colour else #
    return True;
} # sub editors-stats(Bool:D $colour is copy, Bool:D $syntax --> Bool) is export #
