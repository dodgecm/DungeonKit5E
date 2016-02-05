//
//  DKCleric5E.h
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <Foundation/Foundation.h>
#import "DKClass5E.h"

@class DKAbilities5E;

@interface DKCleric5E : DKClass5E

@property (nonatomic, strong) DKNumericStatistic* channelDivinityUsesCurrent;
@property (nonatomic, strong) DKNumericStatistic* channelDivinityUsesMax;
@property (nonatomic, strong) DKStringStatistic* destroyUndeadCR;

- (void)loadClassModifiersWithAbilities:(DKAbilities5E*)abilities;

@end

@interface DKClericSpellBuilder5E : NSObject
+ (DKChoiceModifierGroup*)cantripChoiceWithLevel:(DKNumericStatistic*)level
                                       threshold:(NSInteger)threshold
                                     explanation:(NSString*)explanation;
+ (DKModifierGroup*)spellListForSpellLevel:(NSInteger)spellLevel
                               clericLevel:(DKNumericStatistic*)level;

@end
