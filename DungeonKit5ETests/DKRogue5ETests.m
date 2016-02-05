//
//  DKRogue5ETests.m
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DKCharacter5E.h"
#import "DKModifierGroupTags5E.h"

@interface DKRogue5ETests : XCTestCase
@property (nonatomic, strong) DKCharacter5E* character;
@end

@implementation DKRogue5ETests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _character = [[DKCharacter5E alloc] init];
    _character.experiencePoints.base = @(-1);
    _character.level.base = @(1);
    [_character chooseClass:kDKClassType5E_Rogue];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHitDice {
    
    XCTAssertEqualObjects(_character.hitDiceMax.value.stringValue, @"1d8", @"Rogue should have 1d8 hit dice at level 1.");
    _character.level.base = @5;
    XCTAssertEqualObjects(_character.hitDiceMax.value.stringValue, @"5d8", @"Rogue should have 5d8 hit dice at level 5.");
}

- (void)testSavingThrows {
    XCTAssertEqualObjects(_character.savingThrows.dexterity.proficiencyLevel.value, @1, @"Rogues have proficiency in dexterity saving throws.");
    XCTAssertEqualObjects(_character.savingThrows.intelligence.proficiencyLevel.value, @1, @"Rogues have proficiency in intelligence saving throws.");
    
    XCTAssertEqualObjects(_character.savingThrows.dexterity.value, @2, @"Rogues have proficiency in dexterity saving throws.");
    _character.abilities.dexterity.base = @12;
    XCTAssertEqualObjects(_character.savingThrows.dexterity.value, @3, @"Rogues have proficiency in dexterity saving throws.");
}

- (void)testWeaponProficiencies {
    XCTAssertTrue([_character.weaponProficiencies.value containsObject:@"Simple Weapons"], @"Rogues can use simple weapons.");
    NSArray* weaponProficiencies = @[ @(kDKWeaponType5E_HandCrossbow),
                                      @(kDKWeaponType5E_Longsword),
                                      @(kDKWeaponType5E_Shortsword),
                                      @(kDKWeaponType5E_Rapier) ];
    for (NSNumber* weaponProficiency in weaponProficiencies) {
        XCTAssertTrue([_character.weaponProficiencies.value containsObject:[DKWeaponBuilder5E proficiencyNameForWeapon:weaponProficiency.integerValue]],
                      @"Rogues can use limited martial weapons.");
    }
}

- (void)testArmorProficiencies {
    XCTAssertTrue([_character.armorProficiencies.value containsObject:@"Light Armor"], @"Rogues can wear light armor.");
}

- (void)testToolProficiencies {
    XCTAssertTrue([_character.toolProficiencies.value containsObject:@"Thieves' tools"], @"Rogues can use thieves' tools.");
}

- (void)testSkillProficiencies {
    
    NSArray* skillChoices = [_character allModifierGroupsWithTag:DKChoiceRogueSkillProficiency];
    XCTAssertEqual(skillChoices.count, 2, @"Rogues get two skill proficiency choices.");
    
    XCTAssertEqualObjects(_character.skills.acrobatics.proficiencyLevel.value, @0, @"Rogues do not start out with acrobatics proficiency.");
    DKChoiceModifierGroup* skillChoice = (DKChoiceModifierGroup*) skillChoices[0];
    [skillChoice choose:skillChoice.choices[0]];
    XCTAssertEqualObjects(_character.skills.acrobatics.proficiencyLevel.value, @1, @"Acrobatics proficiency should be granted.");
    
    XCTAssertEqualObjects(_character.skills.animalHandling.proficiencyLevel.value, @0, @"Rogues do not start out with athletics proficiency.");
    skillChoice = (DKChoiceModifierGroup*) skillChoices[1];
    [skillChoice choose:skillChoice.choices[1]];
    XCTAssertEqualObjects(_character.skills.athletics.proficiencyLevel.value, @1, @"Athletics proficiency should be granted.");
}

