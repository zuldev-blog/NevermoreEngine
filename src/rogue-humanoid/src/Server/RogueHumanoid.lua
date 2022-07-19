--[=[
	@class RogueHumanoid
]=]

local require = require(script.Parent.loader).load(script)

local BaseObject = require("BaseObject")
local RogueHumanoidProperties = require("RogueHumanoidProperties")
local AttributeUtils = require("AttributeUtils")
local Rx = require("Rx")
local ValueObject = require("ValueObject")

local GROWTH_VALUE_NAMES = {
	"HeadScale";
	"BodyDepthScale";
	"BodyHeightScale";
	"BodyWidthScale";
}

local RogueHumanoid = setmetatable({}, BaseObject)
RogueHumanoid.ClassName = "RogueHumanoid"
RogueHumanoid.__index = RogueHumanoid

function RogueHumanoid.new(humanoid, serviceBag)
	local self = setmetatable(BaseObject.new(humanoid), RogueHumanoid)

	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._properties = RogueHumanoidProperties:GetPropertyTable(self._serviceBag, self._obj)

	self._maid:GiveTask(self._properties.WalkSpeed:Observe():Subscribe(function(walkSpeed)
		self._obj.WalkSpeed = walkSpeed
	end))
	self._maid:GiveTask(self._properties.JumpHeight:Observe():Subscribe(function(jumpHeight)
		self._obj.JumpHeight = jumpHeight
	end))

	self._scaleState = ValueObject.fromObservable(Rx.combineLatest({
		scale = self._properties.Scale:Observe();
		maxSize = self._properties.ScaleMax:Observe();
		minSize = self._properties.ScaleMin:Observe();
	}))

	self._maid:GiveTask(self._scaleState)
	self._maid:GiveTask(self._scaleState:Observe():Subscribe(function(state)
		if state then
			self:_updateScale(state)
		end
	end))

	self._maid:GiveTask(self._properties.MaxHealth:Observe():Subscribe(function(maxHealth)
		local newMaxHealth = math.max(maxHealth, 1)
		local currentMaxHealth = self._obj.MaxHealth

		if currentMaxHealth < newMaxHealth then
			-- ensure we gain the same health as our max health
			local gained = newMaxHealth - currentMaxHealth
			self._obj.MaxHealth = newMaxHealth
			self._obj.Health = self._obj.Health + gained
		else
			-- Losses do not prevent this
			self._obj.MaxHealth = newMaxHealth
			self._obj.Health = math.max(self._obj.Health, newMaxHealth)
		end
	end))

	self._maid:GiveTask(self._obj.ChildAdded:Connect(function(child)
		if GROWTH_VALUE_NAMES[child.Name] then
			local state = self._scaleState.Value
			if state then
				self:_updateScaleValue(child, state)
			end
		end
	end))

	return self
end

function RogueHumanoid:_updateScale(state)
	for _, name in pairs(GROWTH_VALUE_NAMES) do
		local numberValue = self._obj:FindFirstChild(name)
		if not numberValue then
			return
		end

		self:_updateScaleValue(numberValue, state)
	end
end

function RogueHumanoid:_updateScaleValue(numberValue, state)
	assert(typeof(numberValue) == "Instance", "Bad numberValue")
	assert(numberValue:IsA("NumberValue"), "Bad numberValue")

	local initialValue = AttributeUtils.initAttribute(numberValue, "RogueHumanoid_OriginalValue", numberValue.Value)

	local i = 1
	local t = state.scale
	local r = 0.07
	local max = state.maxSize
	local min = state.minSize

	local multiplier = min
		+ (math.exp(r*t)*(-min + max))/(math.exp(r*t)
		+ (-i + max)/(i - min))

	numberValue.Value = initialValue*multiplier
end

return RogueHumanoid