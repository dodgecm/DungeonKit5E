//
//  DKFighter5ETests.m
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DKCharacter5E.h"
#import "DKModifierGroupTags5E.h"

@interface DKFighter5ETests : XCTestCase
@property (nonatomic, strong) DKCharacter5E* character;
@end

@implementation DKFighter5ETests

@synthesize character = _character;

- (void)setUp {
    [super setUp];
    _character = [[DKCharacter5E alloc] init];
    _character.experiencePoints.base = @(-1);
    _character.level.base = @(1);
    [_character chooseClass:kDKClassType5E_Fighter];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHitDice {
    
    XCTAssertEqualObjects(_character.hitDiceMax.value.stringValue, @"1d10", @"Fighter should have 1d10 hit dice at level 1.");
    _character.level.base = @5;
    XCTAssertEqualObjects(_character.hitDiceMax.value.stringValue, @"5d10", @"Fighter should have 5d10 hit dice at level 5.");
}

- (void)testSavingThrows {
    XCTAssertEqualObjects(_character.savingThrows.strength.proficiencyLevel.value, @1, @"Fighters have proficiency in strength saving throws.");
    XCTAssertEqualObjects(_character.savingThrows.constitution.proficiencyLevel.value, @1, @"Fighters have proficiency in constitution saving throws.");
    
    XCTAssertEqualObjects(_character.savingThrows.strength.value, @2, @"Fighters have proficiency in strength saving throws.");
    _character.abilities.strength.base = @12;
    XCTAssertEqualObjects(_character.savingThrows.strength.value, @3, @"Fighters have proficiency in strength saving throws.");
}

- (void)testWeaponProficiencies {
    XCTAssertTrue([_character.weaponProficiencies.value containsObject:@"Simple Weapons"], @"Fighters can use simple weapons.");
    XCTAssertTrue([_character.weaponProficiencies.value containsObject:@"Martial Weapons"], @"Fighters can use martial weapons.");
}

- (void)testArmorProficiencies {
    XCTAssertTrue([_character.armorProficiencies.value containsObject:@"Light Armor"], @"Fighters can wear light armor.");
    XCTAssertTrue([_character.armorProficiencies.value containsObject:@"Medium Armor"], @"Fighters can wear medium armor.");
    XCTAssertTrue([_character.armorProficiencies.value containsObject:@"Heavy Armor"], @"Fighters can wear heavy armor.");
    XCTAssertTrue([_character.armorProficiencies.value containsObject:@"Shields"], @"Fighters can use shields.");
}

- (void)testSkillProficiencies {
    
    NSArray* skillChoices = [_character allModifierGroupsWithTag:DKChoiceFighterSkillProficiency];
    XCTAssertEqual(skillChoices.count, 2, @"Fighters get two skill proficiency choices.");
    
    XCTAssertEqualObjects(_character.skills.acrobatics.proficiencyLevel.value, @0, @"Fighters do not start out with acrobatics proficiency.");
    DKChoiceModifierGroup* skillChoice = (DKChoiceModifierGroup*) skillChoices[0];
    [skillChoice choose:skillChoice.choices[0]];
    XCTAssertEqualObjects(_character.skills.acrobatics.proficiencyLevel.value, @1, @"Acrobatics proficiency should be granted.");
    
    XCTAssertEqualObjects(_character.skills.animalHandling.proficiencyLevel.value, @0, @"Fighters do not start out with animal handling proficiency.");
    skillChoice = (DKChoiceModifierGroup*) skillChoices[1];
    [skillChoice choose:skillChoice.choices[1]];
    XCTAssertEqualObjects(_character.skills.animalHandling.proficiencyLevel.value, @1, @"Animal handling proficiency should be granted.");
}

- (void)testAbilityScoreImprovements {
    
    NSArray* abilityScoreChoices = [_character allUnallocatedChoicesWithTag:DKChoiceAbilityScoreImprovement];
    XCTAssertEqual(abilityScoreChoices.count, 0, @"Fighters don't start with ability score improvements");
    
    NSArray* levels = @[ @4, @6, @8, @12, @14, @16, @19];
    int improvementCount = 0;
    for (NSNumber* level in levels) {
        
        _character.level.base = level;
        improvementCount += 2;
        abilityScoreChoices = [_character allUnallocatedChoicesWithTag:DKChoiceAbilityScoreImprovement];
        XCTAssertEqual(abilityScoreChoices.count, improvementCount, @"Fighters get two ability score improvements at level %@", level);
    }
    
    DKChoiceModifierGroup* abilityScoreChoice = [_character firstUnallocatedChoiceWithTag:DKChoiceAbilityScoreImprovement];
    [abilityScoreChoice choose:abilityScoreChoice.choices[0]];
    XCTAssertEqualObjects(_character.abilities.strength.value, @11, @"Strength should be increased by one.");
    
    _character.abilities.strength.base = @25;
    XCTAssertEqualObjects(_character.abilities.strength.value, @25, @"Ability score improvement cannot increase the score above 20.");
}

- (void)testArcheryFightingStyle {
    
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Longbow
                                                         forCharacter:_character
                                                           isMainHand:YES]];
     XCTAssertEqualObjects(_character.equipment.mainHandWeaponAttackBonus.value, @2, @"Fighter does not have a ranged bonus to hit.");
    
    DKChoiceModifierGroup* fightingStyleChoice = [_character firstUnallocatedChoiceWithTag:DKChoiceFighterFightingStyle];
    [fightingStyleChoice choose:fightingStyleChoice.choices[0]];
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponAttackBonus.value, @4, @"Fighter gains a ranged bonus to hit.");
    
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Longsword
                                                         forCharacter:_character
                                                           isMainHand:YES]];
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponAttackBonus.value, @2, @"Bonus only applies to ranged weapons.");
}

