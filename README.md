# Converted from Subversion

This was done using the following commands:

```bash
mkdir tapmania-git
cd tapmania-git
git svn init http://tapmania.googlecode.com/svn/trunk/ --no-metadata
git config svn.authorsfile ~/tm-authors.txt
git svn fetch
```

where `~/tm-authors.txt` has the contents of [.svn-authors](.svn-authors).

## Add Subversion origin and authors

This is so this mirror can stay up-to-date with activity on Google Code.

After cloning, add the following to `.git/config`:

```ini
[svn-remote "svn"]
        noMetadata = 1
        url = http://tapmania.googlecode.com/svn/trunk
        fetch = :refs/remotes/git-svn
[svn]
        authorsfile = .svn-authors
```

# How to build

To be written (for modern Xcode 5.1 and such).
