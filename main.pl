#!/usr/bin/perl -w

use Tk;
use strict;
use String::Random;

my $global_login;
my $global_UID;
my $global_GID=1001;
my $global_password;
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

sub generate_password {
    my $pass = String::Random->new;
    return $pass->randpattern("C!nC!ncc!ccn");

}
sub get_available_uid {
        my @list_user_uid = ();# empty list
        my $command = "cut -d: -f1,3 /etc/passwd"; # commnad with all users.

        # for all users.
        foreach my $users (`$command`) {
            my @spl = split(':',$users);# split line `root:0`
            my $uid = $spl[1];
            if ( ($uid >= 1000) && ($uid <= 60000) ){
                push @list_user_uid, $uid;# add uid to list
            }
        }
    @list_user_uid = sort {$a <=> $b } @list_user_uid;

	return $list_user_uid[-1];

}

sub check_login_uid_gid {
    my @list_user = ();# empty list
    my ($user_name, $uid_name, $gid_name) = @_;# user_name = arrgument
    my $command = "cut -d: -f1,3 /etc/passwd";
        foreach my $process (`$command`) {
            my @spl = split(':',$process);# split line `root     14353 kworker/u8:2`
            my $user = $spl[0];# if process doesn't belongs to root.
            if (($user eq "$user_name")==1){
                return my $tmp = "false user name";
            }
        }
    if ($uid_name =~ /^[0-9,.E]+$/){
        foreach my $process (`$command`) {
            my @spl = split(':',$process);# split line `root     14353 kworker/u8:2`
            my $uid = $spl[1];# if process doesn't belongs to root.
            if (($uid == "$uid_name")==1){
                return my $tmp = "false uid";
            }
        }
    }else {
        return my $tmp = "uid is string";
        }
    if ( ($uid_name <= 1000) || ($uid_name >= 60000) ){
        return my $tmp = "false uid <1000";

    }
    if ($gid_name =~ /^[0-9,.E]+$/){
            if ( $gid_name <= 1000 || $gid_name >= 65534 ){
                return my $tmp = "false gid";
		    }
        }else {
            return my $tmp = "gid is string";
        }
}

sub add_user {

	my $mwlocal = MainWindow->new();# creat main window.
    $mwlocal->geometry("300x300"); # set geometry.
    $mwlocal->title("Add User"); # set title.
	my $label_login = $mwlocal->Label(-text=>"Login",-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>2, -column=>0);
	my $entry_login = $mwlocal->Entry(-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>2, -column=>1);
	my $label_uid = $mwlocal-> Label(-text=>"UID",-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>3, -column=>0);
	my $entry_uid = $mwlocal-> Entry(-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>3, -column=>1);

	$global_UID = get_available_uid()+1;
	$entry_uid -> insert(0,$global_UID);

	my $label_password = $mwlocal-> Label(-text=>"password",-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>4, -column=>0);
	my $entry_password = $mwlocal-> Entry(-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>4, -column=>1);
    
    $global_password = generate_password();
    $entry_password -> insert(0,$global_password);

	my $label_gid = $mwlocal-> Label(-text=>"GID",-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>5, -column=>0);
	my $entry_gid = $mwlocal-> Entry(-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>5, -column=>1);

    $entry_gid -> insert(0,$global_GID);

    # label with warnings. 
    my $label_warning = $mwlocal->Label(-text => "Warning:",-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>6, -column=>1);


    my $creat_button = $mwlocal -> Button(-text=>"Add", -command => sub{
        
        my $tmp = check_login_uid_gid($entry_login->get(),$entry_uid->get(), $entry_gid->get());
		if ( $entry_login->get() eq "" ){
			$label_warning->configure(-text=>"Warning: Empty login!");
			return;
		}
		elsif ( $entry_uid->get() eq "" ){
			$label_warning->configure(-text=>"Warning: Empty UID!");
			return;
		}
		elsif ( $entry_password->get() eq "" ){
			$label_warning->configure(-text=>"Warning: Empty PASSWORD!");
			return;
		}
		elsif ( $entry_gid->get() eq "" ){
			$label_warning->configure(-text=>"Warning: Empty GID!");
			return;
		}
		elsif ( $tmp ne "" ){
			$label_warning->configure(-text=>"Warning: $tmp!");
			return;
		}
        else{
			$label_warning->configure(-text=>"Correct data!");

            $global_password = $entry_password->get();
            my $pass=crypt($global_password,"salt");
            my $shell = "/bin/sh";

            $global_UID = $entry_uid->get();
            $global_login = $entry_login->get();
            $global_GID = $entry_gid->get();
            print "$global_UID $global_login $global_GID $global_password\n";
		    `useradd -u $global_UID -s $shell -m -p $pass $global_login`;

            $global_UID = get_available_uid()+1;
            $entry_uid->delete(0,999);
	        $entry_uid -> insert(0,$global_UID);
            $global_password = generate_password();
            $entry_password->delete(0,999);
            $entry_password -> insert(0,$global_password);

        }
    }
    )->grid(-row=>7, -column=>0);

	MainLoop;
}

MainLoop;
