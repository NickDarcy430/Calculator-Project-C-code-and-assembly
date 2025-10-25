#include <avr/io.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>


int calculationArray[19];

int digits[4] = {0, 0, 0, 0};
int operations[3] = {0, 0, 0};
int arrayPosition = 0;

int firstArray[4] = {0,0,0,0};
int secondArray[4] = {0,0,0,0};
int thirdArray[4] = {0,0,0,0};
int fourthArray[4] = {0,0,0,0};

void reset_global_variables()
{
	int i;
	for (i = 0; i < 19; i++) 
	{
		calculationArray[i] = 0;
	}
	digits[0] = 0;
	digits[1] = 0;
	digits[2] = 0;
	digits[3] = 0;
	operations[0] = 0;
	operations[1] = 0;
	operations[2] = 0;
	arrayPosition = 0;

	firstArray[0] = 0;
	firstArray[1] = 0;
	firstArray[2] = 0;
	firstArray[3] = 0;

	secondArray[0] = 0;
	secondArray[1] = 0;
	secondArray[2] = 0;
	secondArray[3] = 0;

	thirdArray[0] = 0;
	thirdArray[1] = 0;
	thirdArray[2] = 0;
	thirdArray[3] = 0;

	fourthArray[0] = 0;
	fourthArray[1] = 0;
	fourthArray[2] = 0;
	fourthArray[3] = 0;
}



int readKP()
{
	uint8_t col1 = 0xEF;
	uint8_t col2 = 0xDF;		
	uint8_t col3 = 0xBF;
	uint8_t col4 = 0x7F;
	uint8_t idle = 0xFF;
	
		
	while(1)
	{
		PORTC = idle;
		int counter = 0;
		uint8_t check = 0x00;
		/*while(PINC != 0xFF)
		{
			counter += 1;
		}*/
		
		//COL1 SCAN
		PORTC = col1;
		check = col1 - PINC;
		
		if (check != 0)
		{
			if (PINC == 0xEE)
			{
				return 0x01;	
			}
			else if (PINC == 0xED)
			{
				return 0x04;
			}
			else if (PINC == 0xEB)
			{
				return 0x07;
			}
			else if(PINC == 0xE7)
			{
				return 0x2A;
			}
			
		}
		
		//COL2 SCAN
		PORTC = col2;
		check = col2 - PINC;
		
		if (check != 0)
		{
			if (PINC == 0xDE)
			{
				return 0x02;
			}
			else if (PINC == 0xDD)
			{
				return 0x05;
			}
			else if (PINC == 0xDB)
			{
				return 0x08;
			}
			else if(PINC == 0xD7)
			{
				return 0x00;
			}
			
		}
		
		//COL3 SCAN
		PORTC = col3;
		check = col3 - PINC;
		
		if (check != 0)
		{
			if (PINC == 0xBE)
			{
				return 0x03;
			}
			else if (PINC == 0xBD)
			{
				return 0x06;
			}
			else if (PINC == 0xBB)
			{
				return 0x09;
			}
			else if(PINC == 0xB7)
			{
				return 0x23;
			}
		}
		
		//COL4 SCAN
		PORTC = col4;
		check = col4 - PINC;
		
		if (check != 0)
		{
			if (PINC == 0x7E)
			{
				return 0x43;
			}
			else if (PINC == 0x7D)
			{
				return 0x45;
			}
			else if (PINC == 0x7B)
			{
				return 0x42;
			}
			
			
			else if(PINC == 0x77)
			{
				return 0x44;
			}
		}
		
	}
}


int init()
	{
		//Initialization
		DDRC = 0xF0;
		PORTC = 0xF;
			
		DDRB = 0xFF;
		PORTB = 0x00;
	}


void debounce(uint8_t keypressed) // debounce function
{
	uint8_t keypresseddb = keypressed;  // the first value of readKP()
	while (keypresseddb == keypressed)	// If same then add delay and read until different.
	{
		keypressed = readKP();
	}
} 


	

int calculation() // storing all potential 19 inputs in an array
{	
	for(int i = 0; i < 19; i++)
	{
		calculationArray[i] = readKP();
		
		if (calculationArray[i] == 0x2A)
		{
			return;
		}
		
		debounce(calculationArray[i]);
	}
	
}

