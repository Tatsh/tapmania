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

To merge, use `git merge remotes/git-svn`.

# How to build

1. Clone this repository.
2. `cd tapmania` and download RapidXML: `curl -o 'https://downloads.sourceforge.net/project/rapidxml/rapidxml/rapidxml%201.13/rapidxml-1.13.zip?r=http%3A%2F%2Frapidxml.sourceforge.net%2F&ts=1514276137&use_mirror=iweb' && unzip rapidxml-1.13.zip`
3. `pod install`
2. Open `TapMania.xcworkspace` in Xcode.
3. Build it.
