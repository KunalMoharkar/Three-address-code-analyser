%{
	#include<bits/stdc++.h>
	using namespace std;
	#include "y.tab.h" 
%}

%%
"{" return OP;
"}" return CL;
.*  { return ALPHANUM; }
'\n' {printf("in lex NL "); return NL;}
%%

int yywrap() 
{ } 