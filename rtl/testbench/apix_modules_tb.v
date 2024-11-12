module TestBench;

    // Signals for Transmitter and Receiver
    reg        clk;
    reg        rst_n;
    reg [23:0] pixel_data_in;
    reg        pixel_valid;

    wire       apix_data;
    wire       apix_clk;
    wire [23:0] pixel_data_out;
    wire       error_flag;

    // Instantiate the Transmitter
    apix_transmitter tx(
        .clk(clk),
        .rst_n(rst_n),
        .pixel_data(pixel_data_in),
        .pixel_valid(pixel_valid),
        .apix_data(apix_data),
        .apix_clk(apix_clk)
    );

    // Instantiate the Receiver
    apix_receiver rx(
        .clk(clk),
        .rst_n(rst_n),
        .apix_data(apix_data),
        .apix_clk(apix_clk),
        .pixel_data(pixel_data_out),
        .error_flag(error_flag)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock toggle every 5 time units
    end

    // Test case
    initial begin
        // Reset
        rst_n = 0;
        pixel_valid = 0;
        pixel_data_in = 24'h000000;
        #10;
        rst_n = 1;

        // Send valid pixel data
        pixel_data_in = 24'hFF00FF; // Example pixel (RGB)
        pixel_valid = 1;
        #10;
        pixel_valid = 0;

        // Send another pixel after a delay
        #20;
        pixel_data_in = 24'h00FF00; // Another pixel (RGB)
        pixel_valid = 1;
        #10;
        pixel_valid = 0;

        // Wait to observe the receiver's output
        #100;
        
        $stop; // End the simulation
    end

endmodule
