BRANCH=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')

git config user.email "ebennett19@gmail.com"
git config user.name "Ethan Bennett"
git add .
git commit -m "Create new snapshot"
git push origin $BRANCH


# git/yarn authentication:
  # should move out of this file
  # should allow for pushing to this branch
  # should allow for publishing