//
//  DKCurrencyTests.m
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DKCurrency5E.h"

@interface DKCurrencyTests : XCTestCase

@end

@implementation DKCurrencyTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConstructors {

    XCTAssertNotNil([[DKCurrency5E alloc] init], @"Constructors should return non-nil object.");
}

- (void)testCurrencyStats {
    
    DKCurrency5E* currency = [[DKCurrency5E alloc] init];
    XCTAssertNotNil(currency.copper, @"Currency statistics should be initialized.");
    XCTAssertNotNil(currency.silver, @"Currency statistics should be initialized.");
    XCTAssertNotNil(currency.electrum, @"Currency statistics should be initialized.");
    XCTAssertNotNil(currency.gold, @"Currency statistics should be initialized.");
    XCTAssertNotNil(currency.platinum, @"Currency statistics should be initialized.");
}

@end
