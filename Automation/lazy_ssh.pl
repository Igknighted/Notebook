#!/bin/perl
# This is a really lazy automation example in perl.
# It will wget the latest wordpress files and throw them into a the directory specified. 

use Expect;

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


$exp = new Expect();
#$exp->raw_pty(1);  
#$exp->log_stdout(0);
$exp->spawn("ssh -l $user $host -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no");
 
$exp->expect(20, ['[Pp]assword:']);
$exp->send("$pw\n");

# Set a custom prompt so things don't get murky.
$exp->expect(10, ['[\#\$]']);
$exp->send("PS1='_# '\n");


# If the specified directory doesn't exist, we will make it exist.
$exp->expect(10, ['_[\#]']);
$exp->send("mkdir -p ~/$dir\n");

# Go to the directory
$exp->expect(10, ['_[\#]']);
$exp->send("cd ~/$dir\n");


# Get latest.tar.gz from wordpress.org
$exp->expect(10, ['_[\#]']);
$exp->send("wget https://wordpress.org/latest.tar.gz\n");

# Extract the wordpress files
$exp->expect(10, ['_[\#]']);
$exp->send("tar -xzf latest.tar.gz\n");

# Move the wordpress files directly into this dir.
$exp->expect(10, ['_[\#]']);
$exp->send("cp -rf wordpress/* .\n");

# Remove the empty wordpress directory and latest.tar.gz.
$exp->expect(10, ['_[\#]']);
$exp->send("rm -rf wordpress latest.tar.gz\n");

# Logout. 
$exp->expect(10, ['_[\#]']);
$exp->send("logout\n");

# Close the connection
$exp->expect(10, ['_[\#]']);
$exp->close();   
