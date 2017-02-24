//
//  BitSet.swift
//  RoaringBitmapConversion
//
//  Created by Ragy Eleish on 3/22/15.
//  Copyright (c) 2015 Regwez, Inc. All rights reserved.
//

import UIKit

private let ADDRESS_BITS_PER_WORD = 6;
private let BITS_PER_WORD = 1 << ADDRESS_BITS_PER_WORD;
private let BIT_INDEX_MASK = BITS_PER_WORD - 1;
/*
* BitSets are packed into arrays of "words."  Currently a word is
* a long, which consists of 64 bits, requiring 6 address bits.
* The choice of word size is determined purely by performance concerns.
*/

/* Used to shift left or right for a partial word mask */
private  let WORD_MASK:UInt64 = 0xffffffffffffffff



open class BitSet{
    
    /**
    * The internal field corresponding to the serialField "bits".
    */
    fileprivate var words:[UInt64]
    
    /**
    * The number of words in the logical size of self BitSet.
    */
    fileprivate var wordsInUse = 0
    
    /**
    * Whether the size of "words" is user-specified.  If so, we assume
    * the user knows what he's doing and try harder to preserve it.
    */
    fileprivate var sizeIsSticky = false;
    
    
    /**
    * Given a bit index, return word index containing it.
    */
    fileprivate static func wordIndex( _ bitIndex:Int) ->Int{
        return bitIndex >> ADDRESS_BITS_PER_WORD;
    }
    
    /**
    * Every public method must preserve these invariants.
    */
    fileprivate func checkInvariants() {
        assert(wordsInUse == 0 || words[wordsInUse - 1] != 0);
        assert(wordsInUse >= 0 && wordsInUse <= words.count);
        assert(wordsInUse == words.count || words[wordsInUse] == 0);
    }
    
    /**
    * Sets the field wordsInUse to the logical size in words of the bit set.
    * WARNING:This method assumes that the number of words actually in use is
    * less than or equal to the current value of wordsInUse!
    */
    fileprivate func recalculateWordsInUse() {
        // Traverse the bitset until a used word is found
 
        var j = -1
        for i in stride(from: wordsInUse-1, through: 0, by: -1){
            j = i
            if (words[i] != 0){
                    break;
            }
        }
        
        wordsInUse = j + 1 // The new logical size
    }
    
    /**
    * Creates a new bit set. All bits are initially {@code false}.
    */
    public init() {
        words = [UInt64](repeating: 0, count: BitSet.wordIndex(BITS_PER_WORD-1) + 1)
        sizeIsSticky = false
    }
    
    /**
    * Creates a bit set whose initial size is large enough to explicitly
    * represent bits with indices in the range {@code 0} through
    * {@code nbits-1}. All bits are initially {@code false}.
    *
    * @param  nbits the initial size of the bit set
    * @throws NegativeArraySizeException if the specified initial size
    *         is negative
    */
    public init(nbits:Int) {
    
        words = [UInt64](repeating: 0, count: BitSet.wordIndex(nbits-1) + 1)
        sizeIsSticky = true;
    }
    
   
    
    /**
    * Creates a bit set using words as the internal representation.
    * The last word (if there is one) must be non-zero.
    */
    fileprivate init(words:[UInt64]) {
        self.words = words;
        self.wordsInUse = words.count
        checkInvariants();
    }
    

    
    /**
    * Ensures that the BitSet can hold enough words.
    * @param wordsRequired the minimum acceptable number of words.
    */
    fileprivate func ensureCapacity( _ wordsRequired:Int) {
        if (words.count < wordsRequired) {
            // Allocate larger of doubled size or required size
            let request = max(2 * words.count, wordsRequired);
           // words = Arrays.copyOf(words, request);
            let zeros = [UInt64](repeating: 0, count: request - words.count)
            words = words + zeros
            sizeIsSticky = false;
        }
    }
    
