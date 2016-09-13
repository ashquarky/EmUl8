#EmUl8
#
#A foray into emulating stuff on the PowerPC
#https://github.com/QuarkTheAwesome/EmUl8
#
#Everything's under the MIT license.
#See https://github.com/QuarkTheAwesome/EmUl8/blob/master/LICENSE for details.

#6502.S - An attempt at implementing the 6502 instruction set
#Eventual 2A03.

#THIS CODE IS CURRENTLY UNTESTED

#remember that hashes are comments, GitHub doesn't highlight them properly

/* register allocations:
r0 is for link register shenanigans but is also technically volatile
r1 is the real stack pointer
r2 is real_pc
r3, r4 and r5 are volatile
r6 is the cycle counter
r7 is the desired cycle count
r8 is the real location of the start of memory

Because this is 6502, I can get away with not dynamically dealing with registers.
If this was anything like the PowerPC I'd never be able to do this without branching

r9 is the emulated stack pointer
r10 is the accumulator (TODO: give processor status its own register?)
r11 is x
r12 is y
All this to avoid messing with r13 so we're following calling convention
*/

//6502Context
.set ctx_real_pc, 0
.set ctx_memory_start, 4
.set ctx_cycles, 8
.set ctx_pc, 0xC
.set ctx_s, 0xE
.set ctx_p, 0xF
.set ctx_a, 0x10
.set ctx_x, 0x11
.set ctx_y, 0x12

//stack coherency
.set stack_ctx, -4

#Main function to actually run the processor.
#
#unsigned int run_cpu(6502Context* ctx, unsigned int cycles);
.globl run_6502
run_6502:
	#deal with calling convention
	mflr r0
	stw r0, 8(r1)
	stwu r1, -16(r1) #grow the stack

	stw r3, stack_ctx(r1) #save ctx for later

	#aight, let's set up our emulated CPU
	lhz r5, ctx_pc(r3) #r5 = pc
	mr r7, r4 #store arg2 into our desired cycle counter
	lwz r8, ctx_memory_start(r3) #r8 = memory_start
	li r6, 0
	lbz r9, ctx_s(r3) #r9 = s (emulated stack pointer)

	#figure out real_pc
	add r5, r5, r8
	stw r5, ctx_real_pc(r3) #save real_pc
	mr r2, r5 #move to r2

	#it's easier for code to operate on real_pc

run_6502_loop:
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
run_6502_loop_end:
	#store new ctx and quit
	lwz r3, stack_ctx(r1) #grab ctx off the stack

	stb r9, ctx_s(r3) #save emulated r1
	sub r4, r2, r8 #start figuring out pc while we wait for memory access
	stw r2, ctx_real_pc(r3) #store real_pc
	sth r4, ctx_pc(r3) #store emulated pc

	lwz r4, ctx_cycles(r3) #get current cycle counter
	add r4, r4, r6
	stw r4, ctx_cycles(r3) #store new cycle counter

	mr r3, r6 #return cycle counter

	addi r1, r1, 16 #put the stack back to normal
	lwz r0, 8(r1) #Get the link register back
	mtlr r0
	blr

op_6502_addr_table:
op_6502_0_addr:
.int op_6502_0
op_6502_1_addr:
.int op_6502_1

lis r3, 0xDEAD
ori r3, r3, 0xC0DE
blr

#Stub opcodes for testing

#fake opcode: "addto1 data", adds to r1
op_6502_0:
	addi r6, r6, 2 #increment cycle counter (up here because superscalarity)
	lbz r3, 1(r2) #load data at 1+r2
	add r9, r9, r3 #do instruction
	addi r2, r2, 2 #increment emulated program counter
	blr
#fake opcode: "nop"
op_6502_1:
	addi r2, r2, 1
	addi r6, r6, 1
	blr
