--[[
Copyright (c) 2010-2013 Matthias Richter
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local assert = assert
local sqrt, cos, sin, atan2 = math.sqrt, math.cos, math.sin, math.atan2

Vector = Core.class()

-- Constructor
function Vector:init(x,y)
	self.x = x or 0
	self.y = y or 0
end

local zero = Vector.new(0,0)

function Vector:clone()
	return Vector.new(self.x, self.y)
end

function Vector:unpack()
	return self.x, self.y
end

function Vector:__tostring()
	return "("..tonumber(self.x)..","..tonumber(self.y)..")"
end

function Vector.__unm(a)
	return Vector.new(-a.x, -a.y)
end

function Vector.add(a,b)
	return Vector.new(a.x + b.x, a.y + b.y)
end

function Vector.sub(a,b)
	return Vector.new(a.x - b.x, a.y - b.y)
end

function Vector.mul(a,b)
	if type(a) == "number" then
		return Vector.new(a * b.x, a * b.y)
	elseif type(b) == "number" then
		return Vector.new(b*a.x, b*a.y)
	else
		
		return a.x * b.x + a.y * b.y
	end
end

function Vector.__div(a,b)
	assert(type(b) == "number", "wrong argument types (expected <vector> / <number>)")
	return Vector.new(a.x / b, a.y / b)
end

function Vector.__eq(a,b)
	return a.x == b.x and a.y == b.y
end

function Vector.__lt(a,b)
	return a.x < b.x or (a.x == b.x and a.y < b.y)
end

function Vector.__le(a,b)
	return a.x <= b.x and a.y <= b.y
end

function Vector.permul(a,b)
	return Vector.new(a.x*b.x, a.y*b.y)
end

function Vector:len2()
	return self.x * self.x + self.y * self.y
end

function Vector:len()
	return sqrt(self.x * self.x + self.y * self.y)
end

function Vector.dist(a, b)
	
	local dx = a.x - b.x
	local dy = a.y - b.y
	
	return sqrt(dx * dx + dy * dy)
end

function Vector.dist2(a, b)
	
	local dx = a.x - b.x
	local dy = a.y - b.y
	
	return (dx * dx + dy * dy)
end

function Vector:normalize_inplace()
	local l = self:len()
	if l > 0 then
		self.x, self.y = self.x / l, self.y / l
	end
	
	return self
end

function Vector:normalized()
	return self:clone():normalize_inplace()
end

function Vector:rotate_inplace(phi)
	local c, s = cos(phi), sin(phi)
	self.x, self.y = c * self.x - s * self.y, s * self.x + c * self.y
	
	return self
end

function Vector:rotated(phi)
	local c, s = cos(phi), sin(phi)
	
	return Vector.new(c * self.x - s * self.y, s * self.x + c * self.y)
end

function Vector:perpendicular()
	return Vector.new(-self.y, self.x)
end

function Vector:projectOn(v)
	-- (self * v) * v / v:len2()
	local s = (self.x * v.x + self.y * v.y) / (v.x * v.x + v.y * v.y)
	
	return Vector.new(s * v.x, s * v.y)
end

function Vector:mirrorOn(v)
	local s = 2 * (self.x * v.x + self.y * v.y) / (v.x * v.x + v.y * v.y)
	
	return Vector.new(s * v.x - self.x, s * v.y - self.y)
end

function Vector:dot(v)
		
	return self.x * v.x + self.y * v.y
end

function Vector:trim_inplace(maxLen)
	local s = maxLen * maxLen / self:len2()
	s = (s > 1 and 1) or math.sqrt(s)
	self.x, self.y = self.x * s, self.y * s
	
	return self
end

function Vector:angleTo(other)
	if other then
		return atan2(self.y, self.x) - atan2(other.y, other.x)
	end
	
	return atan2(self.y, self.x)
end

function Vector:trimmed(maxLen)
	return self:clone():trim_inplace(maxLen)
end
