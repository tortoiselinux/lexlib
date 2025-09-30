#!/usr/bin/env lua

local t = require("tlib")

-- TODO: Diminuir a quantidade de tabelas criadas nesse programa, para melhorar o desempenho.
-- TODO: Carregar mais informações sobre as linhas do programa na tabela
-- TODO: Informar linha e coluna de cada token

local function p(msg, value) print(msg, value) end

local function exit(code)
    os.exit(code)
end

local function string_lines_to_table(str)
    local new_table = {}

    for line in str:gmatch("[^\n]+") do
	table.insert(new_table, {line = line})
    end

    return new_table
end

local function get_lines(program)
    local program_lines = {}

    for pos, t in ipairs(program) do
	table.insert(program_lines, {value = t.line, pos = pos})
    end

    return program_lines
end

local function get_words(program_lines)
    local words = {}

    for i, line in ipairs(program_lines) do
	for word in line.value:gmatch("%S+") do
	    table.insert(words, { value = word, line = line.pos, col = i})
	end
    end
    return words
end

local symbols	= {
    Local	= "local",
    Req		= "require",
    Func	= "function",
    For		= "for",
    If		= "if",
    Elseif	= "elseif",
    Else	= "else",
    Then	= "then",
    Do		= "do",
    In		= "in",
    Eq		= "=",
    Plus	= "+",
    Minus	= "-",
    Mult	= "*",
    Div		= "/",
}

local function lex(words)
    local tokens = {}

    for _, word in ipairs(words) do
	local value	= word.value
	local line	= word.line
	local col	= word.col

	-- reserved words
	if value == symbols.Local then
	    p("declaration founded: ", value)
	    table.insert(tokens, {token = word.value, t_type = "declaration", line = line, col = col})
	elseif value == symbols._req then
	    p("code import: ", value)

	-- operators
	elseif value == symbols.Eq then
	    p("assignment founded: ", value)
	    table.insert(tokens, {token = word.value, t_type = "assignment", line = line, col = col})
	elseif value == symbols.Plus then
	    p("plus operation: ", value)
	    table.insert(tokens, {word = word.value, t_type = "plus", line = line, col = col})
	elseif value == symbols.Minus then
	    p("minus operation: ", value)
	    table.insert(tokens, {token = word.value, t_type = "minus", line = line, col = col})
	elseif value == symbols.Mult then
	    p("mult operation: ", value)
	    table.insert(tokens, {token = word.value, t_type = "mult", line = line, col = col})
	elseif value == symbols.Div then
	    p("div operation: ", value)
	    table.insert(tokens, {token = word.value, t_type = "div", line = line, col = col})

	-- others
	elseif type(tonumber(value)) == "number" then
	    p("number founded: ", value)
	    table.insert(tokens, {token = word.value, t_type = "number", line = line, col = col})
	elseif type(value) == "string" then
	    p("symbol founded: ", value)
	    table.insert(tokens, {token = word.value, t_type = "symbol", line = line, col = col})
	else
	    if word.value ~= nil then
		p("unexpected token: ", value)
	    end
	end
    end

    return tokens
end

if #arg == 0 then
    help()
    exit(1)
elseif t.verify_args(arg, { "h", "-h", "help", "--help" }) then
    help()
    exit(0)
else
    local program = string_lines_to_table(t.read_file(arg[1]))
    if program == nil then 
	error("No program loaded")
    end

    print("program loaded:")
    
    print(program)

    local program_lines = get_lines(program)
    local words = get_words(program_lines)
    local tokens = lex(words)
end