int numSeparate() // separates the digits associated with the same number into their own arrays
{	
	
	int arrayCounter = 0;
	
	for(int i = arrayPosition; calculationArray[i] != 0x2a; i++)
	{	
		if(calculationArray[i] > 10)
		{
			operations[0] = calculationArray[i];
			arrayPosition += 1;
			break;
		}
		else
		{
			digits[0] += 1;
			arrayPosition += 1;
		}
		firstArray[arrayCounter] = calculationArray[i];
		arrayCounter += 1;
	}
	arrayCounter = 0;
	
	for(int i = arrayPosition; calculationArray[i] != 0x2a; i++)
	{	
		if(calculationArray[i] > 10)
		{
			operations[1] = calculationArray[i];
			arrayPosition += 1;
			break;
		}
		else
		{
			digits[1] += 1;
			arrayPosition += 1;
		}
		secondArray[arrayCounter] = calculationArray[i];
		arrayCounter += 1;
	}
	arrayCounter = 0;
	
	for(int i = arrayPosition; calculationArray[i] != 0x2a; i++)
	{	
		if(calculationArray[i] > 10)
		{
			operations[2] = calculationArray[i];
			arrayPosition += 1;
			break;
		}
		else
		{
			digits[2] += 1;
			arrayPosition += 1;
		}
		thirdArray[arrayCounter] = calculationArray[i];
		arrayCounter += 1;
	}
	arrayCounter = 0;
	
	for(int i = arrayPosition; calculationArray[i] != 0x2a; i++)
	{	
		if(calculationArray[i] > 10)
		{
			arrayPosition += 1;
			break;
		}
		else
		{
			digits[3] += 1;
			arrayPosition += 1;
		}
		fourthArray[arrayCounter] = calculationArray[i];
		arrayCounter += 1;
	}
}

int combineDigits(int digits[], int numDigits) // combines the digits for the number stored in the array into a single number
{
	int result = 0;

	for (int i = 0; i < numDigits; i++) {
		result = result * 10 + digits[i];
	}

	return result;
}

bool compareArrays(char arr1[], char arr2[])  // function used to distinguish arrays from each other
{
	for (int i = 0; i < 3; i++) {
		if (arr1[i] != arr2[i]) {
			return false; // Arrays are not the same
		}
	}
	return true; // Arrays are the same
}

