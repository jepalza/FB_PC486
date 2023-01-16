

' raton serie
Static Shared As Integer oldb=0
Sub mouse_serial_poll(x As Integer , y As Integer , b As Integer ) 
        Dim As Ubyte  mousedat(3) =Any
       
        
        If (serial.ier And 1)=0 Then Return 
        If (x=0) And (y=0) And (b=oldb) Then Return 
        

        
        oldb=b 
        If (x>127) Then x=127 
        If (y>127) Then y=127 
        If (x<-128) Then x=-128 
        If (y<-128) Then y=-128 
        
        /'Use Microsoft Format'/
        mousedat(0) = &h40 
        mousedat(0) = mousedat(0) Or (((y Shr 6) And 3) Shl 2) 
        mousedat(0) = mousedat(0) Or  ((x Shr 6) And 3) 
        
        If (b And 1) Then mousedat(0) = mousedat(0) Or &h20 
        If (b And 2) Then mousedat(0) = mousedat(0) Or &h10 
        
        mousedat(1)=x And &h3F 
        mousedat(2)=y And &h3F 
        
        If (serial.mctrl And &h10)=0 Then 
                serial_write_fifo(mousedat(0)) 
                serial_write_fifo(mousedat(1)) 
                serial_write_fifo(mousedat(2)) 
        EndIf
        
                'Locate 31,30:Print "mouse:";x,y,b
End Sub



Sub mouse_serial_rcr() 
        mousepos=-1 
        mousedelay=1000
End Sub


Static Shared As Integer pollmouse_delay = 2
Sub mouse_poll()
        Dim As Integer x=Any,y=Any,mouse_b=Any, relx=Any, rely=Any,xx=Any,yy=Any
        Static As Integer oldx=Any,oldy=Any
        
        pollmouse_delay-=1
        If (pollmouse_delay) Then Return
        pollmouse_delay = 2
        
        'poll_mouse()
        'get_mouse_mickeys(x,y)
        Getmouse (x,y,,mouse_b)
      
		' si se sale de la ventana   
		If x=-1 Or y=-1 Then
			x=oldx
			y=oldy
			xx=0
			yy=0
		EndIf
		If x<>oldx Or y<>oldy Then
			relx=oldx-x
			rely=oldy-y
			xx=-relx
			yy=-rely
			
			oldx=x
			oldy=y
		Else
			xx=0
			yy=0
		EndIf
	
        'If (mouse_poll) Then
        mouse_serial_poll(xx, yy, mouse_b)
        'If (mousecapture) thenposition_mouse(64,64)

End Sub

Sub mousecallback() 
        If (mousepos = -1) Then 
             mousepos = 0 
             serial_fifo_read = 0
             serial_fifo_write = 0 
             serial.linestat  = serial.linestat  And  inv(1)
             serial_write_fifo(Asc("M")) 
        Elseif (serial_fifo_read <> serial_fifo_write) Then
				 serial.iir=4 
             serial.linestat = serial.linestat Or 1 
             If (serial.mctrl And 8) Then picint(&h10) 
        EndIf
End Sub
