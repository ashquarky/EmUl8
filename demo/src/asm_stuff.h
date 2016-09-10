#ifndef __ASM_STUFF_H__
#define __ASM_STUFF_H__

#define e8bit unsigned char
#define e32bit unsigned int
typedef struct { //style; try to keep the 32bit stuff aligned to 0, 4, 8 or C
	/*+0*/e32bit real_pc; //emulated Program Counter, pointer into real memory. Auto-calculated.
	/*+4*/e32bit memory_start; //real memory address of emulated memory.
	/*+8*/e32bit cycles; //cycle counter. May overflow.
	/*+C*/e8bit pc; //emulated Program Counter, pointer into emulated memory
	/*+D*/e8bit r1; //first emulated register
} EmUl8Context;
#undef e8bit
#undef e32bit

unsigned int run_cpu(EmUl8Context* ctx, unsigned int cycles);

#endif