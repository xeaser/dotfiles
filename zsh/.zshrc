# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================================
# Core - Oh My Zsh
# ============================================================================
export GPG_TTY=`tty`
export ZSH="/Users/psharma/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

[[ -z "$TMUX" ]] && export TERM=xterm-256color

plugins=(git jiratui helm go-task-completions kubectl-autocomplete opscore you-should-use zsh-completions zsh-history-substring-search fzf-tab zsh-autosuggestions fast-syntax-highlighting zsh-autocomplete)

export PATH=$PATH:$HOME/bin

source $ZSH/oh-my-zsh.sh

# Must come after zsh-autocomplete to work properly
compdef _task task

# ============================================================================
# Environment Variables
# ============================================================================
export GOPATH=/Users/psharma/go
export GOOGLE_CLOUD_PROJECT=ai-workshop-442209
export K9S_CONFIG_DIR='/Users/psharma/.config/k9s'
export EDITOR='nvim'
export COLORTERM=truecolor
export BUN_INSTALL="$HOME/.bun"
export NVM_DIR="$HOME/.nvm"

# ============================================================================
# PATH
# ============================================================================
export PATH=$PATH:$GOPATH/bin
export PATH="/Users/psharma/.antigravity/antigravity/bin:$PATH"
export PATH="$PATH:/Users/psharma/.lmstudio/bin"
export PATH=$PATH:/Users/psharma/.local/bin
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH=/Users/psharma/.opencode/bin:$PATH

# ============================================================================
# Secrets
# ============================================================================
export GITHUB_PAT=$(gh auth token 2>/dev/null)
[[ -f ~/.secrets ]] && source ~/.secrets

# ============================================================================
# Aliases - Editor
# ============================================================================
alias vim='nvim'
alias vi='nvim'

# ============================================================================
# Aliases - Config Files
# ============================================================================
alias viztmux='vi ~/.tmux.conf.local'
alias viznvim='vi ~/.config/nvim/init.lua'
alias vizkitty='vi ~/.config/kitty/kitty.conf'
alias viz='vi ~/.zshrc'
alias soz='source ~/.zshrc'
alias soztmux='tmux source-file ~/.tmux.conf'
alias vizkube='vi ~/.kube/config'
alias vizaws='vi ~/.aws/config'

# ============================================================================
# Aliases - Tools & Workflow
# ============================================================================
alias k='kubectl'
alias homelab='ssh -i ~/.ssh/id_ed25519 zephyr@192.168.1.222'
alias ssologin='aws sso login --sso-session cb'
alias opencode='AWS_PROFILE=cb-bedrock opencode'
alias opencode-dev="AWS_PROFILE=cb-bedrock ~/.local/bin/opencode-dev"
alias jira='jiratui ui'
alias mcpinspect='npx @modelcontextprotocol/inspector'
alias tdaily='~/.tmux/sessions/daily.sh'
alias toggleNotch=$'open \'xyz.kondor.znotch://v1/manage?action=toggle'\'
alias volUp='osascript -e "set volume input volume 100"'

# ============================================================================
# Aliases - Development
# ============================================================================
alias tidy='go mod tidy'
alias build='make build'
alias aifrUp='task d:delete-kind && task dev:build-images && task dev:create-kind && task dev:kind-load-images && task dev:helmfile-apply'
alias aifrRedploy='task dev:redeploy-apps'

# ============================================================================
# Functions
# ============================================================================
gget() {go get $1;}
clone() {git clone $1;}
sshclear() {ssh-keygen -R $1;}

# ============================================================================
# Keybindings
# ============================================================================
bindkey '^[[1;3C' forward-word
bindkey '^[[1;3D' backward-word

