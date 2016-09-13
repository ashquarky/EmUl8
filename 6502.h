/*EmUl8

A foray into emulating stuff on the PowerPC
https://github.com/QuarkTheAwesome/EmUl8

Everything's under the MIT license.
See https://github.com/QuarkTheAwesome/EmUl8/blob/master/LICENSE for details.*/

#ifndef __6502_H__
#define __6502_H__

#define byte unsigned char
#define hword unsigned short //half-word.
#define word unsigned int //On the PowerPC, this is correct. Somehow.
#define native unsigned int

typedef struct _6502Context { //style; try to keep the 32bit stuff aligned to 0, 4, 8 or C
	/*+0*/native real_pc; //Program Counter, pointer into real memory. Auto-calculated from memory_start and pc.
	/*+4*/native memory_start; //real memory address of emulated memory.
	/*+8*/native cycles; //cycle counter. May overflow.

	/*+C*/hword pc; //Program counter, as presented to emulated CPU.
	/*+E*/byte s; //Stack pointer
	/*+F*/byte p; //processor status
	/*+10*/byte a; //accumulator
	/*+11*/byte x; //index X
	/*+12*/byte y; //index Y
} 6502Context;

/** run_cpu(6502Context*, native)
  * Runs the emulated 6502 for the given number of cycles. Assumes 6502Context is valid.
  * Returns the actual number of completed cycles.
  */
native run_cpu(6502Context* ctx, native cycles);

#undef byte
#undef dbyte
#undef word
#undef native

#endif
