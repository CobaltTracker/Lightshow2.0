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
component led_pwm
Port (CLK : in STD_LOGIC;
      PW : in STD_LOGIC_VECTOR (7 downto 0);
      PWM_OUT : out STD_LOGIC
      );
end component;

--signals for pwm
signal pwm_out : std_logic;

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

--ACCEL_X_OUT <= ACCEL_X (11 downto 4);
--ACCEL_Y_OUT <= ACCEL_Y (11 downto 4);

--port map for pwm
pwm : led_pwm
port map
    (CLK => clk,
     PW => ACCEL_Y(10 downto 3),
     PWM_OUT => pwm_out
     );
--todo - set up logic for leds based on ACCEL_X_OUTPUT
LEDS: process (ACCEL_X)
begin
if ((ACCEL_X (10 downto 3) < x"F") AND (ACCEL_X(11) = '0')) then
    led <= "0000000010000000";
elsif ((ACCEL_X (10 downto 3) < x"FF") AND (ACCEL_X(11) = '0')) then
    led <= "0000000011000000";
elsif ((ACCEL_X (10 downto 3) < x"FFF") AND (ACCEL_X(11) = '0')) then
    led <= "0000000011100000";
elsif ((ACCEL_X (10 downto 3) < x"FFFF") AND (ACCEL_X(11) = '0')) then
    led <= "0000000011110000";
elsif ((ACCEL_X (10 downto 3) < x"FFFFF") AND (ACCEL_X(11) = '0')) then
    led <= "0000000011111000";
elsif ((ACCEL_X (10 downto 3) < x"FFFFFF") AND (ACCEL_X(11) = '0')) then
    led <= "0000000011111100";
elsif ((ACCEL_X (10 downto 3) < x"FFFFFFF") AND (ACCEL_X(11) = '0')) then
    led <= "0000000011111110";
elsif ((ACCEL_X (10 downto 3) < x"FFFFFFFF") AND (ACCEL_X(11) = '0')) then
    led <= "0000000011111111";
elsif ((ACCEL_X (10 downto 3) < x"F") AND (ACCEL_X(11) = '1')) then
    led <= "0000000100000000";
elsif ((ACCEL_X (10 downto 3) < x"FF") AND (ACCEL_X(11) = '1')) then
    led <= "0000001100000000";
elsif ((ACCEL_X (10 downto 3) < x"FFF") AND (ACCEL_X(11) = '1')) then
    led <= "0000011100000000";
elsif ((ACCEL_X (10 downto 3) < x"FFFF") AND (ACCEL_X(11) = '1')) then
    led <= "0000111100000000";
elsif ((ACCEL_X (10 downto 3) < x"FFFFF") AND (ACCEL_X(11) = '1')) then
    led <= "0001111100000000";
elsif ((ACCEL_X (10 downto 3) < x"FFFFFF") AND (ACCEL_X(11) = '1')) then
    led <= "0011111100000000";
elsif ((ACCEL_X (10 downto 3) < x"FFFFFFF") AND (ACCEL_X(11) = '1')) then
    led <= "0111111100000000";
elsif ((ACCEL_X (10 downto 3) < x"FFFFFFFF") AND (ACCEL_X(11) = '1')) then
    led <= "1111111100000000";
end if;
end process;



end Behavioral;
