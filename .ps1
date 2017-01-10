use_color=false

PS1_RESET=$(tput sgr0)
PS1_RED=$(tput setaf 1 ; tput dim)
PS1_BLACK=$(tput setaf 0 ; tput dim)
PS1_BBLACK=$(tput setaf 0 ; tput bold)
PS1_GREEN=$(tput setaf 2 ; tput dim)
PS1_BLUE=$(tput setaf 4 ; tput dim)
PS1_BBLUE=$(tput setaf 4 ; tput bold)
PS1_SPACE=$(tput cuf1)

branch_name() {
    echo "$PS1_BLUE($(git branch | grep -Po '(?<=^\*\s).+$'))"
}

staged() {
    res="$(git status --porcelain | grep -P '^[MA]\s' | wc -l)"
    if [ $res != '0' ]; then
        echo $PS1_GREEN$res
    fi
}

modified() {
    res="$(git status --porcelain | grep -P '[\sM]M' | wc -l)"
    if [ $res != '0' ]; then
        echo "$PS1_RED$res"
    fi
}

untracked() {
    res="$(git status --porcelain | grep -P '^\?\?\s' | wc -l)"
    if [ $res != '0' ]; then
        echo $PS1_BBLACK$res$PS1_RESET
    fi
}

unpushed() {
    res="$(git status | grep -P 'Your branch is up-to-date' | wc -l)"
    if [ $res == '0' ]; then
        echo "$PS1_RED*"
    fi
}

git_data() {
    if [ -d ./.git ] ; then
        echo " $PS1_RESET$(branch_name)$(unpushed) $PS1_BLACK|$(staged)$(modified)$(untracked)$PS1_BLACK|$PS1_BBLUE"
    fi
}

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
        && type -P dircolors >/dev/null \
        && match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
        # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
        if type -P dircolors >/dev/null ; then
                if [[ -f ~/.dir_colors ]] ; then
                        eval $(dircolors -b ~/.dir_colors)
                elif [[ -f /etc/DIR_COLORS ]] ; then
                        eval $(dircolors -b /etc/DIR_COLORS)
    else
      eval $(dircolors)
                fi
        fi

        if [[ ${EUID} == 0 ]] ; then
                PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
        else
                PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[01;34m\] \W$(git_data) \$\[\033[00m\] '
        fi

        alias ls='ls --color=auto'
        alias grep='grep --colour=auto'
else
        if [[ ${EUID} == 0 ]] ; then
                # show root@ when we don't have colors
                PS1='\u@\h \W \$ '
        else
                PS1='\u@\h \w \$ '
        fi
fi

# PPS1=$(echo $PS1 | sed 's/\(\\\$.*$\)/xxx\1/')
# PS1=$PPS1

