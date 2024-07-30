## Setp Config file links


### ZSH needs a lot of files in ~ in easy setup, 

TODO: enhance Setup to have .zsh directory

```
if [ -z $SETUPDIR ]; then
	echo "SETUPDIR variable is not set, set this to absolute path of Repodir (/Users/..../mySeutp)"
else
    rm ~/.zshrc ~/.zsh_alias ~/.zshrc_*
    for i in ${SETUPDIR}/dotfiles/zsh/.*
    do
        ln -s $i ~
    done
fi
```


### Create Links in .config dir

```
for i in btop doing karabiner mc mutt nvim sketchybar starship.toml tmuxinator tt yabai zeit 
do
    rm ~/.config/${i}
    ln -s ${SETUPDIR}/Dotfiles/${i} ~/.config/${i}
done

```
