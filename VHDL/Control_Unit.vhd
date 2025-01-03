library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.helper_package.all;

-- This is the top-level control unit for the image processing system.
-- It instantiates three parallel processing channels (R, G, B), each reading from a ROM, 
-- processing the data, and writing the results to a RAM.
-- The end_pulse_p signal is asserted when all three channels complete processing.


entity control_unit is
	Port(
			clk				:	in		std_logic;
			rst				:	in 	std_logic;
			start_pulse_p	:	in		std_logic;
			end_pulse_p		:	out	std_logic
);
				attribute altera_chip_pin_lc: string;
				attribute altera_chip_pin_lc of clk  : signal is "Y2";
				attribute altera_chip_pin_lc of rst  : signal is "AB28";
				attribute altera_chip_pin_lc of start_pulse_p: signal is "AC28";
				attribute altera_chip_pin_lc of end_pulse_p : signal is "E21";
end control_unit;
architecture control_unit_ARCH of control_unit is
 
 
 component RAM
		generic(
		inst_name	:	string
		);
        port(
            aclr		: in	std_logic;
				address	: in  std_logic_vector(8 downto 0);
            clock  	: in  std_logic;
            data   	: in  std_logic_vector(1023 downto 0);
            wren   	: in  std_logic;
            q      	: out std_logic_vector(1023 downto 0)
        );
    end component;
	
 component ROM
	generic(
	mif_path	:	string
	);
	port(
		aclr		: in  std_logic;
		address		: in  std_logic_vector(8 DOWNTO 0);
		clock		: in  std_logic;
		q		: out  std_logic_vector(1023 DOWNTO 0)
	);
END component; 
 component processing_unit
	generic(
		test_mode	:	std_logic
	);
	Port(
			clk				:	in		std_logic;
			rst				:	in 	std_logic;
			start_pulse_p	:	in		std_logic;
			end_pulse_p		:	out	std_logic;
			
			data_in			:	in		int_array(127 downto 0);
			data_out			:	out	int_array(127 downto 0);
			
			write_start_p	:	out	std_logic;
			
			write_add		:	out	std_logic_vector(8 downto 0);
			read_add			:	out	std_logic_vector(8 downto 0)
);
	end component;
	
--signals

-- Signals for addresses, write enables, and data lines for R, G, and B channels.
-- read_addressX and write_addressX signals define which pixel line is being read or written.
-- wrenX signals are single-cycle pulses that trigger writes to the respective RAM.


    signal read_addressR, read_addressG, read_addressB,write_addressR,write_addressG,write_addressB : std_logic_vector(8 downto 0);
    signal wrenR, wrenG, wrenB          : std_logic;
    signal end_pulse_p_R, end_pulse_p_G, end_pulse_p_B : std_logic;
	 
	 signal data_from_ROM_R,data_from_ROM_G,data_from_ROM_B	:	std_logic_vector(1023 downto 0);
	 
	 signal data_from_ROM_R_int,data_from_ROM_G_int,data_from_ROM_B_int	:	int_array(127 downto 0);
	 
	 signal data_to_RAM_R_int,data_to_RAM_G_int,data_to_RAM_B_int	:	int_array(127 downto 0);
	 
	 signal data_to_RAM_R,data_to_RAM_G,data_to_RAM_B	:	std_logic_vector(1023 downto 0);
	 
begin
-- end_pulse_p is the logical AND of end_pulse_p_R, end_pulse_p_G, and end_pulse_p_B.
-- This ensures that the top-level signal only goes high when all three channels have finished.

	end_pulse_p<=((end_pulse_p_R and end_pulse_p_G) and end_pulse_p_B);
	
	data_from_ROM_R_int<=STDLVtointarr128(data_from_ROM_R);
	data_from_ROM_G_int<=STDLVtointarr128(data_from_ROM_G);
	data_from_ROM_B_int<=STDLVtointarr128(data_from_ROM_B);
	
	data_to_RAM_R<=intarr128toSTDLV(data_to_RAM_R_int);
	data_to_RAM_G<=intarr128toSTDLV(data_to_RAM_G_int);
	data_to_RAM_B<=intarr128toSTDLV(data_to_RAM_B_int);
	
	u_romR:	ROM
		generic map(
			mif_path=>"../ROM_init/lena_noise_r.mif"
		)
		port map(
			aclr		=>rst,
			address	=>read_addressR ,
			clock		=>clk,
			q		=>data_from_ROM_R
	);
	
	u_processing_unitR	:	processing_unit
		generic map(
			test_mode=>'0'
			)
		port map(
			clk=> clk,
			rst=>rst,
			start_pulse_p=>start_pulse_p,
			end_pulse_p=>end_pulse_p_R,
			
			data_in=>data_from_ROM_R_int,
			data_out=>data_to_RAM_R_int,
			
			write_start_p=>wrenR,
			
			write_add=>write_addressR,
			read_add=>read_addressR 
);

	u_ramR: RAM
		generic map(
		inst_name=>"RRAM"
		)
        port map(
            aclr		=>rst,
				address => write_addressR,      -- Connect top-level signals to RAM
            clock   => clk,
            data    => data_to_RAM_R,
            wren    => wrenR,
            q       => OPEN
        );

	u_romG:	ROM
	generic map(
			mif_path=>"../ROM_init/lena_noise_g.mif"
		)
	port map(
		aclr		=>rst,
		address	=>read_addressG ,
		clock		=>clk,
		q		=>data_from_ROM_G
	);
	
	u_processing_unitG	:	processing_unit
	generic map(
			test_mode=>'0'
			)
		port map(
			clk=> clk,
			rst=>rst,
			start_pulse_p=>start_pulse_p,
			end_pulse_p=>end_pulse_p_G,
			
			data_in=>data_from_ROM_G_int,
			data_out=>data_to_RAM_G_int,
			
			write_start_p=>wrenG,
		
			write_add=>write_addressG ,
			read_add=>read_addressG 
);

	u_ramG: RAM
	generic map(
		inst_name=>"GRAM"
		)
        port map(
            aclr		=>rst,
				address => write_addressG,      -- Connect top-level signals to RAM
            clock   => clk,
           data    => data_to_RAM_G,
            wren    => wrenG,
            q       => OPEN
        );

	u_romB:	ROM
	generic map(
			mif_path=>"../ROM_init/lena_noise_b.mif"
		)
	port map(
		aclr		=>rst,
		address	=>read_addressB ,
		clock		=>clk,
		q		=>data_from_ROM_B
	);		  
		  
	u_processing_unitB	:	processing_unit
	generic map(
			test_mode=>'0'
			)
		port map(
			clk=> clk,
			rst=>rst,
			start_pulse_p=>start_pulse_p,
			end_pulse_p=>end_pulse_p_B,
			
			data_in=>data_from_ROM_B_int,
			data_out=>data_to_RAM_B_int,
			
			write_start_p=>wrenB,
			
			write_add=>write_addressB,
			read_add=>read_addressB 
);

	u_ramB: RAM
	generic map(
		inst_name=>"BRAM"
		)
        port map(
            aclr		=>rst,
				address => write_addressB,      -- Connect top-level signals to RAM
            clock   => clk,
            data    => data_to_RAM_B,
            wren    => wrenB,
            q       => OPEN
        );
end architecture control_unit_ARCH;
