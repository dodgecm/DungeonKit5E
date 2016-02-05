//
//  DKSkillsTests.m
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DKSkills5E.h"

@interface DKSkillsTests : XCTestCase

@end

@implementation DKSkillsTests

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
    DKAbilities5E* abilities = [[DKAbilities5E alloc] initWithStr:12 dex:12 con:12 intel:12 wis:12 cha:12];
    DKSkills5E* skills = [[DKSkills5E alloc] initWithAbilities:abilities proficiencyBonus:proficiencyBonus];
    XCTAssertNotNil(skills, @"Constructors should return non-nil object.");
    skills = [[DKSkills5E alloc] initWithAbilities:nil proficiencyBonus:proficiencyBonus];
    XCTAssertNil(skills, @"Constructor should check for nil parameters.");
    skills = [[DKSkills5E alloc] initWithAbilities:abilities proficiencyBonus:nil];
    XCTAssertNil(skills, @"Constructor should check for nil parameters.");
    skills = [[DKSkills5E alloc] initWithAbilities:nil proficiencyBonus:nil];
    XCTAssertNil(skills, @"Constructor should check for nil parameters.");
}

- (void)testSkillValues {
    
    DKNumericStatistic* proficiencyBonus = [DKNumericStatistic statisticWithInt:2];
    DKAbilities5E* abilities = [[DKAbilities5E alloc] initWithStr:12 dex:12 con:12 intel:12 wis:12 cha:12];
    DKSkills5E* skills = [[DKSkills5E alloc] initWithAbilities:abilities proficiencyBonus:proficiencyBonus];
    
    NSArray* abilitiesToTest = @[abilities.strength, abilities.dexterity, abilities.intelligence,
                                 abilities.wisdom, abilities.charisma];
    NSArray* skillsToTest = @[skills.athletics, skills.sleightOfHand, skills.investigation,
                              skills.perception, skills.persuasion];
    
    for (int i = 0; i < abilitiesToTest.count; i++) {
        
        DKNumericStatistic* abilityToTest = abilitiesToTest[i];
        DKProficientStatistic* skillToTest = skillsToTest[i];
        
        proficiencyBonus.base = @2;
        XCTAssertEqualObjects(skillToTest.value, @1, @"Skill values should be calculated properly.");
        
        skillToTest.proficiencyLevel.base = @1;
        XCTAssertEqualObjects(skillToTest.value, @3, @"Skill values should be calculated properly.");
        
        proficiencyBonus.base = @3;
        XCTAssertEqualObjects(skillToTest.value, @4, @"Skill values should be calculated properly.");
        
        abilityToTest.base = @18;
        XCTAssertEqualObjects(skillToTest.value, @7, @"Skill values should be calculated properly.");
        abilityToTest.base = @8;
        XCTAssertEqualObjects(skillToTest.value, @2, @"Skill values should be calculated properly.");
    }
    
    proficiencyBonus.base = @2;
    abilities.wisdom.base = @12;
    XCTAssertEqualObjects(skills.passivePerception.value, @13);
}

@end
