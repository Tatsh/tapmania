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
2. Download [RapidXML](https://sourceforge.net/project/platformdownload.php?group_id=189621&sel_platform=1227) (`rapidxml-1.13.zip`). Unzip it in the `tapmania` directory. You should then have a directory named `rapidxml-1.13` within it.
3. `pod install`
2. Open `TapMania.xcworkspace` in Xcode.
3. Build it.
