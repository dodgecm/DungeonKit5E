//
//  DKProficientStatisticTests.m
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <DungeonKit/DungeonKit.h>
#import "DKProficientStatistic.h"

@interface DKProficientStatisticTests : XCTestCase

@end

@implementation DKProficientStatisticTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConstructors {
    DKNumericStatistic* proficiencyBonus = [DKNumericStatistic statisticWithInt:2];
    XCTAssertNotNil([DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus], @"Constructors should return non-nil object.");
    XCTAssertNotNil([[DKProficientStatistic alloc] initWithBase:0 proficiencyBonus:proficiencyBonus], @"Constructors should return non-nil object.");
}

- (void)testProficiencyLevel {
    
    DKNumericStatistic* proficiencyBonus = [DKNumericStatistic statisticWithInt:2];
    DKProficientStatistic* proficiencyStat = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
    proficiencyStat.proficiencyLevel.base = @1;
    XCTAssertEqualObjects(proficiencyStat.value, @2, @"Proficiency bonus should be applied according to proficiency level.");
    proficiencyStat.proficiencyLevel.base = @0;
    XCTAssertEqualObjects(proficiencyStat.value, @0, @"Proficiency bonus should be applied according to proficiency level.");
    proficiencyStat.proficiencyLevel.base = @3;
    XCTAssertEqualObjects(proficiencyStat.value, @6, @"Proficiency bonus should be applied according to proficiency level.");
    
    proficiencyBonus.base = @3;
    XCTAssertEqualObjects(proficiencyStat.value, @9, @"Proficiency value should be updated when proficiency bonus changes.");
    proficiencyBonus.base = @5;
    XCTAssertEqualObjects(proficiencyStat.value, @15, @"Proficiency value should be updated when proficiency bonus changes.");
    
    DKModifier* bonusModifier = [DKModifier numericModifierWithAdditiveBonus:2];
    [proficiencyBonus applyModifier:bonusModifier];
    XCTAssertEqualObjects(proficiencyStat.value, @21, @"Proficiency value should be updated when proficiency bonus changes.");
    [bonusModifier removeFromStatistic];
    XCTAssertEqualObjects(proficiencyStat.value, @15, @"Proficiency value should be updated when proficiency bonus changes.");
    
    DKModifier* statModifier = [DKModifier numericModifierWithAdditiveBonus:2];
    [proficiencyStat applyModifier:statModifier];
    XCTAssertEqualObjects(proficiencyStat.value, @17, @"Modifiers should be applied correctly.");
}

@end
