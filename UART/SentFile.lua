
module(...,package.seeall)
require"utils"
require"i2c-patch"

local uartID = --UART ID : 1 

sys.taskInit(
    function()                
        local fileHandle = io.open("/files/test_uart_file.bin","rb")
        if not fileHandle then
            log.error("test open file error")
            return
        end
        
        pm.wake("UART_SENT2MCU")
        uart.on(uartID,"sent",function() sys.publish("UART_SENT2MCU_OK") end)
        uart.setup(uartID,115200,8,uart.PAR_NONE,uart.STOP_1,nil,1)
        while true do
            local data = fileHandle:read(1460)
            if not data then break end
            uart.write(uartID,data)
            sys.waitUntil("UART_SENT2MCU_OK")
        end
        
        uart.close(uartID)
        pm.sleep("UART_SENT2MCU")
        fileHandle:close()
    end
)
