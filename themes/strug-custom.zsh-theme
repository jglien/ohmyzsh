# terminal coloring
export CLICOLOR=1
export LSCOLORS=dxFxCxDxBxegedabagacad

local git_branch='$(git_prompt_info)%{$reset_color%}$(git_remote_status)'

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

    echo " ☁️ $AZURE_CONTEXT"
}

PROMPT='
%{$fg[cyan]%}╭─%n@%m %{$reset_color%}%{$fg[magenta]%} ${PWD/#$HOME/~} %{$reset_color%}$(git_prompt_info)$(az_prompt_info)
%{$fg[cyan]%}╰\$ %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[green]%} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_DIRTY="%{$reset_color%}%{$fg[red]%} ✘ %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%} ✔ %{$reset_color%}"

ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_DETAILED=true
ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_PREFIX="%{$fg[magenta]%}("
ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_SUFFIX="%{$fg[magenta]%})%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE=" +"
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR=%{$fg[cyan]%}

ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE=" -"
ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR=%{$fg[red]%}
