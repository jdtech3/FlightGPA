module counter(clock, resetn, enable, out);
	parameter WIDTH = 8;
	input clock, resetn, enable;
	output reg [WIDTH-1:0] out;
	always @(posedge clock) begin
		if(!resetn) out <= 0;
		else if(enable) out <= out + 1;
	end
endmodule
