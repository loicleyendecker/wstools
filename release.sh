#!/bin/bash
set -e

VERSION=$(python -c "from src.wstools.version import __version__ ; print __version__")
echo Preparing to release version $VERSION

pip install -q --upgrade pep8 autopep8
#pip install -q --upgrade autopep8

if ! python setup.py test; then
	echo "The test suite failed. Fix it!"
	exit 1
fi

git pull -u

python setup.py check --restructuredtext  --strict

autopep8 -i -r src/*.py

# commented some errors temporarly, TODO: remove them and fix the code
pep8 --max-line-length=180 --ignore=E502,E128,E123,E127,E125 src

sleep 1

git diff
# Disallow unstaged changes in the working tree
    if ! git diff-files --check --exit-code --ignore-submodules -- >&2
    then
        echo >&2 "error: you have unstaged changes."
        #git diff-files --check --exit-code --ignore-submodules -- >&2
        exit 1
    fi

# Disallow uncommitted changes in the index
    if ! git diff-index --cached --exit-code -r --ignore-submodules HEAD -- >&2
    then
        echo >&2 "error: your index contains uncommitted changes."
        exit 1
    fi



echo "Please don't run this as a user. This generates a new release for PyPI. Press ^C to exit or Enter to continue."
read


# Clear old distutils stuff
rm -rf build dist MANIFEST &> /dev/null

# Build installers, etc. and upload to PyPI
# python setup.py register sdist bdist_wininst upload

#python setup.py register sdist build_sphinx upload upload_sphinx
python setup.py register sdist upload

git tag -f -a $VERSION -m "Version $VERSION"
git tag -f -a RELEASE -m "Current RELEASE"

git push origin --tags

echo "done."