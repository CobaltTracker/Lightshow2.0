--Timothy Bernier and Jean Marrero
--CEC330L Final Project (Lightshow 2.0)
--This program will create a shifting LED array based on the Y rotation of the board

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity top_module is
generic (
    SYSCLK_FREQUENCY_HZ : integer := 100000000;
    SCLK_FREQUENCY_HZ   : integer := 1000000;
    NUM_READS_AVG       : integer := 16;
    UPDATE_FREQUENCY_HZ : integer := 100
    );
    Port (led : out STD_LOGIC_VECTOR (15 downto 0);
          clk : in STD_LOGIC;
          aclMISO : in STD_LOGIC;
          aclMOSI : out STD_LOGIC;
          aclSCK : out STD_LOGIC;
          aclSS : out STD_LOGIC;
          aclInt1 : out STD_LOGIC;
          aclInt2 : out STD_LOGIC
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

-- Self-blocking reset counter constants
constant ACC_RESET_PERIOD_US : integer := 10;
constant ACC_RESET_IDLE_CLOCKS   : integer := ((ACC_RESET_PERIOD_US*1000)/(1000000000/SYSCLK_FREQUENCY_HZ));

signal  ACCEL_X    : STD_LOGIC_VECTOR (11 downto 0);
signal  ACCEL_Y    : STD_LOGIC_VECTOR (11 downto 0);
signal  ACCEL_Z    : STD_LOGIC_VECTOR (11 downto 0);
signal  ACCEL_TMP_OUT    : STD_LOGIC_VECTOR (11 downto 0);

signal Data_Ready : STD_LOGIC;

-- Self-blocking reset counter
signal cnt_acc_reset : integer range 0 to (ACC_RESET_IDLE_CLOCKS - 1):= 0;
signal RESET_INT: std_logic;
signal RESET : std_logic := '0';
signal clk_slow : std_logic;
signal register_counter : std_logic_vector (26 downto 0);
signal led_array : std_logic_vector (15 downto 0);

begin

-- Create the self-blocking reset counter
COUNT_RESET: process(clk, cnt_acc_reset, RESET)
begin
   if clk'EVENT and clk = '1' then
      if (RESET = '1') then
         cnt_acc_reset <= 0;
         RESET_INT <= '1';
      elsif cnt_acc_reset = (ACC_RESET_IDLE_CLOCKS - 1) then
         cnt_acc_reset <= (ACC_RESET_IDLE_CLOCKS - 1);
         RESET_INT <= '0';
      else
         cnt_acc_reset <= cnt_acc_reset + 1;
         RESET_INT <= '1';
      end if;
   end if;
end process COUNT_RESET;

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
 SYSCLK     => clk, 
 RESET      => RESET_INT, 
 
 -- Accelerometer data signals
 ACCEL_X    => ACCEL_X,
 ACCEL_Y    => ACCEL_Y, 
 ACCEL_Z    => ACCEL_Z,
 ACCEL_TMP  => ACCEL_TMP_OUT, 
 Data_Ready => Data_Ready, 
 
 --SPI Interface Signals
 SCLK       => aclSCK, 
 MOSI       => aclMOSI,
 MISO       => aclMISO, 
 SS         => aclSS
);

--Create logic based on Y-axis
LEDS: process (ACCEL_Y)
begin
if (ACCEL_Y(11) = '0') then    
    if (ACCEL_Y (10 downto 3) < 16) then
        led_array <= "0000000100000000";
    elsif (ACCEL_Y (10 downto 3) < 32) then
        led_array <= "0000001100000000";
    elsif (ACCEL_Y(10 downto 3) < 48) then
        led_array <= "0000011100000000";
    elsif (ACCEL_Y(10 downto 3) < 64) then
        led_array <= "0000111100000000";
    elsif (ACCEL_Y(10 downto 3) < 80) then
        led_array <= "0001111100000000";
    elsif (ACCEL_Y(10 downto 3) < 96) then
        led_array <= "0011111100000000";
    elsif (ACCEL_Y(10 downto 3) < 112) then
        led_array <= "0111111100000000";
    elsif (ACCEL_Y(10 downto 3) < 128) then
        led_array <= "1111111100000000";
    else
        null;
    end if;  -- end ACCEL_Y
--w/ ACCEL_Y(11) active high the signal starts full '1'    
elsif (ACCEL_Y(11) = '1') then
    if ((ACCEL_Y (10 downto 3) < 240) AND (ACCEL_Y(10 downto 3) > 224)) then
        led_array <= "0000000010000000";
    elsif ((ACCEL_Y (10 downto 3) < 224) AND (ACCEL_Y(10 downto 3) > 208)) then
        led_array <= "0000000011000000";
    elsif ((ACCEL_Y (10 downto 3) < 208) AND (ACCEL_Y(10 downto 3) > 192)) then
        led_array <= "0000000011100000";
    elsif ((ACCEL_Y (10 downto 3) < 192) AND (ACCEL_Y(10 downto 3) > 176)) then
        led_array <= "0000000011110000";
    elsif ((ACCEL_Y (10 downto 3) < 176) AND (ACCEL_Y(10 downto 3) > 160)) then
        led_array <= "0000000011111000";
    elsif ((ACCEL_Y (10 downto 3) < 160) AND (ACCEL_Y(10 downto 3) > 144)) then
        led_array <= "0000000011111100";
    elsif ((ACCEL_Y (10 downto 3) < 144) AND (ACCEL_Y(10 downto 3) > 128)) then
        led_array <= "0000000011111110";
    elsif (ACCEL_Y (10 downto 3) < 128) then
        led_array <= "0000000011111111";
    else 
        null;
    end if; -- end ACCEL_Y
end if;-- end 11 bit
led <= led_array;
end process;

end Behavioral;
