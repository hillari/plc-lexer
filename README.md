Hillari Denny  
University of Alaska Anchorage  
CSCE A331 Programming Language Concepts  
2/17/2020

----
### Lexer in Lua

The file lexit.lua implements a lexical analyzer for the programming language "Degu", created by Dr. Glenn Chappell at the Univeristy of Alaska Fairbanks. The lexeme specification for Degu is not included in this readme.
The code in lexit.lua implements the first phase of compilation, lexical analysis. It is represented as a state machine and converts input into a sequence of tokens. 
The lexer is based on code and lectures provided by Dr. Chappell. Each function contains 
the author names and a brief description of it's purpose/logic.


##### usage
This program is intended to be used with the test suite provided by Dr. Chappell, `lexit_test.lua`,  which contains several test suites that check lexit.lua. To run it you need to have lua 5.3 installed. With the two files in the same directory, simply run: `>> ./lexit_test.lua`

----
