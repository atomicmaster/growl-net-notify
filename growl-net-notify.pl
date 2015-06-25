#
# Copyright (c) 2009 by kinabalu (andrew AT mysticcoders DOT com)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

#
# Growl Notification script over network using Net::Growl
#
# History:
#
# 2015-06-25, comradical <niksoft AT gmail DOT com>
#	version 0.5, rewritten again for GNTP
#
#
# 2009-04-16, kinabalu <andrew AT mysticcoders DOT com>
#	version 0.2, removed need for Parse::IRC
#
# 2009-04-10, kinabalu <andrew AT mysticcoders DOT com>
#	version 0.1, initial version rewritten from growl-notify
#   - original inspiration from growl-notify.pl author Zak Elep
#
# /growl on
# /growl off
# /growl setup [host] [password]
# /growl inactive [time_in_seconds]
# /growl status
# /growl test [message]
# /help growl
#
# The script can be laoded into WeeChat by executing:
#
# /perl load growl-net-notify.pl
#
# The script may also be auto-loaded by WeeChat.  See the
# WeeChat manual for instructions about how to do this.
#
# This script was tested with WeeChat version 0.2.6.  An
# updated version of this script will be available when
# the new WeeChat API is officially released.
#
# For up-to-date information about this script, and new
# version downloads, please go to:
#
# http://www.mysticcoders.com/apps/growl-notify/
#
# If you have any questions, please contact me on-line at:
#
# irc.freenode.net - kinabalu (op): ##java
#
# - kinabalu
#

use Growl::GNTP;
use integer;
use strict;
#use warnings;

my $version = "0.5";
my $description   = "WeeChat Growl Notification";
my $authors  = "kinabalu <andrew AT mysticcoders DOT com>,  niksoft <niksoft AT gmail DOT com>";
my $license = "GPL2";
my $language    = "perl";

# Growl App Presets
my $growl_app = "growl-net-notify";	# name given to Growl for configuration
my $growl_command = "growl";
my $growl_active = 1;
my $growl = 0;

# Growl App Defaults
my $default_growl_net_pass = "password";
my $default_growl_net_client = "localhost";
my $default_growl_net_inactivity = 30;
my $default_growl_net_port = 23054;

#
# Script setup
#

weechat::register($growl_app, $authors, $version, $license, $description, "", "");

#$wee_version_number = weechat::info_get("version_number", "") || 0;
		
weechat::hook_command($growl_command, $description, 	  "on|off|setup [host] [password] [port]|inactive [time_in_seconds]|status|help",
								  "on: turn on growl notifications (default)\n"
								 ."off: turn off growl notifications\n"
								 ."setup [host] [password] [port]: change the parameters for registration/notification with Growl\n"
								 ."inactive [time_in_seconds]: number of seconds of inactivity before we notify (default: 30)\n"
							  	 ."status: gives info on notification and inactivity settings\n"
							  	 ."test [message]: send a test message\n",
							  	 "on|off|setup|inactive|status",
							  	"handler", "");

&setc("growl_net_pass", $default_growl_net_pass) if (&getc("growl_net_pass") eq "");
&setc("growl_net_client", $default_growl_net_client) if (&getc("growl_net_client") eq "");
&setc("growl_net_inactivity", $default_growl_net_inactivity) if (&getc("growl_net_inactivity") eq "");
&setc("growl_net_port", $default_growl_net_port) if (&getc("growl_net_port") eq "");
		
# register our app with growl		
growl_register( &getc('growl_net_client'), &getc('growl_net_pass'), &getc('growl_net_port'), "$growl_app" );

# send up a we're here and notifying 
growl_notify("$growl_app", "Starting Up", "Weechat notification through Growl = on" );

message_process_init();

return weechat::WEECHAT_RC_OK;

# functions

sub message_process_init {

	weechat::add_message_handler("weechat_highlight", "highlight_public");
	weechat::add_message_handler("weechat_pv", "highlight_privmsg");
}

#
# support for private messages, have to parse the IRC message
#
sub highlight_privmsg {
    my ( $nick, $message ) = ( $_[1] =~ /:([^!]+)[^:]+:(.*)/ );
    
	send_message($nick, $message);    
	return weechat::WEECHAT_RC_OK;	
}