    /**
    * Ensures that the BitSet can accommodate a given wordIndex,
    * temporarily violating the invariants.  The caller must
    * restore the invariants before returning to the user,
    * possibly using recalculateWordsInUse().
    * @param wordIndex the index to be accommodated.
    */
    fileprivate func expandTo( _ wordIndex:Int) {
        let wordsRequired = wordIndex + 1
        if (wordsInUse < wordsRequired) {
            ensureCapacity(wordsRequired);
            wordsInUse = wordsRequired;
        }
    }
    

    
    /**
    * Sets the bit at the specified index to the complement of its
    * current value.
    *
    * @param  bitIndex the index of the bit to flip
    * @throws IndexOutOfBoundsException if the specified index is negative
    * @since  1.4
    */
    open func flip( _ bitIndex:Int) {
    
        let wordIndexS = BitSet.wordIndex(bitIndex);
        expandTo(wordIndexS);
    
        words[wordIndexS] ^= (UInt64(1) << UInt64(bitIndex))
    
        recalculateWordsInUse();
        checkInvariants();
    }

    /**
    * Sets each bit from the specified {@code fromIndex} (inclusive) to the
    * specified {@code toIndex} (exclusive) to the complement of its current
    * value.
    *
    * @param  fromIndex index of the first bit to flip
    * @param  toIndex index after the last bit to flip
    * @throws IndexOutOfBoundsException if {@code fromIndex} is negative,
    *         or {@code toIndex} is negative, or {@code fromIndex} is
    *         larger than {@code toIndex}
    * @since  1.4
    */
    open func flip( _ fromIndex:Int,  toIndex:Int) {
        
        if (fromIndex == toIndex){
            return;
        }
        
        let startWordIndex = BitSet.wordIndex(fromIndex);
        let endWordIndex   = BitSet.wordIndex(toIndex - 1);
        expandTo(endWordIndex);
        
        let shiftingFromIndex:UInt64 = UInt64(fromIndex) % 64
        let firstWordMask:UInt64 = WORD_MASK << shiftingFromIndex
        let toShift = -toIndex & 0x3f
        
        let lastWordMask:UInt64  = WORD_MASK >> UInt64(toShift)

        if (startWordIndex == endWordIndex) {
            // Case 1: One word
            words[startWordIndex] ^= (firstWordMask & lastWordMask);
        } else {
            // Case 2: Multiple words
            // Handle first word
            words[startWordIndex] ^= firstWordMask;
            
            // Handle intermediate words, if any
            for i in startWordIndex+1 ..< endWordIndex {
                words[i] ^= WORD_MASK
            }
            
            // Handle last word
            words[endWordIndex] ^= lastWordMask;
        }
        
        recalculateWordsInUse();
        checkInvariants();
    }

    /**
    * Sets the bit at the specified index to {@code true}.
    *
    * @param  bitIndex a bit index
    * @throws IndexOutOfBoundsException if the specified index is negative
    * @since  JDK1.0
    */
    open func set( _ bitIndex:Int) {
    
        let wordIndexS = BitSet.wordIndex(bitIndex);
        expandTo(wordIndexS);
        
        let shift:UInt64 = UInt64(bitIndex) % UInt64(64)
        words[wordIndexS] |= (UInt64(1) << shift) // Restores invariants
        
        checkInvariants();
    }

    /**
    * Sets the bit at the specified index to the specified value.
    *
    * @param  bitIndex a bit index
    * @param  value a boolean value to set
    * @throws IndexOutOfBoundsException if the specified index is negative
    * @since  1.4
    */
    open func set( _ bitIndex:Int,  value:Bool) {
        if (value){
            set(bitIndex);
        }
        else{
            clear(bitIndex);
        }
    }

