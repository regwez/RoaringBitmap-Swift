//
//  ContainerTests.swift
//  RoaringBitmapConversion
//
//  Created by Ragy Eleish on 3/19/15.
//  Copyright (c) 2015 Regwez, Inc. All rights reserved.
//

import UIKit
import XCTest
import RoaringBitmapConversion

class ContainerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func testTransition() {
        var c:Container = ArrayContainer()
        let threshold:UInt16 = 4096
        
        for i in 0..<threshold {
            c = c.add(UInt16(i))
        }
        XCTAssert(c.cardinality == 4096, "c.cardinality == 4096")
        XCTAssert(c is ArrayContainer, "c should be of Type ArrayContainer")
   
        for i in 0..<threshold {
            c = c.add(UInt16(i))
        }
        
        XCTAssert(c.cardinality == 4096, "c.cardinality == 4096")
        XCTAssert(c is ArrayContainer, "c should be of Type ArrayContainer")
        
        c = c.add(threshold)
        XCTAssert(c.cardinality == 4097, "c.cardinality == 4097")
        XCTAssert(c is BitmapContainer, "c should be of Type BitmapContainer")

        c  = c.remove(threshold)
        XCTAssert(c.cardinality == 4096, "c.cardinality == 4096")
        XCTAssert(c is ArrayContainer, "c should be of Type ArrayContainer")
    }
    

    
