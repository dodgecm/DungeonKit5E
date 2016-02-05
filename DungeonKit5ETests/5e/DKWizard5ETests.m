//
//  DKWizard5ETests.m
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DKCharacter5E.h"
#import "DKModifierGroupTags5E.h"

@interface DKWizard5ETests : XCTestCase
@property (nonatomic, strong) DKCharacter5E* character;
@end

@implementation DKWizard5ETests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _character = [[DKCharacter5E alloc] init];
    _character.experiencePoints.base = @(-1);
    _character.level.base = @(1);
    [_character chooseClass:kDKClassType5E_Wizard];
}

- (void)testHitDice {
    
    XCTAssertEqualObjects(_character.hitDiceMax.value.stringValue, @"1d6", @"Wizard should have 1d6 hit dice at level 1.");
    _character.level.base = @5;
    XCTAssertEqualObjects(_character.hitDiceMax.value.stringValue, @"5d6", @"Wizard should have 5d6 hit dice at level 5.");
}

- (void)testSavingThrows {
    XCTAssertEqualObjects(_character.savingThrows.intelligence.proficiencyLevel.value, @1, @"Wizards have proficiency in intelligence saving throws.");
    XCTAssertEqualObjects(_character.savingThrows.wisdom.proficiencyLevel.value, @1, @"Wizards have proficiency in wisdom saving throws.");
    
    XCTAssertEqualObjects(_character.savingThrows.intelligence.value, @2, @"Wizards have proficiency in intelligence saving throws.");
    _character.abilities.intelligence.base = @12;
    XCTAssertEqualObjects(_character.savingThrows.intelligence.value, @3, @"Wizards have proficiency in intelligence saving throws.");
}

- (void)testWeaponProficiencies {
    NSArray* weaponProficiencies = @[ @(kDKWeaponType5E_Dagger),
                                      @(kDKWeaponType5E_Dart),
                                      @(kDKWeaponType5E_Sling),
                                      @(kDKWeaponType5E_Quarterstaff),
                                      @(kDKWeaponType5E_LightCrossbow) ];
    for (NSNumber* weaponProficiency in weaponProficiencies) {
        XCTAssertTrue([_character.weaponProficiencies.value containsObject:[DKWeaponBuilder5E proficiencyNameForWeapon:weaponProficiency.integerValue]],
                      @"Wizards can use limited simple weapons.");
    }
}

- (void)testArmorProficiencies {
    XCTAssertEqual(_character.armorProficiencies.value.count, 0, @"Wizards have no armor proficiencies.");
}

- (void)testSkillProficiencies {
    
    NSArray* skillChoices = [_character allModifierGroupsWithTag:DKChoiceWizardSkillProficiency];
    XCTAssertEqual(skillChoices.count, 2, @"Wizards get two skill proficiency choices.");
    
    XCTAssertEqualObjects(_character.skills.arcana.proficiencyLevel.value, @0, @"Wizards do not start out with arcana proficiency.");
    DKChoiceModifierGroup* skillChoice = (DKChoiceModifierGroup*) skillChoices[0];
    [skillChoice choose:skillChoice.choices[0]];
    XCTAssertEqualObjects(_character.skills.arcana.proficiencyLevel.value, @1, @"Arcana proficiency should be granted.");
    
    XCTAssertEqualObjects(_character.skills.history.proficiencyLevel.value, @0, @"Wizards do not start out with history proficiency.");
    skillChoice = (DKChoiceModifierGroup*) skillChoices[1];
    [skillChoice choose:skillChoice.choices[1]];
    XCTAssertEqualObjects(_character.skills.history.proficiencyLevel.value, @1, @"History proficiency should be granted.");
}

- (void)testTraits {
    XCTAssertTrue([_character.classes.wizard.classTraits.value containsObject:@"Ritual Casting"], @"Wizards have the Ritual Casting trait.");
    XCTAssertTrue([_character.classes.wizard.classTraits.value containsObject:@"Spellcasting Focus"], @"Wizards have the Spellcasting Focus trait.");
}

- (void)testAbilityScoreImprovements {
    
    NSArray* abilityScoreChoices = [_character allUnallocatedChoicesWithTag:DKChoiceAbilityScoreImprovement];
    XCTAssertEqual(abilityScoreChoices.count, 0, @"Wizards don't start with ability score improvements");
    
    NSArray* levels = @[ @4, @8, @12, @16, @19];
    int improvementCount = 0;
    for (NSNumber* level in levels) {
        
        _character.level.base = level;
        improvementCount += 2;
        abilityScoreChoices = [_character allUnallocatedChoicesWithTag:DKChoiceAbilityScoreImprovement];
        XCTAssertEqual(abilityScoreChoices.count, improvementCount, @"Wizards get two ability score improvements at level %@", level);
    }
}

