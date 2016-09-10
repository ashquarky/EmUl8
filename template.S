#EmUl8
#
#A foray into emulating stuff on the PowerPC
#https://github.com/QuarkTheAwesome/EmUl8
#
#Everything's under the MIT license.
#See https://github.com/QuarkTheAwesome/EmUl8/blob/master/LICENSE for details.

#THIS CODE IS CURRENTLY UNTESTED

#remember that hashes are comments, GitHub doesn't highlight them properly

/* register allocations:
r0 is for link register shenanigans
r1 is the stack pointer
r2 is real_pc
r3, r4 and r5 are volatile
r6 is the cycle counter
r7 is the desired cycle count
r8 is the real location of the start of memory
lower 8 bits of r9 are emulated r1
*/

#Main function to actually run the processor.
#
#unsigned int run_cpu(EmUl8Context* ctx, unsigned int cycles);
.globl run_cpu
run_cpu:
	#deal with calling convention
	#r13 onwards are meant to be callee-save, buuuuttt.... Maybe a problem for later.
	#stmw r13, -0x4C(r1) #write 0x13 words (0x4C bytes)
	mflr r0
	stw r0, 8(r1)
	stwu r1, -16(r1) #grow the stack
	
	stw r3, -4(r1) #save ctx for later
	
	#aight, let's set up our emulated CPU
	lbz r5, 0xC(r3) #r5 = pc (C+ctx)
	mr r7, r4 #store arg2 into our desired cycle counter
	lwz r8, 4(r3) #r8 = memory_start (4+ctx)
	li r6, 0
	lbz r9, 0xD(r3) #r9 = r1 (D+ctx)
	
	#figure out real_pc
	add r5, r5, r8
	stw r5, 0(r3) #save real_pc
	mr r2, r5 #move to r2
	
	#it's easier for code to operate on real_pc
	
run_cpu_loop:
	cmplw r6, r7 #if r6 = r7...
	bge run_cpu_loop_end #we've done enough cycles, return
	#otherwise, run instruction
	
	lbz r4, 0(r2) #load instruction at r2
	mulli r3, r4, 4 #multiply by 4
	addis r3, r3, opcode_addr_table@ha #add top bits of opcode_addr_table
	lwz r3, opcode_addr_table@l(r3)
	
	mtctr r3
	bctrl
	
	b run_cpu_loop	
run_cpu_loop_end:
	#store new ctx and quit
	lwz r3, -4(r1) #grab ctx off the stack
	stb r9, 0xD(r3) #save emulated r1
	sub r4, r2, r8 #start figuring out pc while we wait for memory access
	stw r2, 0(r3) #store real_pc
	stb r4, 0xC(r3) #store emulated pc
	lwz r4, 0x8(r3) #get current cycle counter
	add r4, r4, r6 
	stw r4, 0x8(r3) #store new cycle counter
	
	mr r3, r6 #return cycle counter
	
	addi r1, r1, 16 #put the stack back to normal
	lwz r0, 8(r1) #Get the link register back
	mtlr r0
	blr
	
opcode_addr_table:
opcode_0_addr:
.int opcode_0
opcode_1_addr:
.int opcode_1

lis r3, 0xDEAD
ori r3, r3, 0xC0DE
blr

#Stub opcodes for testing

#fake opcode: "addto1 data", adds to r1
opcode_0:
	addi r6, r6, 2 #increment cycle counter (up here because superscalarity)
	lbz r3, 1(r2) #load data at 1+r2
	add r9, r9, r3 #do instruction
	addi r2, r2, 2 #increment emulated program counter
	blr
#fake opcode: "nop"
opcode_1:
	addi r2, r2, 1
	addi r6, r6, 1
	blr