    /**
    * Sets the bits from the specified {@code fromIndex} (inclusive) to the
    * specified {@code toIndex} (exclusive) to {@code true}.
    *
    * @param  fromIndex index of the first bit to be set
    * @param  toIndex index after the last bit to be set
    * @throws IndexOutOfBoundsException if {@code fromIndex} is negative,
    *         or {@code toIndex} is negative, or {@code fromIndex} is
    *         larger than {@code toIndex}
    * @since  1.4
    */
    open func set( _ fromIndex:Int,  toIndex:Int) {
        
        if (fromIndex == toIndex){
            return;
        }
        
        // Increase capacity if necessary
        let startWordIndex = BitSet.wordIndex(fromIndex);
        let endWordIndex   = BitSet.wordIndex(toIndex - 1);
        expandTo(endWordIndex);
        
        let shiftingFromIndex:UInt64 = UInt64(fromIndex & 0x3f)
        let firstWordMask:UInt64 = WORD_MASK << shiftingFromIndex
        
        let toShift = -toIndex & 0x3f
        
        let lastWordMask:UInt64  = WORD_MASK >> UInt64(toShift)
        if (startWordIndex == endWordIndex) {
            // Case 1: One word
            words[startWordIndex] |= (firstWordMask & lastWordMask);
        } else {
            // Case 2: Multiple words
            // Handle first word
            words[startWordIndex] |= firstWordMask;
            
            // Handle intermediate words, if any
            for i in startWordIndex+1 ..< endWordIndex{
                words[i] = WORD_MASK;
            }
            
            // Handle last word (restores invariants)
            words[endWordIndex] |= lastWordMask;
        }
        
        checkInvariants();
    }

    /**
    * Sets the bits from the specified {@code fromIndex} (inclusive) to the
    * specified {@code toIndex} (exclusive) to the specified value.
    *
    * @param  fromIndex index of the first bit to be set
    * @param  toIndex index after the last bit to be set
    * @param  value value to set the selected bits to
    * @throws IndexOutOfBoundsException if {@code fromIndex} is negative,
    *         or {@code toIndex} is negative, or {@code fromIndex} is
    *         larger than {@code toIndex}
    * @since  1.4
    */
    open func set( _ fromIndex:Int,  toIndex:Int,  value:Bool) {
        if (value){
            set(fromIndex, toIndex:toIndex);
        }else{
            clear(fromIndex, itoIndex:toIndex);
        }
    }

    /**
    * Sets the bit specified by the index to {@code false}.
    *
    * @param  bitIndex the index of the bit to be cleared
    * @throws IndexOutOfBoundsException if the specified index is negative
    * @since  JDK1.0
    */
    open func clear( _ bitIndex:Int) {
        
        let wordIndexS = BitSet.wordIndex(bitIndex);
        if (wordIndexS >= wordsInUse){
            return;
        }
        
        words[wordIndexS] &= ~(UInt64(1) << UInt64(bitIndex));
        
        recalculateWordsInUse();
        checkInvariants();
    }

    /**
    * Sets the bits from the specified {@code fromIndex} (inclusive) to the
    * specified {@code toIndex} (exclusive) to {@code false}.
    *
    * @param  fromIndex index of the first bit to be cleared
    * @param  toIndex index after the last bit to be cleared
    * @throws IndexOutOfBoundsException if {@code fromIndex} is negative,
    *         or {@code toIndex} is negative, or {@code fromIndex} is
    *         larger than {@code toIndex}
    * @since  1.4
    */
    open func clear( _ fromIndex:Int,  itoIndex:Int) {

        
        if (fromIndex == itoIndex){
            return;
        }
        
        let startWordIndex = BitSet.wordIndex(fromIndex);
        if (startWordIndex >= wordsInUse){
            return;
        }
        
        var toIndex = itoIndex
        var endWordIndex = BitSet.wordIndex(toIndex - 1);
        if (endWordIndex >= wordsInUse) {
            toIndex = length();
            endWordIndex = wordsInUse - 1;
        }
        
        let shiftingFromIndex:UInt64 = UInt64(fromIndex) % 64
        let firstWordMask:UInt64 = WORD_MASK << shiftingFromIndex
        let toShift = -toIndex & 0x3f
        
        let lastWordMask:UInt64  = WORD_MASK >> UInt64(toShift)
        if (startWordIndex == endWordIndex) {
            // Case 1: One word
            words[startWordIndex] &= ~(firstWordMask & lastWordMask);
        } else {
            // Case 2: Multiple words
            // Handle first word
            words[startWordIndex] &= ~firstWordMask;
            
            // Handle intermediate words, if any
            for i in startWordIndex+1 ..< endWordIndex {
                words[i] = 0;
            }
            
            // Handle last word
            words[endWordIndex] &= ~lastWordMask;
        }
        
        recalculateWordsInUse();
        checkInvariants();
    }

