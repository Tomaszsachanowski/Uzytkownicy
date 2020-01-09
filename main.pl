#!/usr/bin/perl -w

use Tk;
use strict;

my $mw = MainWindow->new; # creat main window.
$mw->geometry("600x400"); # set geometry.
$mw->title("Uzytkownicy"); # set title.

# create menu
my $menu = $mw->Frame(-relief=> 'groove', -borderwidth=>3, -background=>'white') ->pack(-side=>'top',-fill=>'x');
my $file_button = $menu->Menubutton(-text=>'File', -background=>'white',-foreground=>'black') -> pack(-side=>'left');
my $user_button = $menu->Menubutton(-text=>'User', -background=>'white',-foreground=>'black') -> pack(-side=>'left');
my $group_button = $menu->Menubutton(-text=>'Group', -background=>'white',-foreground=>'black') -> pack(-side=>'left');



MainLoop;