# ============================================================================
# Integrations
# ============================================================================
# Google Cloud SDK
if [ -f '/Users/psharma/Downloads/Programs/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/psharma/Downloads/Programs/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/psharma/Downloads/Programs/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/psharma/Downloads/Programs/google-cloud-sdk/completion.zsh.inc'; fi

# Kiro
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Bun completions
[ -s "/Users/psharma/.bun/_bun" ] && source "/Users/psharma/.bun/_bun"

# direnv
eval "$(direnv hook zsh)"

# zoxide (smart cd)
eval "$(zoxide init zsh)"

# atuin (searchable shell history)
eval "$(atuin init zsh)"

# NVM (loaded last - slow)
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ============================================================================
# Legacy / Zscaler
# ============================================================================
alias ddev='aws sso login --profile dspm-dev'
alias rnd='aws sso login --profile rnd-root'
alias npvs='aws sso login --profile npvs'
alias rndsso='aws sso login --sso-session rnd-sso'
alias devtestsso='aws sso login --sso-session dspm-new'
alias cddspm='cd ~/Work/Bitbucket/DSPM'
alias cdgitlab='cd ~/Work/Gitlab/'
alias dbaccess='cd ~/Work/Bitbucket/DSPM/devops-scripts; ./database_connect.sh; cd ~'

alias startmongo='mongod --auth --dbpath ~/data/db --logpath ~/data/log/mongodb/mongo.log --fork'
alias stopmongo='ps -e | grep mongod | awk "{print \$1}" | xargs kill -9'
alias startpg='cd /Volumes/Work/postgres; pg_ctl -D local -l logfile start; cd ~'
alias stoppg='cd /Volumes/Work/postgres; pg_ctl -D local -l logfile stop; cd ~'
alias daemonizeRedis='redis-server --daemonize yes'
alias startRedis='brew services start redis'
alias stopRedis='brew services stop redis'
alias startclickhouse='sudo clickhouse start'
alias stopclickhouse='sudo clickhouse stop'

alias portForwardSvc='kill -9 $(lsof -ti:27017,5432,8123,5521,8080) & \
k port-forward pods/z-dspm-mongodb-cluster-rs0-1 27017:27017 -n mongodb & \
k port-forward pods/app-pg-cluster-2 5432:5432 -n app-pg & \
k port-forward pods/chi-app-ch-cluster-appcluster-0-1-0 8123:8123 -n clickhouse & \
k -n clickhouse port-forward pods/ch-ui-77996c5844-fnlrp 5521:5521 & \
k -n kafka port-forward pods/kafka-console-659ff57499-hbhvl 8080:8080'

alias killSVCPorts='kill -9 $(lsof -ti:27017,5432,8123,5521,8080)'

lpssh() {ssh -i /Users/psharma/Downloads/Work/ssh/lpteam.pem ubuntu@$1;}
devpg() {ssh -i /Volumes/Work/Bitbucket/DSPM/devops-scripts/parag.sharma-dev-kp.pem -L 5432:z-dspm-dev-us-west-2-zflag-rds-instance.ct29tamw35xv.us-west-2.rds.amazonaws.com:5432 parag.sharma@ec2-52-40-114-167.us-west-2.compute.amazonaws.com;}

# ============================================================================
# Commented Out / Archive
# ============================================================================
#export PATH="/opt/homebrew/bin:$PATH"
#export PATH=$PATH:/Users/psharma/.dapr/bin
#export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@3/lib/pkgconfig"
#export GEM_HOME="$(ruby -e 'puts Gem.user_dir')"
#export PATH="$PATH:$GEM_HOME/bin"
#export GOROOT=/usr/local/go
#export GOBIN=$GOROOT/bin
#export PATH=$PATH:$GOBIN
#export GOPROXY='direct'
#export PATH="$PATH:/Users/psharma/bin"
#export GOPRIVATE='gitlab.corp.zscaler.com/*'
#export GOTOOLCHAIN='local'
# export CLAUDE_CODE_USE_BEDROCK=1
# export ANTHROPIC_MODEL='arn:aws:bedrock:us-east-1:205941181069:inference-profile/us.anthropic.claude-sonnet-4-5-20250929-v1:0'
# export PATH="/opt/homebrew/sbin:$PATH"
# export PATH="/opt/homebrew/bin:$PATH"

#kafkaui() {
#export POD_NAME=$(kubectl get pods --namespace kafka-ui -l "app.kubernetes.io/name=kowl,app.kubernetes.io/instance=kowl" -o jsonpath="{.items[0].metadata.name}")
#kubectl --namespace kafka-ui port-forward $POD_NAME 8080:8080
#}

#kafka-up() (
#	cd /Volumes/Work/CWP/Tooling/kafka-local/kafka-docker && docker-compose up -d && cd ~
#)

#alias kafka-down='cd /Volumes/Work/CWP/Tooling/kafka-local/kafka-docker; docker-compose down; cd ~'

# ============================================================================
# Debug
# ============================================================================
echo "$(date) -- .zshrc executed" >> $HOME/.zshrc.log

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
