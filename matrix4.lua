local ffi = require 'ffi'
local class = require 'ext.class'

-- matrixes are column major

local ident

local GLMatrix4x4 = class()
function GLMatrix4x4:init()
	self.v = ffi.new('float[16]',1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1)
end
function GLMatrix4x4:copy(src)
	ffi.copy(self.v, src.v, 16*4)
end
function GLMatrix4x4:ident()
	self:copy(ident)
end
function GLMatrix4x4:ortho(l,r,b,t,n,f)
	self.v[0] = 2 / (r - l)
	self.v[4] = 0 
	self.v[8] = 0 
	self.v[12] = -(r + l) / (r - l)
	self.v[1] = 0 
	self.v[5] = 2 / (t - b)
	self.v[9] = 0 
	self.v[13] = -(t + b) / (t - b)
	self.v[2] = 0 
	self.v[6] = 0 
	self.v[10] = -2 / (f - n)
	self.v[14] = -(f + n) / (f - n)
	self.v[3] = 0 
	self.v[7] = 0 
	self.v[11] = 0 
	self.v[15] = 1 
end
function GLMatrix4x4:frustum(l,r,b,t,n,f)
	self.v[0] = 2 * n / (r - l)
	self.v[4] = 0 
	self.v[8] = (r + l) / (r - l)
	self.v[12] = 0
	self.v[1] = 0 
	self.v[5] = 2 * n / (t - b)
	self.v[9] = (t + b) / (t - b)
	self.v[13] = 0
	self.v[2] = 0 
	self.v[6] = 0 
	self.v[10] = -(f + n) / (f - n)
	self.v[14] = -2 * f * n / (f - n)
	self.v[3] = 0
	self.v[7] = 0
	self.v[11] = -1
	self.v[15] = 0
end
-- http://iphonedevelopment.blogspot.com/2008/12/glulookat.html?m=1 
local function cross(ax,ay,az,bx,by,bz)
	local cx = ay * bz - az * by
	local cy = az * bx - ax * bz
	local cz = ax * by - ay * bx
	return cx,cy,cz
end
local function normalize(x,y,z)
	local m = math.sqrt(x*x + y*y + z*z)
	if m > 1e-20 then
		return x/m, y/m, z/m
	end
	return 1,0,0
end
function GLMatrix4x4:lookAt(ex,ey,ez,cx,cy,cz,upx,upy,upz)
	local zx,zy,zz = normalize(ex-cx,ey-cy,ez-cz)
	local xx, xy, xz = normalize(cross(upx,upy,upz,zx,zy,zz))
	local yx, yy, yz = normalize(cross(zx,zy,zz,xx,xy,xz))
	self.v[0] = xx
	self.v[4] = xy
	self.v[8] = xz
	self.v[12] = 0
	self.v[1] = yx
	self.v[5] = yy
	self.v[9] = yz
	self.v[13] =0
	self.v[2] = zx
	self.v[6] = zy
	self.v[10] = zz
	self.v[14] = 0
	self.v[3] = 0
	self.v[7] = 0
	self.v[11] = 0
	self.v[15] = 1
end
function GLMatrix4x4:rotate(degrees,x,y,z)
	local r = math.rad(degrees)
	local l = math.sqrt(x*x + y*y + z*z)
	if l < 1e-20 then
		x=1
		y=0
		z=0
	else
		local il = 1/l
		x=x*il
		y=y*il
		z=z*il
	end
	local c = math.cos(r)
	local s = math.sin(r)
	local ic = 1 - c
	self.v[0] = c + x*x*ic
	self.v[4] = x*y*ic - z*s
	self.v[8] = x*z*ic + y*s
	self.v[12] = 0
	self.v[1] = x*y*ic + z*s
	self.v[5] = c + y*y*ic
	self.v[9] = y*z*ic - x*s
	self.v[13] = 0
	self.v[2] = x*z*ic - y*s
	self.v[6] = y*z*ic + x*s
	self.v[10] = c + z*z*ic
	self.v[14] = 0
	self.v[3] = 0
	self.v[7] = 0
	self.v[11] = 0
	self.v[15] = 1
end
function GLMatrix4x4:scale(x,y,z)
	self.v[0] = x
	self.v[1] = 0
	self.v[2] = 0
	self.v[3] = 0
	self.v[4] = 0
	self.v[5] = y
	self.v[6] = 0
	self.v[7] = 0
	self.v[8] = 0
	self.v[9] = 0
	self.v[10] = z
	self.v[11] = 0
	self.v[12] = 0
	self.v[13] = 0
	self.v[14] = 0
	self.v[15] = 1
end
function GLMatrix4x4:translate(x,y,z)
	self.v[0] = 1
	self.v[4] = 0
	self.v[8] = 0
	self.v[12] = x
	self.v[1] = 0
	self.v[5] = 1
	self.v[9] = 0
	self.v[13] = y
	self.v[2] = 0
	self.v[6] = 0
	self.v[10] = 1
	self.v[14] = z
	self.v[3] = 0
	self.v[7] = 0
	self.v[11] = 0
	self.v[15] = 1
end
function GLMatrix4x4:translateMultScale(x,y,z,sx,sy,sz)
	self.v[0] = sx
	self.v[4] = 0
	self.v[8] = 0
	self.v[12] = x
	self.v[1] = 0
	self.v[5] = sy
	self.v[9] = 0
	self.v[13] = y
	self.v[2] = 0
	self.v[6] = 0
	self.v[10] = sz
	self.v[14] = z
	self.v[3] = 0
	self.v[7] = 0
	self.v[11] = 0
	self.v[15] = 1
end


-- cannot work inplace
function GLMatrix4x4:mult(a,b)
	for i=0,3 do
		for j=0,3 do
			local s = 0
			for k=0,3 do
				s = s + a.v[i+4*k] * b.v[k+4*j]
			end
			self.v[i+4*j] = s
		end
	end
end

ident = GLMatrix4x4()

return GLMatrix4x4

