
module(..., package.seeall);

local oldostime = os.time;

function safeostime(t)
	return oldostime(t) or 0;
end;

os.time = safeostime;
local oldosdate = os.date;
function safeosdate(s, t)
	if s == "*t" then
		return oldosdate(s, t) or {
			month = 12,
			day = 12,
			hour = 24,
			min = 60,
			sec = 3600
		};
	else
		return oldosdate(s, t);
	end;
end;

os.date = safeosdate;
local rawcoresume = coroutine.resume;
coroutine.resume = function(...)
	local arg = {
		...
	};
	function wrapper(co, ...)
		local arg = {
			...
		};
			if _G.COROUTINE_ERROR_RESTART then
				rtos.restart();
			end;
		end;
		return unpack(arg);
	end;
	return wrapper(arg[1], rawcoresume(...));
end;

os.clockms = function()
	return rtos.tick() / 16;
end;

if json and json.decode then
	oldjsondecode = json.decode;
end;

local function safeJsonDecode(s)
	local result, info = pcall(oldjsondecode, s);
	if result then
		return info, true;
	else
		return {}, false, info;
	end;
end;

if json and json.decode then
	json.decode = safeJsonDecode;
end;


