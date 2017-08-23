# baofeng-transmit-watchdog
Some hackily thrown together assembly code for a pic 16f688 to help control a baofeng uv-5r for packet radio purposes

There are no interrupts used, it's all just lopping madness.

The primary purpose of this is to invert the ptt signal from the computer's serial port going to an npn transistor to activate the ptt on the handset.  BUT... I also wanted to include some safety features to prevent endless transmission in case of a problem on the computer.

When it starts up, It waits for the pin to go high before allowing trasmit.  I might change this once I actually try it connected to the computer... essentially I'm trying to prevent any transmission until it's actually time to transmit.  Once the signal has gone high it is then allowed to transmit.  The incoming ptt signal goes low to transmit which causes the output to go high to activate the NPN.  After about 70 seconds, if the transmit signal is still low the output goes low as this is way too long for it to have transmited non-stop.  It then waits for the signal to go high again before allowing another transmit.  Woo!
