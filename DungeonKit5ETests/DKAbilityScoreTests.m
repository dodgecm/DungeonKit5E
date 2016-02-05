//
//  DKAbilityScoreTests.m
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <DungeonKit/DungeonKit.h>
#import "DKAbilities5E.h"

@interface DKAbilityScoreTests : XCTestCase

@end

@implementation DKAbilityScoreTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConstructors {
    XCTAssertNotNil([[DKAbilityScore alloc] initWithInt:10], @"Constructors should return non-nil object.");
    XCTAssertNotNil([DKAbilityScore statisticWithInt:10], @"Constructors should return non-nil object.");
}

- (void)testModifierCalculation {
    
    DKAbilityScore* ability = [[DKAbilityScore alloc] initWithInt:0];
    ability.base = @12;
    XCTAssertEqual(ability.abilityModifier, 1, @"Normal modifier should be calculated properly.");
    ability.base = @11;
    XCTAssertEqual(ability.abilityModifier, 0, @"Normal modifier should be calculated properly.");
    ability.base = @10;
    XCTAssertEqual(ability.abilityModifier, 0, @"Normal modifier should be calculated properly.");
    ability.base = @9;
    XCTAssertEqual(ability.abilityModifier, -1, @"Normal modifier should be calculated properly.");
}

- (void)testGeneratedModifiers {
    
    DKAbilityScore* ability = [[DKAbilityScore alloc] initWithInt:0];
    
    DKNumericStatistic* numericStatistic = [DKNumericStatistic statisticWithInt:0];
    [numericStatistic applyModifier:[ability modifierFromAbilityScore]];
    XCTAssertEqual(numericStatistic.value.integerValue, -5, @"Dependent modifier should be calculated properly.");
    
    DKDiceStatistic* diceStatistic = [DKDiceStatistic statisticWithNoDice];
    [diceStatistic applyModifier:ability.diceCollectionModifierFromAbilityScore];
    
    ability.base = @12;
    XCTAssertEqual(ability.abilityModifier, diceStatistic.value.modifier, @"Dependent modifier should be calculated properly.");
    ability.base = @14;
    XCTAssertEqual(ability.abilityModifier, diceStatistic.value.modifier, @"Dependent modifier should be calculated properly.");
}

- (void)testNegativeScores {
    
    DKAbilityScore* ability = [[DKAbilityScore alloc] initWithInt:10];
    XCTAssertEqual(ability.abilityModifier, 0, @"Negative ability scores revert to 0.");
    ability.base = @(-10);
    XCTAssertEqualObjects(ability.value, @0, @"Negative ability scores revert to 0.");
    XCTAssertEqual(ability.abilityModifier, -5, @"Negative ability scores revert to 0.");
}

- (void)testModifierFormatting {
    
    XCTAssertEqualObjects(@"+0", [[DKAbilityScore statisticWithInt:10] formattedAbilityModifier], @"Modifier should be formatted with the correct prefix.");
    XCTAssertEqualObjects(@"+2", [[DKAbilityScore statisticWithInt:14] formattedAbilityModifier], @"Modifier should be formatted with the correct prefix.");
    XCTAssertEqualObjects(@"-2", [[DKAbilityScore statisticWithInt:6] formattedAbilityModifier], @"Modifier should be formatted with the correct prefix.");
}

@end
