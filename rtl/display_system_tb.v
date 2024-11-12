`timescale 1ns / 1ps

module display_system_tb;

    // Testbench signals
    reg clk;
    reg reset;
    reg [23:0] pixel_data;
    wire [7:0] r;
    wire [7:0] g;
    wire [7:0] b;
    wire hsync;
    wire vsync;

    // Instantiate the display system module
    display_system uut (
        .clk(clk),
        .reset(reset),
        .pixel_data(pixel_data),
        .r(r),
        .g(g),
        .b(b),
        .hsync(hsync),
        .vsync(vsync)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock (10 ns period)
    end
    
    initial begin
        // Open VCD file for waveform dump
        $dumpfile("display_system_waveform.vcd");
        $dumpvars(0, display_system_tb);
    end

    // Test sequence
    initial begin
        // Initialize signals
        reset = 1;
        pixel_data = 24'h000000;
        #20;

        // Release reset
        reset = 0;
        #20;

        // Apply some pixel data
        pixel_data = 24'hFF0000; // Red pixel
        #100;
        pixel_data = 24'h00FF00; // Green pixel
        #100;
        pixel_data = 24'h0000FF; // Blue pixel
        #100;

        // Simulate reset condition
        reset = 1;
        #20;
        reset = 0;
        #100;

        // End simulation
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0d | R=%h, G=%h, B=%h, HSYNC=%b, VSYNC=%b", $time, r, g, b, hsync, vsync);
    end

endmodule

