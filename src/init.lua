local __class_str_format = "<class %s>"
local function __classtostring(cls)
	return __class_str_format:format(cls.__name)
end

--[[
	A table structure built to contain methods for the object created though a
	class. This table will eventually become the object's metatable and is
	shared between all objects of this class.

	This table inherits from its parent's __object table through clone

	TODO: __super
]]
local function __object(inherits, name)
	local object = table.clone(inherits.__object or {})
	object.__index = function(obj, index)
		-- prioritize extindex or object[index]?
		local value = object[index]
		if value == nil and object.__extindex then
			value = object.__extindex(obj, index)
		end
		return value
	end
	object.__name = name

	return object
end

--[[
	A table structure built to contain statically made functions and attributes.

	This table stores newly created static values in its raw table and indexes
	its metatable and parent's __static table.
	Overrides are possible
]]
local function __static(inherits)
	local static = {}
	static.__index = function(stc, index)
		return static[index] or (inherits.__static or {})[index]
	end

	return setmetatable({}, static)
end

--[[
	A metatable structure that defines the behavior behind an abstract.

	An abstract is an undefined class, which basically means it has yet to be
	transformed into a full class value that can instantiate new objects.

	This is where the meta class attributes are stored.
]]
local function __abstractmeta(parent, name)
	local abstractmeta
	abstractmeta = {

		--[[
			Controls the assignment of new indexes to the __object 
			metastructure. only allows the assignment of functions (methods).

			Prevents the developer from overriding the __index metamethod.
			Prevents assignments on the abstract
		]]
		__newindex = function(cls, index, value)
			if typeof(value) ~= "function" then
				error("can not define a non-function value", 2)
			end

			-- Prevent developer from overriding __index
			index = if index == "__index" then "__extindex" else index
			rawset(cls.__object, index, value)
		end,

		--[[
			Indexes the abstractmeta or the __static table
		]]
		__index = function(cls, index)
			-- indexes the classmeta or the __static table
			return abstractmeta[index] or cls.__static[index]
		end,

		__name = name,
		__object = __object(parent, name),
		__static = __static(parent),

		__inherit = parent,
		__metatable = "locked"
	}
	return table.freeze(abstractmeta)
end

--[[
	Creates the class metatable that is attached to the new table and stores the
	abstract for interaction with external code.
]]
local function __classmeta(class)
	return table.freeze({
		__index = class,
		__call = function(cls, ...)
			return cls.__static.__new(cls, ...)
		end,
		__tostring = __classtostring
	})
end

--[[
	Allows the extension and creation of new classes. As a default, everything
	inherits from an empty table.

	This returns a table with a metatable to begin the object definition process
	and for other class behaviors to be defined
]]
local function __extend(class, name)
	name = if name == nil then debug.info(2, 's') else name
	class = if class == nil then {} else getmetatable(class).__index
	assert(typeof(class) == "table", "class must contain a metatable")

	local new = {}

	setmetatable(new, __abstractmeta(class, name))
	return new
end

--[[
	Compiles the abstract into a new and usable class
]]
local function __compile(new)
	table.freeze(new.__object)
	table.freeze(new.__static)

	return table.freeze(setmetatable({}, __classmeta(new)))
end

local object = __extend(nil, "Object")

object.__static.__extend = __extend
object.__static.__compile = __compile

function object:__init()
	if table.isfrozen(self) then
		error("__init called while frozen")
	end
end

object.__static.__new = function(cls, ...)
	local self = setmetatable({}, cls.__object)
	self:__init(...)
	return self
end
--[[
	Benchmark(func, count=1, toprint=...)

	runs the passed function and calculates the max, min and average time of
	execution. used to benchmark and performance test code.
]]
function object.__static:Benchmark(func, count, ...)
	count = if count==nil or typeof(count)~="number" then 1 else count

	local results = {}
	for i=1, count do
		local start = os.clock()
		func()
		table.insert(results, os.clock()-start)
    end

	local sum = 0
	for _, v in ipairs(results) do
		sum += v
	end

    print(...)
	print(("max %0.30f"):format(math.max(unpack(results))))
	print(("min %0.30f"):format(math.min(unpack(results))))
	print(("avg %0.30f"):format(sum/#results))
	print(("tot %0.30f"):format(sum))
end

return object:__compile()