- (void)testSpellSaveDC {
    
    XCTAssertEqualObjects(_character.spells.spellSaveDC.value, @10, @"Spell save DC starts out at 10 (8 + proficiency).");
    _character.abilities.intelligence.base = @14;
    XCTAssertEqualObjects(_character.spells.spellSaveDC.value, @12, @"Spell save DC should increase with intelligence.");
    _character.level.base = @9;
    XCTAssertEqualObjects(_character.spells.spellSaveDC.value, @14, @"Spell save DC should increase with proficiency bonus.");
}

- (void)testSpellAttackBonus {
    
    XCTAssertEqualObjects(_character.spells.spellAttackBonus.value, @2, @"Spell attack bonus starts out at 2 (proficiency).");
    _character.abilities.intelligence.base = @14;
    XCTAssertEqualObjects(_character.spells.spellAttackBonus.value, @4, @"Spell attack bonus should increase with intelligence.");
    _character.level.base = @9;
    XCTAssertEqualObjects(_character.spells.spellAttackBonus.value, @6, @"Spell attack bonus should increase with proficiency bonus.");
}

- (void)testPreparedSpells {
    
    XCTAssertEqualObjects(_character.spells.preparedSpellsMax.value, @1, @"Prepared spells limit starts out at 1 (level).");
    _character.abilities.intelligence.base = @14;
    XCTAssertEqualObjects(_character.spells.preparedSpellsMax.value, @3, @"Prepared spells limit should increase with intelligence.");
    _character.level.base = @9;
    XCTAssertEqualObjects(_character.spells.preparedSpellsMax.value, @11, @"Prepared spells limit should increase with level.");
    _character.abilities.intelligence.base = @1;
    _character.level.base = @1;
    XCTAssertEqualObjects(_character.spells.preparedSpellsMax.value, @1, @"Prepared spells limit cannot go below 1.");
}

- (void)testCantrips {
    
    NSArray* cantripChoices = [_character allUnallocatedChoicesWithTag:DKChoiceWizardCantrip];
    XCTAssertEqual(cantripChoices.count, 3, @"Wizards get three cantrip choices.");
    
    XCTAssertEqual(_character.spells.spellbook.cantrips.value.count, 0, @"Wizards do not have cantrips until they are chosen.");
    DKChoiceModifierGroup* cantripChoice = cantripChoices[0];
    [cantripChoice choose:cantripChoice.choices[0]];
    XCTAssertTrue([_character.spells.spellbook.cantrips.value containsObject:@"Acid Splash"], @"Wizard should be granted the cantrip.");
    
    [cantripChoice choose:nil];
    _character.level.base = @4;
    cantripChoices = [_character allUnallocatedChoicesWithTag:DKChoiceWizardCantrip];
    XCTAssertEqual(cantripChoices.count, 4, @"Wizards get a fourth cantrip at level 4.");
    
    _character.level.base = @10;
    cantripChoices = [_character allUnallocatedChoicesWithTag:DKChoiceWizardCantrip];
    XCTAssertEqual(cantripChoices.count, 5, @"Wizards get a fifth cantrip at level 10.");
}

- (void)testSpellbook {
    
    NSArray* spellbookChoices = [_character allUnallocatedChoicesWithTag:DKChoiceWizardSpellbook];
    XCTAssertEqual(spellbookChoices.count, 6, @"Wizards can learn six first-level spells.");
    
    for (int i = 1; i <= 20; i++) {
        _character.level.base = @(i);
        spellbookChoices = [_character allUnallocatedChoicesWithTag:DKChoiceWizardSpellbook];
        XCTAssertEqual(spellbookChoices.count, 6 + (i-1) * 2, @"Wizards can learn two new spells for each level.");
    }
    
    DKChoiceModifierGroup* firstChoice = [_character firstUnallocatedChoiceWithTag:DKChoiceWizardSpellbook];
    [firstChoice choose:firstChoice.choices[0]];
    XCTAssertTrue([_character.spells.spellbook.firstLevelSpells.value containsObject:@"Burning Hands"], @"Wizard should have the spell in the spellbook.");
}

