//
//  DKSpellcasting5E.m
//  DungeonKit
//
//  Created by Christopher Dodge on 4/25/15.
//  Copyright (c) 2015 Dodge. All rights reserved.
//

#import "DKSpellcasting5E.h"
#import "DKStatisticGroupIDs5E.h"
#import "DKStatisticIDs5E.h"
#import "DKModifierBuilder.h"

@implementation DKSpellcasting5E

@synthesize spellbook = _spellbook;

@synthesize spellSaveDC = _spellSaveDC;
@synthesize spellAttackBonus = _spellAttackBonus;
@synthesize preparedSpells = _preparedSpells;
@synthesize preparedSpellsMax = _preparedSpellsMax;

@synthesize firstLevelSpellSlotsCurrent = _firstLevelSpellSlotsCurrent;
@synthesize secondLevelSpellSlotsCurrent = _secondLevelSpellSlotsCurrent;
@synthesize thirdLevelSpellSlotsCurrent = _thirdLevelSpellSlotsCurrent;
@synthesize fourthLevelSpellSlotsCurrent = _fourthLevelSpellSlotsCurrent;
@synthesize fifthLevelSpellSlotsCurrent = _fifthLevelSpellSlotsCurrent;
@synthesize sixthLevelSpellSlotsCurrent = _sixthLevelSpellSlotsCurrent;
@synthesize seventhLevelSpellSlotsCurrent = _seventhLevelSpellSlotsCurrent;
@synthesize eighthLevelSpellSlotsCurrent = _eighthLevelSpellSlotsCurrent;
@synthesize ninthLevelSpellSlotsCurrent = _ninthLevelSpellSlotsCurrent;

@synthesize firstLevelSpellSlotsMax = _firstLevelSpellSlotsMax;
@synthesize secondLevelSpellSlotsMax = _secondLevelSpellSlotsMax;
@synthesize thirdLevelSpellSlotsMax = _thirdLevelSpellSlotsMax;
@synthesize fourthLevelSpellSlotsMax = _fourthLevelSpellSlotsMax;
@synthesize fifthLevelSpellSlotsMax = _fifthLevelSpellSlotsMax;
@synthesize sixthLevelSpellSlotsMax = _sixthLevelSpellSlotsMax;
@synthesize seventhLevelSpellSlotsMax = _seventhLevelSpellSlotsMax;
@synthesize eighthLevelSpellSlotsMax = _eighthLevelSpellSlotsMax;
@synthesize ninthLevelSpellSlotsMax = _ninthLevelSpellSlotsMax;

- (id)initWithProficiencyBonus:(DKNumericStatistic*)proficiencyBonus {
    
    self = [super init];
    if (self) {
        
        if (!proficiencyBonus) {
            NSLog(@"DKSkills5E: Expected non-nil proficiency bonus: %@", proficiencyBonus);
            return nil;
        }
        
        [self.spellSaveDC applyModifier:[DKModifier numericModifierAddedFromSource:proficiencyBonus]];
        [self.spellAttackBonus applyModifier:[DKModifier numericModifierAddedFromSource:proficiencyBonus]];
    }
    
    return self;
}

- (NSDictionary*) statisticKeyPaths {
    return @{
             DKStatIDSpellSaveDC: @"spellSaveDC",
             DKStatIDSpellAttackBonus: @"spellAttackBonus",
             DKStatIDPreparedSpells: @"preparedSpells",
             DKStatIDPreparedSpellsMax: @"preparedSpellsMax",
             
             DKStatIDFirstLevelSpellSlotsCurrent: @"firstLevelSpellSlotsCurrent",
             DKStatIDSecondLevelSpellSlotsCurrent: @"secondLevelSpellSlotsCurrent",
             DKStatIDThirdLevelSpellSlotsCurrent: @"thirdLevelSpellSlotsCurrent",
             DKStatIDFourthLevelSpellSlotsCurrent: @"fourthLevelSpellSlotsCurrent",
             DKStatIDFifthLevelSpellSlotsCurrent: @"fifthLevelSpellSlotsCurrent",
             DKStatIDSixthLevelSpellSlotsCurrent: @"sixthLevelSpellSlotsCurrent",
             DKStatIDSeventhLevelSpellSlotsCurrent: @"seventhLevelSpellSlotsCurrent",
             DKStatIDEighthLevelSpellSlotsCurrent: @"eighthLevelSpellSlotsCurrent",
             DKStatIDNinthLevelSpellSlotsCurrent: @"ninthLevelSpellSlotsCurrent",
             
             DKStatIDFirstLevelSpellSlotsMax: @"firstLevelSpellSlotsMax",
             DKStatIDSecondLevelSpellSlotsMax: @"secondLevelSpellSlotsMax",
             DKStatIDThirdLevelSpellSlotsMax: @"thirdLevelSpellSlotsMax",
             DKStatIDFourthLevelSpellSlotsMax: @"fourthLevelSpellSlotsMax",
             DKStatIDFifthLevelSpellSlotsMax: @"fifthLevelSpellSlotsMax",
             DKStatIDSixthLevelSpellSlotsMax: @"sixthLevelSpellSlotsMax",
             DKStatIDSeventhLevelSpellSlotsMax: @"seventhLevelSpellSlotsMax",
             DKStatIDEighthLevelSpellSlotsMax: @"eighthLevelSpellSlotsMax",
             DKStatIDNinthLevelSpellSlotsMax: @"ninthLevelSpellSlotsMax",
             };
}

