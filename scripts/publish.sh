#/bin/sh

set -o errexit -o nounset

if [ -z "$TRAVIS_TAG" -a "$TRAVIS_BRANCH" != "master" ]
then
  echo "This commit was made against $TRAVIS_BRANCH and not the master or tag! Do not deploy!"
  exit 1
fi

# User info
git config user.name "Admin"
git config user.email "patternfly-build@redhat.com"
git config --global push.default simple

# Add upstream authentication token
git remote add upstream https://$AUTH_TOKEN@github.com/$TRAVIS_REPO_SLUG.git

# Commit generated files
git add dist --force
git commit -m "Added files generated by Travis build"

# Push to releases branch
EXISTING=`git ls-remote --heads https://github.com/"$TRAVIS_REPO_SLUG".git "$TRAVIS_BRANCH"-dist`

if [ -z "$TRAVIS_TAG" ]
then
  if [ -n "$EXISTING" ]
  then
    git fetch upstream $TRAVIS_BRANCH-dist:$TRAVIS_BRANCH-dist
    git checkout $TRAVIS_BRANCH-dist
    git merge -Xtheirs $TRAVIS_BRANCH --no-edit --ff
    git push upstream $TRAVIS_BRANCH-dist --force -v
  else
    git push upstream $TRAVIS_BRANCH:$TRAVIS_BRANCH-dist --force -v
  fi
fi

exit $?
