# This program represents a simple banking application
# The program should allow to make the following operations
# a) opening an account b) finding out the balance, c) making a deposit
# d) making a withdrawal, e) transferring between accounts f) taking a loan 
# closing an account and h) displaying query history.
# The program should terminate when QUIT is entered by the user. 


.data

bank_array: .word 0, 0, 0, 0, 0			# this array holds banking details

# error message for invalid transactions
error_message:	.asciiz "That is an invalid banking transaction. Please enter a valid one. \n" 
# you can add more directives here: including additional arrays and variables.
recordarray: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25	

rcb: .asciiz "]\n["

rcb123: .asciiz "\nPROBLEM\n"

dollar: .asciiz "$"
newline: .asciiz "\n"


bracket1:	.asciiz "\n["
bracket2:	.asciiz "]\n"
comma:	.asciiz ","


array_a: .space 3000
array_i: .space 3000
array_n: .word 0, 0, 0, 0, 0	



str2:	.asciiz "\nproblem\n"
space:	.asciiz "\n"

	.text
	.globl main

# you can create a subroutine that converts ASCII to integers.
# you can call this subroutine anytime you need to make a conversion.

main: 

        # main code comes here	
        addi $s0,$zero,0    # s0 is for counting the no. of element in history
system:	la $t6,array_i      # Convert ascii to int n save it in array_i
	
read:	jal Read	   #star readint user input
	add $a1,$v0,$zero
	addi $t2,$a1,-48
			
	sb $t2,0($t6)  # Storing data in array
			
	beq $a1,10,stop  
	
	#jal Write	
	addi $t6,$t6,1
	j read
		
	
stop:    jal checking   # check whether after first two byte; there number and space

         la $t8, array_i
  
        lb $t5,0($t8)   # first two bytes
        lb $t7,1($t8)   #
        
        bne $t5,19,check_s
        beq $t7,24,open
        beq $t7,28,close   
        j invalid
        

check_s:bne $t5,35,check_d   
        beq $t7,38,open
        j invalid
        
check_d: bne $t5,20,check_w
         beq $t7,21,deposit1
         j invalid  
           
check_w: bne $t5,39,check_l
         beq $t7,36,with
         j invalid      
         
check_l: bne $t5,28,check_t 
         beq $t7,30,loan
         j invalid    
         
check_t: bne $t5,36,check_b
        beq $t7,34,transfer1
        j invalid                             

check_b:bne $t5,18,check_q
        beq $t7,28,balance
        j invalid
        
check_q:bne $t5,33,invalid
        beq $t7,24,history1
        beq $t7,36,exit                                         
        
invalid:  li $v0,4
          la $a0,error_message
          syscall 
          j system
                   
       
records: la $t0,recordarray
         addi $t1,$zero,0
         addi $t0,$t0,96
         
forrecord: beq $t1,20,endrecord
           addi $t1,$t1,1
           lw $t7,-20($t0)
           sw $t7,0($t0)
           addi $t0,$t0,-4
           j forrecord

endrecord:  #addi $t0,$t0,-4
            la $t2,bank_array
            lw $t7,16($t2)
            sw $t7,0($t0)        
            lw $t7,12($t2)
            sw $t7,-4($t0)
            lw $t7,8($t2)
            sw $t7,-8($t0)
            lw $t7,4($t2)
            sw $t7,-12($t0)
            lw $t7,0($t2)
            sw $t7,-16($t0)
            
            jr $ra                            
       
       
open: 
      jal get1 # get1 collect acct no. and amount and store it in array_n
  
      jal open_account
        
      jal print   
      jal records 
      addi $s0,$s0,1
      
      j system      
        
deposit1:   jal get1
      
            jal deposit
        
            jal print   
            jal records 
            addi $s0,$s0,1
            j system    
        
with:  jal get1
                 
       jal withdraw
        
       jal print   
       jal records
       addi $s0,$s0,1
       j system        	

loan:  jal get2  # get2 collect amount and store it in array_n
        
       jal get_loan
           
       jal print   
       jal records
       addi $s0,$s0,1 
       j system       
       
transfer1: 
       jal get3  # get2 collect 2 account no. or one and amount, and then store it in array_n
       add $a1,$v0,$zero  # v0 = 1 means 1 acount; and amount v0 = 0 means 2 acct. no and 1 amount
       
       beq $a1,1,tans1
       jal transfer
       j tans2
 
tans1:  jal transferloan
                          
tans2: jal print   
       jal records
       addi $s0,$s0,1 
       j system 
       
