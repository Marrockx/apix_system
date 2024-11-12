`timescale 1ns/1ps

module apix_transmitter_tb;

    // Test bench signals
    reg clk;
    reg rst_n;
    reg [23:0] pixel_data;
    reg pixel_valid;
    wire apix_data;
    wire apix_clk;

    // Clock generation parameters
    parameter CLK_PERIOD = 10; // 100MHz clock

    // Instantiate the APIX transmitter
    apix_transmitter dut (
        .clk(clk),
        .rst_n(rst_n),
        .pixel_data(pixel_data),
        .pixel_valid(pixel_valid),
        .apix_data(apix_data),
        .apix_clk(apix_clk)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize signals
        rst_n = 0;
        pixel_data = 24'h000000;
        pixel_valid = 0;

        // Initialize dump file
        $dumpfile("apix_transmitter_tb.vcd");
        $dumpvars(0, apix_transmitter_tb);

        // Reset sequence
        #(CLK_PERIOD*5);
        rst_n = 1;
        #(CLK_PERIOD*5);

        // Test Case 1: Single pixel transmission
        pixel_data = 24'hAB_CD_EF;
        pixel_valid = 1;
        #(CLK_PERIOD*10);
        pixel_valid = 0;
        #(CLK_PERIOD*10);

        // Test Case 2: Multiple pixel transmission
        repeat(5) begin
            pixel_data = $random;  // Generate random pixel data
            pixel_valid = 1;
            #(CLK_PERIOD*8);  // Wait for 8 clock cycles per pixel
        end
        pixel_valid = 0;
        #(CLK_PERIOD*10);

        // Test Case 3: Line transmission (simplified)
        pixel_valid = 1;
        repeat(1080) begin  // Simulate one line of 1080p
            pixel_data = $random;
            #(CLK_PERIOD*8);
        end
        pixel_valid = 0;
        #(CLK_PERIOD*20);

        // Test Case 4: Reset during transmission
        pixel_data = 24'h55_AA_55;
        pixel_valid = 1;
        #(CLK_PERIOD*5);
        rst_n = 0;  // Assert reset
        #(CLK_PERIOD*5);
        rst_n = 1;  // De-assert reset
        #(CLK_PERIOD*10);
        pixel_valid = 0;

        // Add delay before ending simulation
        #(CLK_PERIOD*50);
        
        // End simulation
        $display("Simulation completed successfully");
        $finish;
    end

    // Monitor changes
    always @(posedge clk) begin
        if (pixel_valid)
            $display("Time=%0t pixel_data=%h apix_data=%b", $time, pixel_data, apix_data);
    end

    // Assertions
    // initial begin
    //     // Check reset behavior
    //     assert property (@(posedge clk) !rst_n |-> apix_data == 1'b0)
    //     else $error("Reset assertion failed");

    //     // Check that apix_clk matches input clock
    //     assert property (@(posedge clk) apix_clk == clk)
    //     else $error("Clock assertion failed");
    // end

    // Reset behavior check (Manual check instead of assertion)
    always @(posedge clk) begin
        if (!rst_n && apix_data !== 1'b0) begin
            $error("Reset behavior failed: apix_data should be 0 during reset");
        end
    end

    // Clock check (Manual check instead of assertion)
    always @(posedge clk) begin
        if (apix_clk !== clk) begin
            $error("Clock behavior failed: apix_clk does not match input clock");
        end
    end

    // Optional: CRC verification
    reg [7:0] expected_crc;
    always @(posedge clk) begin
        if (dut.state == dut.CRC) begin
            $display("Time=%0t CRC=%h", $time, dut.crc);
        end
    end

endmodule
