#! /bin/sh

# Symbols
: ${omg_is_a_git_repo_symbol:='❤'}
: ${omg_has_untracked_files_symbol:='∿'}
: ${omg_omg_has_adds_symbol:='+'}
: ${omg_has_deletions_symbol:='-'}
: ${omg_has_cached_deletions_symbol:='✖'}
: ${omg_has_modifications_symbol:='✎'}
: ${omg_has_cached_modifications_symbol:='☲'}
: ${omg_ready_to_commit_symbol:='→'}
: ${omg_is_on_a_tag_symbol:='⌫'}
: ${omg_needs_to_merge_symbol:='ᄉ'}
: ${omg_has_upstream_symbol:='⇅'}
: ${omg_detached_symbol:='⚯ '}
: ${omg_can_fast_forward_symbol:='»'}
: ${omg_has_diverged_symbol:='Ⴤ'}
: ${omg_rebase_tracking_branch_symbol:='↶'}
: ${omg_merge_tracking_branch_symbol:='ᄉ'}
: ${omg_should_push_symbol:='↑'}
: ${omg_has_stashes_symbol:='★'}

# Flags
: ${omg_display_has_upstream:=false}
: ${omg_display_tag:=false}
: ${omg_display_tag_name:=true}
: ${omg_two_lines:=false}
: ${omg_finally:=''}
: ${omg_use_color_off:=false}

PROMPT=' %{$fg[magenta]%}%*%  %{$terminfo[bold]$fg_bold[blue]%}%n@%m%  %{${fg_bold[green]}%}%~%  $(before_build_prompt)%{$fg_bold[green]%}
%{${fg_bold[blue]}%}»%{${reset_color}%} '

#load colors
autoload colors && colors
for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
    eval $COLOR='%{$fg_no_bold[${(L)COLOR}]%}'  #wrap colours between %{ %} to avoid weird gaps in autocomplete
    eval BOLD_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
done
eval RESET='%{$reset_color%}'

omg_default_color_on=$WHITE
omg_default_color_off=$WHITE
red=$RED
green=$GREEN
orange=$YELLOW
yellow=$BOLD_YELLOW
violet=$CYAN
reset=$RESET

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX=" %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*%{$fg[yellow]%}›"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[yellow]%}›"


VIRTUAL_ENV_DISABLE_PROMPT=true
function omg_prompt_callback() {
    # check if using a virtualenv, echo the name if found
    virtualenv=`basename "$VIRTUAL_ENV"`

    if [ -n "${VIRTUAL_ENV}" ]; then
        echo "($virtualenv) "
    fi
}

function before_build_prompt {
    # intercept before build_prompt
    # check if is repo & $enabled is false
    # if is repo, check for 'hide-dirty', set if not already
    # then, finally, build prompt with git_prompt_info, and not anything more complex

    # echo virtualenv
    echo -n "${orange}$(omg_prompt_callback)"


    local enabled=`git config --local --get oh-my-git.enabled`
    local info=`git symbolic-ref HEAD 2> /dev/null`

    #vastly speeds up git repsonse times for large repos
    if [[ ${enabled} == simple && -z $info ]]; then
        if [ $info ]; then
            dirty=$(command git config --local --get oh-my-zsh.hide-dirty)
            if [[ "$dirty" != "1" ]]; then
                $(command git config --local oh-my-zsh.hide-dirty 1)
            fi
        fi
        echo "${yellow}$(git_prompt_info)"
        exit;

    # if don't want any git related stats, even branch name, can completely disable
    elif [[ ${enabled} == false ]]; then
        exit;
    else
        build_prompt
    fi

}

function custom_build_prompt {
    local enabled=${1}
    local current_commit_hash=${2}
    local is_a_git_repo=${3}
    local current_branch=${4}
    local detached=${5}
    local just_init=${6}
    local has_upstream=${7}
    local has_modifications=${8}
    local has_modifications_cached=${9}
    local has_adds=${10}
    local has_deletions=${11}
    local has_deletions_cached=${12}
    local has_untracked_files=${13}
    local ready_to_commit=${14}
    local tag_at_current_commit=${15}
    local is_on_a_tag=${16}
    local has_upstream=${17}
    local commits_ahead=${18}
    local commits_behind=${19}
    local has_diverged=${20}
    local should_push=${21}
    local will_rebase=${22}
    local has_stashes=${23}

    local simple=`git config --local --get oh-my-git.simple`

    local prompt=""

    if [[ $is_a_git_repo == true && $enabled != simple ]]; then
        echo -n "${reset}[ "
        enrich $is_a_git_repo $omg_is_a_git_repo_symbol $violet
        enrich $has_stashes $omg_has_stashes_symbol $orange
        enrich $has_untracked_files $omg_has_untracked_files_symbol $red
        enrich $has_adds $omg_has_adds_symbol $orange

        enrich $has_deletions $omg_has_deletions_symbol $red
        enrich $has_deletions_cached $omg_has_cached_deletions_symbol $orange

        enrich $has_modifications $omg_has_modifications_symbol $red
        enrich $has_modifications_cached $omg_has_cached_modifications_symbol $orange
        enrich $ready_to_commit $omg_ready_to_commit_symbol $green
        echo -n " || "
        enrich $detached $omg_detached_symbol $red

        if [[ $omg_display_has_upstream == true ]]; then
            enrich $has_upstream $omg_has_upstream_symbol
        fi
        if [[ $detached == true ]]; then
            if [[ $just_init == true ]]; then
                prompt="${prompt} ${red}detached"
            else
                prompt="${prompt} ${omg_default_color_on}(${current_commit_hash:0:7})"
            fi
        else
            if [[ $has_upstream == true ]]; then
                if [[ $will_rebase == true ]]; then
                    local type_of_upstream=$omg_rebase_tracking_branch_symbol
                else
                    local type_of_upstream=$omg_merge_tracking_branch_symbol
                fi

                if [[ $has_diverged == true ]]; then
                    prompt="${prompt}-${commits_behind} ${omg_has_diverged_symbol} +${commits_ahead} "
                else
                    if [[ $commits_behind -gt 0 ]]; then
                        prompt="${prompt}${omg_default_color_on} -${commits_behind} ${omg_can_fast_forward_symbol} "
                    fi
                    if [[ $commits_ahead -gt 0 ]]; then
                        prompt="${prompt}${omg_default_color_on} ${omg_should_push_symbol} +${commits_ahead} "
                    fi
                fi
                prompt="${prompt}${yellow}‹${current_branch}${reset} ${type_of_upstream} ${upstream//\/$current_branch/}${yellow}›"
            else
                prompt="${prompt}${omg_default_color_on}${yellow}‹${current_branch}${yellow}›${reset}"
            fi
        fi

        if [[ $omg_display_tag == true && $is_on_a_tag == true ]]; then
            prompt="${prompt} ${orange}${omg_is_on_a_tag_symbol}${reset}"
        fi
        if [[ $omg_display_tag_name == true && $is_on_a_tag == true ]]; then
            prompt="${prompt} ${orange}[${tag_at_current_commit}]${reset}"
        fi
        prompt="${prompt}      ${reset}]"
    fi

    if [[ $omg_two_lines == true && $is_a_git_repo == true ]]; then
        break='\n'
    else
        break=''
    fi
    echo "${prompt}${reset}${break}${omg_finally}"
}

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