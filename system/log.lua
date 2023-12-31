module(..., package.seeall);
LOG_SILENT = 0;
LOGLEVEL_TRACE = 1;
LOGLEVEL_DEBUG = 2;
LOGLEVEL_INFO = 3;
LOGLEVEL_WARN = 4;
LOGLEVEL_ERROR = 5;
LOGLEVEL_FATAL = 6;
local LEVEL_TAG = {
	"T",
	"D",
	"I",
	"W",
	"E",
	"F"
};
local PREFIX_FMT = "[%s]-[%s]";
local function _log(level, tag, ...)
	local OPENLEVEL = LOG_LEVEL and LOG_LEVEL or LOGLEVEL_INFO;
	if OPENLEVEL == LOG_SILENT or OPENLEVEL > level then
		return;
	end;
	local prefix = string.format(PREFIX_FMT, LEVEL_TAG[level], type(tag) == "string" and tag or "");
	print(prefix, ...);
end;
function trace(tag, ...)
	_log(LOGLEVEL_TRACE, tag, ...);
end;
function debug(tag, ...)
	_log(LOGLEVEL_DEBUG, tag, ...);
end;
function info(tag, ...)
	_log(LOGLEVEL_INFO, tag, ...);
end;
function warn(tag, ...)
	_log(LOGLEVEL_WARN, tag, ...);
end;
function error(tag, ...)
	_log(LOGLEVEL_ERROR, tag, ...);
end;
function fatal(tag, ...)
	_log(LOGLEVEL_FATAL, tag, ...);
end;
function openTrace(v, uartid, baudrate)
	if uartid then
		if v then
			uart.setup(uartid, baudrate or 115200, 8, uart.PAR_NONE, uart.STOP_1);
		else
			uart.close(uartid);
		end;
	end;
	rtos.set_trace(v and 1 or 0, uartid);
end;
