.PHONY: all deploy clean

all: dist dist/index.html

dist:
	git worktree add _site master

# Replace this rule with whatever builds your project
dist/index.html: _site/index.html
	cp $< $@

deploy: all
	bundle exec jekyll build
	cd _site && \
	git add --all && \
	git commit -m "Deploy to gh-pages" && \
	git push -f origin master

# Removing the actual dist directory confuses git and will require a git worktree prune to fix
clean:
	rm -rf _site/*
  
  
# sudo rm -rf _site
# echo "_site/" >> .gitignore
# git branch master
# sudo bundle exec jekyll build
# git worktree add dist gh-pages
