' EMULADOR 80486 DX2-66 CON TSENG LABS SVGA , POR JOSEBA EPALZA 2019 (JEPALZA @ GMAIL dot COM)
' EMPLEANDO CODIGO FUENTE "PCEM VERSION 8" ( https://pcem-emulator.co.uk/ )

' pantalla grafica
ScreenRes 800,600,32,2
ScreenSet 1,0
Static Shared As any Ptr scrbuffer 
Static Shared As ulong Ptr pixel
scrbuffer = ScreenPtr()


' para el MULTIKEY
#include "fbgfx.bi"
#if __FB_LANG__ = "fb"
Using FB 
#EndIf

 ' necesario para detectar las teclas ALT que el KEYEVENT no detecta
#Include "windows.bi"

' variables para depurar solo
static shared As integer mitemp
Static shared As Integer deb=0
static shared As Integer skipnextprint

' salida a consola
Open cons For Output As 5

' depuracion
declare sub printdebug()



' variables y declaraciones
#Include "INC\ibm.bi"



''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' RAM 
Const RAM_SIZE  =16 ' megas
Const RAM_TOTAL =((RAM_SIZE*1024*1024)-1) ' el total de ram segun RAM_SIZE, empezando en 0, para que acabe en XFFFF
' VRAM
Const VRAM_SIZE  =2 ' megas
Const VRAM_TOTAL =((VRAM_SIZE*1024*1024)-1)


' memoria
static shared As UByte rambuf(0 To RAM_TOTAL) 
static shared As UByte rombuf(0 To &h1FFFF) 
static shared As UByte vrambuf(0 To VRAM_TOTAL) 
static shared As UByte vrombuf(0 To &h7FFF) 

'For f As integer=0 To RAM_TOTAL:rambuf(f)=255:Next

'static shared As UByte rambiosbuf(&h10000) ' inventado por mi
' 
ram=@rambuf(0)
rom=@rombuf(0)
vram=@vrambuf(0)
vrom=@vrombuf(0)
'rambios=@rambiosbuf(0) ' inventado por mi

' cache
static shared As ULong readlookup2buf (0 To (1024*1024)-1)
static shared As ULong writelookup2buf(0 To (1024*1024)-1)
static shared As UByte cachelookup2buf(0 To (1024*1024)-1) 

readlookup2 =@readlookup2buf(0)
writelookup2=@writelookup2buf(0)
cachelookup2=@cachelookup2buf(0)

' marcamos zonas RAM utilizables (menos VRAM), y descartamos ROMS
Dim As Integer f=0
for f=0 To (RAM_SIZE*16)-1
       isram(f)=1
       if (f >= &ha and f<=&hF) Then isram(f)=0 ' entre a0000 y f0000 NO es ram
       ' por ejemplo A0000 es la VRAM, entre E y F es BIOS, la C es VROM
Next
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''






#Include "MODULOS\IDE.bas"
#Include "MODULOS\Keyb.bas"
#Include "MODULOS\serial.bas"
#Include "MODULOS\Mouse.bas"
'
#Include "VIDEO\Video.bas"
#Include "VIDEO\EGA.bas"
#Include "VIDEO\vid_svga.bas"
#Include "VIDEO\vid_et4000.bas"
'
#Include "MODULOS\i8259_pic.bas"
#Include "MODULOS\i8253_pit.bas"
#Include "MODULOS\ali1429.bas"
#Include "MODULOS\mem.bas"
#Include "MODULOS\DMA.bas"
#Include "MODULOS\keyboard_at.bas"

#Include "CPU\x86seg.bas"
#Include "CPU\x86.bas"
#Include "CPU\x87.bas"

#Include "MODULOS\IO.bas"

#Include "CPU\386a.bas" ' este incluye a su vez el B y el C

#Include "Depuracion\Debug.bas"


' esto es solo para mostrar las INS al depurar en la rutina PRINTDEBUG
initoplist()

' ----------------- DEPURACION ---------------------
DEB=0 ' 1=normal sin pausa, 2=normal CON pausa, 3= solo textos del emulador