#
# support for highlights of nicks in public, have to parse the IRC message
#
sub highlight_public {
	my ( $nick, $channel, $message ) = ( $_[1] =~ /:([^!]+)[^#]+([^:]+):(.*)/ );
		
	send_message($nick, $message . " in " . $channel); 
	return weechat::WEECHAT_RC_OK;	
}

sub send_message {
	my ( $nick, $message ) = @_;
	
	my $inactivity = 0;
	
	$inactivity = weechat::get_info("inactivity");
		
	if((&getc('growl_net_inactivity') - $inactivity) <= 0 && $growl_active) {
		growl_notify("$growl_app", "$nick", "$message" );
	}			
}

#
# smaller way to do weechat::config_get_plugin
#
sub getc {
	return weechat::config_get_plugin($_[0]);
}

#
# smaller way to do weechat::config_get_plugin
#
sub setc {
	return weechat::config_set_plugin($_[0], $_[1]);
}


#
# print function
# 
sub prt {
	weechat::print("", $_[0]);
}

#
# Send notification through growl
#
# args: $application_name, $title, $description
#
sub growl_notify {
	if(!$growl){
		growl_register(&getc('growl_net_client'), &getc('growl_net_pass'), &getc('growl_net_port'), "$growl_app");
	}

	$growl->notify(	Event=> $_[0], 
				Title=> $_[1], 
				Message => $_[2], 
				Priority=> 0, 
				Sticky=> 'True'
				);
}

#
# Register your app with Growl system
#
# args: $host, $pass, $port, $app
#
sub growl_register {
	prt("$_[0], $_[2], $_[3]");
	my $enabled = 'False';
	$growl = Growl::GNTP->new( AppName => $growl_app,
					 PeerHost => $_[0],
					 Password => $_[1],
					 PeerPort => $_[2],
					 AppName => $_[3],
					 Timeout => 30,
					 );


	if($growl_active) {
		$enabled = 'True';
	}
	
	$growl->register([	{
				Name => $growl_app,
				DisplayName => "WeeChat Growl Notification",
				Enabled => $enabled,
				Sticky => "True"
				}
				]);
}

#
# Handler will process commands
#
# /growl on
# /growl off
# /growl setup [host] [password] [port]
# /growl inactive [time_in_seconds]
# /growl status
# /growl test [message]
# /help growl
#
sub handler {

	my $args = $_[2];				# get argument 
	$args = lc($args);				# switch argument to lower-case

	my @arr = split(/ /, $args);
	my $command = $arr[0];	
		
	if(!$command) {
		prt("Rawr!");
		return weechat::WEECHAT_RC_OK;
	}
	
	if($command eq "off") {
		$growl_active = 0;
		prt("Growl notifications: OFF");
	} elsif($command eq "on") {
		$growl_active = 1;
		prt("Growl notifications: ON");
	} elsif($command eq "inactive") {
		if(exists $arr[1] && $arr[1] >= 0) {
			setc("growl_net_inactivity", $arr[1]);
			prt("Growl notifications inactivity set to: " . $arr[1] . "s");
		}
	} elsif($command eq "setup") {
		if(exists $arr[1] && $arr[1] ne "") {
			setc("growl_net_client", $arr[1]);			
		} 
		if(exists $arr[2] && $arr[2] ne "") {
			setc("growl_net_pass", $arr[2]);
		}
		if(exists $arr[3] && $arr[3] ne "") {
			setc("growl_net_port", $arr[3]);
		}
		growl_register( &getc('growl_net_client'), &getc('growl_net_pass'), &getc('growl_net_port'), "$growl_app" );				
		prt("Growl setup re-registered with: [host: " . &getc('growl_net_client') . ":"  . &getc('growl_net_port') . ", pass: " . &getc('growl_net_pass') . "]"); 
	} elsif($command eq "status") {
		prt("Growl notifications: " . ($growl_active ? "ON" : "OFF") . ", inactivity timeout: " . &getc("growl_net_inactivity"));
	} elsif($command eq "test") {
		my $test_message = substr $args, 5;
		prt("Sending test message: " . $test_message);
		growl_notify("$growl_app", "Test Message", $test_message );
	} else {
		prt("Umm, whaaat");
	}
	return weechat::WEECHAT_RC_OK;
}