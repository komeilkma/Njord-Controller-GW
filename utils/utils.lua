module(..., package.seeall);
function string.toHex(str, separator)
	return str:gsub(".", function(c)
		return string.format("%02X" .. (separator or ""), string.byte(c));
	end);
end;

function string.fromHex(hex)
	local hex = (hex:gsub("[%s%p]", "")):upper();
	return hex:gsub("%x%x", function(c)
		return string.char(tonumber(c, 16));
	end);
end;

function string.toValue(str)
	return string.fromHex(str:gsub("%x", "0%1"));
end;

function string.utf8Len(str)
	local _, count = string.gsub(str, "[^\128-\193]", "");
	return count;
end;

function string.utf8ToTable(str)
	local tab = {};
	for uchar in string.gfind(str, "[%z\001-\127\194-\244][\128-\191]*") do
		tab[(#tab) + 1] = uchar;
	end;
	return tab;
end;

function string.rawurlEncode(str)
	local t = str:utf8ToTable();
	for i = 1, #t do
		if #t[i] == 1 then
			t[i] = string.gsub(string.gsub(t[i], "([^%w_%~%.%- ])", function(c)
				return string.format("%%%02X", string.byte(c));
			end), " ", "%%20");
		else
			t[i] = string.gsub(t[i], ".", function(c)
				return string.format("%%%02X", string.byte(c));
			end);
		end;
	end;
	return table.concat(t);
end;

function string.urlEncode(str)
	local t = str:utf8ToTable();
	for i = 1, #t do
		if #t[i] == 1 then
			t[i] = string.gsub(string.gsub(t[i], "([^%w_%*%.%- ])", function(c)
				return string.format("%%%02X", string.byte(c));
			end), " ", "+");
		else
			t[i] = string.gsub(t[i], ".", function(c)
				return string.format("%%%02X", string.byte(c));
			end);
		end;
	end;
	return table.concat(t);
end;

function table.gsort(t, f)
	local a = {};
	for n in pairs(t) do
		a[(#a) + 1] = n;
	end;
	table.sort(a, f);
	local i = 0;
	return function()
		i = i + 1;
		return a[i], t[a[i]];
	end;
end;

function table.rconcat(l)
	if type(l) ~= "table" then
		return l;
	end;
	local res = {};
	for i = 1, #l do
		res[i] = table.rconcat(l[i]);
	end;
	return table.concat(res);
end;

function string.formatNumberThousands(num)
	local k, formatted;
	formatted = tostring(tonumber(num));
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2");
		if k == 0 then
			break;
		end;
	end;
	return formatted;
end;


