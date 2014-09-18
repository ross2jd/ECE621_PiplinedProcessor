module memory(
        output reg [31:0] data_out,
        input [31:0] address,
        input [31:0] data_in, 
        input write,
        input clk,
		input [1:0] access_size
);
    reg [31:0] buffer;
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
		if (write) begin    
            if (access_size == '10') begin //32 bit access
            	buffer = data_in;
				memory[address - offset] = buffer; //TODO: will this work, or do we need to clip the buffer to 8 bits before writing it to memory?
				buffer = buffer >> 8;
				memory[address - offset + 1] = buffer;
				buffer = buffer >> 8;
				memory[address - offset + 2] = buffer;
				buffer = buffer >> 8;
				memory[address - offset + 3] = buffer;
            end
            
            if (access_size == '01') begin //16 bit access 
                buffer = data_in;
                memory[address - offset] = buffer;
                buffer = buffer >> 8;
                memory[address - offser + 1] = buffer;
            end
            
            if (access_size == '00') begin //8 bit access
                buffer = data_in;
                memory[address - offset] = buffer;
            end
		end
		
	end
	
	// reading
	always @(negedge clk) begin
        if (!write) begin
            if (access_size == '10') begin //32 bit access
                buffer = memory[address + 3 - offset]; //TODO: Is this correct w.r.t. the endian-ness? We have to use big endian. Need to draw out the memory to make sense of this.
                buffer = buffer << 8;
                buffer = memory[address + 2 - offset];
                buffer = buffer << 8;
                buffer = memory[address + 1 - offset];
                buffer = buffer << 8;
                buffer = memory[address - offset];
                data_out = buffer;
            end
            
            if (access_size == '01') begin //16 bit access
                buffer = memory[address + 1 - offset];
                buffer = buffer << 8;
                buffer = memory[address - offset];
                data_out = buffer;
            end
            
            if (access_size == '00') begin //8 bit access
                buffer = memory[address - offset];
                data_out = buffer;
            end
        end
		
	end

endmodule