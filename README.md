# FPGAFishFeeder
Final Project for ECE three-fishy-one.

This project is an FPGA-controlled fish feeder. The current time is displayed on the seven segment display, and a stepper motor is activated to rotate a container of food when programmed feeding times are met.

This project is constructed using a Basys 3 FPGA, a Pmod STEP, and a 12V stepper motor. The current time as well as three feeding times per day can be programmed. Each feeding time can be enabled or disabled as desired. Additionally, there is a manual feeding option, and a reset operation to quickly set the system time and the feeding set times back to default.

## Components

The following components are necessary for this project:

1. Basys 3 FPGA
2. Pmod STEP
3. 12V Stepper motor
4. Container for food with slots to allow a small amount of food to drop when rotated
5. Attachment to secure the FPGA to the side of the fish tank, and to hold the container over the opening of the fish tank

## How to Use

The general operation of the fish feeder is as follows:

1. Set up the system on the fish tank
2. Set the system time
3. Set the time for and enable desired feeding times
4. Let run
5. If needed, clear all times using the reset operation
6. If needed, activate the manual override

### Opcodes

The opcode is entered on switches 11 through 15, where switch 15 is the most significant bit of the opcode. Switching between op codes is done by pressing the center button (btnc). The op codes are configured in a one-hot encoding scheme.

* `00000` : Normal operation, where clock counts up as normal, and 
* `00001` : Set system time
* `00010` : Set feeding time 1
* `00100` : Set feeding time 2
* `01000` : Set feeding time 3
* `10000` : Reset

#### Normal mode

The FPGA will start in normal mode. Setting the op code on the switches, then pressing the center button, will switch to the new op code. Once on any other state, the only valid state transition is back to normal operation.

In this state, the current set time is displayed on the seven-segment display.

#### Setting times (system time and feeding time 1 - 3)

When in a time setting state, the time can be altered as follows
* Switch 0, when active, sets the time to PM. When off, it sets the time to AM.
* The up button (btnU) increments the hour
* The down button (btnD) decrements the hour
* The right button (btnR) increments the minute
* The left button (btnL) decrements the minute
* The center button does nothing while the op code is the same. If the op code is set to 00000, the device will transition back to the normal state.

When in a setting mode, the time displayed on the seven-segment display will be the time of the desired mode to be set. Additionally, the display will flash the time to differentiate the time being set to the current time.

#### Reset

After transitioning to the reset state, to reset the system time and feeding times, press the center button without changing the op code. Simply transitioning to the state does not reset the times. Then, set the op code to 00000 and press the center button to return back to the normal state.
