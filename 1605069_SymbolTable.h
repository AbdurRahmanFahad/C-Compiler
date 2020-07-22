#include<stdio.h>
#include<string>
#include<iostream>
#include"1605069_ScopeTable.h"

using namespace std;

class Symbol_Table
{
    int count = 0, n;

public:

    ScopeTable *current_scope = nullptr;

    Symbol_Table(int number)
    {
        n = number;
    }

    void Enter_scope()
    {
        ScopeTable *x, *y;
        x = new ScopeTable(n, ++count);
        if(count>1)
            y = current_scope;
        current_scope = x;
        if(count>1)
            current_scope->parentScope = y;

    }

    void Exit_Scope()
    {
        ScopeTable *temp = current_scope;
        current_scope = current_scope->parentScope;
        delete temp;
    }

    bool insert_sym(string s, string t)
    {
        return current_scope->insert_symbol(s, t);
    }



    bool delete_sym(string s)
    {
        return current_scope->delete_entry(s);
    }

    symbol_info* lookup_sym(string s)
    {
        ScopeTable *x = current_scope;
        while(x)
        {
            if(x->look_up(s))
              return x->look_up(s);
            x = x->parentScope;
        }
        return nullptr;
    }

    void print_current_scope()
    {
        current_scope->print();
    }

    void print_all_scope()
    {
        ScopeTable *x = current_scope;
        while(x)
        {
            //cout<<"HI";
            x->print();
            x = x->parentScope;
        }

    }

};