close: jal get22
       
       jal close_account
       
       jal print   
       jal records 
       addi $s0,$s0,1
       j system         
	
balance:jal get22
        
        jal get_balance
        j system
        

history1: jal get4

          la $t0,array_n
          lw $t1,0($t0)
          
          addi $t2,$zero,5
          
          blt $s0,$t1,invalid
          blt $t1,1,invalid
          blt $t2,$t1,invalid

          add $a1,$zero,$t1
          jal history 
          j system  
          
              
checking: la $t0,array_i        
          addi $t0,$t0,2
          lb $t1,0($t0)
 
          
          
checkingloop: beq $t1,-38,checkingend
              beq $t1,-16,checkingjump
              blt $t1,0,invalid
	      bgt $t1,9,invalid

checkingjump: addi $t0,$t0,1
              lb $t1,0($t0)
	      j checkingloop		
	      
checkingend:  jr $ra                     
        
        																												
								
Read:  	lui $t0, 0xffff 	# 
Loop1:	lw $t1, 0($t0) 		# 
	andi $t1,$t1,0x0001	# 
	beq $t1,$zero,Loop1	# 
	lw $v0, 4($t0) 		# 	
	jr $ra

#Write:  lui $t0, 0xffff 	# $t0 = 0xffff0000
#Loop2: 	lw $t1, 8($t0) 		# $t1 = value(0xffff0008)
#	andi $t1,$t1,0x0001	# Is Device ready?
#	beq $t1,$zero,Loop2	# No: check again
#	sw $a1, 12($t0) 	# Yes write to device register @ (0xffff000c) 
#	move $v0,$a0	
#	jr $ra

	# main code ends here
exit:	addi $s0,$zero,0
        li $v0,10
	syscall
	
         
          
	
get1: la $t0,array_i
      la $t1,array_n
      addi $t0,$t0,2
      
      lb $t2,0($t0)
      addi $t3,$zero,0
      
forget11: bne $t2,-16,endget11
          addi $t3,$t3,1
          addi $t0,$t0,1
          lb $t2,0($t0)
          j forget11
      		
endget11: blt $t3,1,invalid
          
          addi $t3,$zero,0
          addi $t4,$zero,0
          
forget12: beq $t2,-16,endget12
          addi $t3,$t3,1
          beq $t3,6,invalid
          mul $t4,$t4,10
          add $t4,$t4,$t2
          addi $t0,$t0,1
          lb $t2,0($t0)
          j forget12
          				
endget12: bne $t3,5,invalid
          sw $t4,0($t1)	
          addi $t3,$zero,0
          								
forget13: bne $t2,-16,endget13
          addi $t3,$t3,1
          addi $t0,$t0,1
          lb $t2,0($t0)
          j forget13								
										
endget13: blt $t3,1,invalid         
          
          addi $t3,$zero,0
          addi $t4,$zero,0
           											
														
forget14: beq $t2,-16,endget14	
          beq $t2,-38,endget14
          mul $t4,$t4,10													
	  add $t4,$t4,$t2																	
	  addi $t0,$t0,1
	  lb $t2,0($t0)
	  j forget14
	  																			
endget14:  addi $t5,$zero,10000000
           blt $t5,$t4,invalid
           sw $t4,4($t1)
           jr $ra  
    
                  
get2: la $t0,array_i
      la $t1,array_n
      addi $t0,$t0,2
      
      lb $t2,0($t0)
      addi $t3,$zero,0
                            
forget21: bne $t2,-16,endget21
          addi $t3,$t3,1
          addi $t0,$t0,1
          lb $t2,0($t0)
          j forget21      
          
endget21:  blt $t3,1,invalid
           
           addi $t3,$zero,0
           addi $t4,$zero,0 
           
                                                                               
forget22: beq $t2,-16,endget22
          beq $t2,-38,endget22
          addi $t3,$t3,1
          beq $t3,6,invalid
          mul $t4,$t4,10
          add $t4,$t4,$t2
          addi $t0,$t0,1
          lb $t2,0($t0)
          j forget22
          				
endget22: addi $t5,$zero,10000000
          blt $t5,$t4,invalid
          sw $t4,0($t1)	
          jr $ra 


get22: la $t0,array_i
      la $t1,array_n
      addi $t0,$t0,2
      
      lb $t2,0($t0)
      addi $t3,$zero,0
                            
forget221: bne $t2,-16,endget221
          addi $t3,$t3,1
          addi $t0,$t0,1
          lb $t2,0($t0)
          j forget221      
          
