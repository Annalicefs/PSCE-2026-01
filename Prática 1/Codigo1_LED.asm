org 0h       
	main:
    	mov p1, #00h  
    	acall delay   
    	mov p1, #0ffh 
    	acall delay    
    	sjmp main      
	delay:
    	mov R0, #0ffh
	d1:
    	mov R1, #0ffh  
	d2:
    	djnz R1, d2    
    	djnz R0, d1   
    	ret            
end