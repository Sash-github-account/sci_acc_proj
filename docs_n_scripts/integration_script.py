# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
top_flist = ["rom_wr_dma_ctrl.sv"]
#["rom_dma_ll_intf.sv", "rom_dma_ctrl.sv"]
# ["ll_op_decode_unit.sv", "ll_mngr.sv", "ll_rd_ctrl_v2.sv", "ll_wr_ctrl_v2.sv", "ll_nxt_avail_memptr_gen.sv", "ll_resp_gen_unit.sv"]

param_rtl_file =  "rom_model.sv" #"generic_fifo.sv" # "ll_mem_model.sv"

mem_inst_list = ["rom_model"]#["rom_data_fifo"]#["data_mem", "nxtptr_mem", "hdptr_mem", "node_cntr_mem"]

file_to_wr = "rom_wr_dma_top.sv"  #"system_wrap.sv" #"rom_dma_top.sv" #"ll_engine_top.sv"

param_file_present = True

gen_py = "\n//---------Gen by Python Script: integration_script.py ---------------//\n"


def ret_only_io_name(line):
    #------------- split and clean i/o string -------------#
    ret_line = line.split()
    ret_io = ret_line[len(ret_line)-1]
    return ret_io
    #--------------------------------------------#


def write_to_top_rtl_file(fileName, str_line):        
    #---------- open file to write -------------#
    wrFilePtr = open(fileName, "a")
    wrFilePtr.write(str_line)
    wrFilePtr.close()
    #-------------------------------------------#

def read_rtl_file_contents(filename):
    #------- open RTL file to create instance -------------#
    fileptr = open(filename,"r")
    content = fileptr.read();  
    fileptr.close()
    return content
    #------------------------------------------------------#
 

def parse_rtl_file(content):
    #------------ parse RTL file to get module name  and i/o list ---------#    
    lines = content.split(";")
    modlName_ioList = lines[0]
    cmnt_io_split = modlName_ioList.split("module")
    cmnt_fltrd = cmnt_io_split[1]
    modName_split = cmnt_fltrd.split("(")
    modName = modName_split[0]
    io_list_W_clsbracket = modName_split[1]
    ioList_noBrac = io_list_W_clsbracket.split(")")
    io_list = ioList_noBrac[0].split(",")
    returnd_io_names = []
    for io_name in io_list:
        returnd_io_names.append(ret_only_io_name(io_name))
    return modName, returnd_io_names
    #-----------------------------------------------------------------------#



def process_param_n_defaults(param_list):
    #------------------------ process parameters ---------------------------#    
    pure_param_list = []
    defaults_list = []
    for param in param_list:
        split_param = param.split("parameter")[1]
        param = split_param.split("=")[0]
        try:
            default = split_param.split("=")[1].replace(" ", "")
        except IndexError:
            default = None
        defaults_list.append(default)
        param.replace(" ", "")
        pure_param_list.append(param)
    print(pure_param_list)
    return pure_param_list, defaults_list
    #-----------------------------------------------------------------------#


    
def parse_param_rtl_file(content):
    #------------ parse RTL file to get module name  and i/o list ---------#    
    lines = content.split(";")
    modlName_ioList = lines[0]
    cmnt_io_split = modlName_ioList.split("module")
    cmnt_fltrd = cmnt_io_split[1]
    param_io_list = cmnt_fltrd.split("#")[1]
    modName_split = cmnt_fltrd.split("#")[0] 
    param_list_blk = param_io_list.split(")")[0]
    io_list_blk = param_io_list.split(")")[1]
    param_list_blk_nobrc = param_list_blk.split("(")[1]
    param_list = param_list_blk_nobrc.split(",")
    pure_param_list, defaults_list = process_param_n_defaults(param_list)
    ioList_noBrac = io_list_blk.split(")")[0]
    io_list = ioList_noBrac.split(",")
    returnd_io_names = []
    for io_name in io_list:
        returnd_io_names.append(ret_only_io_name(io_name))
    return modName_split, pure_param_list, defaults_list, returnd_io_names
    #-----------------------------------------------------------------------#
    
    
def create_instantiation_string(modName, returnd_io_names):
    #------------------ create instantiation string ------------------------#
    modName_noSpace = modName.split()[0]
    cret_inst = "\n" + modName + " " + "i_" + modName_noSpace + "(\n"
    connected_io_list = []
    for io_name in returnd_io_names:
        if (io_name != returnd_io_names[len(returnd_io_names)-1]):
            connected_io_list.append("\t\t\t\t\t\t\t\t." + io_name + " (" + io_name + "),\n")
        else:
            connected_io_list.append("\t\t\t\t\t\t\t\t." + io_name + " (" + io_name + ")\n")
            
    cntdList_string = " ".join(connected_io_list)
    instance_construct = cret_inst + cntdList_string + "\t\t\t\t\t\t\t\t);\n\n"
    return instance_construct
    #-----------------------------------------------------------------------#


