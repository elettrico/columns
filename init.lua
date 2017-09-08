
local safe_region, check_region, reset_pending, area_protection = dofile(minetest.get_modpath("worldedit_commands") .. "/safe.lua")

local function get_position(name) --position 1 retrieval function for when not using `safe_region`
        local pos1 = worldedit.pos1[name]
        if pos1 == nil then 
                worldedit.player_notify(name, "no position 1 selected")
        end
        return pos1 
end

local function get_node(name, nodename)
        local node = worldedit.normalize_nodename(nodename)
        if not node then 
                worldedit.player_notify(name, "invalid node name: " .. nodename)
                return nil
        end
        return node 
end

local check_column = function(name, param)
	if worldedit.pos1[name] == nil then
		worldedit.player_notify(name, "no position 1 selected")
		return nil
	end
	local found, _, axis, length, radius, length_end, radius_end, nodename = param:find("^([xyz%?])%s+([+-]?%d+)%s+(%d+)%s+([+-]?%d+)%s+(%d+)%s+(.+)$")
	if found == nil then
		worldedit.player_notify(name, "invalid usage: " .. param)
		return nil
	end
	length = tonumber(length + length_end)
	if axis == "?" then
		local sign
		axis, sign = worldedit.player_axis(name)
		length = length * sign
	end
	local pos1 = worldedit.pos1[name]
	local current_pos = {x=pos1.x, y=pos1.y, z=pos1.z}
	if length < 0 then
		length = -length
		current_pos[axis] = current_pos[axis] - length
	end
	local other1, other2 = worldedit.get_axis_others(axis)
	local interact_pos1 = {
		x = current_pos.x,
		y = current_pos.y,
		z = current_pos.z,
	}
	local interact_pos2 = {
		x = current_pos.x,
		y = current_pos.y,
		z = current_pos.z,
	}
	interact_pos1[other1] = interact_pos1[other1] - radius
	interact_pos1[other2] = interact_pos1[other2] - radius
	interact_pos2[other1] = interact_pos2[other1] + radius
	interact_pos2[other2] = interact_pos2[other2] + radius
	interact_pos2[axis] = interact_pos2[axis] + length
	local allowed = area_protection:interaction_allowed(
		"cylinder",
		interact_pos1,
		interact_pos2,
		name
	)
	if not allowed then
		return nil
	end
	local node = get_node(name, nodename)
	if not node then return nil end
	return math.ceil(math.pi * (tonumber(radius) ^ 2) * tonumber(length))
end

function column(pos, axis, length, radius, length_end, radius_end, node) 

    local mul = 1
    if (length < 0) then 
        mul = -1 
    end

    local col_body_pos = {x=pos.x, y=pos.y, z=pos.z}
    local col_end_start = {x=pos.x, y=pos.y, z=pos.z}
    local col_end_end = {x=pos.x, y=pos.y, z=pos.z}


    if axis == "x" then
        col_end_start.x = col_end_start.x + length
        col_end_end.x = col_end_end.x + length + length_end
    elseif axis == "y" then
        col_end_start.y = col_end_start.y + length
        col_end_end.y = col_end_end.y + length + length_end
    elseif axis == "z" then
        col_end_start.z = col_end_start.z + length
        col_end_end.z = col_end_end.z + length + length_end
    end

    local count = worldedit.cylinder(col_body_pos, axis, length, tonumber(radius), node)
    local cnt = 0
    local r = 0
    local x = radius_end - radius
    local y = length_end 
    local p = ( x / (y*y) )
    print("*** dati ",x,y,p)
    local current_pos = col_end_start
    while (cnt <= length_end) do
	--r = radius + math.ceil( math.sqrt(4 * p * cnt) )
	r = radius + math.ceil( p * cnt * cnt)
	--print("*** worldedit.cylinder(", col_end_start.y, axis, 1, r, node,")")
	count = count + worldedit.cylinder(col_end_start, axis, 1, r, node)
        if axis == "x" then
            current_pos.x = current_pos.x + mul
        elseif axis == "y" then
            current_pos.y = current_pos.y + mul
        elseif axis == "z" then
            current_pos.z = current_pos.z + mul
        end
	cnt = cnt + 1
    end

    return count
end

minetest.register_chatcommand("/column", {
	params = "x/y/z/? <length> <radius> <length_end> <radius_end> <node>",
	description = "Add a column at WorldEdit position 1 along the x/y/z/? axis with length <length> and radius <radius>, enlarging to <radius_end> at the end for <length_end>, composed of <node>",
	privs = {worldedit=true},
	func = safe_region(function(name, param)
		local found, _, axis, length, radius, length_end, radius_end, nodename = param:find("^([xyz%?])%s+([+-]?%d+)%s+(%d+)%s+([+-]?%d+)%s+(%d+)%s+(.+)$")
		length = tonumber(length)
		length_end = tonumber(length_end)
		if axis == "?" then
			axis, sign = worldedit.player_axis(name)
			length = length * sign
			length_end = length_end * sign
		end
                
                local node = get_node(name, nodename)
                local pos = worldedit.pos1[name]
                count = column(pos, axis, length, radius, length_end, radius_end, node)

		worldedit.player_notify(name, count .. " nodes added")
	end, check_column),
})


minetest.register_chatcommand("/multicolumn", {
	params = "x/y/z/? <length> <radius> <length_end> <radius_end> <repeat-1> <repeat-2> <offset> <node>",
	description = "Add columns at WorldEdit position 1 along the x/y/z/? axis with length <length> and radius <radius>, enlarging to <radius_end> at the end for <length_end>, composed of <node>. The column is repeated <repeat-1> and <repeat-2> times over: z and y if the axis is x, x and z if the axis is y, x and y if the axis is z",
	privs = {worldedit=true},
	--func = safe_region(function(name, param)
	func = function(name, param)
		local found, _, axis, length, radius, length_end, radius_end, repeat1, repeat2, offset, nodename = param:find("^([xyz%?])%s+([+-]?%d+)%s+(%d+)%s+([+-]?%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(.+)$")
	        if found == nil then
		    worldedit.player_notify(name, "invalid usage: " .. param)
		    return nil
	        end
		length = tonumber(length)
		length_end = tonumber(length_end)
		repeat1 = tonumber(repeat1)
		repeat2 = tonumber(repeat2)
		if axis == "?" then
			axis, sign = worldedit.player_axis(name)
			length = length * sign
			length_end = length_end * sign
		end
                
                local node = get_node(name, nodename)
                local repeat_x = 1;
                local repeat_y = 1;
                local repeat_z = 1;

                if axis == "x" then
                    repeat_z = repeat1
                    repeat_y = repeat2
                elseif axis == "y" then
                    repeat_x = repeat1
                    repeat_z = repeat2
                elseif axis == "z" then
                    repeat_x = repeat1
                    repeat_y = repeat2
                end

                local pos = worldedit.pos1[name]

                for yy=0, repeat_y-1, 1 do
                    for xx=0, repeat_x-1, 1 do
                        for zz=0, repeat_z-1, 1 do
                            current_pos = { x=pos.x+offset*xx, y=pos.y+offset*yy, z=pos.z+offset*zz }
                            print("*** column "..yy.." "..xx.." "..zz.." : ",current_pos.x.." "..current_pos.y.."  "..current_pos.z, axis, length, radius, length_end, radius_end)
                            count = column(current_pos, axis, length, radius, length_end, radius_end, node)
                        end
                    end
                end

		worldedit.player_notify(name, count .. " nodes added")
	--end, check_column),
	end,
})

