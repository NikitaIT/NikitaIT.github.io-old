.PHONY: deploy clean

deploy: 
	bundle exec jekyll build
	cd _site && \
	git add --all && \
	git commit -m "Deploy to gh-pages11" && \
	git push origin master

# Removing the actual dist directory confuses git and will require a git worktree prune to fix
clean:
	rm -rf _site/*
  
dev:
	git add --all && \
	git commit -m "Dev commit" && \
	git push origin dev
# sudo rm -rf _site
# echo "_site/" >> .gitignore
# git branch master
# sudo bundle exec jekyll build
# git worktree add dist gh-pages
