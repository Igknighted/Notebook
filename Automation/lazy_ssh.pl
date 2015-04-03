#!/bin/perl
use Expect;


sub run {
	$cmd = $_[0];
	$exp->expect(undef, [$prompt => sub { $exp->send("$cmd\n"); } ]);
}


# Make sure user supplied all 4 arguments 
if ($#ARGV != 3) {
    print "\nArguments required: ssh_username ssh_hostname ssh_password directory\n";
    exit;
}

# Setup variables for our arguments
$user = $ARGV[0];
$host = $ARGV[1];
$pw   = $ARGV[2];
$dir  = $ARGV[3];
# Setup our config variables
$prompt = "_# ";
$exp = new Expect();

# Some debugging stuff
#$exp->raw_pty(1);  
#$exp->log_stdout(0);

# Execute our SSH command.
$exp->spawn("ssh -l $user $host -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no");

# Login to the server
$exp->expect(undef, ["[Pp]assword:" => sub { $exp->send("$pw\n"); } ]);
# Set the prompt to something we can trust
$exp->expect(undef, ["[#\$]" => sub { $exp->send("PS1='$prompt'\n"); } ]);


run("mkdir -p ~/$dir");
run("cd ~/$dir");
run("touch testing12345");
run("exit");


# If we want to provide an interactive shell, we can...
#$exp->interact();

# Doing a soft_close makes expect wait patiently for the EOF
$exp->soft_close();   
