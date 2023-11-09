`timescale 1 ps / 1 ps
module sdram_interface (
	output wire [31:0]  avm_m0_address,       // avm_m0.address
	output wire         avm_m0_read,          //       .read
	input  wire         avm_m0_waitrequest,   //       .waitrequest
	input  wire [31:0]  avm_m0_readdata,      //       .readdata
	input  wire         avm_m0_readdatavalid, //       .readdatavalid
	output wire         avm_m0_write,         //       .write
	output wire [31:0]  avm_m0_writedata,     //       .writedata
	output wire [3:0]   avm_m0_byteenable,	   //	      .byteenable
//	output wire         avm_m0_burstcount,	   //       .burstcount
	input  wire         clk,
	input  wire         reset,
	input       [31:0]  color
);

	parameter S_IDLE = 4'd0;
	parameter S_START = 4'd1;
	parameter S_PRETRANSFER = 4'd2;
	parameter S_WRITE = 4'd3;
	parameter S_POST_WRITE = 4'd4;
	parameter S_DONE = 4'd5;
	
	reg write_go;
	wire write_done;
	reg write_write;
	wire write_buffer_full;
	reg [3:0] write_current_state;
	reg [3:0] write_next_state;

	write_master #(
		.DATAWIDTH(32), 
		.BYTEENABLEWIDTH(4),
//		.MAXBURSTCOUNT(64),
//		.BURSTCOUNTWIDTH(7),
		.FIFODEPTH(128),
		.FIFODEPTH_LOG2(7)
	) writer (
		.clk(clk),
		.reset(reset),
		
		.control_fixed_location(1'b0),
		.control_write_base(32'h00000000),
		.control_write_length(32'd1228800),
		.control_go(write_go),
		.control_done(write_done),
		
//		.user_buffer_data(color),
		.user_buffer_data(32'hFFF1AB86),
		.user_write_buffer(write_write),
		.user_buffer_full(write_buffer_full),
		
		.master_address(avm_m0_address),
		.master_write(avm_m0_write),
		.master_byteenable(avm_m0_byteenable),
		.master_writedata(avm_m0_writedata),
//		.master_burstcount(avm_m0_burstcount),
		.master_waitrequest(avm_m0_waitrequest)
	);
	
//	burst_read_master #(
//		.DATAWIDTH(8), 
//		.BYTEENABLEWIDTH(1)
//	) reader (
//		// Connections
//		.clk(clk),
//		.reset(reset),
//		.master_address(avm_m0_address),
//		.master_read(avm_m0_read),
//		.master_byteenable(avm_m0_byteenable),
//		.master_readdata(avm_m0_readdata),
//		.master_readdatavalid(avm_m0_readdatavalid),
//		.master_burstcount(avm_m0_burstcount),
//		.master_waitrequest(avm_m0_waitrequest)
//	);
	
	always @ (*) begin
		case (write_current_state)
			S_IDLE: 			write_next_state = S_START;
			S_START: 		write_next_state = S_PRETRANSFER;
			S_PRETRANSFER: write_next_state = S_WRITE;
			S_WRITE: 		write_next_state = write_done ? S_DONE : S_POST_WRITE;
			S_POST_WRITE: 	write_next_state = write_buffer_full ? S_POST_WRITE : S_WRITE;	// also stuck here if FIFO full
			S_DONE:			write_next_state = S_DONE;
			default: 		write_next_state = S_IDLE;
		endcase
	end
	
	always @ (posedge clk) begin
		if (reset) write_current_state <= S_IDLE;
		else write_current_state <= write_next_state;
	end
	
	always @ (*) begin
		// reg write_go				assert
		// reg write_write			assert
		// reg write_buffer_full;	read
		write_go = write_current_state == S_START;
		write_write = write_current_state == S_WRITE;
	end
endmodule
