#EmUl8
#
#A foray into emulating stuff on the PowerPC
#https://github.com/QuarkTheAwesome/EmUl8
#
#Everything's under the MIT license.
#See https://github.com/QuarkTheAwesome/EmUl8/blob/master/LICENSE for details.

#THIS CODE IS CURRENTLY UNTESTED

#remember that hashes are comments, GitHub doesn't highlight them properly

#run_test(void* valid_memory_location)
.globl run_test
run_test:
	mr r2, r3 #set emulated PC to valid_memory_location
	li r3, 0
	stb r3, 0(r2) #write opcode "0" to emulated PC
	li r4, 1 #emulated register 1 = 1
	stb r4, 1(r2) #write data "1" (emulated register 1) to valid_memory_location+1
	
	mflr r0
	bl do_opcode #do_opcode(0)
	
	mr r3, r4 #return emulated register 1
	mtlr r0 #break
	blr

#A temporary thing to test the jump table.
#do_opcode(int opcode)
#
#r30 is used for maths, fo realz. Maybe change this to something else.
do_opcode:
	#mulli r3, r3, 4 #opcode = opcode * sizeof(pointer)
	#lis r30, opcode_addr_table@ha
	#ori r30, r30, opcode_addr_table@l #r30 = pointer to opcode_addr_table
	#This ori could be removed by playing with the lwz offset below
	#add r3, r30, r3 #pointer to opcode_#_addr = r30 + opcode
	#lwz r3, 0(r3) #load opcode_#_addr into r3, WRONG
	#TODO: see if the add instruction could be skipped by doing lwz r3, r3(r30)
	
	#alternativley:
	mulli r3, r3, 4
	addis r3, r3, opcode_addr_table@ha #there IS an addis! #D
	lwz r3, opcode_addr_table@l(r3)
	
	#much smaller
	mtctr r3
	bctr
	
opcode_addr_table:
opcode_0_addr:
.int opcode_0
opcode_1_addr:
.int opcode_1

#Stub opcodes for testing, I guess?

#r0 = lr (keep)
#r1 = sp (keep)
#r2 = emulated pc?
#r3 = opcode
#r4 = emulated registers?

#r30 = math

opcode_0: #fake opcode, adds data to r4
	lbz r3, 1(r2) #load data (addressing modes, I know, I know.)
	add r4, r4, r3 #do instruction
	addi r2, r2, 2 #increment emulated program counter
	blr
opcode_1:
	lwz r3, 1(r2)
	sub r4, r4, r3
	addi r2, r2, 2
	blr