    /**
    * Sets all of the bits in self BitSet to {@code false}.
    *
    * @since 1.4
    */
    open func clear() {
        while (wordsInUse > 0){
            wordsInUse-=1
            words[wordsInUse] = 0;
        }
    }

    /**
    * Returns the value of the bit with the specified index. The value
    * is {@code true} if the bit with the index {@code bitIndex}
    * is currently set in self {@code BitSet}; otherwise, the result
    * is {@code false}.
    *
    * @param  bitIndex   the bit index
    * @return the value of the bit with the specified index
    * @throws IndexOutOfBoundsException if the specified index is negative
    */
    open func get( _ bitIndex:Int) ->Bool{
        checkInvariants();
        
        let wordIndexS = BitSet.wordIndex(bitIndex);
        return (wordIndexS < wordsInUse)
            && ((words[wordIndexS] & (UInt64(1) << UInt64(bitIndex))) != 0);
    }

    /**
    * Returns a new {@code BitSet} composed of bits from self {@code BitSet}
    * from {@code fromIndex} (inclusive) to {@code toIndex} (exclusive).
    *
    * @param  fromIndex index of the first bit to include
    * @param  toIndex index after the last bit to include
    * @return a new {@code BitSet} from a range of self {@code BitSet}
    * @throws IndexOutOfBoundsException if {@code fromIndex} is negative,
    *         or {@code toIndex} is negative, or {@code fromIndex} is
    *         larger than {@code toIndex}
    * @since  1.4
    */
    open func get( _ fromIndex:Int,  itoIndex:Int) ->BitSet{
        
        checkInvariants();
        
        let len = length();
        
        // If no set bits in range return empty bitset
        if (len <= fromIndex || fromIndex == itoIndex){
            return BitSet(nbits: 0);
        }
        
        var toIndex = itoIndex
        // An optimization
        if (itoIndex > len){
            toIndex = len;
        }
        
        let result = BitSet(nbits: toIndex - fromIndex);
        let targetWords = BitSet.wordIndex(toIndex - fromIndex - 1) + 1;
        var sourceIndex = BitSet.wordIndex(fromIndex);
        let wordAligned = ((fromIndex & BIT_INDEX_MASK) == 0);
        
        // Process all words but the last word
        for  i in 0..<targetWords-1 {
            let shiftingFromIndex:UInt64 = UInt64(fromIndex) % 64
            
            let nfromIndexShift = -fromIndex & 0x3f
            
            result.words[i] = wordAligned ? words[sourceIndex] :
            (words[sourceIndex] >> shiftingFromIndex) |
            (words[sourceIndex+1] << UInt64(nfromIndexShift))
            sourceIndex+=1
        }
        
        // Process the last word
        let shiftingFromIndex:UInt64 = UInt64(fromIndex) % 64
        let toShift = -toIndex & 0x3f
        let nfromIndexShift = UInt64(-fromIndex & 0x3f)
        
        let lastWordMask:UInt64  = WORD_MASK >> UInt64(toShift)
        result.words[targetWords - 1] = ((toIndex-1) & BIT_INDEX_MASK) < (fromIndex & BIT_INDEX_MASK)
            ? /* straddles source words */
                ((words[sourceIndex] >> shiftingFromIndex) |
                    (words[sourceIndex+1] & lastWordMask) << nfromIndexShift)
        :
        ((words[sourceIndex] & lastWordMask) >> UInt64(fromIndex))
        
        // Set wordsInUse correctly
        result.wordsInUse = targetWords;
        result.recalculateWordsInUse();
        result.checkInvariants();
        
        return result;
    }

