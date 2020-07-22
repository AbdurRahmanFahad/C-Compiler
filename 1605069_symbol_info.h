#include<stdio.h>
#include<string>
#include<string.h>

using namespace std;

class symbol_info
{
    string name, type, subtype;

public:

    string code;
    symbol_info *next;

    symbol_info()
    {
        name = "";
        type = "";
        code = "";
        subtype = "";
        next = nullptr;
    }
    symbol_info(string nam)
    {
        name = nam;
        subtype = "";
        code="";
        next = nullptr;
    }
    symbol_info(string nam, string typ)
    {
        name = nam;
        type = typ;
        subtype = "";
        code="";
        next = nullptr;
    }
    symbol_info(char *symbol, char *type){
            this->name = string(symbol);
            this->type = string(type);
            code="";
            next = nullptr;
        }
    symbol_info(const symbol_info *sym)
    {
         	name = sym->name;
         	type = sym->type;
         	code = sym->code;
            next = sym->next;
            //cout<<"hello";
    }
    symbol_info(string nam, string typ, string subtyp)
    {
        name = nam;
        type = typ;
        subtype = subtyp;
        code="";
        next = nullptr;
    }


    string get_name(){
        return name;
    }
    string get_type(){
        return type;
    }
    string get_subtype(){
        return subtype;
    }



    void set_name(string n)
    {
        this->name = n;
    }

    void set_name(char *symbol)
    {
        //cout<<"hello";
        this->name = string(symbol);
    }

    void set_type(string t)
    {
        this->type = t;
    }

    void set_type(char *type)
    {
        //cout<<"hello";
        this->type= string(type);
    }

    void set_subtype(string st)
    {
        this->subtype = st;
    }
};