endget221:  blt $t3,1,invalid
           
           addi $t3,$zero,0
           addi $t4,$zero,0 
           
                                                                               
forget222: beq $t2,-16,endget222
          beq $t2,-38,endget222
          addi $t3,$t3,1
          beq $t3,6,invalid
          mul $t4,$t4,10
          add $t4,$t4,$t2
          addi $t0,$t0,1
          lb $t2,0($t0)
          j forget222
          				
endget222: bne $t3,5,invalid
          sw $t4,0($t1)	
          jr $ra 

get3: la $t0,array_i
      la $t1,array_n
      addi $t0,$t0,2
      addi $v0,$zero,0
      
      lb $t2,0($t0)
      addi $t3,$zero,0
      
forget31: bne $t2,-16,endget31
          addi $t3,$t3,1
          addi $t0,$t0,1
          lb $t2,0($t0)
          j forget31
      		
endget31: blt $t3,1,invalid
          
          addi $t3,$zero,0
          addi $t4,$zero,0
          
forget32: beq $t2,-16,endget32
          addi $t3,$t3,1
          beq $t3,6,invalid
          mul $t4,$t4,10
          add $t4,$t4,$t2
          addi $t0,$t0,1
          lb $t2,0($t0)
          j forget32
          				
endget32: bne $t3,5,invalid
          sw $t4,0($t1)	
          addi $t3,$zero,0
          
forget33: bne $t2,-16,endget33
          addi $t3,$t3,1
          addi $t0,$t0,1
          lb $t2,0($t0)
          j forget33          																
										
endget33: blt $t3,1,invalid 

          addi $t3,$zero,0
          addi $t4,$zero,0
          
forget34: beq $t2,-16,endget34
          beq $t2,-38,loantran123
          addi $t3,$t3,1
          beq $t3,6,invalid
          mul $t4,$t4,10
          add $t4,$t4,$t2
          
          addi $t0,$t0,1
          lb $t2,0($t0)
          j forget34
          
loantran123:  sw $t4,4($t1)    
           addi $v0,$zero,1
           jr $ra      
          
endget34: #bne $t3,5,invalid
          sw $t4,4($t1)	
          addi $t3,$zero,0  
                 
forget35: beq $t2,-38,loantran123
          bne $t2,-16,endget35
          addi $t3,$t3,1
          addi $t0,$t0,1
          lb $t2,0($t0)
          j forget35								
										
endget35: blt $t3,1,invalid 
          addi $t3,$zero,0
          addi $t4,$zero,0  
          
forget36: beq $t2,-16,endget36	
          beq $t2,-38,endget36
          mul $t4,$t4,10													
	  add $t4,$t4,$t2  																																		
	  addi $t0,$t0,1
	  lb $t2,0($t0)
	  j forget36
	  																			
endget36:  addi $t5,$zero,10000000
           blt $t5,$t4,invalid
           sw $t4,8($t1)
           jr $ra 


get4: la $t0,array_i
      la $t1,array_n
      addi $t0,$t0,2 
      
      lb $t2,0($t0)
      addi $t3,$zero,0   
      
forget41: bne $t2,-16,endget41
          addi $t3,$t3,1
          addi $t0,$t0,1
          lb $t2,0($t0)
          j forget41                                            
          
endget41: blt $t3,1,invalid
          
          
          addi $t4,$zero,0
          
forget42: beq $t2,-16,endget42
          beq $t2,-38,endget42
          mul $t4,$t4,10
          add $t4,$t4,$t2
          addi $t0,$t0,1
          lb $t2,0($t0)
          j forget42
          				
endget42: sw $t4,0($t1)	
          jr $ra 

print: addi $sp,$sp,-4
       sw $ra,0($sp)

       li $v0,4
       la $a0,bracket1
       syscall 
       
       la $t1,bank_array
       addi $t0,$zero,0
          
       
printloop:    beq $t0,4,printexit
              addi $t0,$t0,1
              
              lw $t2,0($t1)
              
              beq $t0,1,printjump  # if acct no. less than 10000 then it add zero in front
              beq $t0,2,printjump  # using zero function
              
              
printback:    li $v0,1
              add $a0,$zero,$t2
              syscall
              
              li $v0,4
              la $a0,comma
              syscall 
              
              addi $t1,$t1,4
    
              j printloop
                      
printjump: 
           add $a1,$zero,$t2
           jal zero
           j printback


