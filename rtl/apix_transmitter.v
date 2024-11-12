module apix_transmitter (
    input wire        clk,         // Clock signal
    input wire        rst_n,       // Active-low reset
    input wire [23:0] pixel_data,  // 24-bit pixel data (RGB)
    input wire        pixel_valid, // Pixel data valid signal
    output reg        apix_data,   // Serialized data output
    output wire       apix_clk     // Transmit clock output
);

    // Internal signals
    reg [31:0] frame_counter;       // Frame counter for video frames
    reg [15:0] line_counter;        // Line counter for 1080 lines/frame
    reg [7:0]  crc;                 // CRC for error detection
    reg [23:0] pixel_buffer;        // Pixel data buffer
    reg [7:0]  serdes_data;         // Serialized 8-bit data
    reg [2:0]  serdes_counter;      // Counter for 8-bit SerDes cycles
    reg        data_ready;          // Data ready for transmission

    // State machine states
    localparam IDLE = 2'b00, SYNC = 2'b01, DATA = 2'b10, CRC = 2'b11;
    reg [1:0]  state, next_state;

    // Clock output assignment
    assign apix_clk = clk;

    // Main sequential process
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all signals
            state <= IDLE;
            frame_counter <= 0;
            line_counter <= 0;
            crc <= 8'h00;
            serdes_counter <= 0;
            data_ready <= 0;
        end else begin
            state <= next_state;
            
            // Frame and line counting logic
            if (state == SYNC) begin
                frame_counter <= frame_counter + 1;
                line_counter <= 0;
            end else if (state == DATA && pixel_valid) begin
                line_counter <= line_counter + 1;
            end

            // CRC calculation (XOR over pixel data)
            if (state == DATA && pixel_valid) begin
                crc <= crc ^ pixel_data[7:0] ^ pixel_data[15:8] ^ pixel_data[23:16];
                pixel_buffer <= pixel_data;
            end

            // SerDes serialization logic
            if (serdes_counter == 3'b111) begin
                serdes_counter <= 0;
                data_ready <= 1; // Data is ready to transmit
            end else begin
                serdes_counter <= serdes_counter + 1;
                data_ready <= 0;
            end
        end
    end

    // Next state logic (state machine)
    always @(*) begin
        case (state)
            IDLE: next_state = (pixel_valid) ? SYNC : IDLE;
            SYNC: next_state = DATA;
            DATA: next_state = (line_counter == 1079) ? CRC : DATA; // After 1080 lines, move to CRC
            CRC:  next_state = IDLE; // After CRC, return to IDLE
            default: next_state = IDLE;
        endcase
    end

    // Serialization of pixel data and CRC
    always @(*) begin
        case (state)
            SYNC: serdes_data = 8'hFF; // Sync pattern
            DATA: begin
                case (serdes_counter)
                    3'b000: serdes_data = pixel_buffer[23:16]; // Red
                    3'b001: serdes_data = pixel_buffer[15:8];  // Green
                    3'b010: serdes_data = pixel_buffer[7:0];   // Blue
                    default: serdes_data = 8'h00; // Default when no data
                endcase
            end
            CRC:  serdes_data = crc; // CRC transmission
            default: serdes_data = 8'h00;
        endcase
    end

    // Output serialized data
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            apix_data <= 0;
        end else if (data_ready) begin
            apix_data <= serdes_data[serdes_counter]; // Transmit serial data bit by bit
        end
    end

endmodule
