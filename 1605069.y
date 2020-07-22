%{
#include<bits/stdc++.h>
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<iostream>
#include<fstream>
//#include "SymbolTable.h"
#include "1605069_SymbolTable.h"

#define YYSTYPE symbol_info*

using namespace std;

extern int yylex();
void yyerror(const char *s);
extern FILE *yyin;
extern int line_count;
extern int error;
FILE *parsertext = fopen("log.txt","w");

int labelCount=0;
int tempCount=0;

vector <string> variable_declaration_list;
vector <pair<string, string> > array_dec_list;

char *newLabel()
{
	char *lb= new char[4];
	strcpy(lb,"L");
	char b[3];
	sprintf(b,"%d", labelCount);
	labelCount++;
	strcat(lb,b);
	return lb;
}

char *newTemp()
{
	char *t= new char[4];
	strcpy(t,"t");
	char b[3];
	sprintf(b,"%d", tempCount);
	tempCount++;
	strcat(t,b);
	return t;
}

//SymbolTable *table= new SymbolTable(31);

%}

%error-verbose

%token IF ELSE FOR WHILE DO INT FLOAT DOUBLE CHAR RETURN 
%token VOID BREAK SWITCH CASE DEFAULT CONTINUE ADDOP MULOP ASSIGNOP RELOP
%token LOGICOP SEMICOLON COMMA LPAREN RPAREN LCURL RCURL LTHIRD 
%token RTHIRD INCOP DECOP CONST_INT CONST_FLOAT ID NOT PRINTLN

%left RELOP LOGICOP BITOP 
%left ADDOP 
%left MULOP

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%%

start : program{
	$$ = new symbol_info();
	string p = "";
	p += ".MODEL SMALL\n\.STACK 100H\n\.DATA \n";

	//declare variables
	for(int i = 0; i<variable_declaration_list.size(); i++)
		p += variable_declaration_list[i] + " dw ?\n";
	
	//declare arrays
	for(int i = 0; i<array_dec_list.size(); i++)
		p += array_dec_list[i].first + " dw " + array_dec_list[i].second + " dup(?)\n";

	//cout<<"Hello";

	p = p + ".CODE\n"; 
	if($1)
	p += $1->code;
	p = p + "\n\n\noutdec proc\n";
	p += " push ax\n push bx\n push cx\n push dx\n";
	p += " cmp ax, 0\n jge begin\n push ax\n mov dl,'-'\n";
	p += " mov ah, 2\n int 21h\n pop ax\n neg ax\n";
	p += "begin: \n xor cx, cx\n mov bx, 10\nrepeat: \n"; 
	p += " xor dx, dx\n div bx\n push dx\n inc cx\n or ax, ax\n";
	p += " jne repeat\n mov ah, 2\nprint_loop: \n pop dx \n";
	p += " add dl, 30h\n int 21h\n loop print_loop\n mov ah, 2\n";
	p += " mov dl, 10\n int 21h\n mov dl, 13\n int 21h\n";
	p += " pop dx\n pop cx\n pop bx\n pop ax\n ret\n";
	p += "outdec endp\nEND MAIN\n";

	ofstream fout;
	fout.open("code.asm");
	fout << p;
	//cout<<p;

};

program : program unit {
	$$ = new symbol_info();
		if($1 && $2)
		$$->code = $1->code + $2->code;
	}
	| unit
	{
		if($1)
		$$ = $1;
	}
	;

