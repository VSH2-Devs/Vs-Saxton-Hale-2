/**
 * ecs_helper.inc
 *
 * Copyright [2022] Nergal the Ashurian
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE ANDNONINFRINGEMENT.
 *
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#if defined _ecs_helper_included
	#endinput
#endif
#define _ecs_helper_included

#include <sourcemod>


/**
 * Entity Component System for SourcePawn.
 * 
 * Entities & Components
 * * An entity is a unique identifier [userids and entity references]
 * * A component can optionally be associated with a plain old datatype [enum struct, methodmap, or array data]
 * * A component identifier is an entity [handled via int or handle types]
 * * An entity can have 0 ... N components
 * * A component can be annotated with a role
 * * An <entity, component> tuple can have 0 ... N components
 * 
 * An action called a 'query' filters entities by a matching set of components.
 * 
 * 
 * Systems
 * * A system is logic matched with entities based on their components
 * * A system is invoked as result of an event
 * * A component mutation is an event
 * * Computing a simulation frame is an event
 * * A frame is divided into N phases
 * * Each system is assigned to a phase
 * 
 * In a nutshell, Systems are an entity-component query & a callback.
 */


/// with 4 bit-counts, max 128 components per entity.
/// 4 * 32 == 128 bits.
enum {
	COMPONENT_BIT_LEN = 1024,
	INT_BIT_LEN       = 32,
	INT_BIT_LEN_IDX   = 5,
};

enum {
	COMPONENT_LEN = COMPONENT_BIT_LEN / INT_BIT_LEN,
};


/// returns the index of where the bit is used.
stock int BitIndexToSlotAndBit(int bitidx, int &bit) {
	bit  = bitidx  &  (INT_BIT_LEN-1); /// modulos by bit-size of type
	return bitidx >>> INT_BIT_LEN_IDX; /// divides by bit-size of type
}

stock int SlotAndBitToBitIndex(int slot, int bit) {
	return (slot << (INT_BIT_LEN_IDX)) + bit;
}


stock bool GenerateBitID(int[] gen_bits, int gen_bits_len, int &arr_idx, int &bit_idx=0) {
	/// make sure bit index is within range.
	if( arr_idx < 0 || arr_idx >= gen_bits_len ) {
		return false;
	} else if( arr_idx==(gen_bits_len - 1) && gen_bits[arr_idx]==0x80000000 ) {
		/// if LAST bitset bit is 1, we're out of component bits...
		bit_idx = COMPONENT_BIT_LEN;
		return false;
	} else if( gen_bits[arr_idx]==0x80000000 ) {
		/// on last bit for the index, 0 and move 1 to the next index.
		gen_bits[arr_idx] = 0;
		arr_idx++;
		gen_bits[arr_idx] = 1;
		bit_idx++;
	} else if( gen_bits[arr_idx]==0 ) {
		/// set up 1st bit so shifting can work.
		gen_bits[arr_idx] = 1;
		bit_idx = 0;
	} else {
		gen_bits[arr_idx] <<= 1;
		bit_idx++;
	}
	return true;
}


stock void BitVec_Set(int[] bitvec, int bitidx) {
	int bit;
	int slot = BitIndexToSlotAndBit(bitidx, bit);
	bitvec[slot] |= (1 << bit);
}
stock void BitVec_Clear(int[] bitvec, int bitidx) {
	int bit;
	int slot = BitIndexToSlotAndBit(bitidx, bit);
	bitvec[slot] &= ~(1 << bit);
}
stock void BitVec_Toggle(int[] bitvec, int bitidx) {
	int bit;
	int slot = BitIndexToSlotAndBit(bitidx, bit);
	bitvec[slot] ^= (1 << bit);
}
stock bool BitVec_Has(int[] bitvec, int bitidx) {
	int bit;
	int slot = BitIndexToSlotAndBit(bitidx, bit);
	return (bitvec[slot] & (1 << bit)) > 0;
}


stock void BitSet_Copy(int n, int[][] bits2D, int[] buf, int buflen) {
	for( int i; i < buflen; i++ ) {
		buf[i] = bits2D[n][i];
	}
}
stock void BitSet_SetByBits(int n, int[][] bits2D, int[] query_bits, int bits_len) {
	for( int i; i < bits_len; i++ ) {
		bits2D[n][i] |= query_bits[i];
	}
}
stock void BitSet_SetByBitIdx(int n, int[][] bits2D, int bitidx) {
	BitVec_Set(bits2D[n], bitidx);
}
stock void BitSet_ClearByBits(int n, int[][] bits2D, int[] query_bits, int bits_len) {
	for( int i; i < bits_len; i++ ) {
		bits2D[n][i] &= ~query_bits[i];
	}
}
stock void BitSet_ClearByBitIdx(int n, int[][] bits2D, int bitidx) {
	BitVec_Clear(bits2D[n], bitidx);
}

stock bool BitSet_Has(int n, int[][] bits2D, int[] query_bits, int bits_len) {
	bool result = true;
	for( int i; i < bits_len; i++ ) {
		if( query_bits[i]==0 ) {
			continue;
		}
		result = result && (bits2D[n][i] & query_bits[i]) > 0;
	}
	return result;
}

stock int QueryPlayers(int[][] bits2D, int[] query_bits, int bits_len, int[/** MaxClients */] player_buf) {
	int k;
	for( int i=1; i<=MaxClients; i++ ) {
		if( !(0 < i <= MaxClients) || !IsClientInGame(i) ) {
			continue;
		} else if( BitSet_Has(i, bits2D, query_bits, bits_len) ) {
			player_buf[k++] = GetClientUserId(i);
		}
	}
	return k;
}