- (void)testAbilityScoreImprovements {
    
    NSArray* abilityScoreChoices = [_character allUnallocatedChoicesWithTag:DKChoiceAbilityScoreImprovement];
    XCTAssertEqual(abilityScoreChoices.count, 0, @"Rogues don't start with ability score improvements");
    
    NSArray* levels = @[ @4, @8, @10, @12, @16, @19];
    int improvementCount = 0;
    for (NSNumber* level in levels) {
        
        _character.level.base = level;
        improvementCount += 2;
        abilityScoreChoices = [_character allUnallocatedChoicesWithTag:DKChoiceAbilityScoreImprovement];
        XCTAssertEqual(abilityScoreChoices.count, improvementCount, @"Rogues get two ability score improvements at level %@", level);
    }
}

- (void)testExpertise {
    
    NSArray* expertiseChoices = [_character allUnallocatedChoicesWithTag:DKChoiceRogueExpertise];
    XCTAssertEqual(expertiseChoices.count, 2, @"Rogues can allocate expertise to two skills at level 1");
    
    DKChoiceModifierGroup* expertiseChoice = expertiseChoices[0];
    [expertiseChoice choose:expertiseChoice.choices[0]];
    XCTAssertEqualObjects(_character.skills.acrobatics.proficiencyLevel.value, @2, @"Rogue should gain a second proficiency level in the selected skill.");
    XCTAssertEqualObjects(_character.skills.acrobatics.value, @4, @"Rogue should gain a second proficiency level in the selected skill.");
    [expertiseChoice choose:nil];
    
    _character.level.base = @6;
    expertiseChoices = [_character allUnallocatedChoicesWithTag:DKChoiceRogueExpertise];
    XCTAssertEqual(expertiseChoices.count, 4, @"Rogues gain two more expertise choices at level 6.");
}

- (void)testRogueTraits {
    
    NSArray* levelLearned = @[ @1, @1, @2, @5, @7, @11, @14, @18, @20 ];
    NSArray*
    
    abilityNames = @[ @"Sneak Attack", @"Thieves' Cant", @"Cunning Action", @"Uncanny Dodge",
                               @"Evasion", @"Reliable Talent", @"Blindsense", @"Elusive", @"Stroke of Luck"];
    for (int i = 0; i < levelLearned.count; i++) {
        NSNumber* level = levelLearned[i];
        NSString* ability = abilityNames[i];
        _character.level.base = level;
        XCTAssertTrue([_character.classes.rogue.classTraits.value containsObject:ability], @"Rogue learns %@ at level %@", ability, level);
    }
    
    XCTAssertEqualObjects(_character.savingThrows.wisdom.proficiencyLevel.value, @1, @"Rogue gets Wisdom saving throw proficiency through Slippery Mind.");
    XCTAssertEqualObjects(_character.classes.rogue.strokeOfLuckUsesMax.value, @1, @"Rogue gets 1 use of Stroke of Luck at level 20.");
}

- (void)testThiefRoguishArchetype {
    
    DKChoiceModifierGroup* roguishArchetype = [_character firstUnallocatedChoiceWithTag:DKChoiceRogueRoguishArchetype];
    XCTAssertNil(roguishArchetype, @"Rogues can't choose Roguish Archetype until level 3.");
    
    _character.level.base = @3;
    roguishArchetype = [_character firstUnallocatedChoiceWithTag:DKChoiceRogueRoguishArchetype];
    DKModifierGroup* thiefArchetype = roguishArchetype.choices[0];
    [roguishArchetype choose:thiefArchetype];
    
    NSArray* levelLearned = @[ @3, @3, @9, @13, @17 ];
    NSArray*
    
    abilityNames = @[ @"Fast Hands", @"Second-Story Work", @"Supreme Sneak", @"Use Magic Device", @"Thief's Reflexes"];
    for (int i = 0; i < levelLearned.count; i++) {
        NSNumber* level = levelLearned[i];
        NSString* ability = abilityNames[i];
        _character.level.base = level;
        XCTAssertTrue([_character.classes.rogue.classTraits.value containsObject:ability], @"Thief learns %@ at level %@", ability, level);
    }
}

@end
