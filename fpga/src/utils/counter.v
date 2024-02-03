module counter(clock, reset, enable, out);
	parameter WIDTH = 8;
	input clock, reset, enable;
	output reg [WIDTH-1:0] out;
	always @(posedge clock) begin
		if(reset) out <= 0;
		else if(enable) out <= out + 1;
	end
endmodule
