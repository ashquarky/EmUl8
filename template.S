;EmUl8
;
;A foray into emulating stuff on the PowerPC
;https://github.com/QuarkTheAwesome/EmUl8
;
;Everything's under the MIT license.
;See https://github.com/QuarkTheAwesome/EmUl8/blob/master/LICENSE for details.

;THIS CODE IS CURRENTLY UNTESTED

;A temporary thing to test the jump table.
;do_opcode(int opcode)
;
;r30 is used for maths, fo realz. Maybe change this to something else.
do_opcode:
	mulli r3, r3, 4 ;opcode = opcode * sizeof(pointer)
	lis r30, opcode_addr_table@ha
	ori r30, r30, opcode_addr_table@l ;r30 = pointer to opcode_addr_table
	add r3, r30, r3 ;pointer to opcode_#_addr = r30 + opcode
	lwz r3, 0(r3) ;load opcode_#_addr into r3
	;TODO: see if the add instruction could be skipped by doing lwz r3, r3(r30)
	
	mtctr r3
	bctrl
	
	blr ;the last instruction may have messed that up
opcode_addr_table:
.dw opcode_0_addr opcode_0
.dw opcode_1_addr opcode_1

;Stub opcodes for testing, I guess?

opcode_0:
	addi r3, r3, 0
	blr
opcode_1:
	subi r3, r3, 0
	blr