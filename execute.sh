#!/bin/bash


lex -i lex.l
yacc -d yacc.y
g++ -c y.tab.c -o y.tab.o
g++ -c lex.yy.c -o lex.yy.o
g++ lex.yy.o y.tab.o -o program
./program 