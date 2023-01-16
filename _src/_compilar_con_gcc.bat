rem  -fpmode fast|precise  	Select floating-point math accuracy/speed
rem  -fpu x87|sse     		Set target FPU
rem  -gen gas|gcc|llvm  	Select code generation backend
rem  -O <value>       		Optimization level (default: 0)
rem  -s console|gui   		Select win32 subsystem
rem  -w all|pedantic|<n>  	Set min warning level: all, pedantic or a value
rem  -Wc <a,b,c>      		Pass options to 'gcc' (-gen gcc) or 'llc' (-gen llvm)

c:\FreeBasic\fbc64  -gen gcc -Wc -Ofast  -s console "80486_emu.bas"
ren 80486_emu.exe 80486_emu64_gcc.exe
move 80486_emu64_gcc.exe ..\
