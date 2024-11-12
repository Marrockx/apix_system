module apix_receiver (
    input wire        clk,         // Clock signal
    input wire        rst_n,       // Active-low reset
    input wire        apix_data,   // Serialized data from Transmitter
    input wire        apix_clk,    // Clock input from Transmitter
    output reg [23:0] pixel_data,  // Reconstructed pixel data (RGB)
    output reg        error_flag   // Error flag if CRC doesn't match
);

    // Internal signals
    reg [7:0]  serdes_data;         // Data for deserialization
    reg [2:0]  serdes_counter;      // 3-bit counter for deserializing 24-bit pixel data
    reg [7:0]  crc_calc;            // Calculated CRC for error checking
    reg [7:0]  crc_received;        // CRC received from transmitter
    reg [23:0] pixel_buffer;        // Buffer to store reconstructed pixel data
    reg [1:0]  state, next_state;   // State machine for receiver

    // State machine parameters
    localparam IDLE = 2'b00, SYNC = 2'b01, DATA = 2'b10, CRC = 2'b11;

    // Main sequential process
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all signals
            state <= IDLE;
            serdes_counter <= 0;
            crc_calc <= 8'h00;
            error_flag <= 0;
        end else begin
            state <= next_state;

            // Deserialization logic
            if (state == DATA) begin
                pixel_buffer[serdes_counter*8 +: 8] <= apix_data; // Reconstruct pixel data from serialized bits
                crc_calc <= crc_calc ^ apix_data; // Update CRC calculation
                if (serdes_counter == 3'b111) begin
                    pixel_data <= pixel_buffer; // Output the 24-bit pixel data
                end
            end

            // CRC checking logic
            if (state == CRC) begin
                crc_received <= apix_data; // Receive CRC
                if (crc_received != crc_calc) begin
                    error_flag <= 1; // Set error flag if CRC doesn't match
                end else begin
                    error_flag <= 0; // No error
                end
            end
        end
    end

    // State machine logic
    always @(*) begin
        case (state)
            IDLE: next_state = (apix_data == 8'hFF) ? SYNC : IDLE; // Wait for sync pattern (0xFF)
            SYNC: next_state = DATA;
            DATA: next_state = (serdes_counter == 3'b111) ? CRC : DATA; // After receiving full pixel, check CRC
            CRC:  next_state = IDLE; // After CRC, go to IDLE
            default: next_state = IDLE;
        endcase
    end

    // Serialization Counter Update
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            serdes_counter <= 0;
        end else if (state == DATA) begin
            serdes_counter <= serdes_counter + 1;
        end else begin
            serdes_counter <= 0; // Reset counter after data received
        end
    end

endmodule
