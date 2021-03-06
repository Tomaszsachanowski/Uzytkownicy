#!/usr/bin/perl -w

use Tk;
use strict;
# do generowania hasłą
use String::Random;
# poniżej zmienne przechowujące inoramcje 
my $global_login;
my $global_UID;
my $global_GID=1001;
my $global_password;
# domyślne prametry przy tworzeniu użytkownika
my $global_shell = "/bin/sh";
my $global_homedir = "/home/";
my $global_command = "cat /etc/passwd";
my $global_save_file = "/var/uzytkownicy";

my $mw = MainWindow->new; # stwórz główne okno.
$mw->geometry("600x400"); # ustaw wymiary.
$mw->title("Uzytkownicy"); # ustaw tytół.

# stórz gółówne menu
my $menu = $mw->Frame(-relief=> 'groove', -borderwidth=>3, -background=>'white') ->pack(-side=>'top',-fill=>'x');
my $file_button = $menu->Menubutton(-text => "Exit", -background=>'white',-foreground=>'black',
                                    -menuitems => [ [ 'command' => "Exit","-command" => sub { exit }, "-underline" => 0 ] ]) -> pack(-side=>'left');
my $user_button = $menu->Menubutton(-text=>'User', -background=>'white',-foreground=>'black') -> pack(-side=>'left');
my $group_button = $menu->Menubutton(-text=>'Group', -background=>'white',-foreground=>'black') -> pack(-side=>'left');

# opcje dla menu
$user_button -> command(-label=>'Add User', -command=>\&add_user);
$user_button -> command(-label=>'Remove User', -command=>\&remove_user);

$group_button -> command(-label=>'Add groups', -command=>\&add_groups);
$group_button -> command(-label=>'Remove groups', -command=>\&remove_groups);

# funkcja generująca hasło C duza litera n cyfra ! znak
sub generate_password {
    my $pass = String::Random->new;
    return $pass->randpattern("C!nC!ncc!ccn");

}

# funkcja do zwrócenia ostatniego zajetego uid
sub get_available_uid {
        my @list_user_uid = ();# pusta lista
        my $command = "cut -d: -f1,3 /etc/passwd"; # polecenie do wyszukanai wszystkich użutkowników.

        # pętla po użytkownikach.
        foreach my $users (`$command`) {
            my @spl = split(':',$users);# split line `root:0`
            my $uid = $spl[1];
            # warunke i numer uid
            if ( ($uid >= 1000) && ($uid <= 60000) ){
                push @list_user_uid, $uid;# add uid to list
            }
        }
    # sortowanie listy uid
    @list_user_uid = sort {$a <=> $b } @list_user_uid;
    # wybieram ostatni zajety uid potem dodam 1.
	return $list_user_uid[-1];

}
# sprawdzenei loginu
sub check_login {
    my ($login) = @_;# user_name = arrgument
    		if ( "$login" eq "" ){
                return my $tmp = "Empty login";
		}else{
            foreach my $process (`$global_command`) {
                my @spl = split(':',$process);# split line `root     14353 kworker/u8:2`
                my $user = $spl[0];
                # czy wybrany login jest juz w passwd
                if (($user eq "$login")==1){
                    return my $tmp = "login exist";
                }
            }
        }
}
# funkcja do sprawdzenia uid
sub check_uid {
        my ($uid) = @_;# uid = arrgument
    # czy jest numerem?
    if ($uid =~ /^[0-9,.E]+$/){
        # czy juz taki istnieje w etc/passwd
        foreach my $process (`$global_command`) {
            my @spl = split(':',$process);# split line `root:14353 `
            my $uid_tmp = $spl[2];# czy login jest już zajety.
            if (($uid_tmp == "$uid")==1){
                return my $tmp = "uid exist";
            }
        }
    }else { # mamy dozynienia z stringiem
        return my $tmp = "uid is string";
        }
    # czy numer nalezy do przedziału
    if ( ($uid <= 1000) || ($uid >= 60000) ){
        return my $tmp = "uid <1000, >60000";

    }
    # czy nie jest pusty
    elsif ( $uid eq "" ){
        return my $tmp = "Empty uid";
    }
}