- (void)testSpellSlots {
    
    //First level spells
    _character.level.base = @1;
    XCTAssertEqualObjects(_character.spells.firstLevelSpellSlotsMax.value, @2, @"Wizards have 2 first-level spells at level 1");
    _character.level.base = @2;
    XCTAssertEqualObjects(_character.spells.firstLevelSpellSlotsMax.value, @3, @"Wizards have 3 first-level spells at level 2");
    _character.level.base = @3;
    XCTAssertEqualObjects(_character.spells.firstLevelSpellSlotsMax.value, @4, @"Wizards have 4 first-level spells at level 3");
    
    //Second level spells
    _character.level.base = @2;
    XCTAssertEqualObjects(_character.spells.secondLevelSpellSlotsMax.value, @0, @"Wizards have 0 second-level spells at level 2");
    _character.level.base = @3;
    XCTAssertEqualObjects(_character.spells.secondLevelSpellSlotsMax.value, @2, @"Wizards have 2 second-level spells at level 3");
    _character.level.base = @4;
    XCTAssertEqualObjects(_character.spells.secondLevelSpellSlotsMax.value, @3, @"Wizards have 3 second-level spells at level 4");
    
    //Third level spells
    _character.level.base = @4;
    XCTAssertEqualObjects(_character.spells.thirdLevelSpellSlotsMax.value, @0, @"Wizards have 0 third-level spells at level 4");
    _character.level.base = @5;
    XCTAssertEqualObjects(_character.spells.thirdLevelSpellSlotsMax.value, @2, @"Wizards have 2 third-level spells at level 5");
    _character.level.base = @6;
    XCTAssertEqualObjects(_character.spells.thirdLevelSpellSlotsMax.value, @3, @"Wizards have 3 third-level spells at level 6");
    
    //Fourth level spells
    _character.level.base = @6;
    XCTAssertEqualObjects(_character.spells.fourthLevelSpellSlotsMax.value, @0, @"Wizards have 0 fourth-level spells at level 6");
    _character.level.base = @7;
    XCTAssertEqualObjects(_character.spells.fourthLevelSpellSlotsMax.value, @1, @"Wizards have 1 fourth-level spells at level 7");
    _character.level.base = @8;
    XCTAssertEqualObjects(_character.spells.fourthLevelSpellSlotsMax.value, @2, @"Wizards have 2 fourth-level spells at level 8");
    _character.level.base = @9;
    XCTAssertEqualObjects(_character.spells.fourthLevelSpellSlotsMax.value, @3, @"Wizards have 3 fourth-level spells at level 9");
    
    //Fifth level spells
    _character.level.base = @8;
    XCTAssertEqualObjects(_character.spells.fifthLevelSpellSlotsMax.value, @0, @"Wizards have 0 fifth-level spells at level 8");
    _character.level.base = @9;
    XCTAssertEqualObjects(_character.spells.fifthLevelSpellSlotsMax.value, @1, @"Wizards have 1 fifth-level spells at level 9");
    _character.level.base = @10;
    XCTAssertEqualObjects(_character.spells.fifthLevelSpellSlotsMax.value, @2, @"Wizards have 2 fifth-level spells at level 10");
    _character.level.base = @18;
    XCTAssertEqualObjects(_character.spells.fifthLevelSpellSlotsMax.value, @3, @"Wizards have 3 fifth-level spells at level 18");
    
    //Sixth level spells
    _character.level.base = @10;
    XCTAssertEqualObjects(_character.spells.sixthLevelSpellSlotsMax.value, @0, @"Wizards have 0 sixth-level spells at level 10");
    _character.level.base = @11;
    XCTAssertEqualObjects(_character.spells.sixthLevelSpellSlotsMax.value, @1, @"Wizards have 1 sixth-level spells at level 11");
    _character.level.base = @19;
    XCTAssertEqualObjects(_character.spells.sixthLevelSpellSlotsMax.value, @2, @"Wizards have 2 sixth-level spells at level 19");
    
    //Seventh level spells
    _character.level.base = @12;
    XCTAssertEqualObjects(_character.spells.seventhLevelSpellSlotsMax.value, @0, @"Wizards have 0 seventh-level spells at level 12");
    _character.level.base = @13;
    XCTAssertEqualObjects(_character.spells.seventhLevelSpellSlotsMax.value, @1, @"Wizards have 1 seventh-level spells at level 13");
    _character.level.base = @20;
    XCTAssertEqualObjects(_character.spells.seventhLevelSpellSlotsMax.value, @2, @"Wizards have 2 seventh-level spells at level 20");
    
    //Eighth level spells
    _character.level.base = @14;
    XCTAssertEqualObjects(_character.spells.eighthLevelSpellSlotsMax.value, @0, @"Wizards have 0 eighth-level spells at level 14");
    _character.level.base = @15;
    XCTAssertEqualObjects(_character.spells.eighthLevelSpellSlotsMax.value, @1, @"Wizards have 1 eighth-level spells at level 15");
    
    //Ninth level spells
    _character.level.base = @16;
    XCTAssertEqualObjects(_character.spells.ninthLevelSpellSlotsMax.value, @0, @"Wizards have 0 ninth-level spells at level 16");
    _character.level.base = @17;
    XCTAssertEqualObjects(_character.spells.ninthLevelSpellSlotsMax.value, @1, @"Wizards have 1 ninth-level spells at level 17");
}