- (void)testDefenseFightingStyle {

    DKChoiceModifierGroup* fightingStyleChoice = [_character firstUnallocatedChoiceWithTag:DKChoiceFighterFightingStyle];
    [fightingStyleChoice choose:fightingStyleChoice.choices[1]];
    
    XCTAssertEqualObjects(_character.armorClass.value, @10, @"Defense style only is active while wearing armor.");
    
    [_character.equipment equipArmor:[DKArmorBuilder5E armorOfType:kDKArmorType5E_Hide forCharacter:_character]];
    XCTAssertEqualObjects(_character.armorClass.value, @13, @"Defense style gives +1 AC while wearing armor.");
}

- (void)testDuelingFightingStyle {
    
    DKChoiceModifierGroup* fightingStyleChoice = [_character firstUnallocatedChoiceWithTag:DKChoiceFighterFightingStyle];
    [fightingStyleChoice choose:fightingStyleChoice.choices[2]];
    
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Dagger
                                                         forCharacter:_character
                                                           isMainHand:YES]];
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponDamage.value.stringValue, @"1d4+2", @"Dueling style provides +2 damage bonus.");
    
    [_character.equipment equipShield:[DKArmorBuilder5E shieldWithEquipment:_character.equipment
                                                         armorProficiencies:_character.armorProficiencies]];
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponDamage.value.stringValue, @"1d4+2", @"Dueling style still works with a shield.");
    
    [_character.equipment equipOffHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Dagger
                                                         forCharacter:_character
                                                           isMainHand:NO]];
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponDamage.value.stringValue, @"1d4", @"Dueling bonus goes away with 2 weapons equipped.");
    
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Greataxe
                                                         forCharacter:_character
                                                           isMainHand:YES]];
    [_character.equipment equipShield:nil];
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponDamage.value.stringValue, @"1d12", @"Dueling bonus goes away with two-handed weapon equipped.");
}

- (void)testGreatWeaponFightingStyle {
    
    //It's only an informational
    DKChoiceModifierGroup* fightingStyleChoice = [_character firstUnallocatedChoiceWithTag:DKChoiceFighterFightingStyle];
    DKModifierGroup* greatWeaponStyle = fightingStyleChoice.choices[3];
    [fightingStyleChoice choose:greatWeaponStyle];
    
    DKModifier* modifier = greatWeaponStyle.modifiers[0];
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Quarterstaff
                                                         forCharacter:_character
                                                           isMainHand:YES]];
    XCTAssertTrue(modifier.enabled, @"Great weapon style is active for versatile weapons that are held in both hands");
    
    [_character.equipment equipShield:[DKArmorBuilder5E shieldForCharacter:_character]];
    XCTAssertFalse(modifier.enabled, @"Great weapon style is inactive once a versatile weapon is only held in one hand");
    
    [_character.equipment equipShield:nil];
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_HeavyCrossbow
                                                         forCharacter:_character
                                                           isMainHand:YES]];
    XCTAssertFalse(modifier.enabled, @"Great weapon style is inactive for ranged weapons");
}

- (void)testProtectionFightingStyle {
    
    DKChoiceModifierGroup* fightingStyleChoice = [_character firstUnallocatedChoiceWithTag:DKChoiceFighterFightingStyle];
    DKModifierGroup* protectionStyle = fightingStyleChoice.choices[4];
    [fightingStyleChoice choose:protectionStyle];
    
    DKModifier* modifier = protectionStyle.modifiers[0];
    XCTAssertFalse(modifier.enabled, @"Protection style requires a shield in the off hand");
    
    [_character.equipment equipShield:[DKArmorBuilder5E shieldForCharacter:_character]];
    XCTAssertTrue(modifier.enabled, @"Protection style requires a shield in the off hand");
}

- (void)testTwoWeaponFightingStyle {
    
    DKChoiceModifierGroup* fightingStyleChoice = [_character firstUnallocatedChoiceWithTag:DKChoiceFighterFightingStyle];
    DKModifierGroup* twoWeaponStyle = fightingStyleChoice.choices[5];
    [fightingStyleChoice choose:twoWeaponStyle];
    
    XCTAssertTrue([_character.weaponProficiencies.value containsObject:@"Two-Weapon Fighting"], @"Two weapon style provides a weapon proficiency.");
}

