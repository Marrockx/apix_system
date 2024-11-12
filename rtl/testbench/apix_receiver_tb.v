`timescale 1ns/1ps

module apix_receiver_tb;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg apix_data;
    reg apix_clk;
    wire [23:0] pixel_data;
    wire error_flag;

        integer i; // Declare the loop variable

    // Clock generation parameters
    parameter CLK_PERIOD = 10; // 100MHz clock

    // Instantiate the DUT (Device Under Test)
    apix_receiver dut (
        .clk(clk),
        .rst_n(rst_n),
        .apix_data(apix_data),
        .apix_clk(apix_clk),
        .pixel_data(pixel_data),
        .error_flag(error_flag)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // APIX Clock generation
    initial begin
        apix_clk = 0;
        forever #(CLK_PERIOD) apix_clk = ~apix_clk;
    end

    // Test stimulus
    initial begin

        // Initialize signals
        rst_n = 0;
        apix_data = 0;

        // Initialize dump file
        $dumpfile("apix_receiver_tb.vcd");
        $dumpvars(0, apix_receiver_tb);

        // Reset sequence
        #(CLK_PERIOD*5);
        rst_n = 1;
        #(CLK_PERIOD*5);

        // Test Case 1: Sending pixel data (24'hFFAA55)
        for (i = 23; i >= 0; i = i - 1) begin
            apix_data = (24'hFFAA55 >> i) & 1'b1;
            #(CLK_PERIOD);
        end
        #(CLK_PERIOD*20);

        // Test Case 2: Sending pixel data with incorrect CRC (24'h123456, CRC 8'hFF)
        for (i = 23; i >= 0; i = i - 1) begin
            apix_data = (24'h123456 >> i) & 1'b1;
            #(CLK_PERIOD);
        end
        for (i = 7; i >= 0; i = i - 1) begin
            apix_data = (8'hFF >> i) & 1'b1;
            #(CLK_PERIOD);
        end
        #(CLK_PERIOD*20);

        // Test Case 3: Sending pixel data with correct CRC (24'h789ABC, correct CRC)
        for (i = 23; i >= 0; i = i - 1) begin
            apix_data = (24'h789ABC >> i) & 1'b1;
            #(CLK_PERIOD);
        end
        for (i = 7; i >= 0; i = i - 1) begin
            apix_data = (dut.crc_calc >> i) & 1'b1;
            #(CLK_PERIOD);
        end
        #(CLK_PERIOD*20);

        // End simulation
        $display("Simulation completed successfully");
        $finish;
    end

endmodule