def create_inst_param_str(pure_param_list, defaults_list):
    #------------------ create instantiation string ------------------------#
    combined_param_inst = []
    for i in range(len(defaults_list)):
        if(defaults_list[i] != None):
            if (pure_param_list[i] != pure_param_list[len(pure_param_list)-1]):
                combined_param_inst.append("\t\t\t\t\t\t\t\t." + pure_param_list[i] + " (" + defaults_list[i] + "),\n")
            else:
                combined_param_inst.append("\t\t\t\t\t\t\t\t." + pure_param_list[i] + " (" + defaults_list[i] + ")\n") 
        else:
            if (pure_param_list[i] != pure_param_list[len(pure_param_list)-1]):
                combined_param_inst.append("\t\t\t\t\t\t\t\t." + pure_param_list[i] + " (" + pure_param_list[i] + "),\n")
            else:
                combined_param_inst.append("\t\t\t\t\t\t\t\t." + pure_param_list[i] + " (" + pure_param_list[i] + ")\n")
    cmbnd_param_str = "".join(combined_param_inst)
    return cmbnd_param_str
    
    #-----------------------------------------------------------------------#


    
def create_param_instantiation_string(modName, inst_list, returnd_io_names, pure_param_list, defaults_list):
    #------------------ create instantiation string ------------------------#
    instance_construct = ""
    for inst in inst_list:
        param_string = "#(\n " + create_inst_param_str(pure_param_list, defaults_list) +") "
        cret_inst = "\n" + modName + " " + param_string + "i_" + inst  + "(\n"
        connected_io_list = []
        for io_name in returnd_io_names:
            if(io_name == "clk" or io_name == "reset_n"):
                if (io_name != returnd_io_names[len(returnd_io_names)-1]):
                    connected_io_list.append("\t\t\t\t\t\t\t\t." + io_name + " (" + io_name + "),\n")
                else:
                    connected_io_list.append("\t\t\t\t\t\t\t\t." + io_name + " (" + io_name + ")\n")
            else:
                if (io_name != returnd_io_names[len(returnd_io_names)-1]):
                    connected_io_list.append("\t\t\t\t\t\t\t\t." + io_name + " (" + inst + "_" + io_name + "),\n")
                else:
                    connected_io_list.append("\t\t\t\t\t\t\t\t." + io_name + " (" + inst + "_" + io_name + ")\n")
                    
        cntdList_string = " ".join(connected_io_list)
        instance_construct = instance_construct + cret_inst + cntdList_string + "\t\t\t\t\t\t\t\t);\n\n"
    return instance_construct
    #-----------------------------------------------------------------------#
    


#---------- Print start of script exec -------------#
write_to_top_rtl_file(file_to_wr, gen_py)
#-------------------------------------------#

for vfile in top_flist:
    #------- open RTL file to create instance -------------#
    content = read_rtl_file_contents(vfile)
    #------------------------------------------------------#
    
    
    #------------ parse RTL file to get module name  and i/o list ---------# 
    modName, returnd_io_names = parse_rtl_file(content)
    #-----------------------------------------------------------------------#
    

    #------------------ create instantiation string ------------------------#
    instance_construct = create_instantiation_string(modName, returnd_io_names)
    #-----------------------------------------------------------------------#
    
    
    #---------- write string to file -------------#
    write_to_top_rtl_file(file_to_wr, "\n" + instance_construct)
    #-------------------------------------------#

if(param_file_present==True):
    #--------------- Memory inst creation -----------------#
    content = read_rtl_file_contents(param_rtl_file)
    modName, pure_param_list, defaults_list, returnd_io_names = parse_param_rtl_file(content)
    instance_construct = create_param_instantiation_string(modName, mem_inst_list, returnd_io_names, pure_param_list, defaults_list)
    write_to_top_rtl_file(file_to_wr, "\n" + instance_construct)
    #------------------------------------------------------#

    
#---------- Append endmodule at EOF w/ filename as comment ---------------------------#
write_to_top_rtl_file(file_to_wr, "\nendmodule" + " //" + file_to_wr + "\n" + gen_py)
#-------------------------------------------------------------------------------------#