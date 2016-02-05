//
//  DKFighter5E.h
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <Foundation/Foundation.h>
#import "DKClass5E.h"

@class DKAbilities5E;
@class DKSkills5E;
@class DKEquipment5E;

typedef NS_ENUM(NSInteger, DKFightingStyle5E) {
    
    kDKFightingStyle5E_Archery = 1,
    kDKFightingStyle5E_Defense,
    kDKFightingStyle5E_Dueling,
    kDKFightingStyle5E_GreatWeapon,
    kDKFightingStyle5E_Protection,
    kDKFightingStyle5E_TwoWeapon,
};

@interface DKFighter5E : DKClass5E

@property (nonatomic, strong) DKNumericStatistic* secondWindUsesCurrent;
@property (nonatomic, strong) DKNumericStatistic* secondWindUsesMax;
@property (nonatomic, strong) DKNumericStatistic* actionSurgeUsesCurrent;
@property (nonatomic, strong) DKNumericStatistic* actionSurgeUsesMax;
@property (nonatomic, strong) DKNumericStatistic* indomitableUsesCurrent;
@property (nonatomic, strong) DKNumericStatistic* indomitableUsesMax;

- (void)loadClassModifiersWithAbilities:(DKAbilities5E*)abilities
                                 skills:(DKSkills5E*)skills
                              equipment:(DKEquipment5E*)equipment
                       proficiencyBonus:(DKNumericStatistic*)proficiencyBonus;

@end
