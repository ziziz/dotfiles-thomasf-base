function complete_cheat {
    sheets=`cheat sheets | grep '^  '`
    COMPREPLY=()
    if [ $COMP_CWORD = 1 ]; then
	COMPREPLY=(`compgen -W "$sheets" -- $2`)
    fi
}
complete -F complete_cheat cheat
