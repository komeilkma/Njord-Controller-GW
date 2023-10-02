require("hibernation");

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
		if not arg[1] then
			local traceBack = debug.traceback(co) or "empty";
			traceBack = traceBack and traceBack ~= "" and (arg[2] or "") .. "\r\n" .. traceBack or (arg[2] or "");
			log.error("coroutine.resume", traceBack);
			if errDump and type(errDump.appendErr) == "function" then
				errDump.appendErr(traceBack);
			end;
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

local oldUartWrite = uart.write;
uart.write = function(...)
	pm.wake("lib.patch.uart.write");
	local result = oldUartWrite(...);
	pm.sleep("lib.patch.uart.write");
	return result;
end;

if i2c and i2c.write then
	local oldI2cWrite = i2c.write;
	i2c.write = function(...)
		pm.wake("lib.patch.i2c.write");
		local result = oldI2cWrite(...);
		pm.sleep("lib.patch.i2c.write");
		return result;
	end;
end;

if i2c and i2c.send then
	local oldI2cSend = i2c.send;
	i2c.send = function(...)
		pm.wake("lib.patch.i2c.send");
		local result = oldI2cSend(...);
		pm.sleep("lib.patch.i2c.send");
		return result;
	end;
end;

if spi and spi.send then
	oldSpiSend = spi.send;
	spi.send = function(...)
		pm.wake("lib.patch.spi.send");
		local result = oldSpiSend(...);
		pm.sleep("lib.patch.spi.send");
		return result;
	end;
end;

if spi and spi.send_recv then
	oldSpiSendRecv = spi.send_recv;
	spi.send_recv = function(...)
		pm.wake("lib.patch.spi.send_recv");
		local result = oldSpiSendRecv(...);
		pm.sleep("lib.patch.spi.send_recv");
		return result;
	end;
end;

if disp and disp.sleep then
	oldDispSleep = disp.sleep;
	disp.sleep = function(...)
		pm.wake("lib.patch.disp.sleep");
		oldDispSleep(...);
		pm.sleep("lib.patch.disp.sleep");
	end;
end;

if io and io.mount then
	oldIoMount = io.mount;
	io.mount = function(...)
		pm.wake("lib.patch.io.mount");
		local result = oldIoMount(...);
		pm.sleep("lib.patch.io.mount");
		return result;
	end;
end;

local pmdInited;
if pmd and pmd.init then
	oldPmdInit = pmd.init;
	pmd.init = function(...)
		if not pmdInited then
			pmdInited = true;
		end;
		local result = oldPmdInit(...);
		return result;
	end;
end;

pmd.libScriptInit = function()
	if not pmdInited then
		pmd.init({});
	end;
end;


