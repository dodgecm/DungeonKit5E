//
//  DKSavingThrows5E.h
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <Foundation/Foundation.h>
#import "DKProficientStatistic.h"
#import "DKAbilities5E.h"
#import "DKStatisticGroup5E.h"

@interface DKSavingThrows5E : DKStatisticGroup5E

@property (nonatomic, strong) DKProficientStatistic* strength;
@property (nonatomic, strong) DKProficientStatistic* dexterity;
@property (nonatomic, strong) DKProficientStatistic* constitution;
@property (nonatomic, strong) DKProficientStatistic* intelligence;
@property (nonatomic, strong) DKProficientStatistic* wisdom;
@property (nonatomic, strong) DKProficientStatistic* charisma;
/** Covers bonuses to saving throws for misc. effects, such as blindness, charm, petrification, etc */
@property (nonatomic, strong) DKStatistic* other;

- (id)init __unavailable;
- (id)initWithAbilities:(DKAbilities5E*)abilities proficiencyBonus:(DKNumericStatistic*)proficiencyBonus;

@end
