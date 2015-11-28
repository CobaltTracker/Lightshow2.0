----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2015 02:12:21 PM
-- Design Name: 
-- Module Name: top_module - Behavioral
-- Project Name: Final Project
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_module is
    Port (led : out STD_LOGIC_VECTOR (15 downto 0);
          clk : in STD_LOGIC;
          ACCEL_X_OUT    : out STD_LOGIC_VECTOR (7 downto 0);
          ACCEL_Y_OUT    : out STD_LOGIC_VECTOR (7 downto 0)
          );
end top_module;

architecture Behavioral of top_module is
--Component for accelerometer
component ADXL362Ctrl
generic 
(
   SYSCLK_FREQUENCY_HZ : integer := 100000000;
   SCLK_FREQUENCY_HZ   : integer := 1000000;
   NUM_READS_AVG       : integer := 16;
   UPDATE_FREQUENCY_HZ : integer := 1000
);
port
(
 SYSCLK     : in STD_LOGIC; -- System Clock
 RESET      : in STD_LOGIC;
 
 -- Accelerometer data signals
 ACCEL_X    : out STD_LOGIC_VECTOR (11 downto 0);
 ACCEL_Y    : out STD_LOGIC_VECTOR (11 downto 0);
 ACCEL_Z    : out STD_LOGIC_VECTOR (11 downto 0);
 ACCEL_TMP  : out STD_LOGIC_VECTOR (11 downto 0);
 Data_Ready : out STD_LOGIC;
 
 --SPI Interface Signals
 SCLK       : out STD_LOGIC;
 MOSI       : out STD_LOGIC;
 MISO       : in STD_LOGIC;
 SS         : out STD_LOGIC

);
end component;

begin


--port map for accelerometer
ADXL_Control: ADXL362Ctrl
generic map
(
   SYSCLK_FREQUENCY_HZ  => SYSCLK_FREQUENCY_HZ,
   SCLK_FREQUENCY_HZ    => SCLK_FREQUENCY_HZ,
   NUM_READS_AVG        => NUM_READS_AVG,   
   UPDATE_FREQUENCY_HZ  => UPDATE_FREQUENCY_HZ
)
port map
(
 SYSCLK     => mclk, 
 RESET      => RESET_INT, 
 
 -- Accelerometer data signals
 ACCEL_X    => ACCEL_X,
 ACCEL_Y    => ACCEL_Y, 
 ACCEL_Z    => ACCEL_Z,
 ACCEL_TMP  => ACCEL_TMP_OUT, 
 Data_Ready => Data_Ready, 
 
 --SPI Interface Signals
 SCLK       => SCLK, 
 MOSI       => MOSI,
 MISO       => MISO, 
 SS         => SS
);

ACCEL_X_OUT <= ACCEL_X (11 downto 4);
ACCEL_Y_OUT <= ACCEL_Y (11 downto 4);


end Behavioral;
