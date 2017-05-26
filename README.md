# CSE341 Project
## Base Conversion Command-line Application

A simple CLI program that can convert numbers from one base to another. The user selects from which base to which base they want to convert and then enters the integer. The program then outputs the number in the target base.

## Features:
* Case-insensitive.
* Verifies if the correct base is entered.
* Verifies if the digits entered are within the valid range for the given source base.

## Available Bases:
* Binary (Base-2)
*	Octal (Base-8)
*	Decimal (Base-10)
*	Hexadecimal (Base-16)

## Limitations:
* Minimum value is 0 for any base.
*	Maximum value is (the system will take values greater than the ones mentioned below but the end result cannot be guaranteed, there’s also a chance for infinite loop):
    *	1111111111111111 for **Binary**
    *	177777 for **Octal**
    *	65535 for **Decimal**
    *	FFFF for **Hexadecimal**
*	Only integer is allowed. No double or float.

## Members:
* A M Saif Mahmud
* Azrin Hakim
* Tanjida Sultana
* Talha Ahmed

---

### License Information
There is no license associated with this project/repository, meaning you are not allowed to edit/redistribute the source code under any circumstances and/or in any form.
