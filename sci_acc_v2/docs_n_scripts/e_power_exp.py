# -*- coding: utf-8 -*-
"""
Created on Tue Feb 15 18:47:42 2022

@author: nsash
"""

x=40
res=x
fac=1
fac_inv_list = []

for i in range(32):
    if (i==0):
        fac = 1
    else:
        fac = fac * i
    print(str(i) + " " + str(1/fac))
    fac_inv_list.append(1/fac)

for i in range(10):
    res = res +  (x**i * fac_inv_list[i])
    print (str(fac_inv_list[i]) + " " + str(x**i) + " " + str(x**i * fac_inv_list[i]) + " " + str(res - (x**i * fac_inv_list[i])) + " " + str(res))
    
    
print(str(res))


x=7
res=0
for i in range(5):

    res = res +  ((-1)**i * x**((2*i)+1) * fac_inv_list[((2*i)+1)])
    print (str(fac_inv_list[(2*i)+1]) + " " + str((-1)**i *x**((2*i)+1)) + " " + str((-1)**i *x**((2*i)+1) * fac_inv_list[(2*i)+1]) + " " + str(res - ((-1)**i *x**((2*i)+1) * fac_inv_list[(2*i)+1])) + " " + str(res))
    
    
print(str(res))



x=1
res=0
for i in range(5):

    res = res +  ((-1)**i * x**((2*i)) * fac_inv_list[((2*i))])
    print (str(fac_inv_list[(2*i)]) + " " + str((-1)**i *x**((2*i))) + " " + str((-1)**i *x**((2*i)) * fac_inv_list[(2*i)]) + " " + str(res - ((-1)**i *x**((2*i)) * fac_inv_list[(2*i)])) + " " + str(res))
    
    
print(str(res))