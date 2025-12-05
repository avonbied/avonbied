#!/bin/sh

# Change old commits to include new committer details
OLD_GIT_NAME="OldName"
OLD_GIT_EMAIL="old.user@example.com"

NEW_GIT_NAME="NewName"
NEW_GIT_EMAIL="new.user@example.com"

git filter-branch --commit-filter 'if { [ "$GIT_AUTHOR_NAME" = "$OLD_GIT_NAME" ] || [ "$GIT_AUTHOR_EMAIL" = "$OLD_GIT_EMAIL" ] ;}
  then export GIT_AUTHOR_NAME="$NEW_GIT_NAME"; export GIT_AUTHOR_EMAIL=$NEW_GIT_EMAIL;
  export GIT_COMMITTER_NAME="$NEW_GIT_NAME"; export GIT_COMMITTER_EMAIL=$NEW_GIT_EMAIL
  fi; git commit-tree "$@"'

rm -Rf .git/refs/original
git gc --aggressive --prune=now
