#! /bin/sh

# Generate the documentation
echo "--> Generating the documentation... (mix.docs)"
mix docs

DOCSDIR="$(pwd)/doc"

cd ..
echo "--> Cloning the repository and checking out the gh-pages branch..."
git clone git@github.com:/dhbw-stginf16a/backend.git ghpages
cd ghpages

git checkout gh-pages
echo "--> Replacing the documentation"
mv ./.git ../ghpages-git
rm -rf * .*
rsync -av --delete $DOCSDIR/ ./
mv ../ghpages-git ./.git

git add -A
echo "--> Committing and pushing everything"
git config --global user.email "travis-documentation-builds@brettprojekt.dhbwstginf16a.notvalidtld"
git config --global user.name "Travis Documentation Bot"
git commit -m "ExDoc generated at $(date)"
git remote set-url origin git@github.com:/dhbw-stginf16a/backend.git
git push -u origin gh-pages
