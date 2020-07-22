
bison -d -y -v 1605069.y
echo '1'
g++ -std=gnu++11 -w -c -o y.o y.tab.c
echo '2'
flex 1605069.l
echo '3'
g++ -std=gnu++11 -w -c -o l.o lex.yy.c
echo '4'
g++ -std=gnu++11 -o a.exe y.o l.o
echo '5'
.\a.exe	input.txt
