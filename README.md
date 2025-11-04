# J2716 SENT Transmitter (VHDL)

This repository contains a VHDL implementation of a **SAE J2716 SENT (Single Edge Nibble Transmission) transmitter**, together with:

* Synthesizable RTL blocks
* Unit-level and system-level testbenches
* ModelSim/Questa `.do` scripts for easy simulation
* Example waveforms captured from simulation

The goal of the project is to generate a valid **SENT data frame** with:

* SYNC pulse
* STATUS nibble (fixed to 0 in this design)
* Two data nibbles (`DATA0`, `DATA1`) → 1 payload byte
* A 4-bit CRC nibble (SAE J2716 CRC)
* Timing based on a **1 MHz clock** (1 µs tick resolution)

---

## 1. SENT / J2716 Protocol Overview

SENT (Single Edge Nibble Transmission) is a **unidirectional, time-encoded** protocol used mainly in automotive sensor interfaces. Information is transmitted on a single digital line (`SENT`) by encoding data in the **time between rising edges**.

### 1.1 Nibble Timing

Each 4-bit data nibble (`0` to `15`) is represented by a number of **ticks**:

> ticks = 12 + nibble

* Base offset: **12 ticks**
* Nibble range: 0…15 → time codes from **12 to 27 ticks**

A special **SYNC pulse** is transmitted before every frame using a **longer, fixed number of ticks** (e.g. 56 ticks), which allows the receiver to recover timing.

### 1.2 Frame Format

The design implements a standard SENT frame consisting of:

1. **SYNC**
2. **STATUS nibble** (fixed to 0 here)
3. **DATA0 nibble** (lower 4 bits of payload)
4. **DATA1 nibble** (upper 4 bits of payload)
5. **CRC nibble** (4-bit CRC over STATUS, DATA0, DATA1)

All timings are based on:

* `CLK = 1 MHz`
* `1 tick = 1 µs`

---

## 2. Repository Structure

A clean structure for this project:

```text
j2716-sent-transmitter/
├─ rtl/
│  ├─ CRC4_SENT.vhd           -- 4-bit CRC encoder
│  ├─ SAE_CRC_CALC_SENT.vhd   -- reference/alternative CRC calculator
│  ├─ PWM_SENT.vhd            -- tick-based pulse generator
│  ├─ FSM_SENT.vhd            -- frame state machine
│  ├─ MUX_SENT.vhd            -- selects tick count per nibble
│  └─ SENT_interface.vhd      -- top-level SENT transmitter
├─ sim/
│  ├─ CRC4_SENT_tb.vhd
│  ├─ SAE_CRC_CALC_SENT_tb.vhd
│  ├─ PWM_SENT_tb.vhd
│  ├─ FSM_SENT_tb.vhd
│  ├─ MUX_SENT_tb.vhd
│  └─ SENT_interface_tb.vhd   -- system-level testbench
├─ scripts/
│  ├─ setup.do                -- system-level sim for SENT_interface_tb
│  ├─ setup_crc.do            -- unit test for CRC blocks
│  ├─ setup_pwm.do            -- unit test for PWM_SENT
│  ├─ setup_fsm.do            -- unit test for FSM_SENT
│  └─ setup_mux.do            -- unit test for MUX_SENT
├─ images/                    -- simulation result waveforms (BMP/PNG)
│  ├─ CRC_waveform.bmp
│  ├─ PWM_waveform.bmp
│  ├─ FSM_waveform.bmp
│  ├─ MUX_Waveform.bmp
│  └─ SENT_top.bmp
└─ README.md
```

(If your filenames differ slightly, adjust the structure or the README accordingly.)

---

## 3. Top-Level Design: `SENT_interface`

### 3.1 Entity (conceptual)