    /**
    * Returns the index of the first bit that is set to {@code true}
    * that occurs on or after the specified starting index. If no such
    * bit exists then {@code -1} is returned.
    *
    * <p>To iterate over the {@code true} bits in a {@code BitSet},
    * use the following loop:
    *
    *  <pre> {@code
    * for (int i = bs.nextSetBit(0); i >= 0; i = bs.nextSetBit(i+1)) {
    *     // operate on index i here
    * }}</pre>
    *
    * @param  fromIndex the index to start checking from (inclusive)
    * @return the index of the next set bit, or {@code -1} if there
    *         is no such bit
    * @throws IndexOutOfBoundsException if the specified index is negative
    * @since  1.4
    */
    open func nextSetBit( _ fromIndex:Int) ->Int{
        
        checkInvariants();
        
        var u = BitSet.wordIndex(fromIndex);
        if (u >= wordsInUse){
            return -1;
        }
        
        let shiftIndex:UInt64  = UInt64(fromIndex) % 64
        var word = words[u] & (WORD_MASK << shiftIndex)
        
        while (true) {
            if (word != 0){
                return (u * BITS_PER_WORD) + numberOfTrailingZeros(word);
            }
            u+=1
            if (u == wordsInUse){
                return -1;
            }
            word = words[u];
        }
    }

    /**
    * Returns the index of the first bit that is set to {@code false}
    * that occurs on or after the specified starting index.
    *
    * @param  fromIndex the index to start checking from (inclusive)
    * @return the index of the next clear bit
    * @throws IndexOutOfBoundsException if the specified index is negative
    * @since  1.4
    */
    open func nextClearBit( _ fromIndex:Int) ->Int{
        // Neither spec nor implementation handle bitsets of maximal length.
        // See 4816253.
        
        checkInvariants();
        
        var u = BitSet.wordIndex(fromIndex);
        if (u >= wordsInUse){
            return fromIndex;
        }
        
        var word = ~words[u] & (WORD_MASK << UInt64(fromIndex))
        
        while (true) {
            if (word != 0){
                return (u * BITS_PER_WORD) + numberOfTrailingZeros(word);
            }
            u+=1
            if (u == wordsInUse){
                return wordsInUse * BITS_PER_WORD;
            }
            word = ~words[u];
        }
    }

    /**
    * Returns the index of the nearest bit that is set to {@code true}
    * that occurs on or before the specified starting index.
    * If no such bit exists, or if {@code -1} is given as the
    * starting index, then {@code -1} is returned.
    *
    * <p>To iterate over the {@code true} bits in a {@code BitSet},
    * use the following loop:
    *
    *  <pre> {@code
    * for (int i = bs.length(); (i = bs.previousSetBit(i-1)) >= 0; ) {
    *     // operate on index i here
    * }}</pre>
    *
    * @param  fromIndex the index to start checking from (inclusive)
    * @return the index of the previous set bit, or {@code -1} if there
    *         is no such bit
    * @throws IndexOutOfBoundsException if the specified index is less
    *         than {@code -1}
    * @since  1.7
    */
    open func previousSetBit( _ fromIndex:Int) ->Int{

            if (fromIndex == -1){
            return -1;
            }
            
        checkInvariants();
        
        var u = BitSet.wordIndex(fromIndex);
        if (u >= wordsInUse){
            return length() - 1;
        }
        
        let toShift = -(fromIndex+1) & 0x3f
        
        var word = words[u] & (WORD_MASK >> UInt64(toShift))
        
        while (true) {
            if (word != 0){
                return (u + 1) * BITS_PER_WORD - 1 - Int(numberOfLeadingZeros(word))
            }
            if (u == 0){
                return -1;
            }
            u-=1
            word = words[u];
        }
    }

    /**
    * Returns the index of the nearest bit that is set to {@code false}
    * that occurs on or before the specified starting index.
    * If no such bit exists, or if {@code -1} is given as the
    * starting index, then {@code -1} is returned.
    *
    * @param  fromIndex the index to start checking from (inclusive)
    * @return the index of the previous clear bit, or {@code -1} if there
    *         is no such bit
    * @throws IndexOutOfBoundsException if the specified index is less
    *         than {@code -1}
    * @since  1.7
    */
    open func previousClearBit( _ fromIndex:Int) ->Int{

            if (fromIndex == -1){
                return -1;
            }
           
        
        checkInvariants();
        
        var u = BitSet.wordIndex(fromIndex);
        if (u >= wordsInUse){
            return fromIndex;
        }
        let fromShift = UInt64 (-(fromIndex+1)  & 0x3f)
        
        var word = ~words[u] & (WORD_MASK >> fromShift)
        
        while (true) {
            if (word != 0){
                return (u+1) * BITS_PER_WORD - 1 - Int(numberOfLeadingZeros(word))
            }
            if (u == 0){
                return -1;
            }
            u-=1
            word = ~words[u];
        }
    }

