#!/bin/bash
reset(){
    current_file=1
    total_items=0
    tput cup 0 0
}

draw_bar(){
    tput cup $rows 0
    echo -e -n "\e[46m$bar"
    tput cup $rows 0
    echo -e -n "\e[97m$PWD ($current_line/${#list[@]})"
    echo -e -n "\e[0m"
}

load_files(){
    local dirs
    local files

    dirs+=(".")
    dirs+=("..")

    for item in "$PWD"/*
    do
        if [[ -d $item ]]
        then
            dirs+=("${item##*/}")
        else
            files+=("${item##*/}")
        fi
    done
    list=("${dirs[@]}" "${files[@]}")
}

print_files(){

    local line=0
    local offset=0
    ((offset=current_line-rows+6))
    if ((offset < 0))
    then
        offset=0
    fi
    for item in "${list[@]:$offset}"
    do
        ((line++))
        if (( line == current_line - offset))
        then
            echo -n ">>"
        fi
        if [[ -d $item ]];then
            echo -e -n "\e[96m"
            echo "/$item                    "

        elif [[ -x $item ]];then
            echo -e -n "\e[92m"
            echo "$item                     "

        elif [[ -f $item ]];then
            echo -e -n "\e[97m"
            echo "$item                     "
        fi
        echo -e -n "\e[0m"
        if ((line == rows - 1))
        then
            break
        fi
    done
}

get_input(){
    read -s -n1 input
    printf '\e[?25l'
    if [ "$input" = "q" ]
    then
        tput clear
    elif [ "$input" = "j" ]
    then
        if (( current_line != ${#list[@]} ))
        then
            ((current_line++))
        fi
            redraw
    elif [ "$input" = "k" ]
    then
        if (( current_line != 1 ))
        then
            ((current_line--))
        fi
            redraw
    elif [ "$input" = "c" ]
    then
        # Enter key (changes dir)
        ((current_line--))
        if [[ -d ${list[$current_line]} ]]
        then
            cd ${list[$current_line]}
            tput clear
            load_files
            current_line=1
            redraw
            ((current_line++))
        else
            tput clear
            tput cup 0 0
            less ${list[$current_line]}
            ((current_line++))
            redraw
        fi
    else
        redraw
    fi
}

redraw(){
    reset
    print_files
    draw_bar
    get_input
}

declare -A map
cols=$(tput cols)
rows=$(tput lines)
tput clear
bar=`printf ' %.0s' $(seq 1 15)`
total_items=0
current_line=1
load_files
redraw