```vhdl
entity SENT_interface is
  port (
    CLK        : in  STD_LOGIC;                     -- 1 MHz clock
    RESn       : in  STD_LOGIC;                     -- active-low async reset

    SENT       : out STD_LOGIC;                     -- SENT output line

    Threshold  : in  UNSIGNED(5 downto 0);          -- high-time threshold within a nibble
    DATA0      : in  STD_LOGIC_VECTOR(3 downto 0);  -- lower payload nibble
    DATA1      : in  STD_LOGIC_VECTOR(3 downto 0);  -- upper payload nibble

    sync       : in  STD_LOGIC_VECTOR(5 downto 0);  -- tick count for SYNC pulse
    status     : in  STD_LOGIC_VECTOR(5 downto 0);  -- tick count for STATUS nibble

    NEXT_Out   : out STD_LOGIC                      -- handshake to payload source
  );
end SENT_interface;
```

### 3.2 Functional Overview

The `SENT_interface` block:

1. **Accepts payload nibbles**
   `DATA0` and `DATA1` together form the 1-byte sensor value.

2. **Computes CRC**
   Uses the CRC blocks (`CRC4_SENT` / `SAE_CRC_CALC_SENT`) to compute a 4-bit CRC over:

   * STATUS nibble (0)
   * `DATA0` nibble
   * `DATA1` nibble

3. **Converts nibbles to tick values**

   * STATUS, DATA0, DATA1, CRC:
     `ticks = 12 + nibble`
   * SYNC:
     `ticks = sync` (fixed setting, e.g. 56)

4. **Controls timing with PWM**

   * Selected tick count is passed to `PWM_SENT` as `reload_value`.
   * `PWM_SENT` generates the SENT pulse inside each nibble interval and asserts `pwm_sent_out` when the nibble ends.

5. **Sequences frame fields**

   * `FSM_SENT` receives `pwm_sent_out` and steps through:

     * SYNC → STATUS → DATA0 → DATA1 → CRC → back to SYNC
   * Current FSM state is used as select input for `MUX_SENT`.

6. **Selects correct tick count**

   * `MUX_SENT` selects between SYNC/STATUS/DATA0/DATA1/CRC tick values based on the FSM state and feeds them to `PWM_SENT`.

7. **Handshake**

   * `NEXT_Out` indicates when the transmitter is ready for new payload nibbles from upstream logic.

8. **SENT line**

   * The final encoded SENT waveform is driven on the `SENT` output pin.

---

## 4. RTL Block Descriptions

### 4.1 `CRC4_SENT` and `SAE_CRC_CALC_SENT`

These blocks implement the SAE J2716 CRC.

**Typical CRC interface:**

```vhdl
entity CRC4_SENT is
  port (
    data       : in  STD_LOGIC_VECTOR(3 downto 0);  -- current nibble
    input_crc  : in  STD_LOGIC_VECTOR(3 downto 0);  -- previous CRC
    output_crc : out STD_LOGIC_VECTOR(3 downto 0)   -- updated CRC
  );
end CRC4_SENT;
```

* The CRC is updated nibble by nibble.
* STATUS, DATA0, DATA1 are processed sequentially.
* The resulting 4-bit CRC is sent as the final nibble in the SENT frame.

`SAE_CRC_CALC_SENT` is a reference/alternative CRC implementation used for comparison and verification.

---

### 4.2 `PWM_SENT`

**Purpose:** Generate the SENT pulse within each nibble’s time slot and indicate the end of the nibble.

**Conceptual interface:**

```vhdl
entity PWM_SENT is
  port (
    clk          : in  STD_LOGIC;
    rst          : in  STD_LOGIC;
    threshold    : in  UNSIGNED(5 downto 0);  -- SENT high duration (ticks)
    reload_value : in  UNSIGNED(5 downto 0);  -- total nibble duration (ticks)
    sent_signal  : out STD_LOGIC;             -- SENT line output
    pwm_sent_out : out STD_LOGIC              -- end-of-nibble pulse
  );
end PWM_SENT;
```

**Behavior:**

* Internal counter increments every clock cycle (1 MHz → 1 µs).
* While `counter < threshold`, `sent_signal = '1'`, otherwise `'0'`.
* When `counter = reload_value - 1`, `pwm_sent_out` is asserted for one clock and the counter wraps.

---

### 4.3 `FSM_SENT`

