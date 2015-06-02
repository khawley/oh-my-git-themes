a simple port of my existing beloved prompt, to take advantage of [oh-my-git](https://github.com/arialdomartini/oh-my-git)

after adding to zshrc:

	source "$HOME/.antigen/antigen.zsh"
	
	antigen-use oh-my-zsh
	antigen-bundle arialdomartini/oh-my-git

also add

	antigen theme khawley/oh-my-git-themes omg-khawley