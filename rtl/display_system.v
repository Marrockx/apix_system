`timescale 1ns / 1ps

module display_system (
    input wire clk,             // Clock signal
    input wire reset,           // Reset signal
    input wire [23:0] pixel_data, // 24-bit pixel data (8 bits for R, G, B)
    output reg [7:0] r,         // Red component
    output reg [7:0] g,         // Green component
    output reg [7:0] b,         // Blue component
    output reg hsync,           // Horizontal sync
    output reg vsync            // Vertical sync
);

    // Horizontal and vertical counters
    reg [10:0] h_count;
    reg [9:0] v_count;

    // Parameters for display timing (for a 640x480 resolution as an example)
    localparam H_TOTAL = 800;
    localparam H_DISPLAY = 640;
    localparam H_FRONT_PORCH = 16;
    localparam H_SYNC_PULSE = 96;

    localparam V_TOTAL = 525;
    localparam V_DISPLAY = 480;
    localparam V_FRONT_PORCH = 10;
    localparam V_SYNC_PULSE = 2;

    // Horizontal and vertical sync signals
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
            hsync <= 1;
            vsync <= 1;
        end else begin
            // Horizontal counter
            if (h_count < H_TOTAL - 1) begin
                h_count <= h_count + 1;
            end else begin
                h_count <= 0;
                // Vertical counter
                if (v_count < V_TOTAL - 1) begin
                    v_count <= v_count + 1;
                end else begin
                    v_count <= 0;
                end
            end

            // Horizontal sync signal generation
            if (h_count < H_SYNC_PULSE) begin
                hsync <= 0;
            end else begin
                hsync <= 1;
            end

            // Vertical sync signal generation
            if (v_count < V_SYNC_PULSE) begin
                vsync <= 0;
            end else begin
                vsync <= 1;
            end

            // Display pixel data when within display area
            if (h_count < H_DISPLAY && v_count < V_DISPLAY) begin
                r <= pixel_data[23:16]; // Red component
                g <= pixel_data[15:8];  // Green component
                b <= pixel_data[7:0];   // Blue component
            end else begin
                r <= 0;
                g <= 0;
                b <= 0;
            end
        end
    end

endmodule