- (NSDictionary*) statisticGroupKeyPaths {
    return @{
             DKStatisticGroupIDSpellbook: @"spellbook",
             };
}

- (void)loadStatistics {

    self.spellSaveDC = [DKNumericStatistic statisticWithInt:8];
    self.spellAttackBonus = [DKNumericStatistic statisticWithInt:0];
    self.preparedSpells = [DKSetStatistic statisticWithEmptySet];
    self.preparedSpellsMax = [DKNumericStatistic statisticWithInt:0];
    
    self.firstLevelSpellSlotsCurrent = [DKNumericStatistic statisticWithInt:0];
    self.secondLevelSpellSlotsCurrent = [DKNumericStatistic statisticWithInt:0];
    self.thirdLevelSpellSlotsCurrent = [DKNumericStatistic statisticWithInt:0];
    self.fourthLevelSpellSlotsCurrent = [DKNumericStatistic statisticWithInt:0];
    self.fifthLevelSpellSlotsCurrent = [DKNumericStatistic statisticWithInt:0];
    self.sixthLevelSpellSlotsCurrent = [DKNumericStatistic statisticWithInt:0];
    self.seventhLevelSpellSlotsCurrent = [DKNumericStatistic statisticWithInt:0];
    self.eighthLevelSpellSlotsCurrent = [DKNumericStatistic statisticWithInt:0];
    self.ninthLevelSpellSlotsCurrent = [DKNumericStatistic statisticWithInt:0];
    
    self.firstLevelSpellSlotsMax = [DKNumericStatistic statisticWithInt:0];
    self.secondLevelSpellSlotsMax = [DKNumericStatistic statisticWithInt:0];
    self.thirdLevelSpellSlotsMax = [DKNumericStatistic statisticWithInt:0];
    self.fourthLevelSpellSlotsMax = [DKNumericStatistic statisticWithInt:0];
    self.fifthLevelSpellSlotsMax = [DKNumericStatistic statisticWithInt:0];
    self.sixthLevelSpellSlotsMax = [DKNumericStatistic statisticWithInt:0];
    self.seventhLevelSpellSlotsMax = [DKNumericStatistic statisticWithInt:0];
    self.eighthLevelSpellSlotsMax = [DKNumericStatistic statisticWithInt:0];
    self.ninthLevelSpellSlotsMax = [DKNumericStatistic statisticWithInt:0];
}

- (void)loadStatisticGroups {
    
    self.spellbook = [[DKSpellbook5E alloc] init];
}

- (void)loadModifiers {
    
    [_firstLevelSpellSlotsCurrent applyModifier:[DKModifier numericModifierAddedFromSource:_firstLevelSpellSlotsMax]];
    [_secondLevelSpellSlotsCurrent applyModifier:[DKModifier numericModifierAddedFromSource:_secondLevelSpellSlotsMax]];
    [_thirdLevelSpellSlotsCurrent applyModifier:[DKModifier numericModifierAddedFromSource:_thirdLevelSpellSlotsMax]];
    [_fourthLevelSpellSlotsCurrent applyModifier:[DKModifier numericModifierAddedFromSource:_fourthLevelSpellSlotsMax]];
    [_fifthLevelSpellSlotsCurrent applyModifier:[DKModifier numericModifierAddedFromSource:_fifthLevelSpellSlotsMax]];
    [_sixthLevelSpellSlotsCurrent applyModifier:[DKModifier numericModifierAddedFromSource:_sixthLevelSpellSlotsMax]];
    [_seventhLevelSpellSlotsCurrent applyModifier:[DKModifier numericModifierAddedFromSource:_seventhLevelSpellSlotsMax]];
    [_eighthLevelSpellSlotsCurrent applyModifier:[DKModifier numericModifierAddedFromSource:_eighthLevelSpellSlotsMax]];
    [_ninthLevelSpellSlotsCurrent applyModifier:[DKModifier numericModifierAddedFromSource:_ninthLevelSpellSlotsMax]];
}

@end
