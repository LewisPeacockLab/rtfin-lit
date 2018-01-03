#!/bin/sh

# setup user
git config --global user.email 'utrewirelab@gmail.com' > /dev/null 2>&1
git config --global user.name 'rtfin-admin' > /dev/null 2>&1

# stage any changes and new files
git add -A
# now commit, ignoring branch gh-pages doesn't seem to work, so trying skip
git commit --allow-empty -m "Deploy to GitHub pages [ci skip]"
# and push, but send any output to /dev/null to hide anything sensitive
git push --force --quiet origin master
# go back to where we started and remove the gh-pages git repo we made and used
# for deployment

echo "Finished Deployment!"
