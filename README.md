# WhackAMole
Whack A Mole Project for Arm Assembly Cortex M3 Chip on the STM32F100RB board. Takes user input and generates a random number for a "mole"

Programmer: Avery Cameron
Date: December 5th, 2018

Project: Whack-a-mole
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Game Description:
Whack-a-mole is a arcade game where "moles" pop out of holes and are whacked with a mallet for points.
Interpretation: Using a STM32F100RB discovery board and a circuit board soldered with 4 buttons and LEDs,each LED
	will represent a "mole" and the buttons will be pressed to simulate a mallet and increment the score.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
How To Play:
The board starts waiting for a user turning on and off the LEDs, Once a button is pressed, play begins.
	A random LED will light up and the corresponding button will need to be pressed. There will be a 
	reaction timer the user has to hit the button within to get the point or they will lose.

The program is currently set up for 16 cycles, if the user correctly  "whacks" the mole, the user wins and 
	proficiency will be displayed. If a user fails to react in time, or the wrong button is pressed, the 
	user will fail and there final score will be displayed.
Steps:
User starts program with reset button
Program enters waiting for user, flashes LEDs on and Off until user clicks any button
User Clicks Button:
Game begins a random LED is turned On
	User presses correct button, program loops game 
	User presses wrong button or times out, program enters end condition
Win:
LEDs are turned on one by one cycling up and down twice
Proficiency is displayed based on time taken per button and is displayed for 1 minute
Loop to start of game, waiting for player
Lose:
Score is displayed to user 
Loop to start of game, waiting for player
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Information:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Noted Encounters:
There were a few areas where Branches were jumping too many lines and had to be restructured.
	This required code reduction which allowed unneccessary code to be found and cut. 	
The initial completion of the project used all 12 registers and in many cases wastefully, although
	this is not a code breaking problem, by rearranging and changing how registers were used I was able to 
	remove ~75 lines of code and 2 procedures that were no longer needed.
The use of the Real Time Clock (RTC) was considered, although after some checking the delayLoops were used 
	instead due to the ease of setup although the RTC would have added accuracy and precision to the delays.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
Implementations:
I implemented a profficiency check comparing total Delay Time versus the Delay Time remaining after all
	buttons were pressed added together, this was done in percentages and allowed a scale from 0-9 to be implemented
	This added another register and some comparisons and multiplication and division.
Reaction time reduction was done initially by subtracting a set constant multiplied by the score from the delay.
	This implementation lends itself to overflowing to 0xFFFFFFFF which would give the user a significantly longer 
	delay time to work with. By using a comparison between the number of cycles and the delay time, the amount 
	to reduce by each time can be calculated using DelayTime/ (2*numCycles). This ensures that the delay time will 
	never flow to 0xFFFFFFFF and will be half of the initial delay on the last Cycle. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Future Expansions:
The use of the RTC for random numbers and delays could be implemented for improved accuracy. After initialization
	the RTC would be potentially easier to manage and ensure consistent results. 	
Currently the score display is only effective upto 15 and potentially for displaying multiples. The score display
	could be updated to show score in Binary-Coded-Decimal BCD to allow for multiple digits up to 99 or higher.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
User Adjustments:
The user can adjust the game in a few ways by altering the Equates at the top of the file, around line 30
PRELIMDELAY is the delay at the beginning of a cycle before showing an led, the larger the value the longer
	the delay time, the shorter the time the harder the game should be
DELAYTIME is the time the user has to react to the LED the is on, to hit the "mole", the shorter the time the harder 
	the game will be, NOTE the delay will be halved by the end of the cycles which may make it significantly harder
CYCLES is the number of cycles, "moles" that have to be hit, before the win condition is reached. The current recommended 
	max is 16 cycles or 0xF. NOTE: A cycle count of 0 will cause the game to enter the win condition automatically.
WINDELAY is used to control the time the win display cycles through, this will change the rate at which the LEDs 
	turn on and off in the set pattern
PROFDELAY is the time used to display proficiency on win condition, currently around 1 minute, this could be altered to 
	any value, although the delay can be skipped through user input similar to waiting to user.
AConstant and CConstant are used for random number generation and would require potentially large changes to ensure 
	proper random generation with new values. 

	