//    func testInot_1() {
//        // Array container, range is complete
//        let content:[UInt16] = [1, 3, 5, 7, 9]
//        var c = ContainerTests.makeContainer(content)
//        c = c.inot(rangeStart: 0, rangeEnd: 65535)
//        var s = [UInt16](count:65536 - content.count, repeatedValue:0)
//        var pos = 0
//        for i in 0..<65536{
//            if (Arrays.binarySearch(content, UInt16(i)) < 0){
//                s[pos++] = UInt16(i)
//            }
//        }
//        XCTAssert(ContainerTests.checkContent(c, s), "c.cardinality == 4096")
//
//    }
 
   
    
    func Testinot10() {
        println("inotTest10");
        // Array container, inverting a range past any set bit
        let content:[UInt16] = [0,2, 4]
        var c = ContainerTests.makeContainer(content)
        var c1 = c.inot(rangeStart: 65190, rangeEnd: 65200)
        XCTAssert(c1 is ArrayContainer, "c1 should be of Type ArrayContainer")
        XCTAssert(c1.cardinality == 14, "c1.cardinality == 14")
        
        let expected:[UInt16] = [0, 2, 4, 65190, 65191,65192, 65193, 65194,  65195,
            65196, 65197, 65198,65199, 65200]
        
   //     XCTAssert(ContainerTests.checkContent(c1, expected), "c1 passed")
    }
    
  /*
    func inotTest2() {
    // Array and then Bitmap container, range is complete
    final short[] content = {1, 3, 5, 7, 9};
    Container c = ContainerTests.makeContainer(content);
    c = c.inot(0, 65535);
    c = c.inot(0, 65535);
    assertTrue(ContainerTests.checkContent(c, content));
    }
    
    
    func inotTest3() {
    // Bitmap to bitmap, full range
    
    Container c = new ArrayContainer();
    for (int i = 0; i < 65536; i += 2)
    c = c.add((short) i);
    
    c = c.inot(0, 65535);
    assertTrue(c.contains((short) 3) && !c.contains((short) 4));
    assertEquals(32768, c.getCardinality());
    c = c.inot(0, 65535);
    for (int i = 0; i < 65536; i += 2)
    assertTrue(c.contains((short) i)
    && !c.contains((short) (i + 1)));
    }
    
    
    func inotTest4() {
    // Array container, range is partial, result stays array
    final short[] content = {1, 3, 5, 7, 9};
    Container c = ContainerTests.makeContainer(content);
    c = c.inot(4, 999);
    assertTrue(c instanceof ArrayContainer);
    assertEquals(999 - 4 + 1 - 3 + 2, c.getCardinality());
    c = c.inot(4, 999); // back
    assertTrue(ContainerTests.checkContent(c, content));
    }
    
    
    func inotTest5() {
    System.out.println("inotTest5");
    // Bitmap container, range is partial, result stays bitmap
    final short[] content = new short[32768 - 5];
    content[0] = 0;
    content[1] = 2;
    content[2] = 4;
    content[3] = 6;
    content[4] = 8;
    for (int i = 10; i <= 32767; ++i)
    content[i - 10 + 5] = (short) i;
    Container c = ContainerTests.makeContainer(content);
    c = c.inot(4, 999);
    assertTrue(c instanceof BitmapContainer);
    assertEquals(31773, c.getCardinality());
    c = c.inot(4, 999); // back, as a bitmap
    assertTrue(c instanceof BitmapContainer);
    assertTrue(ContainerTests.checkContent(c, content));
    
    }
    
    
    func inotTest6() {
    System.out.println("inotTest6");
    // Bitmap container, range is partial and in one word, result
    // stays bitmap
    final short[] content = new short[32768 - 5];
    content[0] = 0;
    content[1] = 2;
    content[2] = 4;
    content[3] = 6;
    content[4] = 8;
    for (int i = 10; i <= 32767; ++i)
    content[i - 10 + 5] = (short) i;
    Container c = ContainerTests.makeContainer(content);
    c = c.inot(4, 8);
    assertTrue(c instanceof BitmapContainer);
    assertEquals(32762, c.getCardinality());
    c = c.inot(4, 8); // back, as a bitmap
    assertTrue(c instanceof BitmapContainer);
    assertTrue(ContainerTests.checkContent(c, content));
    }
    
    
    func inotTest7() {
    System.out.println("inotTest7");
    // Bitmap container, range is partial, result flips to array
    final short[] content = new short[32768 - 5];
    content[0] = 0;
    content[1] = 2;
    content[2] = 4;
    content[3] = 6;
    content[4] = 8;
    for (int i = 10; i <= 32767; ++i)
    content[i - 10 + 5] = (short) i;
    Container c = ContainerTests.makeContainer(content);
    c = c.inot(5, 31000);
    if (c.getCardinality() <= ArrayContainer.DEFAULT_MAX_SIZE)
    assertTrue(c instanceof ArrayContainer);
    else
    assertTrue(c instanceof BitmapContainer);
    assertEquals(1773, c.getCardinality());
    c = c.inot(5, 31000); // back, as a bitmap
    if (c.getCardinality() <= ArrayContainer.DEFAULT_MAX_SIZE)
    assertTrue(c instanceof ArrayContainer);
    else
    assertTrue(c instanceof BitmapContainer);
    assertTrue(ContainerTests.checkContent(c, content));
    }
    
    // case requiring contraction of ArrayContainer.
    
    func inotTest8() {
    System.out.println("inotTest8");
    // Array container
    final short[] content = new short[21];
    for (int i = 0; i < 18; ++i)
    content[i] = (short) i;
    content[18] = 21;
    content[19] = 22;
    content[20] = 23;
    
    Container c = ContainerTests.makeContainer(content);
    c = c.inot(5, 21);
    assertTrue(c instanceof ArrayContainer);
    
    assertEquals(10, c.getCardinality());
    c = c.inot(5, 21); // back, as a bitmap
    assertTrue(c instanceof ArrayContainer);
    assertTrue(ContainerTests.checkContent(c, content));
    }
    
    // mostly same tests, except for not. (check original unaffected)
    
    func notTest1() {
    // Array container, range is complete
    final short[] content = {1, 3, 5, 7, 9};
    final Container c = ContainerTests.makeContainer(content);
    final Container c1 = c.not(0, 65535);
    final short[] s = new short[65536 - content.length];
    int pos = 0;
    for (int i = 0; i < 65536; ++i)
    if (Arrays.binarySearch(content, (short) i) < 0)
    s[pos++] = (short) i;
    assertTrue(ContainerTests.checkContent(c1, s));
    assertTrue(ContainerTests.checkContent(c, content));
    }
    
    
    func notTest10() {
    System.out.println("notTest10");
    // Array container, inverting a range past any set bit
    // attempting to recreate a bug (but bug required extra space
    // in the array with just the right junk in it.
    final short[] content = new short[40];
    for (int i = 244; i <= 283; ++i)
    content[i - 244] = (short) i;
    final Container c = ContainerTests.makeContainer(content);
    final Container c1 = c.not(51413, 51470);
    assertTrue(c1 instanceof ArrayContainer);
    assertEquals(40 + 58, c1.getCardinality());
    final short[] rightAns = new short[98];
    for (int i = 244; i <= 283; ++i)
    rightAns[i - 244] = (short) i;
    for (int i = 51413; i <= 51470; ++i)
    rightAns[i - 51413 + 40] = (short) i;
    
    assertTrue(ContainerTests.checkContent(c1, rightAns));
    }
    
    
    func notTest11() {
    System.out.println("notTest11");
    // Array container, inverting a range before any set bit
    // attempting to recreate a bug (but required extra space
    // in the array with the right junk in it.
    final short[] content = new short[40];
    for (int i = 244; i <= 283; ++i)
    content[i - 244] = (short) i;
    final Container c = ContainerTests.makeContainer(content);
    final Container c1 = c.not(1, 58);
    assertTrue(c1 instanceof ArrayContainer);
    assertEquals(40 + 58, c1.getCardinality());
    final short[] rightAns = new short[98];
    for (int i = 1; i <= 58; ++i)
    rightAns[i - 1] = (short) i;
    for (int i = 244; i <= 283; ++i)
    rightAns[i - 244 + 58] = (short) i;
    
    assertTrue(ContainerTests.checkContent(c1, rightAns));
    }
    
    
    func notTest2() {
    // Array and then Bitmap container, range is complete
    final short[] content = {1, 3, 5, 7, 9};
    final Container c = ContainerTests.makeContainer(content);
    final Container c1 = c.not(0, 65535);
    final Container c2 = c1.not(0, 65535);
    assertTrue(ContainerTests.checkContent(c2, content));
    }
    
    
    func notTest3() {
    // Bitmap to bitmap, full range
    
    Container c = new ArrayContainer();
    for (int i = 0; i < 65536; i += 2)
    c = c.add((short) i);
    
    final Container c1 = c.not(0, 65535);
    assertTrue(c1.contains((short) 3) && !c1.contains((short) 4));
    assertEquals(32768, c1.getCardinality());
    final Container c2 = c1.not(0, 65535);
    for (int i = 0; i < 65536; i += 2)
    assertTrue(c2.contains((short) i)
    && !c2.contains((short) (i + 1)));
    }
    
    
    func notTest4() {
    System.out.println("notTest4");
    // Array container, range is partial, result stays array
    final short[] content = {1, 3, 5, 7, 9};
    final Container c = ContainerTests.makeContainer(content);
    final Container c1 = c.not(4, 999);
    assertTrue(c1 instanceof ArrayContainer);
    assertEquals(999 - 4 + 1 - 3 + 2, c1.getCardinality());
    final Container c2 = c1.not(4, 999); // back
    assertTrue(ContainerTests.checkContent(c2, content));
    }
    
    
    func notTest5() {
    System.out.println("notTest5");
    // Bitmap container, range is partial, result stays bitmap
    final short[] content = new short[32768 - 5];
    content[0] = 0;
    content[1] = 2;
    content[2] = 4;
    content[3] = 6;
    content[4] = 8;
    for (int i = 10; i <= 32767; ++i)
    content[i - 10 + 5] = (short) i;
    final Container c = ContainerTests.makeContainer(content);
    final Container c1 = c.not(4, 999);
    assertTrue(c1 instanceof BitmapContainer);
    assertEquals(31773, c1.getCardinality());
    final Container c2 = c1.not(4, 999); // back, as a bitmap
    assertTrue(c2 instanceof BitmapContainer);
    assertTrue(ContainerTests.checkContent(c2, content));
    }
    
    
    func notTest6() {
    System.out.println("notTest6");
    // Bitmap container, range is partial and in one word, result
    // stays bitmap
    final short[] content = new short[32768 - 5];
    content[0] = 0;
    content[1] = 2;
    content[2] = 4;
    content[3] = 6;
    content[4] = 8;
    for (int i = 10; i <= 32767; ++i)
    content[i - 10 + 5] = (short) i;
    final Container c = ContainerTests.makeContainer(content);
    final Container c1 = c.not(4, 8);
    assertTrue(c1 instanceof BitmapContainer);
    assertEquals(32762, c1.getCardinality());
    final Container c2 = c1.not(4, 8); // back, as a bitmap
    assertTrue(c2 instanceof BitmapContainer);
    assertTrue(ContainerTests.checkContent(c2, content));
    }
    
    
    func notTest7() {
    System.out.println("notTest7");
    // Bitmap container, range is partial, result flips to array
    final short[] content = new short[32768 - 5];
    content[0] = 0;
    content[1] = 2;
    content[2] = 4;
    content[3] = 6;
    content[4] = 8;
    for (int i = 10; i <= 32767; ++i)
    content[i - 10 + 5] = (short) i;
    final Container c = ContainerTests.makeContainer(content);
    final Container c1 = c.not(5, 31000);
    if (c1.getCardinality() <= ArrayContainer.DEFAULT_MAX_SIZE)
    assertTrue(c1 instanceof ArrayContainer);
    else
    assertTrue(c1 instanceof BitmapContainer);
    assertEquals(1773, c1.getCardinality());
    final Container c2 = c1.not(5, 31000); // back, as a bitmap
    if (c2.getCardinality() <= ArrayContainer.DEFAULT_MAX_SIZE)
    assertTrue(c2 instanceof ArrayContainer);
    else
    assertTrue(c2 instanceof BitmapContainer);
    assertTrue(ContainerTests.checkContent(c2, content));
    }
    
    
    func notTest8() {
    System.out.println("notTest8");
    // Bitmap container, range is partial on the lower end
    final short[] content = new short[32768 - 5];
    content[0] = 0;
    content[1] = 2;
    content[2] = 4;
    content[3] = 6;
    content[4] = 8;
    for (int i = 10; i <= 32767; ++i)
    content[i - 10 + 5] = (short) i;
    final Container c = ContainerTests.makeContainer(content);
    final Container c1 = c.not(4, 65535);
    assertTrue(c1 instanceof BitmapContainer);
    assertEquals(32773, c1.getCardinality());
    final Container c2 = c1.not(4, 65535); // back, as a bitmap
    assertTrue(c2 instanceof BitmapContainer);
    assertTrue(ContainerTests.checkContent(c2, content));
    }
    
    
    func notTest9() {
    System.out.println("notTest9");
    // Bitmap container, range is partial on the upper end, not
    // single word
    final short[] content = new short[32768 - 5];
    content[0] = 0;
    content[1] = 2;
    content[2] = 4;
    content[3] = 6;
    content[4] = 8;
    for (int i = 10; i <= 32767; ++i)
    content[i - 10 + 5] = (short) i;
    final Container c = ContainerTests.makeContainer(content);
    final Container c1 = c.not(0, 65200);
    assertTrue(c1 instanceof BitmapContainer);
    assertEquals(32438, c1.getCardinality());
    final Container c2 = c1.not(0, 65200); // back, as a bitmap
    assertTrue(c2 instanceof BitmapContainer);
    assertTrue(ContainerTests.checkContent(c2, content));
    }
    
    
    func rangeOfOnesTest1() {
    final Container c = Container.rangeOfOnes(4, 10); // sparse
    assertTrue(c instanceof ArrayContainer);
    assertEquals(10 - 4 + 1, c.getCardinality());
    assertTrue(ContainerTests.checkContent(c, new short[]{4, 5, 6, 7, 8, 9, 10}));
    }
    
    
    func rangeOfOnesTest2() {
    final Container c = Container.rangeOfOnes(1000, 35000); // dense
    assertTrue(c instanceof BitmapContainer);
    assertEquals(35000 - 1000 + 1, c.getCardinality());
    }
    
    
    func rangeOfOnesTest2A() {
    final Container c = Container.rangeOfOnes(1000, 35000); // dense
    final short s[] = new short[35000 - 1000 + 1];
    for (int i = 1000; i <= 35000; ++i)
    s[i - 1000] = (short) i;
    assertTrue(ContainerTests.checkContent(c, s));
    }
    
    
    func rangeOfOnesTest3() {
    // bdry cases
    final Container c = Container.rangeOfOnes(1,
    ArrayContainer.DEFAULT_MAX_SIZE);
    assertTrue(c instanceof ArrayContainer);
    }
    
    
    func rangeOfOnesTest4() {
    final Container c = Container.rangeOfOnes(1,
    ArrayContainer.DEFAULT_MAX_SIZE + 1);
    assertTrue(c instanceof BitmapContainer);
    }
  
*/
//    static func checkContent(c:Container , s:[UInt16]) ->Bool{
//        let si = c.getShortIterator()
//        var ctr = 0
//        var fail = false
//        while (si.hasNext()) {
//            if (ctr == s.count) {
//                fail = true
//                break
//            }
//            if (si.next() != s[ctr]) {
//                fail = true
//                break
//            }
//            ++ctr
//        }
//        if (ctr != s.count) {
//            fail = true
//        }
//        if (fail) {
//            println("============== fail, found ==================")
//            si = c.getShortIterator();
//            while (si.hasNext()){
//                print(" " + si.next())
//            }
//            print("\n expected ")
//            for s1 in s{
//                print(" \(s1)")
//            }
//            println()
//            println("============== End fail ==================")
//        }
//        return !fail;
//    }
    

    static func  makeContainer(ss:[UInt16]) -> Container{
        var c:Container =  ArrayContainer()
        for s in ss{
            c = c.add(s)
        }
        return c
    }
    
}
