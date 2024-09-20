# Publish to github pages on gh-pages branch
rm -r _vendor/
cp -r ../_vendor ./_vendor

if [ -n "$(git status --porcelain)" ]; then
  echo "Please commit all changes before publishing with this script"
  exit 1
fi

if [ ! -f "_config.yml" ]; then
  echo "Please run this script from the base project directory"
  exit 1
fi

git checkout gh-pages
git fetch --all
git reset --hard origin/master
git pull origin master
commit_hash=$(git rev-parse HEAD)
branch=$(git rev-parse --abbrev-ref HEAD)
if [ -d "_scripts/publish.d" ]; then
  rm -r "/tmp/publish.d"
  cp -r "_scripts/publish.d" "/tmp/publish.d"
fi
# bundle install
bundle exec jekyll b -d /tmp/gh-pages-publish
git ls-files -z -- . ':!:.git*' | xargs -0 rm -f
cp -r /tmp/gh-pages-publish/* .
# for script in "/tmp/publish.d/*"; do
#   $script
# done
git add .
git commit -m "publish commit ${commit_hash}"
git push -u origin +gh-pages
git checkout master