    /**
    * Returns the "logical size" of self {@code BitSet}: the index of
    * the highest set bit in the {@code BitSet} plus one. Returns zero
    * if the {@code BitSet} contains no set bits.
    *
    * @return the logical size of self {@code BitSet}
    * @since  1.2
    */
    open func length() ->Int {
        if (wordsInUse == 0){
            return 0
        }
        
        return BITS_PER_WORD * (wordsInUse - 1) +
            (BITS_PER_WORD - Int(numberOfLeadingZeros(words[wordsInUse - 1])))
    }


    /**
    * Returns the number of bits set to {@code true} in self {@code BitSet}.
    *
    * @return the number of bits set to {@code true} in self {@code BitSet}
    * @since  1.4
    */
    open func cardinality() ->Int{
        var sum = 0;
        for i in 0..<wordsInUse{
            sum += Int(countBits(words[i]))
        }
        return sum;
    }

    /**
    * Performs a logical <b>AND</b> of self target bit set with the
    * argument bit set. This bit set is modified so that each bit in it
    * has the value {@code true} if and only if it both initially
    * had the value {@code true} and the corresponding bit in the
    * bit set argument also had the value {@code true}.
    *
    * @param set a bit set
    */
    open func and(_ set:BitSet) {

        
        while (wordsInUse > set.wordsInUse){
            wordsInUse-=1
            words[wordsInUse] = 0;
        }
        // Perform logical AND on words in common
        for i in 0..<wordsInUse{
            words[i] &= set.words[i];
        }
        
        recalculateWordsInUse();
        checkInvariants();
    }

    /**
    * Performs a logical <b>OR</b> of self bit set with the bit set
    * argument. This bit set is modified so that a bit in it has the
    * value {@code true} if and only if it either already had the
    * value {@code true} or the corresponding bit in the bit set
    * argument has the value {@code true}.
    *
    * @param set a bit set
    */
    open func or(_ set:BitSet) {

        let wordsInCommon = min(wordsInUse, set.wordsInUse);
        
        if (wordsInUse < set.wordsInUse) {
            ensureCapacity(set.wordsInUse)
            wordsInUse = set.wordsInUse
        }
        
        // Perform logical OR on words in common
        for i in 0..<wordsInCommon {
            words[i] |= set.words[i]
        }
        
        // Copy any remaining words
        if (wordsInCommon < set.wordsInUse){
            //System.arraycopy(set.words, wordsInCommon,words, wordsInCommon, wordsInUse - wordsInCommon);
            let startingDelta = wordsInCommon
            let length = wordsInUse - wordsInCommon
            
            let wordsPtr = UnsafeMutableBufferPointer(start: &words, count: words.count)
            let wordsContentPtr = wordsPtr.baseAddress! as UnsafeMutablePointer<UInt64>
            let destinationPtr = wordsContentPtr.advanced(by: startingDelta)
            
            
            
            let setWordsPtr = UnsafeMutableBufferPointer(start: &set.words, count: set.words.count)
            let setWordsContentPtr = setWordsPtr.baseAddress! as UnsafeMutablePointer<UInt64>
            
            
            let sourcePtr = setWordsContentPtr.advanced(by: startingDelta)
            
            memcpy(destinationPtr,sourcePtr,length * MemoryLayout<UInt64>.size)
            

        }
        
        // recalculateWordsInUse() is unnecessary
        checkInvariants();
    }