**Purpose:** Control the ordering of fields within a SENT frame.

**Conceptual interface:**

```vhdl
entity FSM_SENT is
  port (
    clk            : in  STD_LOGIC;
    rst            : in  STD_LOGIC;
    pwm_sent_out   : in  STD_LOGIC;                -- advance pulse from PWM
    fsm_out_signal : out STD_LOGIC_VECTOR(2 downto 0)
  );
end FSM_SENT;
```

Typical state encoding (example):

* `000` → SYNC
* `001` → STATUS
* `010` → DATA0
* `011` → DATA1
* `100` → CRC

The FSM advances one state on each `pwm_sent_out` pulse.

---

### 4.4 `MUX_SENT`

**Purpose:** Select the appropriate 6-bit tick value depending on the current FSM state.

**Conceptual interface:**

```vhdl
entity MUX_SENT is
  port (
    clk        : in  STD_LOGIC;
    sync       : in  STD_LOGIC_VECTOR(5 downto 0);
    stat       : in  STD_LOGIC_VECTOR(5 downto 0);
    d0         : in  STD_LOGIC_VECTOR(5 downto 0);
    d1         : in  STD_LOGIC_VECTOR(5 downto 0);
    crc4       : in  STD_LOGIC_VECTOR(5 downto 0);
    fsm_out    : in  STD_LOGIC_VECTOR(2 downto 0);
    output_mux : out STD_LOGIC_VECTOR(5 downto 0)
  );
end MUX_SENT;
```

* Decodes `fsm_out` and forwards one of the tick values (SYNC/STATUS/DATA0/DATA1/CRC).
* `output_mux` is connected to `PWM_SENT.reload_value`.

---

## 5. Testbenches

All testbenches are stored under `sim/`.

### 5.1 Unit-Level Testbenches

* **`CRC4_SENT_tb.vhd`**

  * Feeds known nibble sequences into `CRC4_SENT`.
  * Checks the resulting CRC against expected values or a reference.

* **`SAE_CRC_CALC_SENT_tb.vhd`**

  * Verifies the reference CRC implementation.
  * Useful to confirm compliance with SAE J2716 CRC rules.

* **`PWM_SENT_tb.vhd`**

  * Stimulates `PWM_SENT` with various `threshold` and `reload_value` values.
  * Checks high/low timing of `sent_signal` and correct timing of `pwm_sent_out`.

* **`FSM_SENT_tb.vhd`**

  * Drives artificial `pwm_sent_out` pulses.
  * Confirms correct state progression (SYNC → STATUS → DATA0 → DATA1 → CRC).

* **`MUX_SENT_tb.vhd`**

  * Applies different FSM state encodings and tick values.
  * Verifies that `output_mux` selects the appropriate input.

### 5.2 System-Level Testbench: `SENT_interface_tb.vhd`

* Instantiates the complete `SENT_interface` block.
* Generates:

  * 1 MHz clock
  * Active-low reset (`RESn`)
* Applies:

  * `DATA0`/`DATA1` patterns
  * `sync`, `status`, and `Threshold` settings
* Monitors:

  * `SENT` waveform
  * FSM state signals
  * CRC value
  * `NEXT_Out` handshake

This testbench is intended for **full-frame functional verification** and waveform inspection.

---

## 6. Simulation with ModelSim / Questa

The `scripts/` folder contains `.do` files to automatically compile and run simulations.

### 6.1 System-Level Simulation

From the repository root, in the ModelSim/Questa console:

```tcl
do scripts/setup.do
```

`setup.do` will:

1. Recreate the `work` library.
2. Compile all RTL files under `rtl/`.
3. Compile `sim/SENT_interface_tb.vhd`.
4. Start a simulation of `SENT_interface_tb` (architecture `tb`).
5. Add DUT signals to the waveform.
6. Run the simulation until completion (`run -all`).

### 6.2 Unit-Level Simulations

To run individual block testbenches:

```tcl
# CRC block tests
do scripts/setup_crc.do

# PWM block tests
do scripts/setup_pwm.do

# FSM block tests
do scripts/setup_fsm.do

# MUX block tests
do scripts/setup_mux.do
```

