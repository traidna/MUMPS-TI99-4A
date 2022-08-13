cd c:\Users\traid_000\Desktop\emulators\asw\Sources
c:\Users\traid_000\Desktop\emulators\asw\bin\asw.exe Minimal.asm -cpu TMS9900 -L -olist Listint.txt -D BuildT99 -o minimal.bld
c:\Users\traid_000\Desktop\emulators\asw\bin\p2bin.exe minimal.bld minC.bin

C:\Users\traid_000\Desktop\Emulators\classic99\classic99\classic99.exe -rom minC.bin