- (void)testSecondWind {
    
    XCTAssertTrue([_character.classes.fighter.classTraits.value containsObject:@"Second Wind"], @"Fighters get Second Wind at level 1.");
    XCTAssertEqualObjects(_character.classes.fighter.secondWindUsesMax.value, @1, @"Fighters get one use of Second Wind per short or long rest.");
}

- (void)testActionSurge {
    
    _character.level.base = @2;
    XCTAssertTrue([_character.classes.fighter.classTraits.value containsObject:@"Action Surge"], @"Fighters get Action Surge at level 2.");
    XCTAssertEqualObjects(_character.classes.fighter.actionSurgeUsesMax.value, @1, @"Fighters get one use of Action Surge per short or long rest.");

    _character.level.base = @17;
    XCTAssertEqualObjects(_character.classes.fighter.actionSurgeUsesMax.value, @2, @"Fighters get a second use of Action Surge at level 17.");
}

- (void)testExtraAttacks {
    
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Dagger
                                                         forCharacter:_character
                                                           isMainHand:YES]];
    [_character.equipment equipOffHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Dagger
                                                         forCharacter:_character
                                                           isMainHand:NO]];
    
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponAttacksPerAction.value, @1, @"Fighters start with one attack per round.");
    XCTAssertEqualObjects(_character.equipment.offHandWeaponAttacksPerAction.value, @1, @"Fighters start with one attack per round.");
    
    _character.level.base = @5;
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponAttacksPerAction.value, @2, @"Fighters get a second attack per round at level 5.");
    XCTAssertEqualObjects(_character.equipment.offHandWeaponAttacksPerAction.value, @2, @"Fighters get a second attack per round at level 5.");
    
    _character.level.base = @11;
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponAttacksPerAction.value, @3, @"Fighters get a third attack per round at level 11.");
    XCTAssertEqualObjects(_character.equipment.offHandWeaponAttacksPerAction.value, @3, @"Fighters get a third attack per round at level 11.");
    
    _character.level.base = @20;
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponAttacksPerAction.value, @4, @"Fighters get a fourth attack per round at level 20.");
    XCTAssertEqualObjects(_character.equipment.offHandWeaponAttacksPerAction.value, @4, @"Fighters get a fourth attack per round at level 20.");
}

- (void)testIndomitable {
    
    _character.level.base = @9;
    XCTAssertTrue([_character.classes.fighter.classTraits.value containsObject:@"Indomitable"], @"Fighters get Indomitable at level 9.");
    XCTAssertEqualObjects(_character.classes.fighter.indomitableUsesMax.value, @1, @"Fighters get one use of Indomitable per short or long rest.");
    
    _character.level.base = @13;
    XCTAssertEqualObjects(_character.classes.fighter.indomitableUsesMax.value, @2, @"Fighters get a second use of Indomitable at level 13.");
    
    _character.level.base = @17;
    XCTAssertEqualObjects(_character.classes.fighter.indomitableUsesMax.value, @3, @"Fighters get a third use of Indomitable at level 17.");
}

- (void)testChampionArchetype {

    DKChoiceModifierGroup* martialArchetype = [_character firstUnallocatedChoiceWithTag:DKChoiceFighterMartialArchetype];
    XCTAssertNil(martialArchetype, @"Fighters can't choose Martial Archetype until level 3.");
    
    _character.level.base = @3;
    martialArchetype = [_character firstUnallocatedChoiceWithTag:DKChoiceFighterMartialArchetype];
    DKModifierGroup* championArchetype = martialArchetype.choices[0];
    [martialArchetype choose:championArchetype];
    
    _character.level.base = @3;
    XCTAssertTrue([_character.classes.fighter.classTraits.value containsObject:@"Improved Critical"], @"Champions get Improved Critical at level 3.");
    
    _character.level.base = @7;
    XCTAssertTrue([_character.classes.fighter.classTraits.value containsObject:@"Remarkable Athlete"], @"Champions get Remarkable Athlete at level 7.");
    XCTAssertEqualObjects(_character.skills.athletics.value, @2, @"Remarkable Athlete gives bonuses to non-proficient Strength skills.");
    XCTAssertEqualObjects(_character.skills.acrobatics.value, @2, @"Remarkable Athlete gives bonuses to non-proficient Dexterity skills.");
    
    _character.skills.athletics.proficiencyLevel.base = @1;
    XCTAssertEqualObjects(_character.skills.athletics.value, @3, @"Remarkable Athlete bonus goes away if the skill has proficiency.");
    
    _character.level.base = @10;
    NSArray* fightingStyles = [_character allUnallocatedChoicesWithTag:DKChoiceFighterFightingStyle];
    XCTAssertEqual(fightingStyles.count, 2, @"Champions get a second fighting style at level 10.");
    
    _character.level.base = @15;
    XCTAssertTrue([_character.classes.fighter.classTraits.value containsObject:@"Superior Critical"], @"Champions get Superior Critical at level 15.");
    
    _character.level.base = @18;
    XCTAssertTrue([_character.classes.fighter.classTraits.value containsObject:@"Survivor"], @"Champions get Survivor at level 18.");
}

@end
