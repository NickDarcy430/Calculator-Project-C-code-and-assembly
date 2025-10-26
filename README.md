🧮 AVR Keypad Calculator

This project implements a 4-operation calculator using an ATmega microcontroller, 4x4 keypad, and LED display via PORTB. It supports multi-digit arithmetic, operator precedence, and real-time keypad scanning — with both Assembly and C versions for educational comparison.

⚙️ Features

✅ Reads user input from a 4x4 matrix keypad

➕ Supports addition, subtraction, multiplication, and division

🔢 Handles up to four multi-digit numbers

⚡ Real-time keypad scanning and debouncing

💡 Displays results on PORTB LEDs

🚨 Visual feedback for:

Negative results (LED blink pattern)

16-bit overflow results (two-stage LED display)

🔁 Reset functionality using the keypad (# key)

🧩 Hardware Setup
Component	Connection	Description
Keypad	PORTC (Rows: PC0–PC3, Cols: PC4–PC7)	4x4 matrix keypad input
LEDs	PORTB	Displays numerical result or error indication
Microcontroller	ATmega Series (e.g., ATmega328P)	8-bit MCU used for computation
Power	5V regulated	Standard logic level
🧠 Program Overview
Assembly Version (main.asm)

Implements keypad scanning at a low level using direct I/O port manipulation.

Stores and processes up to four numbers and three operators.

Includes lookup tables and routines for digit combination, operation ordering, and arithmetic execution.

Demonstrates modular assembly design via routines (ReadKey, StoreFirst, combineFirst, etc.).

C Version (main.c)

Recreates the same functionality in C for AVR-GCC.

Uses structured functions for:

readKP() → Scans the keypad

debounce() → Handles key bounce

calculation() → Collects up to 19 inputs

numSeparate() & combineDigits() → Organizes and combines inputs

finalCalculation() → Performs arithmetic following operator precedence

Adds reset handling, 16-bit output management, and visual LED feedback.

🧰 Dependencies

AVR-GCC Toolchain

AVRDUDE (for flashing)

Microchip Studio (optional IDE)

Standard AVR 4x4 Keypad and 8 LEDs or LED bar
