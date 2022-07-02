
<h1 align="center">Abstract</h1>

</br>

A simple simulation of Object Oriented Programming in Luau. Documentation is currently limited and will be filled in eventually.

## Usage

</br>

```Lua
local Object = require(Abstract)

local anObject = Object:__extend("AnObject")

function anObject:__init()
    -- called once the object is initialized
    self.Value = 5
end

function anObject:DoWork()
    -- do work
    print("working:", self.Value)
end

anObject = anObject:__compile()

local obj = anObject()
anObject:DoWork() --> "working: 5"

```

## Conventions

</br>

Naming conventions that should be used to avoid collisions with internal metamethods:

Classes will follow the CamelCase naming scheme.

Indices that begin with two underscores and a lowercase letter are meant to be reserved for meta-values. These should not be created by default and should only be overridden in the case of intentional metamethods.

Common metamethods are: the default Lua metamethods, __new, __init, __super, __object, and __static. The only ones that are intended to be overridden are __new and __init along with the default luau metamethods.

Indices that begin with two underscores and an upper case letter are meant to be private/protected members. These (at least currently) are not protected outside through the library (as its not entirely critical); they are only meant to be suggestions though there is no guaruntee this will not change in the future.