finalCalculation(int firstNumber, int secondNumber, int thirdNumber, int fourthNumber, int operations[])  // result calculation with if statements to determine the order of operations
{
	int result = 0;
	char operationChar[] = {0, 0, 0};
	
	char combination1[] = {'+', '+', '+'};
	char combination2[] = {'+', '+', '-'};
	char combination3[] = {'+', '+', '*'};
	char combination4[] = {'+', '+', '/'};
	char combination5[] = {'+', '-', '+'};
	char combination6[] = {'+', '-', '-'};
	char combination7[] = {'+', '-', '*'};
	char combination8[] = {'+', '-', '/'};
	char combination9[] = {'+', '*', '+'};
	char combination10[] = {'+', '*', '-'};
	char combination11[] = {'+', '*', '*'};
	char combination12[] = {'+', '*', '/'};
	char combination13[] = {'+', '/', '+'};
	char combination14[] = {'+', '/', '-'};
	char combination15[] = {'+', '/', '*'};
	char combination16[] = {'+', '/', '/'};

	char combination17[] = {'-', '+', '+'};
	char combination18[] = {'-', '+', '-'};
	char combination19[] = {'-', '+', '*'};
	char combination20[] = {'-', '+', '/'};
	char combination21[] = {'-', '-', '+'};
	char combination22[] = {'-', '-', '-'};
	char combination23[] = {'-', '-', '*'};
	char combination24[] = {'-', '-', '/'};
	char combination25[] = {'-', '*', '+'};
	char combination26[] = {'-', '*', '-'};
	char combination27[] = {'-', '*', '*'};
	char combination28[] = {'-', '*', '/'};
	char combination29[] = {'-', '/', '+'};
	char combination30[] = {'-', '/', '-'};
	char combination31[] = {'-', '/', '*'};
	char combination32[] = {'-', '/', '/'};

	char combination33[] = {'*', '+', '+'};
	char combination34[] = {'*', '+', '-'};
	char combination35[] = {'*', '+', '*'};
	char combination36[] = {'*', '+', '/'};
	char combination37[] = {'*', '-', '+'};
	char combination38[] = {'*', '-', '-'};
	char combination39[] = {'*', '-', '*'};
	char combination40[] = {'*', '-', '/'};
	char combination41[] = {'*', '*', '+'};
	char combination42[] = {'*', '*', '-'};
	char combination43[] = {'*', '*', '*'};
	char combination44[] = {'*', '*', '/'};
	char combination45[] = {'*', '/', '+'};
	char combination46[] = {'*', '/', '-'};
	char combination47[] = {'*', '/', '*'};
	char combination48[] = {'*', '/', '/'};

	char combination49[] = {'/', '+', '+'};
	char combination50 []= {'/', '+', '-'};
	char combination51 []= {'/', '+', '*'};
	char combination52 []= {'/', '-', '+'};
	char combination53 []= {'/', '-', '-'};
	char combination54 []= {'/', '-', '*'};
	char combination55 []= {'/', '*', '+'};
	char combination56 []= {'/', '*', '-'};
	char combination57 []= {'/', '*', '*'};
	char combination58 []= {'/', '*', '/'};
	char combination59 []= {'/', '+', '/'};
	char combination60 []= {'/', '-', '/'};
	char combination61 []= {'/', '/', '/'};
	char combination62 []= {'/', '/', '+'};
	char combination63 []= {'/', '/', '-'};
	char combination64 []= {'/', '/', '*'};

			
	for(int i=0;i<3;i++)
	{
		switch(operations[i])
		{
			case 67:
				operationChar[i] = '+';
				break;
			case 69:
				operationChar[i] = '-';
				break;
			case 66:
				operationChar[i] = '*';
				break;
			case 68:
				operationChar[i] = '/';
				break;
			default:
				operationChar[i] = '+';
				break;
		}
	}
	

	if (compareArrays(operationChar, combination1))
	{
		result = firstNumber + secondNumber + thirdNumber + fourthNumber;
	}
	else if (compareArrays(operationChar, combination2))
	{
		result = firstNumber + secondNumber + thirdNumber - fourthNumber;
	}
	else if (compareArrays(operationChar, combination3))
	{
		result = firstNumber + secondNumber + thirdNumber * fourthNumber;
	}
	else if (compareArrays(operationChar, combination4))
	{
		result = firstNumber + secondNumber + thirdNumber / fourthNumber;
	}
	else if (compareArrays(operationChar, combination5))
	{
		result = firstNumber + secondNumber - thirdNumber + fourthNumber;
	}
	else if (compareArrays(operationChar, combination6))
	{
		result = firstNumber + secondNumber - thirdNumber - fourthNumber;
	}
	else if (compareArrays(operationChar, combination7))
	{
		result = firstNumber + secondNumber - thirdNumber * fourthNumber;
	}
	else if (compareArrays(operationChar, combination8))
	{
		result = firstNumber + secondNumber - thirdNumber / fourthNumber;
	}
	else if (compareArrays(operationChar, combination9))
	{
		result = firstNumber + secondNumber * thirdNumber + fourthNumber;
	}
	else if (compareArrays(operationChar, combination10))
	{
		result = firstNumber + secondNumber * thirdNumber - fourthNumber;
	}
	else if (compareArrays(operationChar, combination11))
	{
		result = firstNumber + secondNumber * thirdNumber * fourthNumber;
	}
	else if (compareArrays(operationChar, combination12))
	{
		result = firstNumber + secondNumber * thirdNumber / fourthNumber;
	}
	else if (compareArrays(operationChar, combination13))
	{
		result = firstNumber + secondNumber / thirdNumber + fourthNumber;
	}
	else if (compareArrays(operationChar, combination14))
	{
		result = firstNumber + secondNumber / thirdNumber - fourthNumber;
	}
	else if (compareArrays(operationChar, combination15))
	{
		result = firstNumber + secondNumber / thirdNumber * fourthNumber;
	}
	else if (compareArrays(operationChar, combination16))
	{
		result = firstNumber + secondNumber / thirdNumber / fourthNumber;
	}
	else if (compareArrays(operationChar, combination17))
	{
		result = firstNumber - secondNumber + thirdNumber + fourthNumber;
	}
	else if (compareArrays(operationChar, combination18))
	{
		result = firstNumber - secondNumber + thirdNumber - fourthNumber;
	}
	else if (compareArrays(operationChar, combination19))
	{
		result = firstNumber - secondNumber + thirdNumber * fourthNumber;
	}
	else if (compareArrays(operationChar, combination20))
	{
		result = firstNumber - secondNumber + thirdNumber / fourthNumber;
	}
	else if (compareArrays(operationChar, combination21))
	{
		result = firstNumber - secondNumber - thirdNumber + fourthNumber;
	}
	else if (compareArrays(operationChar, combination22))
	{
		result = firstNumber - secondNumber - thirdNumber - fourthNumber;
	}
	else if (compareArrays(operationChar, combination23))
	{
		result = firstNumber - secondNumber - thirdNumber * fourthNumber;
	}
	else if (compareArrays(operationChar, combination24))
	{
		result = firstNumber - secondNumber - thirdNumber / fourthNumber;
	}
	else if (compareArrays(operationChar, combination25))
	{
		result = firstNumber - secondNumber * thirdNumber + fourthNumber;
	}
	else if (compareArrays(operationChar, combination26))
	{
		result = firstNumber - secondNumber * thirdNumber - fourthNumber;
	}
	else if (compareArrays(operationChar, combination27))
	{
		result = firstNumber - secondNumber * thirdNumber * fourthNumber;
	}
	else if (compareArrays(operationChar, combination28))
	{
		result = firstNumber - secondNumber * thirdNumber / fourthNumber;
	}
	else if (compareArrays(operationChar, combination29))
	{
		result = firstNumber - secondNumber / thirdNumber + fourthNumber;
	}
	else if (compareArrays(operationChar, combination30))
	{
		result = firstNumber - secondNumber / thirdNumber - fourthNumber;
	}
	else if (compareArrays(operationChar, combination31))
	{
		result = firstNumber - secondNumber / thirdNumber * fourthNumber;
	}
	else if (compareArrays(operationChar, combination32))
	{
		result = firstNumber - secondNumber / thirdNumber / fourthNumber;
	}
	else if (compareArrays(operationChar, combination33))
	{
		result = firstNumber * secondNumber + thirdNumber + fourthNumber;
	}
	else if (compareArrays(operationChar, combination34))
	{
		result = firstNumber * secondNumber + thirdNumber - fourthNumber;
	}
	else if (compareArrays(operationChar, combination35))
	{
		result = firstNumber * secondNumber + thirdNumber * fourthNumber;
	}
	else if (compareArrays(operationChar, combination36))
	{
		result = firstNumber * secondNumber + thirdNumber / fourthNumber;
	}
	else if (compareArrays(operationChar, combination37))
	{
		result = firstNumber * secondNumber - thirdNumber + fourthNumber;
	}
	else if (compareArrays(operationChar, combination38))
	{
		result = firstNumber * secondNumber - thirdNumber - fourthNumber;
	}
	else if (compareArrays(operationChar, combination39))
	{
		result = firstNumber * secondNumber - thirdNumber * fourthNumber;
	}
	else if (compareArrays(operationChar, combination40))
	{
		result = firstNumber * secondNumber - thirdNumber / fourthNumber;
	}
	else if (compareArrays(operationChar, combination41))
	{
		result = firstNumber * secondNumber * thirdNumber + fourthNumber;
	}
	else if (compareArrays(operationChar, combination42))
	{
		result = firstNumber * secondNumber * thirdNumber - fourthNumber;
	}
	else if (compareArrays(operationChar, combination43))
	{
		result = firstNumber * secondNumber * thirdNumber * fourthNumber;
	}
	else if (compareArrays(operationChar, combination44))
	{
		result = firstNumber * secondNumber * thirdNumber / fourthNumber;
	}
	else if (compareArrays(operationChar, combination45))
	{
		result = firstNumber * secondNumber / thirdNumber + fourthNumber;
	}
	else if (compareArrays(operationChar, combination46))
	{
		result = firstNumber * secondNumber / thirdNumber - fourthNumber;
	}
	else if (compareArrays(operationChar, combination47))
	{
		result = firstNumber * secondNumber / thirdNumber * fourthNumber;
	}
	else if (compareArrays(operationChar, combination48))
	{
		result = firstNumber * secondNumber / thirdNumber / fourthNumber;
	}
	else if (compareArrays(operationChar, combination49))
	{
		result = firstNumber / secondNumber + thirdNumber + fourthNumber;
	}
	else if (compareArrays(operationChar, combination50))
	{
		result = firstNumber / secondNumber + thirdNumber - fourthNumber;
	}
	else if (compareArrays(operationChar, combination51))
	{
		result = firstNumber / secondNumber + thirdNumber * fourthNumber;
	}
	else if (compareArrays(operationChar, combination52))
	{
		result = firstNumber / secondNumber - thirdNumber + fourthNumber;
	}
	else if (compareArrays(operationChar, combination53))
	{
		result = firstNumber / secondNumber - thirdNumber - fourthNumber;
	}
	else if (compareArrays(operationChar, combination54))
	{
		result = firstNumber / secondNumber - thirdNumber * fourthNumber;
	}
	else if (compareArrays(operationChar, combination55))
	{
		result = firstNumber / secondNumber * thirdNumber + fourthNumber;
	}
	else if (compareArrays(operationChar, combination56))
	{
		result = firstNumber / secondNumber * thirdNumber - fourthNumber;
	}
	else if (compareArrays(operationChar, combination57))
	{
		result = firstNumber / secondNumber * thirdNumber * fourthNumber;
	}
	else if (compareArrays(operationChar, combination58))
	{
		result = firstNumber / secondNumber * thirdNumber / fourthNumber;
	}
	else if (compareArrays(operationChar, combination59))
	{
		result = firstNumber / secondNumber + thirdNumber / fourthNumber;
	}
	else if (compareArrays(operationChar, combination60))
	{
		result = firstNumber / secondNumber - thirdNumber / fourthNumber;
	}
	else if (compareArrays(operationChar, combination61))
	{
		result = firstNumber / secondNumber / thirdNumber / fourthNumber;
	}
	else if (compareArrays(operationChar, combination62))
	{
		result = firstNumber / secondNumber / thirdNumber + fourthNumber;
	}
	else if (compareArrays(operationChar, combination63))
	{
		result = firstNumber / secondNumber / thirdNumber - fourthNumber;
	}
	else if (compareArrays(operationChar, combination64))
	{
		result = firstNumber / secondNumber / thirdNumber * fourthNumber;
	}

	return result;
}

