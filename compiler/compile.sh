#!/bin/bash
#
# Script to compile asm to bash

OK="\033[32mOK\033[0m"
ERROR="\033[31mERR !\033[0m"

if [ $# -lt 1 -o $# -gt 2 ]; then
    echo "Usage: asm (-d) program_name (whithout extension)"
    echo "            -d    debug mode"
    exit 2;
fi

if [ "$1" = "-d" -o "$2" = "-d" ]; then 
    PROG="$2"
    echo -en "\tCompilation... "    
    nasm -f elf32 -g -F dwarf $PROG.asm
    if [ $? -ne 0 ]; then
        echo -e "$ERROR"
        exit 3;              
    fi                                         
    echo -en "$OK\t"                           
    echo -n "Reading... "            
    ld -o $PROG -m elf_i386 -e main $PROG.o    
    if [ $? -ne 0 ]; then    
        echo -e "$ERROR"    
        exit 3;
    fi
    echo -e "$OK"

else
    PROG="$1"
    echo -en "\tCompilation... "
    nasm -f elf32 $PROG.asm
    if [ $? -ne 0 ]; then
        echo -e "$ERROR"
        exit 3;
    fi
    echo -en "$OK\t"
    echo -n "Reading... "
    ld -o $PROG -m elf_i386 -e main $PROG.o
    if [ $? -ne 0 ]; then
        echo -e "$ERROR"
        exit 3;
    fi
    echo -e "$OK"
fi
