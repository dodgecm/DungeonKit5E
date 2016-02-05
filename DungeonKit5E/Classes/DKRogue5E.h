//
//  DKRogue5E.h
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <Foundation/Foundation.h>
#import "DKClass5E.h"

@class DKAbilities5E;
@class DKEquipment5E;

@interface DKRogue5E : DKClass5E

@property (nonatomic, strong) DKNumericStatistic* strokeOfLuckUsesCurrent;
@property (nonatomic, strong) DKNumericStatistic* strokeOfLuckUsesMax;

- (void)loadClassModifiersWithAbilities:(DKAbilities5E*)abilities
                              equipment:(DKEquipment5E*)equipment
                       proficiencyBonus:(DKNumericStatistic*)proficiencyBonus;

@end
