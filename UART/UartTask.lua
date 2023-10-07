
module(...,package.seeall)

require"utils"
require"i2c-patch"
local UART_ID = --UART ID : 1 


local function taskRead()
    local cacheData,frameCnt = "",0
    while true do
        local s = uart.read(UART_ID,"*l")
        if s == "" then            
            if not sys.waitUntil("UART_RECEIVE",100) then
                if cacheData:len()>0 then
                    log.info("UartTask.taskRead","100ms no data, received length",cacheData:len())
                    log.info("UartTask.taskRead","received data",cacheData:sub(1,1024))
                    cacheData = ""
                    frameCnt = frameCnt+1
                    write("received "..frameCnt.." frame")
                end
            end
        else
            cacheData = cacheData..s            
        end
    end
end

function write(s)
    log.info("UartTask.write",s)
    uart.write(UART_ID,s.."\r\n")
end

local function writeOk()
    log.info("UartTask.writeOk")
end

pm.wake("UartTask")
uart.on(UART_ID,"sent",writeOk)
uart.on(UART_ID,"receive",function() sys.publish("UART_RECEIVE") end)
uart.setup(UART_ID,115200,8,uart.PAR_NONE,uart.STOP_1)
sys.taskInit(taskRead)