int main(void)
{	
	reset:
	init();
	
	calculation();
	
	numSeparate();
	
	int firstNumber = combineDigits(firstArray, digits[0]);
	int secondNumber = combineDigits(secondArray, digits[1]);
	int thirdNumber = combineDigits(thirdArray, digits[2]);
	int fourthNumber = combineDigits(fourthArray, digits[3]);
	
	int answer = finalCalculation(firstNumber, secondNumber, thirdNumber, fourthNumber, operations);
	
	bool negative_detected = false;
	

	if(answer < 0x00) // determine if result is negative and change the value to an absolute value
	{
		answer = abs(answer);
		negative_detected = true;
	}
	
	
	if(answer > 0xFF)  // used to detect results that are 16 bits
	{
		if(negative_detected)
		{
			PORTB = 0xFF;
			for(uint64_t j = 0; j < 300000; j++)								// 2s time delay loop
			{
				
			}
			PORTB = 0x00;
			for(uint64_t j = 0; j < 300000; j++)								// 2s time delay loop
			{
				
			}
			PORTB = 0xFF;
			for(uint64_t j = 0; j < 300000; j++)								// 2s time delay loop
			{
				
			}
			PORTB = 0x00;
			for(uint64_t j = 0; j < 300000; j++)								// 2s time delay loop
			{
				
			}
		}
		
		PORTB = (answer >> 8);												// MSB being displayed on Port B by incrementing keySum by 8 bits
		
		for(uint64_t j = 0; j < 300000; j++)								// 2s time delay loop
		{
			
		}
		
		PORTB = (answer & 0xFF);											// LSB being displayed on Port B
		
		for(uint64_t j = 0; j < 300000; j++)								// 2s time delay loop
		{
			
		}
	}
	
	
	else if(negative_detected)
	{
		PORTB = 0xFF;
		for(uint64_t j = 0; j < 300000; j++)								// 2s time delay loop
		{
			
		}
		PORTB = 0x00;
		for(uint64_t j = 0; j < 300000; j++)								// 2s time delay loop
		{
			
		}
		PORTB = 0xFF;
		for(uint64_t j = 0; j < 300000; j++)								// 2s time delay loop
		{
			
		}
		PORTB = 0x00;
		for(uint64_t j = 0; j < 300000; j++)								// 2s time delay loop
		{
			
		}
		
		PORTB = answer;	
	}
	
	
	else
	{
		PORTB = answer;
	}
	
	while(answer > 0xFF)
	{
		if(readKP() == 0x01)
		{
			PORTB = (answer >> 8);
		}
		else if (readKP() == 0x02)
		{
			PORTB = (answer & 0xFF);
		}
		
		else if (readKP() == 0x23)
		{
			PORTB = 0x00;
			reset_global_variables();
			goto reset;
		}
	}
	
	
	int reset_pressed = 0;
	
	while(reset_pressed != 0x23)
	{
		reset_pressed = readKP();
	}

	if(reset_pressed == 0x23)
	{
		PORTB = 0x00;
		reset_global_variables();
		goto reset;
	}
	
	
}