# Sprawdzami numer gid
sub check_gid {
        my ($gid, $login) = @_;# gid = arrgument 1, login = agrument 2
        # Czy to jest numer i czy nalezy do odpoiwedniego przedziału
    if ($gid =~ /^[0-9,.E]+$/){
            if ( $gid < 1000 || $gid >= 65534 ){
                return my $tmp = "false gid";
		    }
        }else {
            return my $tmp = "gid is string";
        }
    # czy mamy dostępny podnay gid
    foreach my $process (`cat /etc/group`) {
                my @spl = split(':',$process);# split line `root     14353 kworker/u8:2`
                my $gid_tmp = $spl[2];# if process doesn't belongs to root.
                if (($gid_tmp == "$gid")==1){
                    return "";
                }
    }
    # jak podany numer nie istniej tworze nowa grupe o nzwie podanego użytkowniak
    `groupadd -g $gid $login`;
    return "";
                
}

# funkcja do dodnia użytkownika
sub add_user {

    # Tworze okna geometrie tytów oraz label tyczące sie danego parametru wraz z elementami tekstowymi obok.
	my $mwlocal = MainWindow->new();# creat main window.
    $mwlocal->geometry("300x300"); # set geometry.
    $mwlocal->title("Add User"); # set title.
	my $label_login = $mwlocal->Label(-text=>"Login",-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>2, -column=>0);
	my $entry_login = $mwlocal->Entry(-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>2, -column=>1);
	my $label_uid = $mwlocal-> Label(-text=>"UID",-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>3, -column=>0);
	my $entry_uid = $mwlocal-> Entry(-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>3, -column=>1);

	$global_UID = get_available_uid()+1; # do ostaniego zajetego uid dodjae 1 i jest to pierwszy wolny numer
	$entry_uid -> insert(0,$global_UID);

	my $label_password = $mwlocal-> Label(-text=>"password",-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>4, -column=>0);
	my $entry_password = $mwlocal-> Entry(-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>4, -column=>1);
    
    $global_password = generate_password(); # dodaje wygenerowane hasło
    $entry_password -> insert(0,$global_password);

	my $label_gid = $mwlocal-> Label(-text=>"GID",-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>5, -column=>0);
	my $entry_gid = $mwlocal-> Entry(-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>5, -column=>1);

    $entry_gid -> insert(0,$global_GID);

    # label with warnings. 
    my $label_warning = $mwlocal->Label(-text => "Warning:",-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>6, -column=>1);


    my $creat_button = $mwlocal -> Button(-text=>"Add", -command => sub{
        # guzik button wraz z funkcja uruchamiajaća po wciśnieciu go
        # jesli tmp nie jest pustym stringiem to mamy doczynienia z błedem któ©y wyświetlamy w Warning. 
        my $tmp = check_login($entry_login->get());
        if ( $tmp ne ""){
			$label_warning->configure(-text=>"Warning: $tmp!");
			return;
        }
        $tmp = check_uid($entry_uid->get());
        if ( $tmp ne ""){
			$label_warning->configure(-text=>"Warning: $tmp!");
			return;
        }

		if ( $entry_password->get() eq "" ){
			$label_warning->configure(-text=>"Warning: Empty PASSWORD!");
			return;
		}
        $tmp = check_gid($entry_gid->get(), $entry_login->get());
        if ( $tmp ne ""){
			$label_warning->configure(-text=>"Warning: $tmp!");
			return;
        }
        # teraz gdy wszsytkie dane sa poprawne 
        # pobieram dane z pól tekstowych  i umieszaczam je w poleceniu useradd
        else{
            my $tmp = "";
			$label_warning->configure(-text=>"Correct data!");

            $global_password = $entry_password->get();
            my $pass=crypt($global_password,"salt"); # towrzenei zaszfrowanego hasła wymóg przez polecenie useradd
            my $shell = "/bin/sh";

            $global_UID = $entry_uid->get();
            $global_login = $entry_login->get();
            $global_GID = $entry_gid->get();
            print "$global_UID $global_login $global_GID $global_password\n";

		    `useradd -u $global_UID -s $shell -m -p $pass -g $global_GID $global_login`;
            #zapisuje informacje o dodnaym uzytkowniu do pliku /var/uzytkownicy
            `echo "$global_login:$global_UID:$global_password">>$global_save_file`;
            # wprowadzam nowe dane do formulaza aby moc dodac kolejnego uzytkownika
            $global_UID = get_available_uid()+1;
            $entry_uid->delete(0,999);
	        $entry_uid -> insert(0,$global_UID);
            $global_password = generate_password();
            $entry_password->delete(0,999);
            $entry_password -> insert(0,$global_password);

        }
    }
    )->grid(-row=>7, -column=>0);

    my $exit_button = $mwlocal -> Button(-text=>"Exit", -command => sub { $mwlocal->DESTROY})->grid(-row=>7, -column=>1);

	MainLoop;
}