Each `.do` script:

* Creates a fresh `work` library
* Compiles the corresponding RTL + testbench
* Starts the simulation with all signals in the waveform window
* Executes `run -all`

---

## 7. Alternative Simulation with GHDL (Optional)

For users of an open-source simulator such as **GHDL**:

```bash
# From the repo root:

# Analyze RTL
ghdl -a rtl/CRC4_SENT.vhd rtl/SAE_CRC_CALC_SENT.vhd \
       rtl/PWM_SENT.vhd rtl/FSM_SENT.vhd rtl/MUX_SENT.vhd \
       rtl/SENT_interface.vhd

# Analyze system-level testbench
ghdl -a sim/SENT_interface_tb.vhd

# Elaborate
ghdl -e SENT_interface_tb

# Run and dump VCD
ghdl -r SENT_interface_tb --vcd=images/sent_waveform.vcd
```

The generated `sent_waveform.vcd` can be opened in **GTKWave** or any VCD viewer to inspect:

* `SENT` line
* FSM state
* Tick counters and thresholds
* CRC nibble
* `NEXT_Out` handshake

---

## 8. Results (Example Waveforms)

This section shows selected simulation results from ModelSim/Questa for each major block and for the top-level SENT transmitter.
Waveform screenshots are stored in the `images/` folder.

### 8.1 Top-Level SENT Frame

![Top-level SENT frame](images/SENT_top.bmp)

This waveform shows one complete SENT frame on the `SENT` line:

* Initial **SYNC pulse** with a longer tick period
* **STATUS nibble** (fixed to 0)
* **DATA0 nibble**
* **DATA1 nibble**
* **CRC nibble**

You can also see the timing alignment with the system clock and, if enabled in your testbench, internal control signals such as FSM state and end-of-nibble pulses.

---

### 8.2 CRC Block Waveform

![CRC block waveform](images/CRC_waveform.bmp)

This waveform captures the behavior of the CRC generator:

* Input nibbles (STATUS, DATA0, DATA1) are applied in sequence.
* The internal CRC value is updated nibble-by-nibble.
* The final **4-bit CRC nibble** matches the SAE J2716 CRC for the given payload.

This demonstrates that the CRC logic correctly implements the specified polynomial and update sequence.

---

### 8.3 PWM Block Waveform

![PWM waveform](images/PWM_waveform.bmp)

This waveform shows the `PWM_SENT` block:

* The **internal tick counter** increments at 1 MHz.
* The `sent_signal` output stays **high** for `threshold` ticks and then **low** until `reload_value` is reached.
* At the end of the nibble, `pwm_sent_out` asserts for **one clock cycle**, which is used by the FSM to advance to the next field.

This confirms that the pulse width and total nibble duration follow the expected SENT timing.

---

### 8.4 FSM Block Waveform

![FSM waveform](images/FSM_waveform.bmp)

This waveform illustrates the `FSM_SENT` behavior:

* The FSM starts in the **SYNC** state after reset.
* On each `pwm_sent_out` pulse from the PWM block, the state advances:

  * SYNC → STATUS → DATA0 → DATA1 → CRC → back to SYNC
* The encoded state output (`fsm_out_signal`) changes accordingly.

This verifies that the state machine correctly sequences all fields of a SENT frame.

---

### 8.5 MUX Block Waveform

![MUX waveform](images/MUX_Waveform.bmp)

This waveform shows the `MUX_SENT` operation:

* Different **tick values** (for SYNC, STATUS, DATA0, DATA1, CRC) are present on the MUX inputs.
* As `fsm_out` changes, `output_mux` switches to the corresponding input value.
* The selected `output_mux` value is fed into `PWM_SENT.reload_value`.

This confirms that the MUX correctly routes the right tick count for each SENT field based on the FSM state.

---

## 9. Author

**Author:** Amith Nanjesh

This design was developed as part of a digital design project focused on implementing and verifying a **SAE J2716 SENT transmitter** using VHDL and ModelSim/Questa simulations.
