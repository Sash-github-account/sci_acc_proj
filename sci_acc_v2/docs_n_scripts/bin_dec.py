# -*- coding: utf-8 -*-
"""
Created on Sat Feb 26 16:06:31 2022

@author: nsash
"""

def bin_dec_conv(my_choice, my_dec, my_bin):
    if my_choice==1:
        i=1
        s=0
        while my_dec>0:
           rem=int(my_dec%2)
           s=s+(i*rem)
           my_dec=int(my_dec/2)
           i=i*10
           print ("The binary of the given number is ",s,'.')
    else:
       #my_bin=input ('Enter binary to be converted: ')
       n=len(my_bin)
       res=0
       for i in range(1,n+1):
          res=res+ int(my_bin[i-1])*2**(n-i)
       print ("The decimal of the given binary is ",res,'.')
    return res


def create_bin_file(file, byte_arr):
    f = open(file, 'a+b')
    binary_format = bytearray(byte_arr)
    print(binary_format)
    f.write(binary_format)
    f.close()


def clean_bin_file(file):
    f = open(file, 'w+b')
    f.close()    


def rd_bin_txt_file(file):
    fp = open(file, 'r')
    lines = fp.read().split("\n")
    #for l in range(len(lines)):
    #    lines[l] = int(lines[l])
    print(lines[0])
    arr_for_bin_file = []
    for l in lines:
        arr_for_bin_file.append(bin_dec_conv(0, 0, l))
    fp.close()
    return arr_for_bin_file
    


def compile_sciacc():
    bin_file = "sci_acc_eeprom_bin"
    txt_file = "test_sci_acc_mem"
    byte_arr = rd_bin_txt_file(txt_file)
    print(byte_arr)
    clean_bin_file(bin_file)
    create_bin_file(bin_file, byte_arr)
    
    
#----------#
compile_sciacc()
#----------#
    