sub list_all_user{
    # creat list of all users
    # from file /etc/passwd and command `ps -e -o user`

    my @list_users = ();# creat empty list
    foreach my $file (`cut -d: -f1,3 /etc/passwd`) {
    my @spl = split(':',$file);# split line `root:x:0:0:root:/root:/bin/bash`
    my $user = $spl[0];# frst element is user name.
    my $uid_name = $spl[1];
    if ( ($uid_name > 100) && ($uid_name <= 60000) ){
        push @list_users, $user;# add user to list
        }
    }
    return @list_users;# return all list of users
}

sub list_all_groups{
    # creat list of all groups
    # from file /etc/group and command `ps -e -o user`

    my @list_groups = ();# creat empty list
    foreach my $line (`cut -d: -f1,3 /etc/group`) {
    my @spl = split(':',$line);# split line `root:x:0:0:root:/root:/bin/bash`
    my $group = $spl[0];# frst element is user name.
    my $gid_name = $spl[1];
    if ( ($gid_name > 1000) && ($gid_name <= 60000) ){
        push @list_groups, $group;# add user to list
        }
    }
    return @list_groups;# return all list of users
}

sub remove_user {
        my $user;
        my $uid_name;
        my $gid_name;
        my $home_name;
        my $shell_name;
    my $mwlocal = MainWindow->new();# creat main window.
    $mwlocal->geometry("400x300"); # set geometry.
    $mwlocal->title("Remove User"); # set title.
    my $left_frame = $mwlocal->Frame(-background => 'cyan')->pack(-side => "left"); # add main frame.
    my $right_frame = $mwlocal->Frame(-background => 'cyan')->pack(-side => "right",); # add main frame.

    # # list of users from file /etc/passwd.
    my @all_users = list_all_user();
    # #Add Listbox of all users.
    my $listbox_all_user = $left_frame->Scrolled("Listbox", -scrollbars => "osoe")->pack();
    my $label_user_name = $right_frame->Label(-text => "User information:")->grid(-row=>1, -column=>0);
    # text widget where we see all process information for some user.                                                                                                                                                                           
	my $label_login = $right_frame->Label(-text=>"Login",-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>2, -column=>0);
	my $entry_login = $right_frame->Entry(-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>2, -column=>1);
	my $label_uid = $right_frame-> Label(-text=>"UID",-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>3, -column=>0);
	my $entry_uid = $right_frame-> Entry(-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>3, -column=>1);

	my $label_dir = $right_frame-> Label(-text=>"home_dir",-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>4, -column=>0);
	my $entry_dir = $right_frame-> Entry(-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>4, -column=>1);

	my $label_gid = $right_frame-> Label(-text=>"GID",-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>5, -column=>0);
	my $entry_gid = $right_frame-> Entry(-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>5, -column=>1);

	my $label_shell = $right_frame-> Label(-text=>"shell",-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>6, -column=>0);
	my $entry_shell = $right_frame-> Entry(-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>6, -column=>1);
    my $label_warning = $right_frame->Label(-text => "Warning:",-background=>'white',-foreground=>'black',-relief => 'sunken')->grid(-row=>7, -column=>1);

    my $exit_button = $right_frame -> Button(-text=>"Exit", -command => sub { $mwlocal->DESTROY})->grid(-row=>8, -column=>1);

    # #Add array with users to Listbox.
    $listbox_all_user->insert("end",@all_users);
    # #add event if we click a item from Listbox we run change_user function.
    $listbox_all_user->bind('<Button-1>'=> sub {
                            #get user name from Listbox. $_[0] is event from Listbox  
                            my $user_name = $_[0]->get($_[0]->curselection);
                            # joining string.
                            my $text = "User information:" . $user_name;
                            # Update label with information about user name.
                            $label_user_name->configure(-text=>"$text");

                            foreach my $file (`$global_command`) {
                            my @spl = split(':',$file);# split line `root:x:0:0:root:/root:/bin/bash`
                            $user = $spl[0];# frst element is user name.
                            $uid_name = $spl[2];
                            $gid_name = $spl[3];
                            $home_name = $spl[-2];
                            $shell_name = $spl[-1];
                            if ($user eq $user_name ){
                                $entry_login->delete(0,999);
                                $entry_login -> insert(0,$user);
                                $entry_uid->delete(0,999);
                                $entry_uid -> insert(0,$uid_name);

                                $entry_dir->delete(0,999);
                                $entry_dir -> insert(0,$home_name);
                                $entry_gid->delete(0,999);
                                $entry_gid -> insert(0,$gid_name);
                                $entry_shell->delete(0,999);
                                $entry_shell -> insert(0,$shell_name);
                                }
                            }

                        });

    my $delete_button = $right_frame -> Button(-text=>"Delete", -command => sub {
                                    my $tmp = $entry_login->get();
                                    `sudo userdel $tmp`;
                                    @all_users = list_all_user();
                                    $listbox_all_user->delete(0,999);
                                    $listbox_all_user->insert("end",@all_users);
                                        $entry_login->delete(0,999);
                                        $entry_uid->delete(0,999);
                                        $entry_dir->delete(0,999);
                                        $entry_gid->delete(0,999);
                                        $entry_shell->delete(0,999);
                                        my $text = "User information:";
                                        # Update label with information about user name.
                                        $label_user_name->configure(-text=>"$text");
        })->grid(-row=>7, -column=>0);
    
    my $modif_button = $right_frame -> Button(-text=>"Modif_user", -command => sub {

        my $command = "cut -d: -f1,3 /etc/passwd";

        my $user_modif = $entry_login->get();
        if($user_modif ne $user){
            my $tmp = check_login($user_modif);
            if ( $tmp ne ""){
                $label_warning->configure(-text=>"Warning: $tmp!");
                return;
            }

            `usermod -l $user_modif $user`;
        }

        my $uid_modif = $entry_uid->get();
        if($uid_modif ne $uid_name){
            my $tmp = check_uid($uid_modif);
            if ( $tmp ne ""){
                $label_warning->configure(-text=>"Warning: $tmp!");
                return;
            }

            `usermod -u $uid_modif $user_modif`;
        }
        
        my $gid_modif = $entry_gid->get();
        if($gid_modif ne $gid_name){
            my $tmp = check_gid($gid_modif, $user_modif);
            print "tu jestem $tmp";
            if ( $tmp ne ""){
                $label_warning->configure(-text=>"Warning: $tmp!");
                return;
            }

            `usermod -g $uid_modif $user_modif`;
        }

        @all_users = list_all_user();
        $listbox_all_user->delete(0,999);
        $listbox_all_user->insert("end",@all_users);
        $entry_login->delete(0,999);
        $entry_uid->delete(0,999);
        $entry_dir->delete(0,999);
        $entry_gid->delete(0,999);
        $entry_shell->delete(0,999);
        my $text = "User information:";
        # Update label with information about user name.
        $label_user_name->configure(-text=>"$text");
    })->grid(-row=>8, -column=>0);

	MainLoop;

}

