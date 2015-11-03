# Multi-user git setup


#### Setup the server
```
# yum install git -y
# useradd git
# passwd -l git
# su - git
$ wget https://raw.githubusercontent.com/Igknighted/Notebook/master/git/utils/gitserve
$ mv -fv gitserve ~/bin/gitserve
$ chmod +x ~/bin/gitserve
```

#### Add an SSH key
```
$ cat ~/.ssh/authorized_keys
command="/home/git/bin/gitserve username",no-port-forwarding,no-agent-forwarding,no-X11-forwarding,no-pty {SSH KEY LINE HERE}
```

#### Add user to repo
```
$ cat ~/git_repos
username username/repo_name.git
```


#### Initiate a repo
```
$ git init username/repo_name.git
$ git --git-dir=username/repo_name.git/.git/ config receive.denyCurrentBranch ignore
```


#### Make a change locally to the repo
```
$ cd username/repo_name.git/
$ git config user.name "John Smith"
$ git config user.email john@example.com
$ echo Something > filename.txt
$ git add .
$ git commit -m ''
```

#### The user-end
```
# mkdir repo_name
# cd repo_name
# echo Hello World > test.txt
# git init
# git add .
# git commit -m 'first'
# git remote add origin git@104.239.145.132:username/repo_name.git
# git push -u origin master
```
