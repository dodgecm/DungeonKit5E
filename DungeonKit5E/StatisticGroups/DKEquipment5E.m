//
//  DKEquipment5E.m
//  DungeonKit
//
//  Created by Christopher Dodge on 5/5/15.
//  Copyright (c) 2015 Dodge. All rights reserved.
//

#import "DKEquipment5E.h"
#import "DKStatisticIDs5E.h"
#import "DKModifierGroupTags5E.h"
#import "DKModifierBuilder.h"
#import "DKAbilities5E.h"

@implementation DKEquipment5E

@synthesize mainHandOccupied = _mainHandOccupied;
@synthesize offHandOccupied = _offHandOccupied;
@synthesize armorSlotOccupied = _armorSlotOccupied;

@synthesize mainHandWeapon = _mainHandWeapon;
@synthesize mainHandWeaponAttackBonus = _mainHandWeaponAttackBonus;
@synthesize mainHandWeaponDamage = _mainHandWeaponDamage;
@synthesize mainHandWeaponRange = _mainHandWeaponRange;
@synthesize mainHandWeaponAttacksPerAction = _mainHandWeaponAttacksPerAction;
@synthesize mainHandWeaponAttributes = _mainHandWeaponAttributes;

@synthesize offHandWeapon = _offHandWeapon;
@synthesize offHandWeaponAttackBonus = _offHandWeaponAttackBonus;
@synthesize offHandWeaponDamage = _offHandWeaponDamage;
@synthesize offHandWeaponRange = _offHandWeaponRange;
@synthesize offHandWeaponAttacksPerAction = _offHandWeaponAttacksPerAction;
@synthesize offHandWeaponAttributes = _offHandWeaponAttributes;

@synthesize inventory = _inventory;

@synthesize armor = _armor;
@synthesize shield = _shield;
@synthesize otherEquipment = _otherEquipment;

- (id)initWithAbilities:(DKAbilities5E*)abilities
       proficiencyBonus:(DKNumericStatistic*)proficiencyBonus
          characterSize:(DKStringStatistic*)characterSize
    weaponProficiencies:(DKSetStatistic*)weaponProficiencies
     armorProficiencies:(DKSetStatistic*)armorProficiencies {
    
    self = [super init];
    if (self) {
        
        self.mainHandWeapon = [[DKSubgroupChoiceModifierGroup alloc] initWithTag:DKChoiceMainHandWeapon];
        self.offHandWeapon = [[DKSubgroupChoiceModifierGroup alloc] initWithTag:DKChoiceOffHandWeapon];
        DKWeapon5E* unarmed = [DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Unarmed
                                                    abilities:abilities
                                             proficiencyBonus:proficiencyBonus
                                                characterSize:characterSize
                                          weaponProficiencies:weaponProficiencies
                                              offHandOccupied:_offHandOccupied
                                                   isMainHand:YES];
        [self equipWeapon:unarmed inMainHand:YES];
        
        DKWeapon5E* emptyHand = [[DKModifierGroup alloc] init];
        emptyHand.explanation = @"Empty";
        [self equipWeapon:emptyHand inMainHand:NO];
        
        self.armor = [[DKSubgroupChoiceModifierGroup alloc] initWithTag:DKChoiceArmor];
        DKArmor5E* unarmored = [DKArmorBuilder5E armorOfType:kDKArmorType5E_Unarmored
                                                   abilities:abilities
                                          armorProficiencies:armorProficiencies];
        [self equipArmor:unarmored];
        
        self.shield = [[DKSubgroupChoiceModifierGroup alloc] initWithTag:DKChoiceShield];
        DKArmor5E* emptyShield = [[DKModifierGroup alloc] init];
        emptyShield.explanation = @"Empty";
        [self equipShield:emptyShield];
    }
    return self;
}