printexit: lw $t2,0($t1)
              
              li $v0,1
              add $a0,$zero,$t2
              syscall

          li $v0,4
          la $a0,bracket2
          syscall 
          
          lw $ra,0($sp)
          addi $sp,$sp,4
          jr $ra



zero: add $s1,$zero,$a1
      addi $s2,$zero,0
      
      blt $s1,10,four
      blt $s1,100,three
      blt $s1,1000,two
      blt $s1,10000,one
      j zeroexit   

one: addi $s2,$zero,1
     j zeroloop
two: addi $s2,$zero,2
     j zeroloop
three: addi $s2,$zero,3
       j zeroloop
four: addi $s2,$zero,4

zeroloop: beq $s2,0,zeroexit
          
          li $v0,1
          addi $a0,$zero,0
          syscall
          
          addi $s2,$s2,-1
          j zeroloop

zeroexit: addi $s2,$zero,0
          jr $ra



open_account:           
        la $t3,array_n
        lw $t1,0($t3)
        lw $t2,4($t3)
             
        la $t4,array_i
        lb $t5,0($t4)
        
        la $t3,bank_array     
        
        beq $t5,19,och
        lw $t6,4($t3)
        bne $t6,0,invalid 
        lw $t6,0($t3)
        beq $t6,$t1,invalid
        sw $t1,4($t3)
        sw $t2,12($t3)
        j open_accountend

och:    lw $t6,0($t3)
        bne $t6,0,invalid 
        lw $t6,4($t3)
        beq $t6,$t1,invalid
        sw $t1,0($t3)
        sw $t2,8($t3)                 
        
open_accountend:jr $ra
	

deposit:la $t3,array_n
        lw $t1,0($t3)
        lw $t2,4($t3)
        
        la $t3,bank_array
        
        lw $t6,0($t3)
        beq $t6,$t1,dch
        
        lw $t6,4($t3)
        bne $t6,$t1,invalid
        
        lw $t5,12($t3)
        add $t5,$t5,$t2
        sw $t5,12($t3)
        j depositend

dch:    lw $t5,8($t3)
        add $t5,$t5,$t2
        sw $t5,8($t3)

depositend:jr $ra


withdraw:
        la $t3,array_n
        lw $t1,0($t3)
        lw $t2,4($t3)
        
        la $t3,bank_array
        
        lw $t6,0($t3)
        beq $t6,$t1,wch
        lw $t6,4($t3)
        bne $t6,$t1,invalid
        
        lw $t5,12($t3)
        
        mul $t6,$t2,5        # to add 5% of t2 to t2
        div $t6,$t6,100
        
        add $t2,$t2,$t6
        blt $t5,$t2,invalid
        sub $t5,$t5,$t2
        sw $t5,12($t3)
        j withdrawend     

wch:    lw $t5,8($t3)
        blt $t5,$t2,invalid
        sub $t5,$t5,$t2
        sw $t5,8($t3) 


withdrawend:jr $ra
	
	
get_loan:
        la $t0 array_n
        lw $t1,0($t0)
        
        la $t3,bank_array
        lw $t5,8($t3)
        lw $t6,12($t3)
        lw $t8,16($t3)
        
        add $t1,$t1,$t8
        
        add $t7,$t6,$t5
        blt $t7,10001,invalid
        div $t7,$t7,2 
        addi $t7,$t7,1   
        blt $t7,$t1,invalid
        sw $t1,16($t3)
	jr $ra
	

	
transferloan: 	

        la $t0,array_n
        lw $t1,0($t0)
        lw $t2,4($t0)	
        
        la $t3,bank_array
        lw $t5,0($t3)
        lw $t6,4($t3)
        
        beq $t1,$t5,transferloanch
        bne $t1,$t6,invalid
        lw $t4,12($t3)
        lw $t7,16($t3)
	blt $t4,$t2,invalid
        blt $t7,$t2,invalid
        sub $t7,$t7,$t2
        sub $t4,$t4,$t2
        sw $t4,12($t3)
        sw $t7,16($t3)
        j transferloanend

transferloanch: lw $t4,8($t3)
                lw $t7,16($t3)
	        blt $t4,$t2,invalid
                blt $t7,$t2,invalid
                sub $t7,$t7,$t2
                sub $t4,$t4,$t2
                sw $t4,8($t3)
                sw $t7,16($t3)
                
									
