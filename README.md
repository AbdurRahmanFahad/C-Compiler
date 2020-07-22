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

* Clone the repository in your machine.
* Put your C code in `input.txt` file or you can choose your own C file and edit the `script.sh` file or    `cmdline.bat` file according to your input file name. 
* change directory to the this directory
* if you are on windows run the **cmdline.bat** file from command line
* if you are on linux run the **script.sh** file from terminal
* the corresponding assembly code will be generated into `code.asm` file and will generate a log file named `log.txt` containing errors(if any) in the code.
* run the `code.asm` file in **8086 emulator**