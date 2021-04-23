import re 
import operator 
import sys 
import copy 
import csv 

#printContent = False 

def eval_binary_expr(op1, oper, op2):
    op1,op2 = int(op1), int(op2)
    if(oper=='+'):
        return op1+op2
    elif(oper=='-'):
        return op1-op2
    elif(oper=='*'):
        return op1*op2
    elif(oper=="/"):
        return op1/op2
    elif(oper=="<"):
        return op1<op2
    elif(oper==">"):
        return op1>op2
    elif(oper=="||"):
        return op1 or op2
    elif(oper=="&&"):
        return op1 and op2

def print_tac(icg):
    for i in icg:
        if(i["OP"] in ['+','-','*','/','>','<','>=','<=','==','&&','||']):
            print(i["RES"],'=',i["ARG1"],i["OP"],i["ARG2"],sep = " ")
        
        elif(i["OP"] == '='):
            print(i["RES"],'=',i["ARG1"],sep = " ")

        elif(i["OP"] == 'if'):
            print(i["OP"],i["ARG1"],"goto",i["RES"],sep = " ")

        elif(i["OP"] == 'goto'):
            print("goto",i["RES"],sep=" ")

        elif(i["OP"] == 'label'):
            print(i["RES"],":",sep="")

        elif(i["OP"] == 'call'):
            print(i["OP"],i["ARG1"],i["ARG2"])

        elif(i["OP"] == 'param'):
            print(i["OP"],i["ARG1"])

icg = [] 
with open("icg.txt") as csvFile: #Assuming it is in a csv format
    reader = csv.DictReader(csvFile)
    icg = list(reader)

for d in icg:
    for k in d.keys():
        if d[k] is not None:
            d[k]=d[k].strip()

#print(icg)

def findEntries(icg,entry):
    entry.add(0)

    for i in range(len(icg)):
        if(icg[i]['OP'] == 'if' or icg[i]['OP'] == 'goto'): #GOTO for us 
            entry.add(i+1)
        if(icg[i]['OP'] == 'label'):
            entry.add(i)  

entry = set()
findEntries(icg,entry)
entry.add(len(icg))
entry = sorted(entry)
bblocks = [] 


for i in range(len(entry)-1):
    bblocks.append(icg[entry[i]:entry[i+1]])

def is_num(num): #this can be rewritten in terms of operator, exponent and 
    return bool(re.match(r'^-?\d+(\.\d+)?$',num))

#to print the icg in tac format - not needed now?
'''
def print_icg(icg):
    for i in icg:
        print(i.strip())
'''

def constant_folding(bblock): 
    for i in bblock:
        if(is_num(i["ARG1"]) and is_num(i["ARG2"])):
            op = i["OP"]

            if (i["OP"] == "&&"):
                op = "and"
            elif (i["OP"] == "||"):
                op = "or"

            expr = i["ARG1"] + op + i["ARG2"]
            i["OP"] = "="
            i["ARG1"] = str(eval(expr))
            i["ARG2"] = "" 


def constant_propagation(bblock): 
    prop = dict() 

    for i in bblock:
        if(i["OP"] == '=' and i["ARG2"] == ""):
            prop[i["RES"]] = i["ARG1"] 

        if(i["ARG1"] in prop):
            i["ARG1"] = prop[i["ARG1"]]

        if(i["ARG2"] in prop):
            i["ARG2"] = prop[i["ARG2"]]
    print(prop)
        

def cse(bblock):
    subexpression = dict()
    used = set() 

    for i in bblock:
        expr1 = (i["OP"],i["ARG1"],i["ARG2"])
        expr2 = (i["OP"],i["ARG2"],i["ARG1"])
  
    unused = dict() 

    for i in subexpression:
        if(i[1] not in used and i[2] not in used):
            unused[i] = subexpression[i]

    subexpression = unused

    for i in bblock:
        exp = (i["OP"],i["ARG1"],i["ARG2"]) 
        if(exp in subexpression and i["RES"] != subexpression[exp]):
            i["OP"] = '='
            i["ARG1"] = subexp[exp]
            i["ARG2"] = ""
    
def dce(icg):
    alive = set() 
    dead = set()

    for i in range(len(icg)-1):
        if(icg[i]["OP"] == "if"):
            if(icg[i]["ARG1"] == "True"):
                alive.add(icg[i]["RES"])
                dead.add(icg[i+1]["RES"])
                
            if(icg[i]["ARG1"] == "False"):
                alive.add(icg[i+1]["RES"])
                dead.add(icg[i]["RES"])

    icg_new = [] 

    print(alive)
    print(dead) 

    is_alive = True 

    for i in icg:

        if(i["OP"] == "if" and i["ARG1"] in ['True','False']):

            if(i["RES"] in dead):
                is_alive = False
            else:
                is_alive = True
            continue

        elif(i["OP"] == "goto"):
            if(i["RES"] in dead):
                is_alive = False
            else:
                is_alive = True

        elif(i["OP"] == "label"):
            if(i["RES"] in dead):
                is_alive = False
            else:
                is_alive = True
        
        if(is_alive):
            icg_new.append(i)
    return icg_new


for i in bblocks:
    old_i = copy.deepcopy(i) 
    constant_folding(i)
    constant_propagation(i)

    while(old_i!=i):
        old_i = copy.deepcopy(i)
        constant_folding(i)
        constant_propagation(i)
    
    #Common subexpression elimination 
    cse(i)

icg = [i for bblock in bblocks for i in bblock]
print_tac((icg))

print('-----------------------------------\n')
icg = dce(icg)
print_tac(icg)