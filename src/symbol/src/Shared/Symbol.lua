--[=[
	A 'Symbol' is an opaque marker type.

	Symbols have the type 'userdata', but when printed to the console, the name
	of the symbol is shown.
	@class Symbol
]=]

local Symbol = {}

--[=[
	Creates a Symbol with the given name.

	When printed or coerced to a string, the symbol will turn into the string
	given as its name.

	@param name string
	@return Symbol
]=]
function Symbol.named(name)
	assert(type(name) == "string", "Symbols must be created using a string name!")

	local self = newproxy(true)

	local wrappedName = string.format("Symbol(%s)", name)

	getmetatable(self).__tostring = function()
		return wrappedName
	end

	return self
end

--[=[
	Returns true if a symbol

	@param value boolean
	@return boolean
]=]
function Symbol.isSymbol(value)
	return typeof(value) == "userdata"
end

return Symbol