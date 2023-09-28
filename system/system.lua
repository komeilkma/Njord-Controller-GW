
require("log");
require("utils");
require("i2c-patch");

module(..., package.seeall);
SCRIPT_LIB_VER = "1.0.0";
local TASK_TIMER_ID_MAX = 536870911;
local MSG_TIMER_ID_MAX = 2147483647;
local taskTimerId = 0;
local msgId = TASK_TIMER_ID_MAX;
local timerPool = {};
local taskTimerPool = {};
local para = {};
local loop = {};

function powerOn()
	rtos.poweron(1);
end;


function restart(r)

    assert(r and r ~= "", "sys.restart cause null")
    if errDump and errDump.appendErr and type(errDump.appendErr) == "function" then errDump.appendErr("restart[" .. r .. "];") end
    log.warn("sys.restart", r)
	rtos.restart();
end;

function wait(ms)
	assert(ms > 0, "The wait time cannot be negative!");
	if ms < 5 then
		ms = 5;
	end;
	if taskTimerId >= TASK_TIMER_ID_MAX then
		taskTimerId = 0;
	end;
	taskTimerId = taskTimerId + 1;
	local timerid = taskTimerId;
	taskTimerPool[coroutine.running()] = timerid;
	timerPool[timerid] = coroutine.running();
	if 1 ~= rtos.timer_start(timerid, ms) then
		log.debug("rtos.timer_start error");
		return;
	end;
	local message = {
		coroutine.yield()
	};
	if #message ~= 0 then
		rtos.timer_stop(timerid);
		taskTimerPool[coroutine.running()] = nil;
		timerPool[timerid] = nil;
		return unpack(message);
	end;
end;

function waitUntil(id, ms)
	subscribe(id, coroutine.running());
	local message = ms and {
		wait(ms)
	} or {
		coroutine.yield()
	};
	unsubscribe(id, coroutine.running());
	return message[1] ~= nil, unpack(message, 2, #message);
end;


function waitUntilExt(id, ms)
	subscribe(id, coroutine.running());
	local message = ms and {
		wait(ms)
	} or {
		coroutine.yield()
	};
	unsubscribe(id, coroutine.running());
	if message[1] ~= nil then
		return unpack(message);
	end;
	return false;
end;

function taskInit(fun, ...)
	local co = coroutine.create(fun);
	coroutine.resume(co, ...);
	return co;
end;