
#include<stdio.h>
#include<string>
#include<iostream>
#include"1605069_symbol_info.h"
extern FILE *pulser;

using namespace std;

class ScopeTable
{
public:
    symbol_info **table;
    ScopeTable *parentScope = nullptr;
    int table_id, length;

    int hash_function(string name, int size)
    {
        long long x = 0, p = 73;
        for(long long i = 0; i<name.size(); i++)
        {
            x += name[i]*p;
            p = p*73;
        }

        return (x%size);
    }

    ScopeTable(int n, int id)
    {
        table = new symbol_info*[n];
        for(int i = 0; i<n; i++)
            table[i] = nullptr;
        length = n;
        table_id = id;
    }

    bool insert_symbol(string symbol, string typ)
    {
        if(look_up(symbol)==nullptr)
        {

            int key = hash_function(symbol, length), index = 0;
            symbol_info* x = table[key];
            if(x==nullptr)
            {
                symbol_info *new_obj;
                new_obj = new symbol_info(symbol, typ);
                table[key] = new_obj;
            }
            else
            {
                index++;
                while(x->next)
                {
                    x = x->next;
                    index++;
                }
                symbol_info *new_obj;
                new_obj = new symbol_info(symbol, typ);

                x->next = new_obj;
            }
            //printf("Inserted in ScopeTable# %d at position %d, %d\n", table_id, key, index);

        }
        else
        {
            //cout<<"already exists in current ScopeTable"<<endl;
            return false;
        }


    }

    symbol_info* look_up(string symbol)
    {
        int key = hash_function(symbol, length), index = 0;
        if(table[key]==nullptr)
            return nullptr;
        else
        {
            symbol_info* auto1 = table[key];
            while(auto1)
            {
                if(auto1->get_name()==symbol)
                {
                    //printf("Found in ScopeTable# %d at position %d, %d\n", table_id, key, index);
                    return auto1;
                }
                index++;
                auto1 = auto1->next;
            }
        }
        return nullptr;
    }

    bool delete_entry(string symbol)
    {
        if(look_up(symbol)!=nullptr)
        {
            int key = hash_function(symbol, length), index = 0;
            symbol_info* auto1 = table[key];
            while(auto1)
            {
                if(auto1->next)
                {
                    if(auto1->next->get_name()==symbol)
                    {
                        auto1->next = auto1->next->next;
                        //auto1->next = nullptr;
                        return true;
                    }
                }
                else if(auto1->get_name()==symbol)
                {
                    //cout<<"ajshf";
                    table[key] = nullptr;
                    return true;
                }

                auto1 = auto1->next;
            }

        }
        else
        {
            //cout<<"Not found"<<endl;
            return false;
        }
    }

    void print()
    {
        fprintf(pulser, "\n\n--------------------------------------------------------------------------- \n");
        fprintf(pulser, "\nScopeTable #%d\n" , table_id);
        for(int i = 0; i<length; i++)
        {
            fprintf(pulser, "%d --> " , i);
            symbol_info *x = table[i];
            if(x!=nullptr)
            {
                while(x)
                {
                    fprintf(pulser, "< %s : %s > " ,x->get_name().c_str(), x->get_type().c_str() );
                    //cout<<"< "<<x->get_name()<<" : "<<x->get_type()<<"> ";
                    x = x->next;
                }
            }
            fprintf(pulser, "\n");

        }
        fprintf(pulser, "\n--------------------------------------------------------------------------- \n\n");

    }

    ~ScopeTable()
    {
        delete table;
    }
};