# funkcja do usuwania group
sub remove_groups {

    my $mwlocal = MainWindow->new();# creat main window.
    $mwlocal->geometry("400x300"); # set geometry.
    $mwlocal->title("Remove User Groups"); # set title.
    my $left_frame = $mwlocal->Frame(-background => 'cyan')->pack(-side => "left"); # add main frame.
    my $right_frame = $mwlocal->Frame(-background => 'cyan')->pack(-side => "right",); # add main frame.
    my $group_name = "";
    my $user_name = "";
    # # list of users from file /etc/passwd.
    my @all_users = list_all_user();
    my @user_groups_list;
    my $listbox_all_user = $left_frame->Scrolled("Listbox", -scrollbars => "osoe")->pack();
    # #Add array with users to Listbox.
    $listbox_all_user->insert("end",@all_users);
    my $listbox_all_user_groups = $right_frame->Scrolled("Listbox", -scrollbars => "osoe")->grid(-row=>1, -column=>0);
    
    
    # #add event if we click a item from Listbox we run change_user function.
    $listbox_all_user->bind('<Button-1>'=> sub {
            $user_name = $_[0]->get($_[0]->curselection);
            foreach my $group (`groups $user_name`) {
                my @spl = split(' ',$group);# split line `root:x:0:0:root:/root:/bin/bash`
                my $max_index = $#spl;
                @user_groups_list = @spl[3..$max_index];
                $listbox_all_user_groups->delete(0,999);
                $listbox_all_user_groups->insert("end",@user_groups_list);


            }
        });
    $listbox_all_user_groups->bind('<Button-1>'=> sub {
            $group_name = $_[0]->get($_[0]->curselection);
        });

    my $remove_button = $right_frame -> Button(-text=>"Remove group", -command => sub {
        if (($group_name ne "") && ($user_name ne "")){
            `deluser $user_name $group_name`;
            foreach my $group (`groups $user_name`) {
                my @spl = split(' ',$group);# split line `root:x:0:0:root:/root:/bin/bash`
                my $max_index = $#spl;
                @user_groups_list = @spl[3..$max_index];
                $listbox_all_user_groups->delete(0,999);
                $listbox_all_user_groups->insert("end",@user_groups_list);
           
            }
        }
    })->grid(-row=>2, -column=>0);
    my $exit_button = $right_frame -> Button(-text=>"Exit", -command => sub { $mwlocal->DESTROY})->grid(-row=>2, -column=>1);

    MainLoop;

}

