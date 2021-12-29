cd c:\Users\traid_000\Desktop\emulators\asw\Sources
c:\Users\traid_000\Desktop\emulators\asw\bin\asw.exe am0.asm -cpu TMS9900 -L -olist am0Listing.txt -D BuildT99 -o am0.bld
c:\Users\traid_000\Desktop\emulators\asw\bin\p2bin.exe am0.bld am0C.bin

pause

c:\Users\traid_000\Desktop\emulators\asw\bin\asw.exe am1.asm -cpu TMS9900 -L -olist am1Listing.txt -D BuildT99 -o am1.bld
c:\Users\traid_000\Desktop\emulators\asw\bin\p2bin.exe am1.bld am1C.bin

pause

c:\Users\traid_000\Desktop\emulators\asw\bin\asw.exe am2.asm -cpu TMS9900 -L -olist am2Listing.txt -D BuildT99 -o am2.bld
c:\Users\traid_000\Desktop\emulators\asw\bin\p2bin.exe am2.bld am2C.bin

pause

copy /B am0C.bin + am1C.bin + am2C.bin  amC.bin 

copy amC.bin C:\Users\traid_000\Desktop\Emulators\classic99\classic99\amC.bin

cd C:\Users\traid_000\Desktop\Emulators\classic99\classic99\

C:\Users\traid_000\Desktop\Emulators\classic99\classic99\classic99.exe -rom amC.bin

cd c:\Users\traid_000\Desktop\emulators\asw\Sources
