#! /usr/bin/env bash

# Set up the build directory
mkdir -p _build
touch _build/.nojekyll

# Build slides
for d in *; do
    if [ -d "$d" ] && [ "$d" != "_build" ]; then
        cp -r $d _build/

        if [ -f "_build/$d/requirements.txt" ]; then
            rm _build/$d/requirements.txt
        fi

        for j in _build/$d/*.ipynb; do
            [ -f "$j" ] || break
            jupyter nbconvert --execute --inplace $j
            jupyter nbconvert $j --to slides --output-dir=_build/$d
            rm $j
        done
    fi
done

HTML_OPEN="<!DOCTYPE html>
<html>
<body>
  <h1>Slides</h1>
  <p>These slides are built automatically from <a href="https://github.com/So-Cool/slides">So-Cool/slides</a> GitHub repository.</p>
  <p>This page only allows for a static preview of the slides. To launch their interactive version you need to launch them through <a href="https://mybinder.org/v2/gh/so-cool/slides/master">MyBinder</a>.</p>
  <ul>
"
HTML_CLOSE="
  </ul>
</body>
</html>
"

# Generate index
echo $HTML_OPEN > _build/index.html
for d in *; do
    if [ -d "$d" ] && [ "$d" != "_build" ]; then
        for j in _build/$d/*.slides.html; do
            [ -f "$j" ] || break
            relative=${j#_build/}
            relative_dir=${relative%/*}
            echo "<li><a href=\"$relative\">$relative_dir</a></li>" >> _build/index.html
        done
    fi
done
echo $HTML_CLOSE >> _build/index.html
