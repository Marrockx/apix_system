# APIX Transmitter-Receiver Simulation

This repository contains the Verilog implementation of an **APIX Transmitter-Receiver System**, along with testbenches and waveform analysis using GTKWave. The project simulates high-speed communication between a transmitter and receiver, focusing on pixel data transmission and integrity checks.

## 📋 Project Overview
APIX (Automotive Pixel Link) is a high-speed digital communication interface used in automotive applications for transmitting video and control signals. This project demonstrates a simple simulation of the APIX protocol, focusing on:
- Data transmission from the transmitter (APIX_TX).
- Data reception and decoding at the receiver (APIX_RX).
- Pixel data handling for display systems.

## 🔍 Key Features
- **Clock Synchronization**: Synchronizes transmitter and receiver using a generated clock signal.
- **Data Transmission**: Sends 24-bit pixel data (`pixel_data[23:0]`) from the transmitter to the receiver.
- **Error Detection**: Includes an error flag (`error_flag`) for data integrity checks.
- **Waveform Analysis**: Uses GTKWave to verify signal timing, clock synchronization, and data accuracy.
- **Display System Integration**: Simulates a basic display system with horizontal sync (`hsync`) and vertical sync (`vsync`) signals.

## 🛠️ Simulation Tools
- **Verilog**: HDL for designing the transmitter and receiver modules.
- **GTKWave**: Waveform viewer for analyzing signal timing and data flow.
- **Vivado/ModelSim**: (Optional) for synthesis and additional simulation.

## 📂 Project Structure
apix_system/ ├── rtl/ │ ├── apix_transmitter.v │ ├── apix_receiver.v │ ├── display_system.v ├── testbench/ │ ├── apix_transmitter_tb.v │ ├── apix_receiver_tb.v │ └── display_system_tb.v ├── sim_files/ │ ├── transmitter_waveform.vcd │ └── receiver_waveform.vcd ├── README.md 

## 📈 Waveform Analysis
The simulation results are visualized using GTKWave. Below are some key observations from the waveforms:

1. **Transmitter-Receiver Sync**:
   - The transmitter (`apix_clk`) and receiver (`clk`) are synchronized, ensuring accurate data transmission.
   - Pixel data (`pixel_data[23:0]`) is correctly captured by the receiver, as shown in the waveform.

2. **Error Flag**:
   - The `error_flag` signal indicates potential data mismatches or transmission errors.
   - No errors were detected in this simulation, as the flag remains low.

3. **Display System Output**:
   - The decoded pixel data is processed by the display system module, generating RGB values (`r[7:0]`, `g[7:0]`, `b[7:0]`).
   - The sync signals (`hsync`, `vsync`) are correctly toggled, indicating proper frame synchronization.

## 🚀 Getting Started
### Prerequisites
- Verilog simulator (e.g., ModelSim, Vivado)
- GTKWave for waveform viewing

### Running the Simulation
1. Clone the repository:
   ```bash
   git clone https://github.com/Marrockx/apix_system.git
   cd apix_systen
2. Compile the Verilog files:
   ```bash
   iverilog -o apix_system rtl/apix_transmitter.v rtl/apix_receiver.v rtl/testbench/apix_receiver_tb.v

3. Run the simulation:
   ```bash
   vvp apix_sim
4. View the waveform using GTKWave:
   ```bash
   gtkwave waveforms/receiver_waveform.vcd

<hr>

### 📊 Example Waveform

The waveform shows:

- apix_clk: The clock signal for the transmitter.
- pixel_data: The 24-bit pixel data transmitted.
- error_flag: Indicates error status (low means no errors).
- r, g, b: Decoded RGB pixel values for the display system.

### 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.
🤝 Contributing

Feel free to open issues or submit pull requests for improvements or bug fixes. Your contributions are welcome!
### 🛠️ Future Work

- Implement support for higher resolution data transmission.
- Integrate with a physical display interface for hardware testing.
- Extend error-checking mechanisms for enhanced reliability.

### 📫 Contact

For any questions or support, please contact Mariam and Daniel.