''''''''''''''''''''''''''''''''''''''''''''''''  BIOS ''''''''''''''''''''''''''''''''''''''''''''''''''''

'''''''''''''''''
' por ahora, la config mas chula es la de 16mb de RAM, 2mb VRAM, bios ALI1429 y TSENG ET4K_W32 
'''''''''''''''''

' VGA ( usar "ET4K_W32" para mi programa de CAD )
loadbinary &h0000, "VIDEO\ET4K_W32.bin", vrom ' con 1mb de VRAM : esta permite llegar a 800x600 16 colores en el DP

' AMIBIOS
init_PC("ami486")
loadbinary &h0000, "bios\ami486.bin", rom  'con esta BIOS, se ve como inicia el PC antes del test de RAM

'init_PC("ali1429g") 
'loadbinary &h0000, "BIOS\ali1429g.bin", rom  ' con esta BIOS no se ve iniciar, pasa directo a test de RAM

'loadbinary &h0000, "bios\test.bin", rom 



''''''''''''''''''''''''''''''''''''''''''''''   DISCO DURO (HD) '''''''''''''''''''''''''''''''''''''''''
	' coge el disco duro deseado, desde el fichero externo
	Dim As String HDD=""
	Dim As integer CIL=0
	Dim As Integer SEC=0
	Dim As Integer HDS=0
	Open "HDD.TXT" For Input As 11
		While Not Eof(11) 
			Input #11,HDD
			Input #11,CIL
			Input #11,SEC
			Input #11,HDS
			If Left(HDD,1)<>"#" Then Exit While Else HDD=""
		Wend
	Close 11
	If HDD="" Then 
		Print #5,"Falta el fichero con los discos duros 'HDD.TXT'"
		Print #5,"con lineas como 'HDD\msdos622.img,512,63,16'"
		Print #5,"solo uno activo, el resto con # delante para ocultarlo"
		Sleep:end
	EndIf

	'HDD="HDD\msdos622.img" ' disco 512 cilindros,63 sectores, 16 cabezas, 256 mb
	'HDD="HDD\MEMORIA_EMS.img"   ' disco 1580 cilindros,63 sectores, 16 cabezas, 800 mb
	'HDD="HDD\minix.img" ' el 1255 es desconocido, pero con este funciona
	
	loadhd(HDD,CIL,SEC,HDS)  
	Print #5,"Usando disco virtual: ";HDD;"    Con ";CIL;" Cilindros, ";SEC;" Sectores y ";HDS;" Cabezas"
	Print #5,""
' ------------------------------------------------------------------------------------------------------



' DISCO FLEXIBLE , no funciona bien, eliminado por el momento.
'loaddisc("FDC\msdos622.IMA",0)




Print #5,"Teclas especiales:"
Print #5,"<F10> Captura o Devuelve el Raton a nuestra ventana"
Print #5,"<F11> Sale del emulador guardando datos de memoria."
Print #5,"<F12> Modo depuracion"
Print #5,"Si salimos picando la 'X' de la ventana de comandos, sale sin guardar"
Print #5,""



''''''''''''''''''''''''''''''''''
''''''''' PRINCIPAL ''''''''''''''
''''''''''''''''''''''''''''''''''

Open "_salida.txt" For Output As 1


If hasfpu=0 Then Print #5,"SIN FPU !!!!"
If IDE_GRABA=1 Then Print #5,"ATENCION!!! IDE permite grabar en el DISCO DURO VIRTUAL ....."

Dim fps As Double

cpu_exec = CPUCLOCK\100

Var ratoncapturado=1
While 1
	
 'fps=Timer
 
 exec386(cpu_exec)


  ' capturar o devolver el raton de windows a nuestra ventana
  If MultiKey(SC_F10) Then 
  	If ratoncapturado=0 Then 
  		ratoncapturado=1
  		SetMouse ,,0,1 ' captura el raton
  		Sleep 300,1
  	Else
  		ratoncapturado=0
  		SetMouse ,,1,0 ' devuelve el raton
  		Sleep 300,1
  	EndIf
  EndIf
  
  If MultiKey(SC_F11) Then GoTo ya ' F11 para salir
  If MultiKey(SC_F12) Then deb=2

	'tiempo_teclado=Timer
	f=leeteclado()
   mouse_poll()
   
   'Print #5,Int((Timer-fps)*100);

Wend

' si pulsamos ESC salimos "sin mas"
Close 1
end

' si pulsamos F11 salimos aqui, y se permite guardar datos de memoria
ya:
Close 1





''''''''''''''''''''''''''''''''''''''  final con salida de datos opcional '''''''''''''''''''''''''''''''''
' depuracion, salida de datos
	Print #5,""
	Print #5, "Guardando datos de memoria. Paciencia, que son muchos!!!"
	Print #5,""
	Print #5," Guardando RAM (16mb)"
	Dim g As Integer
	Dim sd As String
	Open "salida_ram_16mb.bin" For Binary Access write As 1
	For f=0 To RAM_TOTAL Step 256
	   For g=0 To 255:sd=sd+Chr(ram[f+g]):Next
		Put #1, f+1, sd'Chr(ram[f])
		sd=""
	Next
	Close 1
	Print #5," Guardando 2mb VRAM 'A0000' 800x600"
	Open "salida_vram_800x600.bin" For Binary Access write As 1
	sd=""
	For f=0 To VRAM_TOTAL Step 256
	   For g=0 To 255:sd=sd+Chr(vram[f+g]):Next
		Put #1, f+1, sd'Chr(vram[f])
		sd=""
	Next
	Close 1
	Print #5," Guardando 'B0000'"
	Open "salida_B0000-C0000.bin" For Binary Access write As 1
	sd=""
	For f=0 To 131071 Step 256 'RAM_TOTAL-1
	   For g=0 To 255:sd=sd+Chr(ram[f+g+&HB0000]):Next
		Put #1, f+1, sd 'Chr(ram[f+&HB0000])
		sd=""
	Next
	Close 1