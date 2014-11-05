module memory(
        output reg [31:0] data_out,
        input [31:0] address,
        input [31:0] data_in, 
        input write,
        input clk,
		input [1:0] access_size
);
    reg [31:0] buffer;
	parameter size = 'h100000;
	parameter offset = 'h80020000;
	
	reg [7:0] memory [0:size];  //1048577 = 1MB
	
    // On every negative edge of the clock cycle we will write/read values into memory based the address that was set on the rising edge.
	always @(negedge clk) begin
		if (write) begin // write the value from data_in into memory
            if (access_size == 2'b10) begin //32 bit access
				memory[address-offset] = data_in[31:24];
				memory[(address-offset) + 1] = data_in[23:16];
				memory[(address-offset) + 2] = data_in[15:8];
				memory[(address-offset) + 3] = data_in[7:0];
            end
            
            if (access_size == 2'b01) begin //16 bit access 
                memory[(address-offset)] = data_in[15:8];
				memory[(address-offset) + 1] = data_in[7:0];
            end
            
            if (access_size == 2'b00) begin //8 bit access
                memory[(address-offset)] = data_in[7:0];
            end
        end
        else begin // Read the value into data_out
            if (access_size == 'b10) begin //32 bit access
                data_out[7:0] = memory[(address-offset) + 3];
                data_out[15:8] = memory[(address-offset) + 2];
                data_out[23:16] = memory[(address-offset) + 1];
                data_out[31:24] = memory[(address-offset)];
            end
            
            if (access_size == 'b01) begin //16 bit access
                data_out[7:0] = memory[(address-offset) + 1];
                data_out[15:8] = memory[(address-offset)];
            end
            
            if (access_size == 'b00) begin //8 bit access
                data_out[7:0] = memory[(address-offset)];
            end
        end
	end

endmodule