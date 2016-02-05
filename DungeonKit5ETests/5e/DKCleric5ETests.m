//
//  DKCleric5ETests.m
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <DungeonKit/DungeonKit.h>
#import "DKCharacter5E.h"
#import "DKModifierGroupTags5E.h"

@interface DKCleric5ETests : XCTestCase
@property (nonatomic, strong) DKCharacter5E* character;
@end

@implementation DKCleric5ETests

@synthesize character = _character;

- (void)setUp {
    [super setUp];
    
    _character = [[DKCharacter5E alloc] init];
    _character.experiencePoints.base = @(-1);
    _character.level.base = @(1);
    [_character chooseClass:kDKClassType5E_Cleric];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHitDice {
    
    XCTAssertEqualObjects(_character.hitDiceMax.value.stringValue, @"1d8", @"Cleric should have 1d8 hit dice at level 1.");
    _character.level.base = @5;
    XCTAssertEqualObjects(_character.hitDiceMax.value.stringValue, @"5d8", @"Cleric should have 5d8 hit dice at level 5.");
}

- (void)testHitPointsMax {
    
    XCTAssertEqualObjects(_character.hitPointsMax.value, @8, @"Cleric should have 8 HP at level 1.");
    NSArray* hitPointsChoices = [_character allUnallocatedChoicesWithTag:DKChoiceHitPointsMax];
    XCTAssertEqual(hitPointsChoices.count, 0, @"Cleric shouldn't have any HP increases at level 1.");
    
    _character.level.base = @6;
    hitPointsChoices = [_character allUnallocatedChoicesWithTag:DKChoiceHitPointsMax];
    XCTAssertEqual(hitPointsChoices.count, 5, @"Cleric should have 5 HP increases at level 6.");
    
    DKChoiceModifierGroup* firstChoice = hitPointsChoices[0];
    [firstChoice choose:firstChoice.choices[0]];
    XCTAssertEqual(firstChoice.choices.count, 8, @"Cleric should be able to choose any number between 1 and 8.");
    XCTAssertEqualObjects(_character.hitPointsMax.value, @9, @"Cleric should have 9 HP after choosing the 1 HP bonus.");
}

- (void)testSpellSaveDC {
    
    XCTAssertEqualObjects(_character.spells.spellSaveDC.value, @10, @"Spell save DC starts out at 10 (8 + proficiency).");
    _character.abilities.wisdom.base = @14;
    XCTAssertEqualObjects(_character.spells.spellSaveDC.value, @12, @"Spell save DC should increase with wisdom.");
    _character.level.base = @9;
    XCTAssertEqualObjects(_character.spells.spellSaveDC.value, @14, @"Spell save DC should increase with proficiency bonus.");
}

- (void)testSpellAttackBonus {
    
    XCTAssertEqualObjects(_character.spells.spellAttackBonus.value, @2, @"Spell attack bonus starts out at 2 (proficiency).");
    _character.abilities.wisdom.base = @14;
    XCTAssertEqualObjects(_character.spells.spellAttackBonus.value, @4, @"Spell attack bonus should increase with wisdom.");
    _character.level.base = @9;
    XCTAssertEqualObjects(_character.spells.spellAttackBonus.value, @6, @"Spell attack bonus should increase with proficiency bonus.");
}

- (void)testPreparedSpells {
    
    XCTAssertEqualObjects(_character.spells.preparedSpellsMax.value, @1, @"Prepared spells limit starts out at 1 (level).");
    _character.abilities.wisdom.base = @14;
    XCTAssertEqualObjects(_character.spells.preparedSpellsMax.value, @3, @"Prepared spells limit should increase with wisdom.");
    _character.level.base = @9;
    XCTAssertEqualObjects(_character.spells.preparedSpellsMax.value, @11, @"Prepared spells limit should increase with level.");
    _character.abilities.wisdom.base = @1;
    _character.level.base = @1;
    XCTAssertEqualObjects(_character.spells.preparedSpellsMax.value, @1, @"Prepared spells limit cannot go below 1.");
}

- (void)testTraits {
    XCTAssertTrue([_character.classes.cleric.classTraits.value containsObject:@"Channel Divinity"], @"Clerics have the Channel Divinity trait.");
    XCTAssertTrue([_character.classes.cleric.classTraits.value containsObject:@"Ritual Casting"], @"Clerics have the Ritual Casting trait.");
}

- (void)testSavingThrows {
    XCTAssertEqualObjects(_character.savingThrows.wisdom.proficiencyLevel.value, @1, @"Clerics have proficiency in wisdom saving throws.");
    XCTAssertEqualObjects(_character.savingThrows.charisma.proficiencyLevel.value, @1, @"Clerics have proficiency in charisma saving throws.");
    
    XCTAssertEqualObjects(_character.savingThrows.wisdom.value, @2, @"Clerics have proficiency in wisdom saving throws.");
    _character.abilities.wisdom.base = @12;
    XCTAssertEqualObjects(_character.savingThrows.wisdom.value, @3, @"Clerics have proficiency in wisdom saving throws.");
}

- (void)testWeaponProficiencies {
    XCTAssertTrue([_character.weaponProficiencies.value containsObject:@"Simple Weapons"], @"Clerics can use simple weapons.");
}

- (void)testArmorProficiencies {
    XCTAssertTrue([_character.armorProficiencies.value containsObject:@"Light Armor"], @"Clerics can wear light armor.");
    XCTAssertTrue([_character.armorProficiencies.value containsObject:@"Medium Armor"], @"Clerics can wear medium armor.");
    XCTAssertTrue([_character.armorProficiencies.value containsObject:@"Shields"], @"Clerics can use shields.");
}

- (void)testSkillProficiencies {
    
    NSArray* skillChoices = [_character allModifierGroupsWithTag:DKChoiceClericSkillProficiency];
    XCTAssertEqual(skillChoices.count, 2, @"Clerics get two skill proficiency choices.");
    
    XCTAssertEqualObjects(_character.skills.history.proficiencyLevel.value, @0, @"Clerics do not start out with history proficiency.");
    DKChoiceModifierGroup* skillChoice = (DKChoiceModifierGroup*) skillChoices[0];
    [skillChoice choose:skillChoice.choices[0]];
    XCTAssertEqualObjects(_character.skills.history.proficiencyLevel.value, @1, @"History proficiency should be granted.");
    
    XCTAssertEqualObjects(_character.skills.insight.proficiencyLevel.value, @0, @"Clerics do not start out with insight proficiency.");
    skillChoice = (DKChoiceModifierGroup*) skillChoices[1];
    [skillChoice choose:skillChoice.choices[1]];
    XCTAssertEqualObjects(_character.skills.insight.proficiencyLevel.value, @1, @"Insight proficiency should be granted.");
}

- (void)testChannelDivinity {
    XCTAssertEqualObjects(_character.classes.cleric.channelDivinityUsesMax.value, @0, @"Clerics start with 0 Channel Divinity uses.");
    _character.level.base = @2;
    XCTAssertEqualObjects(_character.classes.cleric.channelDivinityUsesMax.value, @1, @"Clerics get 1 Channel Divinity use at level 2.");
    _character.level.base = @6;
    XCTAssertEqualObjects(_character.classes.cleric.channelDivinityUsesMax.value, @2, @"Clerics get 2 Channel Divinity uses at level 6.");
    _character.level.base = @18;
    XCTAssertEqualObjects(_character.classes.cleric.channelDivinityUsesMax.value, @3, @"Clerics get 3 Channel Divinity uses at level 18.");
}

- (void)testTurnUndead
{
    XCTAssertFalse([_character.classes.cleric.classTraits.value containsObject:@"Channel Divinity - Turn Undead"], @"Cleric doesn't learn Turn Undead until level 2");
    _character.level.base = @2;
    XCTAssertTrue([_character.classes.cleric.classTraits.value containsObject:@"Channel Divinity - Turn Undead"], @"Cleric learns Turn Undead at level 2");
    
    XCTAssertFalse([_character.classes.cleric.classTraits.value containsObject:@"Destroy Undead"], @"Cleric doesn't learn Destroy Undead until level 5");
    _character.level.base = @5;
    XCTAssertTrue([_character.classes.cleric.classTraits.value containsObject:@"Destroy Undead"], @"Cleric learns Destroy Undead at level 5");
    
    XCTAssertEqualObjects(_character.classes.cleric.destroyUndeadCR.value, @"1/2", @"Destroy Undead CR is 1/2 at level 5");
    _character.level.base = @8;
    XCTAssertEqualObjects(_character.classes.cleric.destroyUndeadCR.value, @"1", @"Destroy Undead CR is 1/2 at level 8");
    _character.level.base = @11;
    XCTAssertEqualObjects(_character.classes.cleric.destroyUndeadCR.value, @"2", @"Destroy Undead CR is 2 at level 11");
    _character.level.base = @14;
    XCTAssertEqualObjects(_character.classes.cleric.destroyUndeadCR.value, @"3", @"Destroy Undead CR is 3 at level 14");
    _character.level.base = @17;
    XCTAssertEqualObjects(_character.classes.cleric.destroyUndeadCR.value, @"4", @"Destroy Undead CR is 4 at level 17");
}

- (void)testDivineIntervention {
    
    XCTAssertFalse([_character.classes.cleric.classTraits.value containsObject:@"Divine Intervention"], @"Cleric doesn't learn Divine Intervention until level 2");
    _character.level.base = @10;
    XCTAssertTrue([_character.classes.cleric.classTraits.value containsObject:@"Divine Intervention"], @"Cleric learns Divine Intervention at level 10");
    _character.level.base = @20;
    XCTAssertTrue([_character.classes.cleric.classTraits.value containsObject:@"Divine Intervention"], @"Description for Divine Intervention changes at 20");
}

- (void)testCantrips {
    
    NSArray* cantripChoices = [_character allUnallocatedChoicesWithTag:DKChoiceClericCantrip];
    XCTAssertEqual(cantripChoices.count, 3, @"Clerics get three cantrip choices.");
    
    XCTAssertEqual(_character.spells.spellbook.cantrips.value.count, 0, @"Clerics do not have cantrips until they are chosen.");
    DKChoiceModifierGroup* cantripChoice = cantripChoices[0];
    [cantripChoice choose:cantripChoice.choices[0]];
    XCTAssertTrue([_character.spells.spellbook.cantrips.value containsObject:@"Guidance"], @"Cleric should be granted the cantrip.");
    
    [cantripChoice choose:nil];
    _character.level.base = @4;
    cantripChoices = [_character allUnallocatedChoicesWithTag:DKChoiceClericCantrip];
    XCTAssertEqual(cantripChoices.count, 4, @"Clerics get a fourth cantrip at level 4.");
    
    _character.level.base = @10;
    cantripChoices = [_character allUnallocatedChoicesWithTag:DKChoiceClericCantrip];
    XCTAssertEqual(cantripChoices.count, 5, @"Clerics get a fifth cantrip at level 10.");
}

- (void)testSpellSlots {
    
    //First level spells
    _character.level.base = @1;
    XCTAssertEqualObjects(_character.spells.firstLevelSpellSlotsMax.value, @2, @"Clerics have 2 first-level spells at level 1");
    _character.level.base = @2;
    XCTAssertEqualObjects(_character.spells.firstLevelSpellSlotsMax.value, @3, @"Clerics have 3 first-level spells at level 2");
    _character.level.base = @3;
    XCTAssertEqualObjects(_character.spells.firstLevelSpellSlotsMax.value, @4, @"Clerics have 4 first-level spells at level 3");
    
    //Second level spells
    _character.level.base = @2;
    XCTAssertEqualObjects(_character.spells.secondLevelSpellSlotsMax.value, @0, @"Clerics have 0 second-level spells at level 2");
    _character.level.base = @3;
    XCTAssertEqualObjects(_character.spells.secondLevelSpellSlotsMax.value, @2, @"Clerics have 2 second-level spells at level 3");
    _character.level.base = @4;
    XCTAssertEqualObjects(_character.spells.secondLevelSpellSlotsMax.value, @3, @"Clerics have 3 second-level spells at level 4");
    
    //Third level spells
    _character.level.base = @4;
    XCTAssertEqualObjects(_character.spells.thirdLevelSpellSlotsMax.value, @0, @"Clerics have 0 third-level spells at level 4");
    _character.level.base = @5;
    XCTAssertEqualObjects(_character.spells.thirdLevelSpellSlotsMax.value, @2, @"Clerics have 2 third-level spells at level 5");
    _character.level.base = @6;
    XCTAssertEqualObjects(_character.spells.thirdLevelSpellSlotsMax.value, @3, @"Clerics have 3 third-level spells at level 6");
    
    //Fourth level spells
    _character.level.base = @6;
    XCTAssertEqualObjects(_character.spells.fourthLevelSpellSlotsMax.value, @0, @"Clerics have 0 fourth-level spells at level 6");
    _character.level.base = @7;
    XCTAssertEqualObjects(_character.spells.fourthLevelSpellSlotsMax.value, @1, @"Clerics have 1 fourth-level spells at level 7");
    _character.level.base = @8;
    XCTAssertEqualObjects(_character.spells.fourthLevelSpellSlotsMax.value, @2, @"Clerics have 2 fourth-level spells at level 8");
    _character.level.base = @9;
    XCTAssertEqualObjects(_character.spells.fourthLevelSpellSlotsMax.value, @3, @"Clerics have 3 fourth-level spells at level 9");
    
    //Fifth level spells
    _character.level.base = @8;
    XCTAssertEqualObjects(_character.spells.fifthLevelSpellSlotsMax.value, @0, @"Clerics have 0 fifth-level spells at level 8");
    _character.level.base = @9;
    XCTAssertEqualObjects(_character.spells.fifthLevelSpellSlotsMax.value, @1, @"Clerics have 1 fifth-level spells at level 9");
    _character.level.base = @10;
    XCTAssertEqualObjects(_character.spells.fifthLevelSpellSlotsMax.value, @2, @"Clerics have 2 fifth-level spells at level 10");
    _character.level.base = @18;
    XCTAssertEqualObjects(_character.spells.fifthLevelSpellSlotsMax.value, @3, @"Clerics have 3 fifth-level spells at level 18");
    
    //Sixth level spells
    _character.level.base = @10;
    XCTAssertEqualObjects(_character.spells.sixthLevelSpellSlotsMax.value, @0, @"Clerics have 0 sixth-level spells at level 10");
    _character.level.base = @11;
    XCTAssertEqualObjects(_character.spells.sixthLevelSpellSlotsMax.value, @1, @"Clerics have 1 sixth-level spells at level 11");
    _character.level.base = @19;
    XCTAssertEqualObjects(_character.spells.sixthLevelSpellSlotsMax.value, @2, @"Clerics have 2 sixth-level spells at level 19");
    
    //Seventh level spells
    _character.level.base = @12;
    XCTAssertEqualObjects(_character.spells.seventhLevelSpellSlotsMax.value, @0, @"Clerics have 0 seventh-level spells at level 12");
    _character.level.base = @13;
    XCTAssertEqualObjects(_character.spells.seventhLevelSpellSlotsMax.value, @1, @"Clerics have 1 seventh-level spells at level 13");
    _character.level.base = @20;
    XCTAssertEqualObjects(_character.spells.seventhLevelSpellSlotsMax.value, @2, @"Clerics have 2 seventh-level spells at level 20");
    
    //Eighth level spells
    _character.level.base = @14;
    XCTAssertEqualObjects(_character.spells.eighthLevelSpellSlotsMax.value, @0, @"Clerics have 0 eighth-level spells at level 14");
    _character.level.base = @15;
    XCTAssertEqualObjects(_character.spells.eighthLevelSpellSlotsMax.value, @1, @"Clerics have 1 eighth-level spells at level 15");
    
    //Ninth level spells
    _character.level.base = @16;
    XCTAssertEqualObjects(_character.spells.ninthLevelSpellSlotsMax.value, @0, @"Clerics have 0 ninth-level spells at level 16");
    _character.level.base = @17;
    XCTAssertEqualObjects(_character.spells.ninthLevelSpellSlotsMax.value, @1, @"Clerics have 1 ninth-level spells at level 17");
}

- (void)testSpellList {
    
    for (int i = 1; i <= 9; i++) {
        DKSetStatistic* spellList = [_character.spells.spellbook statForSpellLevel:i];
        _character.level.base = @(i * 2 - 2);
        XCTAssertEqual(spellList.value.count, 0, @"Clerics don't gain access to level %i spells until level %i", i, i * 2 - 1);
        _character.level.base = @(i * 2 - 1);
        XCTAssertGreaterThan(spellList.value.count, 0, @"Clerics have access to level %i spells at level %i", i, i * 2 - 1);
    }
}

- (void)testAbilityScoreImprovements {
    
    NSArray* abilityScoreChoices = [_character allUnallocatedChoicesWithTag:DKChoiceAbilityScoreImprovement];
    XCTAssertEqual(abilityScoreChoices.count, 0, @"Clerics don't start with ability score improvements");
    
    NSArray* levels = @[@4, @8, @12, @16, @19];
    int improvementCount = 0;
    for (NSNumber* level in levels) {
        
        _character.level.base = level;
        improvementCount += 2;
        abilityScoreChoices = [_character allUnallocatedChoicesWithTag:DKChoiceAbilityScoreImprovement];
        XCTAssertEqual(abilityScoreChoices.count, improvementCount, @"Clerics get two ability score improvements at level %@", level);
    }
}

- (void)testLifeDomain {
    
    DKChoiceModifierGroup* divineDomain = [_character firstUnallocatedChoiceWithTag:DKChoiceClericDivineDomain];
    [divineDomain choose:divineDomain.choices[0]];
    
    XCTAssertTrue([_character.armorProficiencies.value containsObject:@"Heavy Armor"], @"Clerics can wear heavy armor with Life Domain");
    
    XCTAssertTrue([_character.spells.preparedSpells.value containsObject:@"Bless"], @"Life domain spells");
    XCTAssertTrue([_character.spells.preparedSpells.value containsObject:@"Cure Wounds"], @"Life domain spells");
    XCTAssertEqualObjects(_character.spells.preparedSpellsMax.value, @3, @"Life domain spells do not count against prepared spells limit.");
    
    _character.level.base = @3;
    XCTAssertTrue([_character.spells.preparedSpells.value containsObject:@"Lesser Restoration"], @"Life domain spells");
    XCTAssertTrue([_character.spells.preparedSpells.value containsObject:@"Spiritual Weapon"], @"Life domain spells");
    XCTAssertEqualObjects(_character.spells.preparedSpellsMax.value, @7, @"Life domain spells do not count against prepared spells limit.");
    
    _character.level.base = @5;
    XCTAssertTrue([_character.spells.preparedSpells.value containsObject:@"Beacon of Hope"], @"Life domain spells");
    XCTAssertTrue([_character.spells.preparedSpells.value containsObject:@"Revivify"], @"Life domain spells");
    XCTAssertEqualObjects(_character.spells.preparedSpellsMax.value, @11, @"Life domain spells do not count against prepared spells limit.");
    
    _character.level.base = @7;
    XCTAssertTrue([_character.spells.preparedSpells.value containsObject:@"Death Ward"], @"Life domain spells");
    XCTAssertTrue([_character.spells.preparedSpells.value containsObject:@"Guardian of Faith"], @"Life domain spells");
    XCTAssertEqualObjects(_character.spells.preparedSpellsMax.value, @15, @"Life domain spells do not count against prepared spells limit.");
    
    _character.level.base = @9;
    XCTAssertTrue([_character.spells.preparedSpells.value containsObject:@"Mass Cure Wounds"], @"Life domain spells");
    XCTAssertTrue([_character.spells.preparedSpells.value containsObject:@"Raise Dead"], @"Life domain spells");
    XCTAssertEqualObjects(_character.spells.preparedSpellsMax.value, @19, @"Life domain spells do not count against prepared spells limit.");
    
    _character.level.base = @1;
    XCTAssertTrue([_character.classes.cleric.classTraits.value containsObject:@"Disciple of Life"], @"Life domain grants the Disciple of Life heal bonus");
    
    _character.level.base = @2;
    XCTAssertTrue([_character.classes.cleric.classTraits.value containsObject:@"Channel Divinity - Preserve Life"], @"Life domain grants Preserve Life");
    
    _character.level.base = @6;
    XCTAssertTrue([_character.classes.cleric.classTraits.value containsObject:@"Blessed Healer"], @"Life domain grants Blessed Healer");
    
    _character.level.base = @8;
    XCTAssertTrue([_character.classes.cleric.classTraits.value containsObject:@"Divine Strike"], @"Life domain grants Divine Strike");
    
    _character.level.base = @17;
    XCTAssertTrue([_character.classes.cleric.classTraits.value containsObject:@"Supreme Healing"], @"Life domain grants Supreme Healing");
}

@end
