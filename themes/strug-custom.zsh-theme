# Author: John Lien
# Preferably, use Inconsolata Nerd Font Mono

# terminal coloring
export CLICOLOR=1
export LSCOLORS=dxFxCxDxBxegedabagacad

# Azure
az_prompt_info() {
    AZURE_FILE=$HOME/.azure/accessTokens.json
    if [ ! -f "$AZURE_FILE" ]; then
        return
    fi

    ACCESS_TOKEN=$(cat $AZURE_FILE | jq -r ". | sort_by(.expiresOn) | reverse | .[0].accessToken" | cut -d '.' -f 2 | base64 -d 2> /dev/null)

    if echo $ACCESS_TOKEN | jq -e ".exp" >/dev/null 2>&1; then
        ACCESS_TOKEN_EXPIRY=$(echo $ACCESS_TOKEN | jq -e ".exp")
    elif echo "$ACCESS_TOKEN]}" | jq -e ".exp" >/dev/null 2>&1; then
        ACCESS_TOKEN_EXPIRY=$(echo "$ACCESS_TOKEN]}" | jq -e ".exp")
    elif echo "$ACCESS_TOKEN}" | jq -e ".exp" >/dev/null 2>&1; then
        ACCESS_TOKEN_EXPIRY=$(echo "$ACCESS_TOKEN}" | jq -e ".exp")
    else
        return
    fi

    if [[ $(date +"%s") -gt $ACCESS_TOKEN_EXPIRY ]]; then
        return
    fi

    AZURE_CONTEXT=$(cat $HOME/.azure/azureProfile.json | jq -r ".subscriptions[] | select(.isDefault == true) | .name")
    AZURE_CONTEXT_GROUP=$(cat $HOME/.azure/config | grep group | cut -d "=" -f 2 | cut -d " " -f 2)

    if [[ ! -z "${AZURE_CONTEXT_GROUP// }" ]]; then
        AZURE_CONTEXT="$AZURE_CONTEXT ($AZURE_CONTEXT_GROUP)"
    fi

    echo "%{$FG[032]%}ﴃ $AZURE_CONTEXT%{$reset_color%}"
}

PROMPT='
%{$FG[037]%}╭─ %n@%m %{$reset_color%}%{$FG[126]%} ${PWD/#$HOME/~} %{$reset_color%}$(git_prompt_info)%{$reset_color%}$(az_prompt_info)
%{$FG[037]%}╰ \$ %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$FG[184]%} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_DIRTY="%{$reset_color%}%{$fg[red]%} ✘ %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%} ✔ %{$reset_color%}"

ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_DETAILED=true
ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_PREFIX="%{$FG[126]%}("
ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_SUFFIX="%{$FG[126]%})%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE=" +"
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR=%{$FG[037]%}

ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE=" -"
ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR=%{$fg[red]%}
