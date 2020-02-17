-- lexit.lua
-- Hillari M. Denny, Glenn G. Chappell
-- CSCE A331 Assignment 3, Exercise 2

-- This code is based on the lexer example provided by Dr. Chappell, found here
-- https://github.com/ggchappell/cs331-2020-01/blob/master/lexer.lua

-- This code is a lexical analyzer for the programming language Degu. It uses much 
-- of the same program structure and utility functions provided in Dr. Chappels code. 


-- *********************************************************************
-- Module Table Initialization
-- *********************************************************************


local lexer = {}  -- Our module; members are added below


-- *********************************************************************
-- Public Constants
-- *********************************************************************

-- Numeric constants representing lexeme categories
lexer.KEY    = 1
lexer.ID     = 2
lexer.NUMLIT = 3
lexer.STRLIT = 4
lexer.OP 	 = 5
lexer.PUNCT  = 6
lexer.MAL 	 = 7


-- catnames
-- Array of names of lexeme categories.
-- Human-readable strings. Indices are above numeric constants.
lexer.catnames = {
    "Keyword",
    "Identifier",
    "NumericLiteral",
    "StringLiteral",
    "Operator",
    "Punctuation",
    "Malformed"
}


-- *********************************************************************
-- Kind-of-Character Functions
-- *********************************************************************

-- All functions return false when given a string whose length is not
-- exactly 1.


-- isLetter
-- Returns true if string c is a letter character, false otherwise.
local function isLetter(c)
    if c:len() ~= 1 then
        return false
    elseif c >= "A" and c <= "Z" then
        return true
    elseif c >= "a" and c <= "z" then
        return true
    else
        return false
    end
end


-- isDigit
-- Returns true if string c is a digit character, false otherwise.
local function isDigit(c)
    if c:len() ~= 1 then
        return false
    elseif c >= "0" and c <= "9" then
        return true
    else
        return false
    end
end

-- isWhitespace
-- Returns true if string c is a whitespace character, false otherwise.
-- According the lexeme specifications, whitespace characters include;
-- blank, tab(t), vertical-tab(v), new-line(n), carriage-return(r), form-feed(f)
local function isWhitespace(c)
    if c:len() ~= 1 then
        return false
    elseif c == " " or c == "\t" or c == "\n" or c == "\r"
      or c == "\f" or c == "\v" then
        return true
    else
        return false
    end
end

-- isPrintableASCII
-- Returns true if string c is a printable ASCII character (codes 32 " "
-- through 126 "~"), false otherwise.
local function isPrintableASCII(c)
    if c:len() ~= 1 then
        return false
    elseif c >= " " and c <= "~" then
        return true
    else
        return false
    end
end

-- isIllegal
-- Returns true if string c is an illegal character, false otherwise.
local function isIllegal(c)
    if c:len() ~= 1 then
        return false
    elseif isWhitespace(c) then
        return false
    elseif isPrintableASCII(c) then
        return false
    else
        return true
    end
end



-- *********************************************************************
-- The lexit
-- *********************************************************************


-- lex
-- Our lexit
-- Intended for use in a for-in loop:
--     for lexstr, cat in lexit.lex(program) do
-- Here, lexstr is the string form of a lexeme, and cat is a number
-- representing a lexeme category. (See Public Constants.)
function lexit.lex(program)
    -- ***** Variables (like class data members) *****

    local pos       -- Index of next character in program
                    -- INVARIANT: when getLexeme is called, pos is
                    --  EITHER the index of the first character of the
                    --  next lexeme OR program:len()+1
    local state     -- Current state for our state machine
    local ch        -- Current character
    local lexstr    -- The lexeme, so far
    local prevLex
    local category  -- Category of lexeme, set when state set to DONE
    local prevCat
    local handlers  -- Dispatch table; value created later

    -- ***** States *****

    local DONE      = 0
    local START     = 1
    local LETTER    = 2
    local DIGIT     = 3
    local DIGEX     = 4
    local PLUSMINUS = 5
    local SINGLEQ   = 6
    local DOUBLEQ   = 7

    -- ***** Character-Related Utility Functions *****

    -- currChar
    -- Return the current character, at index pos in program. Return
    -- value is a single-character string, or the empty string if pos is
    -- past the end.
    local function currChar()
        return program:sub(pos, pos)
    end

    -- nextChar
    -- Return the next character, at index pos+1 in program. Return
    -- value is a single-character string, or the empty string if pos+1
    -- is past the end.
    local function nextChar()
        return program:sub(pos+1, pos+1)
    end

    -- drop1
    -- Move pos to the next character.
    local function drop1()
        pos = pos+1
    end

    -- add1
    -- Add the current character to the lexeme, moving pos to the next
    -- character.
    local function add1()
        lexstr = lexstr .. currChar()
        drop1()
    end


    -- skipWhitespace
    -- Skip whitespace and comments, moving pos to the beginning of
    -- the next lexeme, or to program:len()+1.
    local function skipWhitespace()
        while true do      -- In whitespace
            while isWhitespace(currChar()) do
                drop1()
            end

            if currChar() ~= "#" then  -- if we only have whitespace, just break
                break
            end
            drop1()

            while true do  -- In comment
                if currChar() == "" or currChar() == "\n" then -- end of input or newline
                    drop1()
                    break
                end
                drop1()
            end
        end
    end

    -- lookAhead
	-- takes a number and returns that number of chars ahead of current position
    local function lookAhead(n)
        return program:sub(pos+n, pos+n)
    end

    -- ***** State-Handler Functions *****

    -- A function with a name like handle_XYZ is the handler function
    -- for state XYZ

    local function handle_DONE()
        error("'DONE' state should not be handled\n")
    end

    local function handle_START()
    	if isIllegal(ch) then
    		add1()
    		state = DONE
    		category = lexer.MAL
    	elseif isLetter(ch) or ch == "_" then
    		add1()
    		state = LETTER
    	elseif isDigit(ch) then
    		add1()
    		state = DIGIT
    	elseif ch == "'" or ch == '"' then
    		add1()
    		state = STRLITERAL


    end

   local function handle_LETTER()
   		if isLetter(ch) or isDigit(ch) or ch == "_" then --TODO why check for isDigit() here?
   			add1()
   		else
   			state = DONE
   			if lexstr == "and" or lexstr == "char" or lexstr == "elif" or lexstr == "else" or
   			lexstr == "end" or lexstr == "false" or lexstr == "func" or lexstr == "if" 
   			or lexstr == "input" or lexstr == "not" or lexstr == "or" or lexstr == "print"
   			or lexstr == "return" or lexstr == "true" or lexstr == "while" then
   				category = lexit.KEY
   			else
   				category = lexit.ID
   			end
   		end
   end












end -- end lexit.lex


return lexit