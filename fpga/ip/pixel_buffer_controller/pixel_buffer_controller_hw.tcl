# TCL File Generated by Component Editor 18.1
# Sun Dec 03 15:43:55 EST 2023
# DO NOT MODIFY


# 
# pixel_buffer_controller "Pixel Buffer DMA Avalon MM Master" v1.0
#  2023.12.03.15:43:55
# Joe Dai
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module pixel_buffer_controller
# 
set_module_property DESCRIPTION "Joe Dai"
set_module_property NAME pixel_buffer_controller
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME "Pixel Buffer DMA Avalon MM Master"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL pixel_buffer_controller
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE true
add_fileset_file pixel_buffer_controller.sv SYSTEM_VERILOG PATH pixel_buffer_controller.sv TOP_LEVEL_FILE


# 
# parameters
# 
add_parameter BASE_ADDR_OFFSET STD_LOGIC_VECTOR 0 ""
set_parameter_property BASE_ADDR_OFFSET DEFAULT_VALUE 0
set_parameter_property BASE_ADDR_OFFSET DISPLAY_NAME BASE_ADDR_OFFSET
set_parameter_property BASE_ADDR_OFFSET WIDTH 32
set_parameter_property BASE_ADDR_OFFSET TYPE STD_LOGIC_VECTOR
set_parameter_property BASE_ADDR_OFFSET UNITS None
set_parameter_property BASE_ADDR_OFFSET DESCRIPTION ""
set_parameter_property BASE_ADDR_OFFSET HDL_PARAMETER true
add_parameter ADDR_WIDTH INTEGER 4 ""
set_parameter_property ADDR_WIDTH DEFAULT_VALUE 4
set_parameter_property ADDR_WIDTH DISPLAY_NAME ADDR_WIDTH
set_parameter_property ADDR_WIDTH WIDTH ""
set_parameter_property ADDR_WIDTH TYPE INTEGER
set_parameter_property ADDR_WIDTH UNITS None
set_parameter_property ADDR_WIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property ADDR_WIDTH DESCRIPTION ""
set_parameter_property ADDR_WIDTH HDL_PARAMETER true


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
# connection point avm
# 
add_interface avm avalon start
set_interface_property avm addressUnits SYMBOLS
set_interface_property avm associatedClock clock
set_interface_property avm associatedReset reset
set_interface_property avm bitsPerSymbol 8
set_interface_property avm burstOnBurstBoundariesOnly false
set_interface_property avm burstcountUnits WORDS
set_interface_property avm doStreamReads false
set_interface_property avm doStreamWrites false
set_interface_property avm holdTime 0
set_interface_property avm linewrapBursts false
set_interface_property avm maximumPendingReadTransactions 0
set_interface_property avm maximumPendingWriteTransactions 0
set_interface_property avm readLatency 0
set_interface_property avm readWaitTime 0
set_interface_property avm setupTime 0
set_interface_property avm timingUnits Cycles
set_interface_property avm writeWaitTime 0
set_interface_property avm ENABLED true
set_interface_property avm EXPORT_OF ""
set_interface_property avm PORT_NAME_MAP ""
set_interface_property avm CMSIS_SVD_VARIABLES ""
set_interface_property avm SVD_ADDRESS_GROUP ""

add_interface_port avm avm_address address Output ADDR_WIDTH
add_interface_port avm avm_write write Output 1
add_interface_port avm avm_writedata writedata Output 32
add_interface_port avm avm_waitrequest waitrequest Input 1


# 
# connection point ext_interface
# 
add_interface ext_interface conduit end
set_interface_property ext_interface associatedClock clock
set_interface_property ext_interface associatedReset ""
set_interface_property ext_interface ENABLED true
set_interface_property ext_interface EXPORT_OF ""
set_interface_property ext_interface PORT_NAME_MAP ""
set_interface_property ext_interface CMSIS_SVD_VARIABLES ""
set_interface_property ext_interface SVD_ADDRESS_GROUP ""

add_interface_port ext_interface swap_buffer swap_buffer Input 1