- (void)testArcaneRecovery {
    
    XCTAssertTrue([_character.classes.wizard.classTraits.value containsObject:@"Arcane Recovery"], @"Wizards have the Arcane Recovery trait.");
    
    XCTAssertEqualObjects(_character.classes.wizard.arcaneRecoveryUsesMax.value, @1, @"Wizards have 1 use of Arcane Recovery per day");
    XCTAssertEqualObjects(_character.classes.wizard.arcaneRecoverySpellSlots.value, @1, @"Wizards regain 1 spell slot when using Arcane Recovery");
    
    _character.level.base = @3;
    XCTAssertEqualObjects(_character.classes.wizard.arcaneRecoverySpellSlots.value, @2, @"Wizards regain 2 spell slots at level 3");
}

- (void)testSpellMastery {
    
    NSArray* spellMasteryChoices = [_character allUnallocatedChoicesWithTag:DKChoiceWizardSpellMastery];
    XCTAssertEqual(spellMasteryChoices.count, 0, @"Wizard does not learn Spell Mastery until level 18");
    
    _character.level.base = @18;
    spellMasteryChoices = [_character allUnallocatedChoicesWithTag:DKChoiceWizardSpellMastery];
    XCTAssertEqual(spellMasteryChoices.count, 2, @"Wizard learns Spell Mastery at level 18");
    XCTAssertTrue([_character.classes.wizard.classTraits.value containsObject:@"Spell Mastery"], @"Wizards have the Spell Mastery trait.");
    
    DKChoiceModifierGroup* firstLevelChoice = spellMasteryChoices[0];
    [firstLevelChoice choose:firstLevelChoice.choices[0]];
    XCTAssertTrue([_character.classes.wizard.spellMasterySpells.value containsObject:@"Burning Hands"], @"Wizard's mastered spell should be added.");
    
    DKChoiceModifierGroup* secondLevelChoice = spellMasteryChoices[1];
    [secondLevelChoice choose:secondLevelChoice.choices[0]];
    XCTAssertTrue([_character.classes.wizard.spellMasterySpells.value containsObject:@"Arcane Lock"], @"Wizard's mastered spell should be added.");
}

- (void)testSignatureSpells {
    
    NSArray* signatureSpellChoices = [_character allUnallocatedChoicesWithTag:DKChoiceWizardSignatureSpell];
    XCTAssertEqual(signatureSpellChoices.count, 0, @"Wizard does not learn Signature Spells until level 20");
    
    _character.level.base = @20;
    signatureSpellChoices = [_character allUnallocatedChoicesWithTag:DKChoiceWizardSignatureSpell];
    XCTAssertEqual(signatureSpellChoices.count, 2, @"Wizard learns Signature Spells at level 20");
    XCTAssertTrue([_character.classes.wizard.classTraits.value containsObject:@"Signature Spells"], @"Wizards have the Signature Spells trait.");
    
    DKChoiceModifierGroup* firstChoice = signatureSpellChoices[0];
    [firstChoice choose:firstChoice.choices[0]];
    XCTAssertTrue([_character.classes.wizard.signatureSpells.value containsObject:@"Counterspell"], @"Wizard's signature spell should be added.");
    XCTAssertTrue([_character.spells.preparedSpells.value containsObject:@"Counterspell"], @"Wizard's signature spells are always prepared.");
}

- (void)testEvocationArcaneTradition {
    
    DKChoiceModifierGroup* arcaneTradition = [_character firstUnallocatedChoiceWithTag:DKChoiceWizardArcaneTradition];
    XCTAssertNil(arcaneTradition, @"Wizards can't choose Arcane Tradition until level 2.");
    
    _character.level.base = @2;
    arcaneTradition = [_character firstUnallocatedChoiceWithTag:DKChoiceWizardArcaneTradition];
    DKModifierGroup* evocationTradition = arcaneTradition.choices[0];
    [arcaneTradition choose:evocationTradition];
    
    NSArray* levelLearned = @[ @2, @2, @6, @10, @14 ];
    NSArray*
    
    abilityNames = @[ @"Evocation Savant", @"Sculpt Spells", @"Potent Cantrip", @"Empowered Evocation", @"Overchannel"];
    for (int i = 0; i < levelLearned.count; i++) {
        NSNumber* level = levelLearned[i];
        NSString* ability = abilityNames[i];
        _character.level.base = level;
        XCTAssertTrue([_character.classes.wizard.classTraits.value containsObject:ability], @"Wizard learns %@ at level %@", ability, level);
    }
}

@end
