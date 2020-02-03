#!/bin/sh

# Generamos sitio
JEKYLL_ENV=production bundle exec jekyll build

# Sincronizar con /home/josedu/blog/ en VPS
rsync -crvz --rsh='ssh -p22' --delete-after --delete-excluded  _site/ jekyll-rsync:/home/josedu/blog/