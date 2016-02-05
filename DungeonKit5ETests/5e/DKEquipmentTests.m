//
//  DKEquipmentTests.m
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <DungeonKit/DungeonKit.h>
#import "DKCharacter5E.h"
#import "DKEquipment5E.h"
#import "DKStatisticIDs5E.h"

@interface DKEquipmentTests : XCTestCase
@property (nonatomic, strong) DKCharacter5E* character;
@end

@implementation DKEquipmentTests

@synthesize character = _character;

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _character = [[DKCharacter5E alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark -

- (void)testConstructors {
    
    XCTAssertNotNil([[DKEquipment5E alloc] initWithAbilities:_character.abilities
                                            proficiencyBonus:_character.proficiencyBonus
                                               characterSize:_character.size
                                         weaponProficiencies:_character.weaponProficiencies
                                          armorProficiencies:_character.armorProficiencies], @"Constructors should return non-nil object.");
}

- (void)testAttackBonus {
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Mace
                                                         forCharacter:_character
                                                           isMainHand:YES]];
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponAttackBonus.value, @(0), "Non proficient, +0 STR character should have no attack bonus.");
    
    _character.abilities.strength.base = @12;
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponAttackBonus.value, @(1), "Non proficient, +1 STR character should have +1 attack bonus.");
}

- (void)testDamage {
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Morningstar
                                                         forCharacter:_character
                                                           isMainHand:YES]];
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponDamage.value.stringValue, @"1d8", "Morningstars deal 1d8 damage.");
}

- (void)testMeleeDamageBonus {
    
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Flail
                                                         forCharacter:_character
                                                           isMainHand:YES]];
    XCTAssertEqual(_character.equipment.mainHandWeaponDamage.value.modifier, 0, "+0 STR character should have no damage bonus.");
    
    _character.abilities.strength.base = @12;
    XCTAssertEqual(_character.equipment.mainHandWeaponDamage.value.modifier, 1, "+1 STR character should have +1 damage bonus.");
}

- (void)testRangedDamageBonus {
    
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Shortbow
                                                                 forCharacter:_character
                                                                   isMainHand:YES]];
    XCTAssertEqual(_character.equipment.mainHandWeaponDamage.value.modifier, 0, "+0 DEX character should have no damage bonus.");
    
    _character.abilities.dexterity.base = @12;
    XCTAssertEqual(_character.equipment.mainHandWeaponDamage.value.modifier, 1, "+1 DEX character should have +1 damage bonus.");
}

- (void)testVersatileWeapon {
    
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Quarterstaff
                                                         forCharacter:_character
                                                           isMainHand:YES]];
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponDamage.value.stringValue, @"1d8", "Quarterstaves deal 1d8 damage if used with both hands.");
    
    [_character.equipment equipShield:[DKArmorBuilder5E shieldWithEquipment:_character.equipment
                                                         armorProficiencies:_character.armorProficiencies]];
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponDamage.value.stringValue, @"1d6", "Quarterstaves deal 1d6 damage if used with one hand.");
    XCTAssertTrue([_character.equipment.mainHandWeaponAttributes.value containsObject:@"Versatile"], @"Weapon attributes contain proper values.");
}

- (void)testWeaponProficiency {
    
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_WarPick
                                                         forCharacter:_character
                                                           isMainHand:YES]];
    
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponAttackBonus.value, @(0), "Non-proficient character should have +0 attack bonus.");
    
    _character.weaponProficiencies.base = [NSSet setWithObject:@"Picks"];
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponAttackBonus.value, @(2), "Proficient character should have +2 attack bonus.");
    
    _character.weaponProficiencies.base = [NSSet setWithObject:@"Martial Weapons"];
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponAttackBonus.value, @(2), "Proficient character should have +2 attack bonus.");
}

- (void)testReachWeapon {
    
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Lance
                                                         forCharacter:_character
                                                           isMainHand:YES]];
    
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponRange.value, @(10), "Weapon with reach should have range of 10 feet.");
}

- (void)testFinesseWeapon {
    
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Rapier
                                                         forCharacter:_character
                                                           isMainHand:YES]];
    
    XCTAssertTrue([_character.equipment.mainHandWeaponAttributes.value containsObject:@"Finesse"], @"Weapon attributes contain proper values.");
    XCTAssertEqual(_character.equipment.mainHandWeaponDamage.value.modifier, 0, "+0 STR and +0 DEX character should have no damage bonus.");
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponAttackBonus.value, @0, "+0 STR and +0 DEX character should have no attack bonus.");
    
    _character.abilities.dexterity.base = @12;
    XCTAssertEqual(_character.equipment.mainHandWeaponDamage.value.modifier, 1, "+1 DEX character should have +1 damage bonus.");
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponAttackBonus.value, @1, "+1 DEX character should have +1 attack bonus.");
    
    _character.abilities.strength.base = @14;
    XCTAssertEqual(_character.equipment.mainHandWeaponDamage.value.modifier, 2, "+2 STR character should have +2 damage bonus.");
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponAttackBonus.value, @2, "+2 STR character should have +2 attack bonus.");
}

