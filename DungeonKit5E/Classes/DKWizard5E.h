//
//  DKWizard5E.h
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <Foundation/Foundation.h>
#import "DKClass5E.h"

@class DKAbilities5E;

@interface DKWizard5E : DKClass5E

@property (nonatomic, strong) DKNumericStatistic* arcaneRecoveryUsesCurrent;
@property (nonatomic, strong) DKNumericStatistic* arcaneRecoveryUsesMax;
@property (nonatomic, strong) DKNumericStatistic* arcaneRecoverySpellSlots;
@property (nonatomic, strong) DKSetStatistic* spellMasterySpells;
@property (nonatomic, strong) DKNumericStatistic* signatureSpellUsesCurrent;
@property (nonatomic, strong) DKNumericStatistic* signatureSpellUsesMax;
@property (nonatomic, strong) DKSetStatistic* signatureSpells;

- (void)loadClassModifiersWithAbilities:(DKAbilities5E*)abilities;

@end

@interface DKWizardSpellBuilder5E : NSObject

+ (DKChoiceModifierGroup*)cantripChoiceWithExplanation:(NSString*)explanation;

+ (DKChoiceModifierGroup*)cantripChoiceWithLevel:(DKNumericStatistic*)level
                                       threshold:(NSInteger)threshold
                                     explanation:(NSString*)explanation;

+ (DKModifierGroup*)spellListUpToAndIncludingSpellLevel:(NSInteger)spellLevel;
+ (DKModifierGroup*)spellListForSpellLevel:(NSInteger)spellLevel;

@end