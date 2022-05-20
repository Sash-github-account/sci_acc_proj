# -*- coding: utf-8 -*-
"""
Created on Tue Feb  1 16:14:59 2022

@author: nsash
"""


from datetime import datetime

import math

init_time = datetime.now()

x = 110

res = 512
y = 0

fact = 1

for i in range(res):
    if(i != 0):
        fact = fact * i
    #print(fact)
    #fact_inv = 1.0 / fact
    #print(fact_inv)
    y = y + (x**i/fact)
    
#y1 = math.exp(x)

#print(str(y))
#print(str(y1))

fin_time = datetime.now()
print("Execution time : ", (fin_time-init_time))