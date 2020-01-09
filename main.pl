#!/usr/bin/perl -w

use Tk;
use strict;

my $mw = MainWindow->new; # creat main window.
$mw->geometry("600x400"); # set geometry.
$mw->title("Uzytkownicy"); # set title.

# create menu
my $menu = $mw->Frame(-relief=> 'groove', -borderwidth=>3, -background=>'white') ->pack(-side=>'top',-fill=>'x');
my $file_button = $menu->Menubutton(-text => "Exit", -background=>'white',-foreground=>'black',
                                    -menuitems => [ [ 'command' => "Exit","-command" => sub { exit }, "-underline" => 0 ] ]) -> pack(-side=>'left');
my $user_button = $menu->Menubutton(-text=>'User', -background=>'white',-foreground=>'black') -> pack(-side=>'left');
my $group_button = $menu->Menubutton(-text=>'Group', -background=>'white',-foreground=>'black') -> pack(-side=>'left');

# create options in menu
$user_button -> command(-label=>'Add User', -command=>\&add_user);
$user_button -> command(-label=>'Remove User', -command=>\&remove_user);

sub get_available_uid {
        my @list_user_uid = ();# empty list
        my $command = "cut -d: -f1,3 /etc/passwd"; # commnad with all users.

        # for all users.
        foreach my $users (`$command`) {
            my @spl = split(':',$users);# split line `root:0`
            my $uid = $spl[1];
            push @list_user_uid, $uid;# add uid to list
        }
    @list_user_uid = sort {$a <=> $b } @list_user_uid;

	return $list_user_uid[-1];

}

sub add_user {
	my $mwlocal = MainWindow->new();# creat main window.
    $mwlocal->geometry("200x300"); # set geometry.
    $mwlocal->title("Add User"); # set title.
	my $label_login = $mwlocal->Label(-text=>"Login",-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>2, -column=>0);
	my $entry_login = $mwlocal->Entry(-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>2, -column=>1);
	my $label_uid = $mwlocal-> Label(-text=>"UID",-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>3, -column=>0);
	my $entry_uid = $mwlocal-> Entry(-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>3, -column=>1);
    get_available_uid();



	MainLoop;
}

MainLoop;