    /**
    * Performs a logical <b>XOR</b> of self bit set with the bit set
    * argument. This bit set is modified so that a bit in it has the
    * value {@code true} if and only if one of the following
    * statements holds:
    * <ul>
    * <li>The bit initially has the value {@code true}, and the
    *     corresponding bit in the argument has the value {@code false}.
    * <li>The bit initially has the value {@code false}, and the
    *     corresponding bit in the argument has the value {@code true}.
    * </ul>
    *
    * @param  set a bit set
    */
    open func xor(_ set:BitSet) {
        let wordsInCommon = min(wordsInUse, set.wordsInUse);
        
        if (wordsInUse < set.wordsInUse) {
            ensureCapacity(set.wordsInUse);
            wordsInUse = set.wordsInUse;
        }
        
        // Perform logical XOR on words in common
        for i in 0..<wordsInCommon {
            words[i] ^= set.words[i];
        }
        
        // Copy any remaining words
        if (wordsInCommon < set.wordsInUse){
            //System.arraycopy(set.words, wordsInCommon,words, wordsInCommon,set.wordsInUse - wordsInCommon);
            
            let startingDelta = wordsInCommon
            let length = set.wordsInUse - wordsInCommon
            
            let wordsPtr = UnsafeMutableBufferPointer(start: &words, count: words.count)
            let wordsContentPtr = wordsPtr.baseAddress! as UnsafeMutablePointer<UInt64>
            
            
            let destinationPtr = wordsContentPtr.advanced(by: startingDelta)
            
            
            let setWordsPtr = UnsafeMutableBufferPointer(start: &set.words, count: set.words.count)
            let setWordsContentPtr = setWordsPtr.baseAddress! as UnsafeMutablePointer<UInt64>
            let sourcePtr = setWordsContentPtr.advanced(by: startingDelta)
            
            memcpy(destinationPtr,sourcePtr,length * MemoryLayout<UInt64>.size)
        }
        
        recalculateWordsInUse();
        checkInvariants();
    }

    /**
    * Clears all of the bits in self {@code BitSet} whose corresponding
    * bit is set in the specified {@code BitSet}.
    *
    * @param  set the {@code BitSet} with which to mask self
    *         {@code BitSet}
    * @since  1.2
    */
    open func andNot(_ set:BitSet) {
        // Perform logical (a & !b) on words in common
        for  i in stride(from: min(wordsInUse, set.wordsInUse) - 1, through: 0, by: -1) {
            words[i] &= ~set.words[i];
        }
        
        recalculateWordsInUse();
        checkInvariants();
    }


    /**
    * Compares self object against the specified object.
    * The result is {@code true} if and only if the argument is
    * not {@code null} and is a {@code Bitset} object that has
    * exactly the same set of bits set to {@code true} as self bit
    * set. That is, for every nonnegative {@code int} index {@code k},
    * <pre>((BitSet)obj).get(k) == self.get(k)</pre>
    * must be true. The current sizes of the two bit sets are not compared.
    *
    * @param  obj the object to compare with
    * @return {@code true} if the objects are the same;
    *         {@code false} otherwise
    * @see    #size()
    */
    open func equals(_ set:BitSet) ->Bool{
        

        
        checkInvariants();
        set.checkInvariants();
        
        if (wordsInUse != set.wordsInUse){
            return false;
        }
        
        // Check words in use by both BitSets
        for i in 0..<wordsInUse {
            if (words[i] != set.words[i]){
                return false;
            }
        }
        
        return true;
    }

    /**
    * Cloning self {@code BitSet} produces a new {@code BitSet}
    * that is equal to it.
    * The clone of the bit set is another bit set that has exactly the
    * same bits set to {@code true} as self bit set.
    *
    * @return a clone of self bit set
    * @see    #size()
    */
    open func clone() -> BitSet{
        if  !sizeIsSticky {
            trimToSize();
        }
        

        let result = BitSet()
        result.words = words
        result.checkInvariants();
        return result;
       
    }

    /**
    * Attempts to reduce internal storage used for the bits in self bit set.
    * Calling self method may, but is not required to, affect the value
    * returned by a subsequent call to the {@link #size()} method.
    */
    fileprivate func trimToSize() {
        if (wordsInUse != words.count) {
           // words = Arrays.copyOf(words, wordsInUse);
            words = Array(words[0..<wordsInUse])
            checkInvariants();
        }
    }



}
