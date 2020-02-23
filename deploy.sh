#!/bin/sh

# build site
JEKYLL_ENV=production bundle exec jekyll build

# sync with ~/www/ in VPS
rsync -crvz --rsh='ssh -p22' --delete-after --delete-excluded  _site/ jekyll-rsync:/home/josedu/www/