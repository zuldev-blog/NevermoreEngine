---
-- @module ValueBaseUtils
-- @author Quenty

local ValueBaseUtils = {}

function ValueBaseUtils.setValue(parent, instanceType, name, value)
	assert(typeof(parent) == "Instance")
	assert(type(instanceType) == "string")
	assert(type(name) == "string")

	local foundChild = parent:FindFirstChild(name)
	if foundChild then
		foundChild.Value = value
	else
		local newChild = Instance.new(instanceType)
		newChild.Name = name
		newChild.Value = value
		newChild.Parent = parent
	end
end

function ValueBaseUtils.getValue(parent, instanceType, name, default)
	assert(typeof(parent) == "Instance")
	assert(type(instanceType) == "string")
	assert(type(name) == "string")

	local foundChild = parent:FindFirstChild(name)
	if foundChild then
		if foundChild:IsA(instanceType) then
			return foundChild.Value
		else
			warn(("[ValueBaseUtils.getValue] - Value of type %q of name %q is of type %q in %s instead")
				:format(instanceType, name, foundChild.ClassName, foundChild:GetFullName()))
			return nil
		end
	else
		return default
	end
end

return ValueBaseUtils