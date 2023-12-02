# FlightGPA
Implementing a flight simulator (term used loosely) game in FPGA on the DE1 SoC

### File organization

  * `fpga/`: Quartus project for running on FPGA
    * `fpga/ip`: Quartus IPs + rest of manually written Verilog: custom Platform Designer IPs
    * `fpga/src`: most of manually written Verilog
    * `fpga/test`: `coco_tb` test benches
    * `fpga/signaltaps`: SignalTap logic analyzer files
  * `hps/` C/C++ code for running on ARM core
