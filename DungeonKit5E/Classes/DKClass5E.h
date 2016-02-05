//
//  DKClass5E.h
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <Foundation/Foundation.h>
#import <DungeonKit/DungeonKit.h>
#import "DKStatisticGroup5E.h"

@class DKCharacter5E;

@interface DKClass5E : DKStatisticGroup5E

@property (nonatomic, strong) DKNumericStatistic* classLevel;
@property (nonatomic, strong) DKSetStatistic* classTraits;
@property (nonatomic, strong) DKModifierGroup* classModifiers;
@property (nonatomic, strong) DKDiceStatistic* classHitDice;

+ (DKModifierGroup*)abilityScoreImprovementForThreshold:(NSInteger)threshold level:(DKNumericStatistic*)classLevel;
+ (DKModifierGroup*)skillProficienciesWithStatIDs:(NSArray*)statIDs choiceGroupTag:(NSString*)tag;
+ (DKModifier*)hitDiceModifierForSides:(NSInteger)sides level:(DKNumericStatistic*)classLevel;
+ (DKModifierGroup*)hitPointsMaxIncreasesForSides:(NSInteger)sides level:(DKNumericStatistic*)classLevel;

- (void)loadClassModifiersForCharacter:(DKCharacter5E*)character;

@end