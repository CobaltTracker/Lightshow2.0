library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity led_pwm is
    Port (CLK : in STD_LOGIC;
          PW : in STD_LOGIC_VECTOR (15 downto 0);
          PWM_OUT : out STD_LOGIC
          );
end led_pwm;

architecture Behavioral of led_pwm is

signal pulse : std_logic := '0';
signal register_counter : std_logic_vector (7 downto 0);

begin


pwm_cycle : process (pulse, CLK)
begin
    if rising_edge(CLK) then
        register_counter <= register_counter + '1';
        if register_counter < PW then
            pulse <= '1';
        else
            pulse <= '0';
        end if;
    end if;
end process pwm_cycle;


PWM_OUT <= pulse;

end Behavioral;
