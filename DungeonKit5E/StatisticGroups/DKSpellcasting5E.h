//
//  DKSpellcasting5E.h
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <Foundation/Foundation.h>
#import <DungeonKit/DungeonKit.h>
#import "DKSpellbook5E.h"

@interface DKSpellcasting5E : DKStatisticGroup5E

@property (nonatomic, strong) DKSpellbook5E* spellbook;

@property (nonatomic, strong) DKNumericStatistic* spellSaveDC;
@property (nonatomic, strong) DKNumericStatistic* spellAttackBonus;
@property (nonatomic, strong) DKSetStatistic* preparedSpells;
@property (nonatomic, strong) DKNumericStatistic* preparedSpellsMax;

@property (nonatomic, strong) DKNumericStatistic* firstLevelSpellSlotsCurrent;
@property (nonatomic, strong) DKNumericStatistic* secondLevelSpellSlotsCurrent;
@property (nonatomic, strong) DKNumericStatistic* thirdLevelSpellSlotsCurrent;
@property (nonatomic, strong) DKNumericStatistic* fourthLevelSpellSlotsCurrent;
@property (nonatomic, strong) DKNumericStatistic* fifthLevelSpellSlotsCurrent;
@property (nonatomic, strong) DKNumericStatistic* sixthLevelSpellSlotsCurrent;
@property (nonatomic, strong) DKNumericStatistic* seventhLevelSpellSlotsCurrent;
@property (nonatomic, strong) DKNumericStatistic* eighthLevelSpellSlotsCurrent;
@property (nonatomic, strong) DKNumericStatistic* ninthLevelSpellSlotsCurrent;

@property (nonatomic, strong) DKNumericStatistic* firstLevelSpellSlotsMax;
@property (nonatomic, strong) DKNumericStatistic* secondLevelSpellSlotsMax;
@property (nonatomic, strong) DKNumericStatistic* thirdLevelSpellSlotsMax;
@property (nonatomic, strong) DKNumericStatistic* fourthLevelSpellSlotsMax;
@property (nonatomic, strong) DKNumericStatistic* fifthLevelSpellSlotsMax;
@property (nonatomic, strong) DKNumericStatistic* sixthLevelSpellSlotsMax;
@property (nonatomic, strong) DKNumericStatistic* seventhLevelSpellSlotsMax;
@property (nonatomic, strong) DKNumericStatistic* eighthLevelSpellSlotsMax;
@property (nonatomic, strong) DKNumericStatistic* ninthLevelSpellSlotsMax;

- (id)init __unavailable;
- (id)initWithProficiencyBonus:(DKNumericStatistic*)proficiencyBonus;

@end