- (void)equipWeapon:(DKWeapon5E*)weapon
          inMainHand:(BOOL)isMainHand {
    
    DKChoiceModifierGroup* weaponGroup;
    if (isMainHand) {
        weaponGroup = _mainHandWeapon;
    } else {
        weaponGroup = _offHandWeapon;
    }
    
    if (weaponGroup && ![weaponGroup.subgroups containsObject:weapon]) {
        [weaponGroup addSubgroup:weapon];
    }
    
    if (weaponGroup.choice != weapon) {
        [weaponGroup choose:weapon];
    }
}

- (void)equipMainHandWeapon:(DKWeapon5E*)weapon {
    [self equipWeapon:weapon inMainHand:YES];
}
- (void)equipOffHandWeapon:(DKWeapon5E*)weapon {
    [self equipWeapon:weapon inMainHand:NO];
}

- (void)equipArmor:(DKArmor5E*)armor {
    
    if (armor && ![_armor.subgroups containsObject:armor]) {
        [_armor addSubgroup:armor];
    }
    
    if (_armor.choice != armor) {
        [_armor choose:armor];
    }
}
- (void)equipShield:(DKArmor5E*)shield {
    
    if (shield && ![_shield.subgroups containsObject:shield]) {
        [_shield addSubgroup:shield];
    }
    
    if (_shield.choice != shield) {
        [_shield choose:shield];
    }
}

- (NSDictionary*) statisticKeyPaths {
    return @{
             DKStatIDMainHandOccupied: @"mainHandOccupied",
             DKStatIDOffHandOccupied: @"offHandOccupied",
             DKStatIDArmorSlotOccupied: @"armorSlotOccupied",
             
             DKStatIDMainHandWeaponAttackBonus: @"mainHandWeaponAttackBonus",
             DKStatIDMainHandWeaponDamage: @"mainHandWeaponDamage",
             DKStatIDMainHandWeaponRange: @"mainHandWeaponRange",
             DKStatIDMainHandWeaponAttacksPerAction: @"mainHandWeaponAttacksPerAction",
             DKStatIDMainHandWeaponAttributes: @"mainHandWeaponAttributes",
             
             DKStatIDOffHandWeaponAttackBonus: @"offHandWeaponAttackBonus",
             DKStatIDOffHandWeaponDamage: @"offHandWeaponDamage",
             DKStatIDOffHandWeaponRange: @"offHandWeaponRange",
             DKStatIDOffHandWeaponAttacksPerAction: @"offHandWeaponAttacksPerAction",
             DKStatIDOffHandWeaponAttributes: @"offHandWeaponAttributes",
             
             DKStatIDInventory: @"inventory",
             };
}

- (void)loadStatistics {
    
    self.mainHandOccupied = [DKNumericStatistic statisticWithInt:0];
    self.offHandOccupied = [DKNumericStatistic statisticWithInt:0];
    self.armorSlotOccupied = [DKNumericStatistic statisticWithInt:0];
    
    self.mainHandWeaponAttackBonus = [DKNumericStatistic statisticWithInt:0];
    self.mainHandWeaponDamage = [DKDiceStatistic statisticWithNoDice];
    self.mainHandWeaponRange = [DKNumericStatistic statisticWithInt:0];
    self.mainHandWeaponAttacksPerAction = [DKNumericStatistic statisticWithInt:0];
    self.mainHandWeaponAttributes = [DKSetStatistic statisticWithEmptySet];
    
    self.offHandWeaponAttackBonus = [DKNumericStatistic statisticWithInt:0];
    self.offHandWeaponDamage = [DKDiceStatistic statisticWithNoDice];
    self.offHandWeaponRange = [DKNumericStatistic statisticWithInt:0];
    self.offHandWeaponAttacksPerAction = [DKNumericStatistic statisticWithInt:0];
    self.offHandWeaponAttributes = [DKSetStatistic statisticWithEmptySet];
    
    self.inventory = [DKSetStatistic statisticWithEmptySet];
}

@end