sub add_groups {
    my $mwlocal = MainWindow->new();# creat main window.
    $mwlocal->geometry("400x300"); # set geometry.
    $mwlocal->title("Remove User Groups"); # set title.
    my $left_frame = $mwlocal->Frame(-background => 'cyan')->pack(-side => "left"); # add main frame.
    my $right_frame = $mwlocal->Frame(-background => 'cyan')->pack(-side => "right",); # add main frame.
    my $group_name = "";
    my $user_name = "";
    # # list of users from file /etc/passwd.
    my @all_users = list_all_user();
    my @all_groups = list_all_groups();
    my @user_groups_list;
    my $listbox_all_user = $left_frame->Scrolled("Listbox", -scrollbars => "osoe")->pack();
    # #Add array with users to Listbox.
    $listbox_all_user->insert("end",@all_users);
    my $listbox_all_user_groups = $right_frame->Scrolled("Listbox", -scrollbars => "osoe")->grid(-row=>1, -column=>0);
    $listbox_all_user_groups->insert("end",@all_groups);

    $listbox_all_user->bind('<Button-1>'=> sub {
            $user_name = $_[0]->get($_[0]->curselection);
        });

    $listbox_all_user_groups->bind('<Button-1>'=> sub {
            $group_name = $_[0]->get($_[0]->curselection);
        });

    my $add_button = $right_frame -> Button(-text=>"Add to group", -command => sub {
        if (($group_name ne "") && ($user_name ne "")){
            `usermod -a -G $group_name $user_name`;
            }
    })->grid(-row=>2, -column=>0);
    my $exit_button = $right_frame -> Button(-text=>"Exit", -command => sub { $mwlocal->DESTROY})->grid(-row=>2, -column=>1);

    MainLoop;

}

MainLoop;