- (void)testTwoHandedWeapon {
    
    XCTAssertEqualObjects(_character.equipment.mainHandOccupied.value, @0, "Main hand should start out unoccupied.");
    XCTAssertEqualObjects(_character.equipment.offHandOccupied.value, @0, "Off hand should start out unoccupied.");
    
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Maul
                                                         forCharacter:_character
                                                           isMainHand:YES]];
    
    XCTAssertTrue([_character.equipment.mainHandWeaponAttributes.value containsObject:@"Two-handed"], @"Weapon attributes contain proper values.");
    XCTAssertEqualObjects(_character.equipment.mainHandOccupied.value, @1, "Two handed weapon should occupy both hands.");
    XCTAssertEqualObjects(_character.equipment.offHandOccupied.value, @1, "Two handed weapon should occupy both hands.");
}

- (void)testLightWeapon {
    
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Sickle
                                                         forCharacter:_character
                                                           isMainHand:YES]];

    XCTAssertTrue([_character.equipment.mainHandWeaponAttributes.value containsObject:@"Light"], @"Weapon attributes contain proper values.");
    XCTAssertEqualObjects(_character.equipment.offHandOccupied.value, @0, "Each weapon should occupy one hand.");
    
    [_character.equipment equipOffHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Dagger
                                                         forCharacter:_character
                                                           isMainHand:NO]];
    
    XCTAssertTrue([_character.equipment.offHandWeaponAttributes.value containsObject:@"Light"], @"Weapon attributes contain proper values.");
    
    //Hand occupied
    XCTAssertEqualObjects(_character.equipment.mainHandOccupied.value, @1, "Each weapon should occupy one hand.");
    XCTAssertEqualObjects(_character.equipment.offHandOccupied.value, @1, "Each weapon should occupy one hand.");
    
    //Attack bonus
    _character.weaponProficiencies.base = [NSSet setWithObjects:@"Sickles", @"Daggers", nil];
    XCTAssertEqualObjects(_character.equipment.offHandWeaponAttackBonus.value, @2, "Off hand finesse weapon should get +2 attack bonus from proficiency.");
    
    _character.abilities.strength.base = @14;
    XCTAssertEqualObjects(_character.equipment.offHandWeaponAttackBonus.value, @4, "Off hand weapon should get +4 attack bonus from proficiency and STR.");
    
    _character.abilities.dexterity.base = @18;
    XCTAssertEqualObjects(_character.equipment.offHandWeaponAttackBonus.value, @6, "Off hand finesse weapon should get +6 attack bonus from proficiency and DEX.");
    
    //Attacks per round
    XCTAssertEqualObjects(_character.equipment.offHandWeaponAttacksPerAction.value, @1, "Off hand weapon should get 1 attack per round.");
    
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Trident
                                                         forCharacter:_character
                                                           isMainHand:YES]];
    XCTAssertEqualObjects(_character.equipment.offHandWeaponAttacksPerAction.value, @0, "Off hand weapon cannot attack if a non-light weapon is in the main hand.");
    
    //Damage
    XCTAssertEqual(_character.equipment.offHandWeaponDamage.value.modifier, 0, "Off hand weapon does not get ability score bonus to damage.");
    _character.abilities.strength.base = @8;
    XCTAssertEqual(_character.equipment.offHandWeaponDamage.value.modifier, 0, "Off hand weapon does not get negative damage bonus due to versatile weapon.");
    _character.abilities.dexterity.base = @6;
    XCTAssertEqual(_character.equipment.offHandWeaponDamage.value.modifier, -1, "Off hand weapon only gets negative damage bonuses from ability score.");
    
    XCTAssertThrows([DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Pike
                                       forCharacter:_character
                                         isMainHand:NO],
                    @"Weapon builder should not generate an off-hand item unless it has the light attribute.");
}

- (void)testOffhandProficiency {
    
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Scimitar
                                                         forCharacter:_character
                                                           isMainHand:YES]];
    [_character.equipment equipOffHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Shortsword
                                                         forCharacter:_character
                                                           isMainHand:NO]];
    
    _character.abilities.strength.base = @14;
    XCTAssertEqual(_character.equipment.offHandWeaponDamage.value.modifier, 0, "Off hand weapon does not get ability score bonus to damage.");
    
    _character.weaponProficiencies.base = [NSSet setWithObjects:@"Two-Weapon Fighting", nil];
    XCTAssertEqual(_character.equipment.offHandWeaponDamage.value.modifier, 2, "Off hand weapon does get ability score bonus to damage with proficiency.");
}

- (void)testLoadingWeapon {
    
    [_character applyModifier:[DKModifier numericModifierWithAdditiveBonus:1] toStatisticWithID:DKStatIDMainHandWeaponAttacksPerAction];
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponAttacksPerAction.value, @2, "Main hand weapon should get 2 attacks per round.");
    
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_HeavyCrossbow
                                                         forCharacter:_character
                                                           isMainHand:YES]];
    XCTAssertTrue([_character.equipment.mainHandWeaponAttributes.value containsObject:@"Loading"], @"Weapon attributes contain proper values.");
    XCTAssertEqualObjects(_character.equipment.mainHandWeaponAttacksPerAction.value, @1, "Loading weapons can only be used to attack once per round.");
}

