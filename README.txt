CPSC 599.82 Term Project Test Programs
Erich Kirchner #30016988
Scot Rahal     #10130792

Test Program Details:

1. ek_test0.asm
Prints a 'B' character on the screen, in an infinite loop.

Testing:
-How to get the basic stub to load and execute the SYS instruction
-How to print a character in a loop

2. ek_test1.asm
Plays a low 'C' note through the sound output, in an infinite loop.

Testing:
-How to mimic BASIC "POKE" instructions in 6502 assembly, reading and writing values from accumulator
-How to create sounds on the VIC-20

3. ek_test2.asm
Starts a timer upon program execution. The timer runs for 1024 clock ticks (17.06 seconds at 60 ticks/second). When the timer is finished, prints "DONE" on the screen and waits for the user to press 'Q' key to quit.

Testing:
-How to read/store information from the system clock
-How to implement a very basic timer
-How to poll the user for keyboard input & exit the program

4. ek_test3.asm
Plays notes from the C major scale. User may change the music note being played by pressing the following keys: 'C','D','E','F','G','A','B'
Press 'Q' to exit the program.

Testing:
-How to play various musical notes based on keyboard input
-May be very useful for writing actual music and sound effects
-Capability to change sound/music based on branches during runtime
-How to gracefully start and stop music

5. ek_test4.asm
"Shakes" the screen visuals for a few seconds upon program execution

Testing:
-How to shift the on-screen visuals based on vertical/horizontal screen origin
-Experimenting with screen origin offsets to change visuals/add effects
-Implemented a looping system to "slow down" the visual effect, simply adding lines of computation between on-screen events (as an alternative to some form of timer) - may or may not be useful in the future

6. ek_test5.asm
A timer routine that prints "DONE" every n seconds, where n is a pre-defined constant. The constant n is a 3 byte number defined at the bottom of the source code, currently hard-coded to $000258 == 600 clock ticks == ~10 seconds.

Testing:
-How to start a timer at an arbitrary moment during execution
-How to read/store information from zero page
-How to perform subtraction over multi-byte numbers located in memory
-How to perform some event based on a timer loop - will likely be extremely useful (for music/sound effects, in-game enemy spawning, timing of "menu" screens, etc.)

7. sr_test0.asm
Changing the color of the background and playfield through user input 'A' cycles through the colors 'C' increments through the colors fast
'Q' quits the program.

Testing:
-How to change the color of the screen
-What happens if you update it really fast, could be used for effects.

8. sr_test1.asm
fills the screen with all of the characters that are available 
'Q' quits

Testing:
-How many characters are on the screen and understanding how to place them.
-understanding how many characters there are and what is available in the default characters

9. sr_test2.asm
changes the color of the fonts 'A' changes the primary color of the text 'Z' changes the auxiliary color in multicolor mode
'Q' quits

Testing:
-How the colors of the text look
-Multicolor mode
-Changing colors of certain characters on the screen

10. sr_test3.asm
changes where the characters are read from in memory and reads some custom characters
uses code from previous programs to demonstrate.
'Q' quits

Testing:
-How characters are stored
-How to use custom characters
