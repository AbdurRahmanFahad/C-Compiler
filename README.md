# C-Compiler
A Custom Compiler for the C language made using the tools `bison` and `flex`
that generates corresponding assembly code. It supports a subset of the C language,
therefore not all syntaxes are supported. 

# How to use

You will need the followings installed in your machine
* `bison`
* `flex`
* `8086 emulator`

**Steps**

* Clone the repository in your local machine.
* Put your C code in `input.txt` file or you can choose your own C file and edit the `script.sh` file or    `cmdline.bat` file according to your input file name. 
* change directory to the this directory
* if you are on windows run the `cmdline.bat` file from command line (use `.\cmdline.bat` command)
* if you are on linux run the `script.sh` file from terminal (use `./script.sh ` command)
* the corresponding assembly code will be generated into `code.asm` file and will generate a log file named `log.txt` containing errors(if any) in the code.
* run the `code.asm` file in **8086 emulator**


# Sample input output

**input code**

```javascript
int main()
{
    int a , b;
    a = 5;
    b = 7;
    int sum;
    sum = a + b;
    println(sum);
    
}
```

**output assembly code**

```javascript
`
.MODEL SMALL
.STACK 100H
.DATA 
a dw ?
b dw ?
sum dw ?
t0 dw ?
.CODE
main proc

mov ax, @DATA
 mov ds, ax 
mov ax, 5
mov a, ax
mov ax, 7
mov b, ax
mov ax, a
add ax, b
mov t0, ax
mov ax, t0
mov sum, ax
mov ax, sum
call outdec

mov ah, 4ch 
 int 21h 
main endp


outdec proc
 push ax
 push bx
 push cx
 push dx
 cmp ax, 0
 jge begin
 push ax
 mov dl,'-'
 mov ah, 2
 int 21h
 pop ax
 neg ax
begin: 
 xor cx, cx
 mov bx, 10
repeat: 
 xor dx, dx
 div bx
 push dx
 inc cx
 or ax, ax
 jne repeat
 mov ah, 2
print_loop: 
 pop dx 
 add dl, 30h
 int 21h
 loop print_loop
 mov ah, 2
 mov dl, 10
 int 21h
 mov dl, 13
 int 21h
 pop dx
 pop cx
 pop bx
 pop ax
 ret
outdec endp
END MAIN

```
