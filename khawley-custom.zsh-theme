# edited from afowler
if [ $UID -eq 0 ]; then CARETCOLOR="red"; else CARETCOLOR="blue"; fi

#local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"


# uses the %{$fg[magenta]%}%* portion below as a constantly updating clock, as updated by schedprompt()
PROMPT='$(schedprompt)%{$fg[magenta]%}%* %{$reset_color%} ~ %{$terminfo[bold]$fg_bold[blue]%}%n@%m% %{$reset_color%} :: %{${fg_bold[green]}%}%3~ $(git_prompt_info)%{${fg_bold[$CARETCOLOR]}%}
»%{${reset_color}%} '

RPS1="${return_code}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX=" %{$reset_color%}"

#edited from mat malone
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*%{$fg[yellow]%}›"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[yellow]%}›"

# continuously updated timestamp for every executed command ☺
function schedprompt() {
  emulate -L zsh
  zmodload -i zsh/sched
  integer i=${"${(@)zsh_scheduled_events#*:*:}"[(I)schedprompt]}
  (( i )) && sched -$i
  zle && zle reset-prompt
  sched +1 schedprompt
}

schedprompt