#pragma mark -

- (void)testUnarmored {
    
    XCTAssertEqualObjects(_character.equipment.armorSlotOccupied.value, @0, "Armor starts off unequipped.");
    [_character.equipment equipArmor:[DKArmorBuilder5E armorOfType:kDKArmorType5E_Unarmored
                                                      forCharacter:_character]];
    
    XCTAssertEqualObjects(_character.equipment.armorSlotOccupied.value, @0, "Armor still does not take up the armor slot.");
    _character.abilities.dexterity.base = @14;
    XCTAssertEqualObjects(_character.armorClass.value, @12, "Dexterity ability score gets applied for unarmored.");
}

- (void)testLightArmor {
    
    XCTAssertEqualObjects(_character.equipment.armorSlotOccupied.value, @0, "Armor starts off unequipped.");
    [_character.equipment equipArmor:[DKArmorBuilder5E armorOfType:kDKArmorType5E_Leather
                                                      forCharacter:_character]];
    
    XCTAssertEqualObjects(_character.equipment.armorSlotOccupied.value, @1, "Armor takes up the armor slot properly.");
    XCTAssertEqualObjects(_character.armorClass.value, @11, "Armor class bonus from armor should be applied properly.");
    
    _character.abilities.dexterity.base = @14;
    XCTAssertEqualObjects(_character.armorClass.value, @13, "Dexterity ability score gets applied for light armor.");
}

- (void)testMediumArmor {
    
    [_character.equipment equipArmor:[DKArmorBuilder5E armorOfType:kDKArmorType5E_Breastplate
                                                      forCharacter:_character]];
    XCTAssertEqualObjects(_character.armorClass.value, @14, "Armor class bonus from armor should be applied properly.");
    
    _character.abilities.dexterity.base = @14;
    XCTAssertEqualObjects(_character.armorClass.value, @16, "Dexterity ability score gets applied for medium armor.");
    
    _character.abilities.dexterity.base = @18;
    XCTAssertEqualObjects(_character.armorClass.value, @16, "Dexterity ability score bonus to armor class gets capped at +2 for medium armor.");
}

- (void)testHeavyArmor {
    
    [_character.equipment equipArmor:[DKArmorBuilder5E armorOfType:kDKArmorType5E_Plate
                                                      forCharacter:_character]];
    XCTAssertEqualObjects(_character.armorClass.value, @18, "Armor class bonus from armor should be applied properly.");
    
    _character.abilities.dexterity.base = @14;
    XCTAssertEqualObjects(_character.armorClass.value, @18, "Dexterity ability score does not get applied for heavy armor.");
    
    //Replacement racial movement speed since we haven't picked a race
    [_character.movementSpeed applyModifier:[DKModifier numericModifierWithAdditiveBonus:30]];
    _character.abilities.strength.base = @13;
    XCTAssertEqualObjects(_character.movementSpeed.value, @20, "Movement speed is reduced by 10 for heavy armor if the strength requierment is not met.");
    
    _character.abilities.strength.base = @16;
    XCTAssertEqualObjects(_character.movementSpeed.value, @30, "Movement speed is not reduced by 10 for heavy armor if the strength requierment is met.");
}

- (void)testArmorProficiency {
    
    [_character applyModifier:[DKModifier numericModifierWithAdditiveBonus:1] toStatisticWithID:DKStatIDFirstLevelSpellSlotsCurrent];
    XCTAssertEqualObjects(_character.spells.firstLevelSpellSlotsCurrent.value, @1, "Unarmed armor does not require any proficiency.");
    
    [_character.equipment equipArmor:[DKArmorBuilder5E armorOfType:kDKArmorType5E_StuddedLeather
                                                      forCharacter:_character]];
    XCTAssertEqualObjects(_character.spells.firstLevelSpellSlotsCurrent.value, @0, "Wearing armor without proficiency prevents casting.");
    
    _character.armorProficiencies.base = [NSSet setWithObject:@"Light Armor"];
    XCTAssertEqualObjects(_character.spells.firstLevelSpellSlotsCurrent.value, @1, "Wearing armor with proficiency does not prevent casting.");
}

- (void)testShield {
    
    [_character.equipment equipShield:[DKArmorBuilder5E shieldWithEquipment:_character.equipment
                                                         armorProficiencies:_character.armorProficiencies]];
    XCTAssertEqualObjects(_character.armorClass.value, @12, "Armor class bonus from shield should be applied properly.");
    
    [_character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Greatclub
                                                         forCharacter:_character
                                                           isMainHand:YES]];
    XCTAssertEqualObjects(_character.armorClass.value, @10, "Armor class bonus from shield should not be applied when wielding a two handed weapon.");
}

@end
