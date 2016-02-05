//
//  DKAbilitiesTests.m
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DKAbilities5E.h"

@interface DKAbilitiesTests : XCTestCase

@end

@implementation DKAbilitiesTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConstructors {
    
    DKAbilities5E* abilities = [[DKAbilities5E alloc] initWithStr:12 dex:12 con:12 intel:12 wis:12 cha:12];
    XCTAssertNotNil(abilities, @"Constructors should return non-nil object.");
    abilities = [[DKAbilities5E alloc] initWithScoreArray:@[@(12), @(12), @(12), @(12), @(12), @(12)]];
    XCTAssertNotNil(abilities, @"Constructors should return non-nil object.");
    abilities = [[DKAbilities5E alloc] initWithScores:@(12), @(12), @(12), @(12), @(12), @(12), nil];
    XCTAssertNotNil(abilities, @"Constructors should return non-nil object.");
    
    NSArray* wrongTypeArray = @[@"12", @"12", @"12", @"12", @"12", @"12"];
    XCTAssertThrows([[DKAbilities5E alloc] initWithScoreArray:wrongTypeArray],
                    @"Constructor should throw exception if input array contains invalid object types");
    NSArray* wrongCountArray = @[@"12", @"12", @"12", @"12", @"12"];
    XCTAssertThrows([[DKAbilities5E alloc] initWithScoreArray:wrongCountArray],
                    @"Constructor should throw exception if input array contains less than 6 scores");
    
}

@end
