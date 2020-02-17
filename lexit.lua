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


local lexit = {}  -- Our module; members are added below


-- *********************************************************************
-- Public Constants
-- *********************************************************************

-- Numeric constants representing lexeme categories
lexit.KEY    = 1
lexit.ID     = 2
lexit.NUMLIT = 3
lexit.STRLIT = 4
lexit.OP 	 = 5
lexit.PUNCT  = 6
lexit.MAL 	 = 7


-- catnames
-- Array of names of lexeme categories.
-- Human-readable strings. Indices are above numeric constants.
lexit.catnames = {
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
    local EXP       = 4


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
    		category = lexit.MAL
    	elseif isLetter(ch) or ch == "_" then
    		add1()
    		state = LETTER
    	elseif isDigit(ch) then
    		add1()
    		state = DIGIT
    	elseif ch == "'" or ch == '"' then
    		add1()
    		state = STRLITERAL
        elseif ch == "<" or ch == ">" or ch == "+" or
            ch == "-" or ch == "*" or ch == "/" or
            ch == "%" or ch == "[" or ch == "]" then
                add1()
                state = DONE
                category = lexit.OP
        elseif ch == "!" and nextChar() == "=" or
               ch == "<" and nextChar() == "=" or
               ch == ">" and nextChar() == "=" or
               ch == "=" and nextChar() == "=" then
                add1()
                add1()
                state = DONE
                category = lexit.OP
    	else 
    		add1()
    		state = DONE
    		category = lexit.PUNCT
    	end
    end

    local function handle_DIGIT()
    	if isDigit(ch) then
    		add1()
    	elseif ch == "e" or ch == "E" then -- legal exponent, now we need to check next two characters
            nextCh = lookAhead(1) 
            nextnextCh = lookAhead(2) 
    		if isDigit(nextCh) then --legal exponent followed by digit
    			add1()
    			state = EXP  
            elseif nextCh == "+" and isDigit(nextnextCh) then -- exponent followed by a "+" and digit
                add1()
                add1()
                state = EXP
    		else
    			state = DONE 
    			category = lexit.NUMLIT
    		end
    	else
    		state = DONE
    		category = lexit.NUMLIT
    	end
    end


    local function handle_EXP()
        if isDigit(ch) then
            add1()
        else
            state = DONE
            category = lexit.NUMLIT

        end
    end


   local function handle_LETTER()
   		if isLetter(ch) or isDigit(ch) or ch == "_" then -- we have a letter followed by another lette or digit
   			add1()
   		else
   			state = DONE
   			if lexstr == "and" or lexstr == "char" or lexstr == "elif" or lexstr == "else" or
   				 lexstr == "end" or lexstr == "false" or lexstr == "func" or lexstr == "if" or
   				 lexstr == "input" or lexstr == "not" or lexstr == "or" or lexstr == "print" or
   				 lexstr == "return" or lexstr == "true" or lexstr == "while" then
   				 category = lexit.KEY
   			else
   				category = lexit.ID
   			end
   		end
   end


       -- ***** Table of State-Handler Functions *****

	    handlers = {
	        [DONE]=handle_DONE,
	        [START]=handle_START,
	        [LETTER]=handle_LETTER,
            [DIGIT]=handle_DIGIT,
	        [EXP]=handle_EXP,
	    }

    -- -- ***** Iterator Function *****

    -- getLexeme
    -- Called each time through the for-in loop.
    -- Returns a pair: lexeme-string (string) and category (int), or
    -- nil, nil if no more lexemes.
    local function getLexeme(dummy1, dummy2)
        if pos > program:len() then
            return nil, nil
        end
        lexstr = ""
        state = START
        while state ~= DONE do
            ch = currChar()
            handlers[state]()
        end

        skipWhitespace()
        return lexstr, category
    end

    -- ***** Body of Function lex *****

    -- Initialize & return the iterator function
    pos = 1
    skipWhitespace()
    return getLexeme, nil, nil
end


-- *********************************************************************
-- Module Table Return
-- *********************************************************************


return lexit