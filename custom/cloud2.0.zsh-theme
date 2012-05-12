# === 1. Left hand prompt =========================================================================
autoload -U colors && colors
PROMPT='$(return_code)%{$fg_bold[green]%}%p'
if [[ -n $SSH_CLIENT ]]; then
 PROMPT=$PROMPT" %{$fg[red]%}%n⟁%m▷"
fi
PROMPT=$PROMPT'%{$fg[green]%} %c %{$fg_bold[cyan]%}$(git_prompt_info)%{$fg_bold[blue]%} % %{$reset_color%}'
  

function return_code(){
  if [ $? -eq 0 ]; then
    echo "%{$fg_bold[cyan]%}☁ "
  else
    echo "%{$fg_bold[red]%}⚡ "
  fi
}

function remote_host(){
}


ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}[%{$fg[cyan]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}]"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}]"

# === 2. Titles and Tabs ===========================================================================

# display nice tab labels
function set_tab_label() {
  local tab_label="$PWD:h:t/$PWD:t"
  echo -ne "\e]1;${tab_label}\a"
}

# format titles for screen and rxvt
function set_title() {
  # escape '%' chars in $1, make nonprintables visible
  a=${(V)1//\%/\%\%}

  # Truncate command, and join lines.
  a=$(print -Pn "%40>...>$a" | tr -d "\n")

  case $TERM in
  screen)
    print -Pn "\ek$a:$3\e\\"      # screen title (in ^A")
    ;;
  xterm*|rxvt)
    print -Pn "\e]2;$2 | $a:$3\a" # plain xterm title
    ;;
  esac
}

# === 3. Right hand prompt (inspiration from kolo) =================================================
autoload -Uz vcs_info
zstyle ':vcs_info:*' stagedstr '%F{green}♦ '
zstyle ':vcs_info:*' unstagedstr '%F{yellow}♣ '
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{11}%r'
zstyle ':vcs_info:*' enable git svn
function determine_untracked_files() {
  if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
      zstyle ':vcs_info:*' formats ' %c%u%B%F{green}'
  } else {
      zstyle ':vcs_info:*' formats ' %c%u%B%F{red}♠ %F{green}'
  }
}
function rvm_prompt(){
  `hash rvm 2>/dev/null`
  exit_code=$?
  if [[  $exit_code == 0 ]]; then
    local prompt_info="$(rvm-prompt i v g)"
    if [ -n "$prompt_info" ]; then
     echo -ne "%{$fg[blue]%}‹$prompt_info›"
    fi
  fi
}

function determine_remote_branch_status() {
local git_status="$(git status  2> /dev/null  | grep 'Your branch' | sed s/\'//g | head -1)"
# local git_ffwardable=$(echo -ne "$git_status" | grep "Your branch is" | )
if [[ $git_status =~ diverged ]]; then
  echo -ne "%{$fg[red]%} [✘]"
elif [[ $git_status =~ Your\ branch\ is\ ahead ]] || [[ $git_status =~ Your\ branch\ is\ behind ]]; then
  echo -ne $(echo -ne "%{$git_status}" | sed "s/.*Your\ branch\ is\ \(behind\)\ .*\ by\ \([0-9][0-9]*\)\ commit.*/\1\2/" | sed "s/.*Your\ branch\ is\ \(ahead\)\ .*\ by\ \([0-9][0-9]*\)\ commit.*/\1\2/" | sed "s/ahead\(.*\)/%{$fg[green]%}[⬆ \1]%{$reset_color%}/"| sed "s/behind\(.*\)/%{$fg[red]%}[⬇ \1]%{$reset_color%}/")
fi
}

setopt prompt_subst

RPROMPT='$(rvm_prompt)%{$reset_color%}${vcs_info_msg_0_}%{$reset_color%}$(determine_remote_branch_status)%{$reset_color%}'

# === 4. GOGOGO! ===================================================================================

# preexec is called just before any command line is executed
function preexec() {
  set_title "$1" "$USER@%m" "%35<...<%~"
  set_tab_label
}

# wrap everything in a precmd
function precmd () {
    determine_untracked_files
    vcs_info

    set_title "zsh" "$USER@%m" "%55<...<%~"
    set_tab_label
}
