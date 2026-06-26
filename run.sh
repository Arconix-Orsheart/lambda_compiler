bison -d -v -r all myanalyzer.y -Wcounterexamples
flex mylexer.l
gcc -o mycompiler lex.yy.c myanalyzer.tab.c cgen.c -lfl

