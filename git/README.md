The git Basics
==============


This will setup our ~/.gitconfig  so that people will know it's me committing files.
```
# git config --global user.name "Igknighted"
# git config --global user.email sam.igknighted@gmail.com
```

Repository setup process::
```
# vim .gitignore
# git init
# git add -A
# git commit -m 'Comment here'
# git remote add origin git@github.com:Igknighted/expglyph.com.git
# git push origin master --force
```

Pushing changes
```
# git add -A
# git ls-files --deleted | xargs git rm
# git commit -m 'Comment here'
# git push origin master
```

Force the changes if it told me 'no'
```
# git push origin master --force
```

Pull from the repository
```
# git pull origin master
```

Forcefully pull and replace files if it told me 'no'
```
# git reset --hard origin/master
```

Remove something from the history
```
# git rm "FILENAME" --cache
# git commit -m "Wiping history for FILENAME"
# git filter-branch --force --index-filter "git rm -r -f --ignore-unmatch FILENAME" --prune-empty --tag-name-filter cat -- --all
```

Check to see if there are updates?
```
# git fetch --all
```

Full revision list (not sure if it's useful yet)
```
# git rev-list --objects --all
```

Restore a file from one of the prior commited verions.
```
# git log --oneline FILENAME
# git checkout 16be209 FILENAME
```

If I started working on a new system and forgot to set the git config, this example will replace committer 'glyph' with 'Igknighted'.
```
# git filter-branch -f --commit-filter '
        if [ "$GIT_COMMITTER_NAME" = "glyph" ];
        then
                GIT_COMMITTER_NAME="Igknighted";
                GIT_AUTHOR_NAME="Igknighted";
                GIT_COMMITTER_EMAIL="sam.igknighted@gmail.com";
                GIT_AUTHOR_EMAIL="sam.igknighted@gmail.com";
                git commit-tree "$@";
        else
                git commit-tree "$@";
        fi' -f HEAD
```

I like to ensure that my daily coding streak is properly documented in github, so if the server I'm committing from fucks me, this line will ammend the commit date:
```
# git commit --amend --date="Wed Feb 16 14:00 2011 +0100"
```

If I have to revise what I already pushed,
```
# git log | head -n12
# git filter-branch --env-filter \
    'if [ $GIT_COMMIT = 119f9ecf58069b265ab22f1f97d2b648faf932e0 ]
     then
         export GIT_AUTHOR_DATE="Fri Jan 2 21:38:53 2009 -0800"
         export GIT_COMMITTER_DATE="Sat May 19 01:01:01 2007 -0700"
     fi'
# git push origin master --force
```