transferloanend: jr $ra
					
															
transfer:         
        la $t0,array_n
        lw $t1,0($t0)
        lw $t2,4($t0)
        lw $t8,8($t0)
        
        la $t3,bank_array
        lw $t5,0($t3)
        lw $t6,4($t3)
        
        beq $t5,$t1,tch
        bne $t6,$t1,invalid
        lw $t7,12($t3)
        sub $t7,$t7,$t8
        blt $t7,0,invalid
        sw $t7,12($t3)
        lw $t7,8($t3)
        add $t7,$t7,$t8
        sw $t7,8($t3)
        j transferend
        
tch:    lw $t7,8($t3)
        sub $t7,$t7,$t8
        blt $t7,0,invalid
        sw $t7,8($t3)
        lw $t7,12($t3)
        add $t7,$t7,$t8
        sw $t7,12($t3)
               
transferend:	jr $ra
	
	
close_account:
        la $t0,array_n
        lw $t1,0($t0)
        
        addi $t8,$zero,0
        
        la $t3,bank_array
        lw $t5,0($t3)
        lw $t6,4($t3)
        
        bne $t1,$t5,checkother
        beq $t6,0,transfern
        lw $t7,12($t3)
        lw $t4,8($t3)
        add $t7,$t7,$t4
        sw $t7,12($t3)
        sw $t8,8($t3)
        sw $t8,0($t3)
        j close_accountend
        

checkother: bne $t1,$t6,invalid
	    beq $t5,0,transfern2
	    lw $t7,12($t3)
            lw $t4,8($t3)
            add $t7,$t7,$t4
            sw $t7,8($t3)
            sw $t8,12($t3)
            sw $t8,4($t3)
            j close_accountend
	    
	
transfern: lw $t7,16($t3)
           lw $t4,8($t3)
           sub $t7,$t7,$t4
           bgt $t7,0,invalid
           sw $t8,8($t3)
           sw $t8,0($t3)
           sw $t8,16($t3)
           j close_accountend

 	
transfern2:lw $t7,16($t3)
           lw $t4,12($t3)
           sub $t7,$t7,$t4
           bgt $t7,0,invalid
           sw $t8,12($t3)
           sw $t8,4($t3)
           sw $t8,16($t3)
           j close_accountend

close_accountend: jr $ra



get_balance:
        la $t0,array_n
        lw $t1,0($t0)
        
        la $t3,bank_array
        lw $t5,0($t3)
        lw $t6,4($t3)
        
        beq $t1,$t5,balance1
        bne $t1,$t6,invalid       
        lw $t7,12($t3)
        
        li $v0,4
        la $a0,dollar
        syscall
          
        li $v0,1
        add $a0,$zero,$t7
        syscall 
          
        li $v0,4
        la $a0,newline
        syscall
        
        j balanceend
        
balance1: lw $t7,8($t3)
          
          li $v0,4
          la $a0,dollar
          syscall
          
          li $v0,1
          add $a0,$zero,$t7
          syscall 
          
          li $v0,4
          la $a0,newline
          syscall
              

balanceend:jr $ra




quit:


	jr $ra


history: addi $sp,$sp,-4
       sw $ra,0($sp)

       add $t1,$zero,$a1
       mul $t1,$t1,5
       addi $t1,$t1,-1
 
       li $v0,4
       la $a0,bracket1
       syscall 
      
       la $t2,recordarray
      
       addi $t8,$zero,0

quitloop: beq $t8,$t1,quitend
          addi $t8,$t8,1
          lw $t7,0($t2)
          
          
          beq $t8,1,historyjump
          beq $t8,6,historyjump
          beq $t8,11,historyjump
          beq $t8,16,historyjump
          beq $t8,21,historyjump
          
          
historyback:
          li $v0,1
          add $a0,$zero,$t7
          syscall
          

          
          
          beq $t8,5,pq
          beq $t8,10,pq
          beq $t8,15,pq
          beq $t8,20,pq
          
          li $v0,4
          la $a0,comma
          syscall 
          
          
qiu:      addi $t2,$t2,4
          j quitloop
          
      
pq:       li $v0,4
          la $a0,rcb
          syscall 
          j qiu  
          
               
historyjump: add $a1,$zero,$t7
             jal zero
             j historyback                   
        
quitend:  lw $t7,0($t2)

          li $v0,1
          add $a0,$zero,$t7
          syscall 
          
           li $v0,4
           la $a0,bracket2
           syscall  
           
          li $v0,4
          la $a0,newline
          syscall 
          
          lw $ra,0($sp)
          addi $sp,$sp,4
          jr $ra

