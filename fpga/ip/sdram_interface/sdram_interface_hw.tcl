# TCL File Generated by Component Editor 18.1
# Sun Nov 26 18:36:09 EST 2023
# DO NOT MODIFY


# 
# sdram_interface "SDRAM Avalon MM Master" v1.1
# Joe Dai 2023.11.26.18:36:09
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module sdram_interface
# 
set_module_property DESCRIPTION ""
set_module_property NAME sdram_interface
set_module_property VERSION 1.1
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR "Joe Dai"
set_module_property DISPLAY_NAME "SDRAM Avalon MM Master"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL sdram_interface
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file sdram_interface.sv SYSTEM_VERILOG PATH sdram_interface.sv TOP_LEVEL_FILE
add_fileset_file write_master.v VERILOG PATH write_master.v


# 
# parameters
# 
add_parameter DATA_WIDTH STRING 32 ""
set_parameter_property DATA_WIDTH DEFAULT_VALUE 32
set_parameter_property DATA_WIDTH DISPLAY_NAME DATA_WIDTH
set_parameter_property DATA_WIDTH TYPE STRING
set_parameter_property DATA_WIDTH UNITS None
set_parameter_property DATA_WIDTH DESCRIPTION ""
set_parameter_property DATA_WIDTH HDL_PARAMETER true


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1


# 
# connection point rm
# 
add_interface rm avalon start
set_interface_property rm addressUnits SYMBOLS
set_interface_property rm associatedClock clock
set_interface_property rm associatedReset reset
set_interface_property rm bitsPerSymbol 8
set_interface_property rm burstOnBurstBoundariesOnly false
set_interface_property rm burstcountUnits WORDS
set_interface_property rm doStreamReads false
set_interface_property rm doStreamWrites false
set_interface_property rm holdTime 0
set_interface_property rm linewrapBursts false
set_interface_property rm maximumPendingReadTransactions 0
set_interface_property rm maximumPendingWriteTransactions 0
set_interface_property rm readLatency 0
set_interface_property rm readWaitTime 1
set_interface_property rm setupTime 0
set_interface_property rm timingUnits Cycles
set_interface_property rm writeWaitTime 0
set_interface_property rm ENABLED true
set_interface_property rm EXPORT_OF ""
set_interface_property rm PORT_NAME_MAP ""
set_interface_property rm CMSIS_SVD_VARIABLES ""
set_interface_property rm SVD_ADDRESS_GROUP ""

add_interface_port rm rm_address address Output 32
add_interface_port rm rm_readdata readdata Input DATA_WIDTH
add_interface_port rm rm_read read Output 1
add_interface_port rm rm_readdatavalid readdatavalid Input 1
add_interface_port rm rm_waitrequest waitrequest Input 1


# 
# connection point wm
# 
add_interface wm avalon start
set_interface_property wm addressUnits SYMBOLS
set_interface_property wm associatedClock clock
set_interface_property wm associatedReset reset
set_interface_property wm bitsPerSymbol 8
set_interface_property wm burstOnBurstBoundariesOnly false
set_interface_property wm burstcountUnits WORDS
set_interface_property wm doStreamReads false
set_interface_property wm doStreamWrites false
set_interface_property wm holdTime 0
set_interface_property wm linewrapBursts false
set_interface_property wm maximumPendingReadTransactions 0
set_interface_property wm maximumPendingWriteTransactions 0
set_interface_property wm readLatency 0
set_interface_property wm readWaitTime 1
set_interface_property wm setupTime 0
set_interface_property wm timingUnits Cycles
set_interface_property wm writeWaitTime 0
set_interface_property wm ENABLED true
set_interface_property wm EXPORT_OF ""
set_interface_property wm PORT_NAME_MAP ""
set_interface_property wm CMSIS_SVD_VARIABLES ""
set_interface_property wm SVD_ADDRESS_GROUP ""

add_interface_port wm wm_address address Output 32
add_interface_port wm wm_writedata writedata Output DATA_WIDTH
add_interface_port wm wm_write write Output 1
add_interface_port wm wm_waitrequest waitrequest Input 1

