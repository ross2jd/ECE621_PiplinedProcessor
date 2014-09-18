module memory(
        output reg [31:0] data_out,
        input [31:0] address,
        input [31:0] data_in, 
        input writing,
        input clk,
		input [1:0] access_size
);
	parameter size = 1048577;
	parameter offset = 2147614720 ;  // 0x80020000 in decimal
	
	reg [7:0] memory [0:size - 1];  //1048577 = 1MB
	
	initial begin
		// Instantiate the cells so that they are all empty
		for (i = 0; i < 1048577; i = i + 1) begin
			memory[i] = 0;
		end		
	end
	
	// writing
	always @(posedge clk) begin
		if (writing) begin    
			//Writing logic
		end
		
	end
	
	// reading
	always @(negedge clk) begin					//full word access
		//Reading logic
	end

endmodule