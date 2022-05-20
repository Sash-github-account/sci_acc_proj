# -*- coding: utf-8 -*-
"""
Created on Thu Feb 17 11:18:52 2022

@author: nsash
Usage:
    First import this file as a module <name>:
            import sci_acc_assembler [as <name>]
        and call required functions: 
            <name>.exp(), <name>.sin(), <name>.cos()
    This will automatically create the binary file for target memory (default memory organisation is 8 bits -or- 1 Byte). 
    
    For different memory organisation, set the value for the variable 
        <name>.mem_d_wd = <int value>
    To specify a file name for write target memory binary, set the variable 
        <name>.trgt_mem_file = <string>
    To specify number of coefficients used, set 
        <name>.coeff_dpth = <int value>
        
        
references:
    1.https://www.pythonpool.com/python-int-to-binary/
    2.https://www.geeksforgeeks.org/program-for-conversion-of-32-bits-single-precision-ieee-754-floating-point-representation/#:~:text=Write%20a%20program%20to%20find%20out%20the%2032,%3D%200%20%7C%2010000011%20%7C%2000001100000000000000000%20Output%3A%2016.75
    3.https://stackoverflow.com/questions/8751653/how-to-convert-a-binary-string-into-a-float-value/8762541#38283005
"""    

"""--------------------------------"""
"""--------------------------------"""    
"""--------------------------------"""
start_prog = 0
fac_inv_list = []
mem_d_wd = 8
trgt_mem_file = "trgt_sci_acc_mem"
coeff_dpth = 32
for i in range(coeff_dpth):
    if (i==0):
        fac = 1
    else:
        fac = fac * i
    fac_inv_list.append(1/fac)
"""----------------------------------"""
"""--------------------------------"""
"""--------------------------------"""




"""--------------------------------"""
import struct
"""--------------------------------"""


"""--------------------------------"""
"""--------------------------------"""
"""--------------------------------"""
def float_to_bin(num):
    bits, = struct.unpack('!I', struct.pack('!f', num))
    return "{:032b}".format(bits)

def int_2_bin(n): 
    b= []
    while(n>0):
        d=n%2
        b.append(str(d))
        n=n//2
    b.reverse()
    if(len(b) < 4):
        b.insert(0,"0")
    res = "".join(b)
    return res
  
def res_chk(res):
    if(res > 15):
        res = 15
    elif(res < 5):
        res = 5
    else:
        res  = res
    return int(res)


def exp_sin_cos_comp_model(op, resl, x):
    res=0    
    if(op == "exp"):
        for i in range(resl):
            res = res +  (x**i * fac_inv_list[i])
    elif(op == "sin"):
        for i in range(resl):
            res = res +  ((-1)**i * x**((2*i)+1) * fac_inv_list[((2*i)+1)])
    elif(op == "cos"):
        for i in range(resl):
            res = res +  ((-1)**i * x**((2*i)) * fac_inv_list[((2*i))])
    return res


def assm_for_trgt_mem(op_str,  mem_file="trgt_sci_acc_mem", mem_wd=8):
    global start_prog
    op_str_ar = list(op_str)
    lenstr = len(op_str_ar)
    pad = lenstr % mem_wd 
    print(mem_wd-pad)
    list_fin = []    
    if(start_prog == 0):
        fl = open(mem_file,"w")
        fl.close()
        start_prog = 1
    for i in range(mem_wd-pad):
        op_str_ar.insert(0, "0")
    for i in range(0, len(op_str_ar), mem_wd):
        list_fin.append("".join(op_str_ar[i:i+mem_wd]))
    print(list_fin)
    jnt_pkt = "\n".join(list_fin) + "\n"
    wr_to_mem_file(jnt_pkt, mem_file)
        

def exp(x, res=5):
    res = res_chk(res)
    print(res)
    raw_op = "exp" + " " + str(res) + " " + str(x)
    op_str = "000" + int_2_bin(res) + float_to_bin(x)
    print(raw_op)
    assm_for_trgt_mem(op_str, mem_file=trgt_mem_file, mem_wd=mem_d_wd)
    return exp_sin_cos_comp_model("exp", res, x)

def sin(x, res=5):
    res = res_chk(res)
    print(res)    
    raw_op = "sin" + " " + str(res) + " " + str(x)
    op_str = "001" + int_2_bin(res) + float_to_bin(x)
    print(raw_op)
    assm_for_trgt_mem(op_str, mem_file=trgt_mem_file, mem_wd=mem_d_wd)
    return exp_sin_cos_comp_model("sin", res, x)

def cos(x, res=5):
    res = res_chk(res)        
    print(res)
    raw_op = "cos" + " " + str(res) + " " + str(x)
    op_str = "010" + int_2_bin(res) + float_to_bin(x)
    print(raw_op)
    assm_for_trgt_mem(op_str, mem_file=trgt_mem_file, mem_wd=mem_d_wd)
    return exp_sin_cos_comp_model("cos", res, x)


def wr_to_mem_file(str_list, mem_file="trgt_sci_acc_mem"):
    fileptr = open(mem_file, "a")
    fileptr.write(str_list)
    fileptr.close()
"""--------------------------------"""
"""--------------------------------"""
"""--------------------------------"""
    


    
if __name__ == "__main__":
    e,raw = exp(1.2,6)
    print(e)
    print(len(list(e)))
    print(raw)
    assm_for_trgt_mem(e)
    e,raw = sin(1.2,6)
    print(e)
    print(len(list(e)))
    print(raw)
    assm_for_trgt_mem(e)
    e,raw = cos(1.2,6)
    print(e)
    print(len(list(e)))
    print(raw)
    assm_for_trgt_mem(e)    