function aigcm --description "Generate AI commit message and commit with git"
    git add -A .
    git diff --minimal --cached | \
        llm -t gitcommit > (git rev-parse --git-dir)/COMMIT_EDITMSG
    and git commit --verbose --edit --file=(git rev-parse --git-dir)/COMMIT_EDITMSG
end
