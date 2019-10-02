#!/bin/bash
reset(){
    current_file=-1
    tput civis -- invisible
    tput cnorm -- normal
    total_items=0
    tput clear
}

draw_bar(){
    tput cup $rows 0
    echo -e -n "\e[46m$bar"
    tput cup $rows 0
    ((current_line++))
    echo -e -n "\e[97m$PWD ($current_line/$total_items)"
    ((current_line--))
    echo -e -n "\e[0m"
}

print_files(){
    #Print directories then files.
    IFS=$'\r\n' GLOBIGNORE='*' command eval  'dirs=($(ls -p -a | grep /))'
    echo -e -n "\e[96m"
    for i in "${dirs[@]}"
    do
        if (( current_line == total_items ))
        then
            highlight
            echo -e  "${i}"
            un_highlight_dir
        else
            echo -e  "${i}"
        fi
        ((total_items++))
        if (( total_items == rows ))
        then
            return
        fi
    done
    IFS=$'\r\n' GLOBIGNORE='*' command eval  'files=($(ls -p -a| grep -v /))'
    echo -e -n "\e[97m"
    count=0
    for i in "${files[@]}"
    do
        if (( current_line == total_items ))
        then
            highlight
            echo -e  "${i}"
            current_file=$count
            un_highlight_file
        else
            echo -e  "${i}"
        fi
        ((total_items++))
        if (( total_items == rows ))
        then
            return
        fi
        ((count++))
    done
    echo -e -n "\e[39m"
}

get_input(){
    read -r -n1 input
    if [ "$input" = "q" ]
    then
        tput clear
    elif [ "$input" = "j" ]
    then
        if (( current_line != (total_items - 1) ))
        then
            ((current_line++))
        fi
            redraw
    elif [ "$input" = "k" ]
    then
        if (( current_line != 0 ))
        then
            ((current_line--))
        fi
            redraw
    elif [ "$input" = "c" ]
    then
        # Enter key (changes dir)
        if ((current_file == -1))
        then
            cd ${dirs[$current_line]}
            redraw
        else
            tput clear
            tput cup 0 0
            less ${files[$current_file]}
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

highlight(){
    echo -e -n "\e[106m"
    echo -e -n "\e[30m"
}

un_highlight_dir(){
    echo -e -n "\e[96m"
    echo -e -n "\e[49m"
}

un_highlight_file(){
    echo -e -n "\e[97m"
    echo -e -n "\e[49m"
}
declare -A map
cols=$(tput cols)
rows=$(tput lines)

bar=`printf ' %.0s' $(seq 1 $cols)`
total_items=0
current_line=0
redraw