unit : var_declaration
	{
		$$ = new symbol_info();
		if($1)
		$$ = $1;
	}
     | func_declaration{
		 $$ = new symbol_info();
		 if($1)
		 $$ = $1;
	 }
     | func_definition
	 {
		 $$ = new symbol_info();
		 if($1)
		 $$ = $1;
	 }
     ;

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON{
	$$ = new symbol_info();
	}
		| type_specifier ID LPAREN RPAREN SEMICOLON{
			$$ = new symbol_info();
		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement{
			$$ = new symbol_info();
			$$->code += $2->get_name() + " proc\n";

			if($2->get_name() == "main")
			{
				$$->code += "mov ax, @data\n mov ds, ax \n" + $6->code;
				$$->code += "\nmov ah, 4ch \n int 21h \nmain endp";
            }
			else
			{
				$$->code += $6->code + "\nret\n" + $2->get_name() + "endp\n";
			}
		}
		| type_specifier ID LPAREN RPAREN compound_statement{
			$$ = new symbol_info();
			$$->code += $2->get_name() + " proc\n";
			if($2->get_name() == "main")
			{
				$$->code += "\nmov ax, @DATA\n mov ds, ax \n" + $5->code;
				$$->code += "\nmov ah, 4ch \n int 21h \nmain endp";
            }
			else
			{
				$$->code += $5->code + "\nret\n" + $2->get_name() + " endp\n";
			}
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID{
	$$ = new symbol_info();
				//variable_declaration_list.push_back($4->get_name());

		}
		| parameter_list COMMA type_specifier{
			$$ = new symbol_info();
		}
 		| type_specifier ID{
			 $$ = new symbol_info();
		 }
		| type_specifier{
			$$ = new symbol_info();
		}
 		;

compound_statement	: LCURL statements RCURL
						{	$$ = new symbol_info();
							if($2)
							$$=$2;
							//table->Enter_Scope();
						}
					| LCURL RCURL
						{
							$$=new symbol_info("compound_statement","dummy");
							//table->Enter_Scope();
						}
					;



var_declaration : type_specifier declaration_list SEMICOLON{
					//declaration_list push
					$$ = new symbol_info();
			}
 		 ;

type_specifier	: INT
 		| FLOAT
 		| VOID
 		;

declaration_list : declaration_list COMMA ID{
			//declaration_list push
			$$ = new symbol_info();
			variable_declaration_list.push_back($3->get_name());
			}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD{
			 //array declaration_list push
			 $$ = new symbol_info();
			 array_dec_list.push_back(make_pair($3->get_name(), $5->get_name() ) );
		   }
 		  | ID{
			//declaration_list push
			$$ = new symbol_info();
			if($1)
			$$ = $1;
			variable_declaration_list.push_back($1->get_name());
		   }
 		  | ID LTHIRD CONST_INT RTHIRD{
			//array declaration_list push 
			$$ = new symbol_info();  
			array_dec_list.push_back(make_pair($1->get_name(), $3->get_name()));
		   }
 		  ;

statements : statement {
				$$ = new symbol_info();
				if($1)
				$$ = $1;
			}
	       | statements statement {
			   	$$ = new symbol_info();
				if($1)
				$$ = $1;
				if($2)
				$$->code += $2->code;
				delete $2;
			}
	       ;


statement 	: var_declaration{
					$$ = new symbol_info();
					if($1)
					$$=$1;
				}
	  		|	expression_statement {
				  	$$ = new symbol_info();
					if($1)
					$$=$1;
				}
			| 	compound_statement {
					$$ = new symbol_info();
					if($1)
					$$=$1;
				}
			|	FOR LPAREN expression_statement expression_statement expression RPAREN statement {			
					
					
					$$ = new symbol_info();
					if($3)
                    $$ = $3;
					char *l1 = newLabel();
					char *l2 = newLabel();
					if($4)																					$$->code += string(l1) + ":\n";
					$$->code += $4->code;
					$$->code += "mov ax," + $4->get_name() + "\n";
					$$->code += "cmp ax, 0\n";
					$$->code += "je " + string(l2) + "\n";
					if($7)
					$$->code += $7->code;
					if($5)
					$$->code += $5->code;
					$$->code += "jmp " + string(l1) + "\n";
					$$->code += string(l2) + ":\n";	

				}
			|	IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
					$$ = new symbol_info();
					if($3)
					$$ = $3;
					
					char *label = newLabel();
					$$->code += "mov ax, "+$3->get_name()+"\n";
					$$->code += "cmp ax, 0\n";
					$$->code += "je "+string(label)+"\n";
					if($5)
					$$->code += $5->code;
					$$->code += string(label)+":\n";
					
					//$$->set_name("if");//not necessary
				}
			|	IF LPAREN expression RPAREN statement ELSE statement {
					$$ = new symbol_info();
					if($3)
					$$ = $3;
					//similar to if part
					char *l1 = newLabel();
					char *l2 = newLabel();
					$$->code += "mov ax, " + $3->get_name() + "\n";
					$$->code += "cmp ax, 0\n";
					$$->code += "je " + string(l1) + "\n";
					if($5)
					$$->code += $5->code;
					$$->code += "jmp " + string(l2) + "\n";;
					$$->code += string(l1) + ":\n";
					if($7)
					$$->code += $7->code;
					$$->code += string(l2) + ":\n";

				}
			|	WHILE LPAREN expression RPAREN statement {
					$$ = new symbol_info();
					char *l1 = newLabel();
					char *l2 = newLabel();
					$$->code += string(l1) + ":\n";
					$$->code += $3->code;
					$$->code += "mov ax, " + $3->get_name() + "\n";
					$$->code += "cmp ax, 0\n";
					$$->code += "je " + string(l2) + "\n";
					$$->code += $5->code;
					$$->code += "jmp " + string(l1) + "\n";
					$$->code += string(l2) + ":\n";
				}
			|	PRINTLN LPAREN ID RPAREN SEMICOLON {
					// write code for printing an ID. You may assume that ID is an integer variable.
					$$ = new symbol_info("println", "nonterminal");
					if($3)
					$$->code += "mov ax, " + $3->get_name() ;
				    $$->code += "\ncall outdec\n";
				}
			| 	RETURN expression SEMICOLON {
					// write code for return.
					$$ = new symbol_info();
					if($1)
					$$ = $1;
					if($2)
					$$->code += "mov ax, " + $2->get_name() + "\n";
					$$->code += "ret\n";
				}
			;
		
expression_statement	: SEMICOLON	{
							$$ = new symbol_info(";","SEMICOLON");
							$$->code="";
						}			
					| expression SEMICOLON {
						$$ = new symbol_info();
							if($1)
							$$=$1;
						}		
					;
						
variable	: ID {
				
				$$ = new symbol_info($1);
				$$->code="";
				$$->set_type("notarray");
		}		
		| ID LTHIRD expression RTHIRD {
			$$ = new symbol_info();
				if($1)
				$$= new symbol_info($1);
				$$->set_type("array");
				
				if($3)
				$$->code = $3->code+"mov bx, " +$3->get_name() +"\nadd bx, bx\n";
				
				delete $3;
		}	
		;



expression : logic_expression {
	$$ = new symbol_info();
			if($1)
			$$= $1;
		}	
		| variable ASSIGNOP logic_expression {
			$$ = new symbol_info();
				if($1)
				$$=$1;
				$$->code=$3->code+$1->code;
				$$->code+="mov ax, "+$3->get_name()+"\n";
				if($$->get_type()=="notarray"){ 
					$$->code+= "mov "+$1->get_name()+", ax\n";
				}
				
				else{
					$$->code+= "mov  "+$1->get_name()+"[bx], ax\n";
				}
				delete $3;
			}	
		;
			
logic_expression : rel_expression {
	$$ = new symbol_info();
					if($1)
					$$= $1;		
				}	
		| rel_expression LOGICOP rel_expression {
			$$ = new symbol_info();
					if($1)
					$$=$1;
					$$->code+=$3->code;
					
					char *l1 = newLabel();
					char *l2 = newLabel();
					char *l3 = newLabel();
					char *temp=newTemp();

					if($2->get_name()=="&&"){
						$$->code += "mov ax, " + $1->get_name() + "\n";
						$$->code += "cmp ax, 0\n";
						$$->code += "je " + string(l2) + "\n";
						$$->code += "mov ax, " + $3->get_name() + "\n";
						$$->code += "cmp ax, 0\n";
						$$->code += "je " + string(l2) + "\n";
						$$->code += string(l1) + ":\n";
						$$->code += "mov " + string(temp) + ", 1\n";
						$$->code += "jmp " + string(l3) + "\n";
						$$->code += string(l2) + ":\n";
						$$->code += "mov " + string(temp) + ", 0\n";
						$$->code += string(l3) + ":\n";
					}
					else if($2->get_name()=="||"){
						$$->code += "mov ax, " + $1->get_name() + "\n";
						$$->code += "cmp ax, 0\n";
						$$->code += "jne " + string(l2) + "\n";
						$$->code += "mov ax, " + $3->get_name() + "\n";
						$$->code += "cmp ax, 0\n";
						$$->code += "jne " + string(l2) + "\n";
						$$->code += string(l1) + ":\n";
						$$->code += "mov " + string(temp) + ", 0\n";
						$$->code += "jmp " + string(l3) + "\n";
						$$->code += string(l2) + ":\n";
						$$->code += "mov " + string(temp) + ", 1\n";
						$$->code += string(l3) + ":\n";

					}
					variable_declaration_list.push_back(temp);
					delete $3;
				}	
			;
			
rel_expression	: simple_expression {
	$$ = new symbol_info();
				if($1)
				$$= $1;
			}	
		| simple_expression RELOP simple_expression {
			$$ = new symbol_info();
				if($1)
				$$=$1;
				$$->code+=$3->code;
				$$->code+="mov ax, " + $1->get_name()+"\n";
				$$->code+="cmp ax, " + $3->get_name()+"\n";
				char *temp=newTemp();
				char *label1=newLabel();
				char *label2=newLabel();
				if($2->get_name()=="<"){
					$$->code+="jl " + string(label1)+"\n";
				}
				else if($2->get_name()=="<="){
					$$->code+="jle " + string(label1)+"\n";
				}
				else if($2->get_name()==">"){
					$$->code+="jg " + string(label1)+"\n";
				}
				else if($2->get_name()==">="){
					$$->code+="jge " + string(label1)+"\n";
				}
				else if($2->get_name()=="=="){
					$$->code+="je " + string(label1)+"\n";
				}
				else{
					$$->code+="jne " + string(label1)+"\n";
				}
				
				$$->code+="mov "+string(temp) +", 0\n";
				$$->code+="jmp "+string(label2) +"\n";
				$$->code+=string(label1)+":\nmov "+string(temp)+", 1\n";
				$$->code+=string(label2)+":\n";
				$$->set_name(temp);
				variable_declaration_list.push_back(temp);
				delete $3;
			}	
		;
				
simple_expression : term {
	$$ = new symbol_info();
				if($1)
				$$ = $1;
			}
		| simple_expression ADDOP term {
			$$ = new symbol_info();
				if($1)
				$$ = $1;
				if($3)
				$$->code += $3->code;
				
				// move one of the operands to a register, perform addition or subtraction with the other operand and move the result in a temporary variable  
				if($1)
				$$->code += "mov ax, " + $1->get_name() + "\n";
				char *temp= newTemp();

				if($2->get_name()=="+"){
					$$->code += "add ax, " + $3->get_name() + "\n";
				}
				else{
					$$->code += "sub ax, " + $3->get_name() + "\n";
				} 
				$$->code += "mov " + string(temp) + ", ax\n";
				$$->set_name(temp);
				variable_declaration_list.push_back(temp);
				delete $3;
				//cout << endl;
			}
				;
				
term :	unary_expression {
	$$ = new symbol_info();
						if($1)
						$$= $1;
						}
	 | 	term MULOP unary_expression {
		 $$ = new symbol_info();
		 				if($1)
						$$=$1;
						$$->code += $3->code;
						$$->code += "mov ax, "+ $1->get_name()+"\n";
						$$->code += "mov bx, "+ $3->get_name() +"\n";
						char *temp=newTemp();
						if($2->get_name()=="*"){
							$$->code += "mul bx\n";
							$$->code += "mov "+ string(temp) + ", ax\n";
						}
						else if($2->get_name()=="/"){
							// clear dx, perform 'div bx' and mov ax to temp
							$$->code += "mov dx, 0\n";
							$$->code += "div bx\n";
							$$->code += "mov "+ string(temp) + ", ax\n";
						}
						else{
							// clear dx, perform 'div bx' and mov dx to temp
							$$->code += "mov dx, 0\n";
							$$->code += "div bx\n";
							$$->code += "mov "+ string(temp) + ", dx\n";
						}
						$$->set_name(temp);
						//cout << endl << $$->code << endl;
						variable_declaration_list.push_back(temp);
						delete $3;
						}
	 ;

unary_expression 	:	ADDOP unary_expression  {
	$$ = new symbol_info();
							if($2)
							$$=$2;
							// Perform NEG operation if the symbol of ADDOP is '-'
							if($1->get_name() == "-")
							{
								$$->code += "mov ax, " + $2->get_name() + "\n";
								$$->code += "neg ax\n";
								$$->code += "mov " + $2->get_name() + ",ax";
							}
						}
					|	NOT unary_expression {
						$$ = new symbol_info();
							if($2)
							$$=$2;
							$$->code="mov ax, " + $2->get_name() + "\n";
							$$->code+="not ax\n";
							$$->code+="mov " + $2->get_name() + ", ax";
						}
					|	factor {
						$$ = new symbol_info();
							if($1)
							$$=$1;
						}
					;
	
factor	: variable 
			{
				$$ = new symbol_info();
				if($1)
				$$= $1;
				
				if($$->get_type()=="notarray"){
					}
				else{
					char *temp = newTemp();
					$$->code+="mov ax, " + $1->get_name() + "[bx]\n";
					$$->code+= "mov " + string(temp) + ", ax\n";
					$$->set_name(temp);
					variable_declaration_list.push_back(temp);
					}
			}
	| LPAREN argument_list RPAREN 
	{
		//
		$$ = new symbol_info();
	}
	| LPAREN expression RPAREN 
			{
				$$ = new symbol_info();
			if($2)
			$$ = $2;
			}
	| CONST_INT {
		$$ = new symbol_info();
			if($1)
			$$ = $1;
			}
	| CONST_FLOAT {
		$$ = new symbol_info();
			if($1)
			$$ = $1;
			}
	| variable INCOP {
		$$ = new symbol_info();
			if($1)
			$$=$1;
			// perform incop depending on whether the varaible is an array or not
			char *temp= newTemp();

			if($$->get_type() == "array")
				$$->code += "mov ax, " + $1->get_name() + "[bx]\n";
			else
				$$->code += "mov ax, " + $1->get_name() + "\n";

			$$->code += "mov " + string(temp) + ", ax\n";

			if($$->get_type() == "array"){
				$$->code += "mov ax, " + $1->get_name() + "[bx]\n";
				$$->code += "inc ax\n";
				$$->code += "mov ax, " + $1->get_name() + "[bx], ax\n";
			}
			else
				$$->code += "inc " + $1->get_name() + "\n";

			$$->set_name(temp);
			variable_declaration_list.push_back(temp);
			}
	| variable DECOP {
		$$ = new symbol_info();
			if($1)
			$$=$1;
			// perform incop depending on whether the varaible is an array or not
			char *temp= newTemp();

			if($$->get_type() == "array")
				$$->code += "mov ax, " + $1->get_name() + "[bx]\n";
			else
				$$->code += "mov ax, " + $1->get_name() + "\n";

			$$->code += "mov " + string(temp) + ", ax\n";

			if($$->get_type() == "array"){
				$$->code += "mov ax, " + $1->get_name() + "[bx]\n";
				$$->code += "dec ax\n";
				$$->code += "mov ax, " + $1->get_name() + "[bx], ax\n";
			}
			else
				$$->code += "dec " + $1->get_name() + "\n";

			$$->set_name(temp);
			variable_declaration_list.push_back(temp);
	}
	;

argument_list : arguments
				{
					$$ = new symbol_info();
					if($1)
					$$ = $1;
				}
			  |
			  ;
	
arguments : arguments COMMA logic_expression
			{
				$$ = new symbol_info();
				if($1 && $3)
				$$->code += $1->code + $3->code;
 			}
	      | logic_expression
		  	{
				  $$ = new symbol_info();
				if($1)
				$$ = $1;
		  	}
	      ;		
		
%%


void yyerror(const char *s){
	cout << "Error at line no " << line_count << " : " << s << endl;
}

int main(int argc, char * argv[]){
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	

	yyin= fin;
	yyparse();
	cout << endl;
	//cout << endl << "\t\tsymbol table: " << endl;
	//table->dump();
	
	fprintf(parsertext, "\nTotal Lines: %d\n",line_count);
	fprintf(parsertext, "\nTotal Errors: %d\n",error);
	fclose(parsertext);
	printf("\n");
	return 0;
}
