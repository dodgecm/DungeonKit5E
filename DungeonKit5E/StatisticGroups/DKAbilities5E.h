//
//  DKAbilities.h
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <Foundation/Foundation.h>
#import <DungeonKit/DungeonKit.h>
#import "DKStatisticGroup5E.h"

@interface DKAbilityScore : DKNumericStatistic

/** The modifier based on the raw score.  modifier = ((score - 10) / 2) */
@property (nonatomic, readonly) int abilityModifier;

+ (NSExpression*)abilityScoreValueForDependency:(NSString*)dependency;
+ (NSExpression*)diceCollectionValueFromAbilityScoreDependency:(NSString*)dependency;

- (DKModifier*)modifierFromAbilityScore;
- (DKModifier*)modifierFromAbilityScoreWithExplanation:(NSString*)explanation;

- (DKModifier*)diceCollectionModifierFromAbilityScore;

/** Returns the modifier with the proper prefix, ex: +4, +2, +0, -1 */
- (NSString*)formattedAbilityModifier;

@end

@interface DKAbilities5E : DKStatisticGroup5E

@property (nonatomic, strong) DKAbilityScore* strength;
@property (nonatomic, strong) DKAbilityScore* dexterity;
@property (nonatomic, strong) DKAbilityScore* constitution;
@property (nonatomic, strong) DKAbilityScore* intelligence;
@property (nonatomic, strong) DKAbilityScore* wisdom;
@property (nonatomic, strong) DKAbilityScore* charisma;

- (id)init __unavailable;
/** Convenience constructor that accepts exactly 6 NSNumbers for ability scores in the order: STR, DEX, CON, INT, WIS, CON */
- (id)initWithScores:(NSNumber*)firstScore, ... NS_REQUIRES_NIL_TERMINATION;
/** Constructor that accepts an array of 6 NSNumbers for ability scores
 @param scoreArray An array of exactly 6 NSNumbers in the order: STR, DEX, CON, INT, WIS, CON */
- (id)initWithScoreArray:(NSArray*)scoreArray;
/** Constructor that accepts an 6 values for ability scores */
- (id)initWithStr:(int)str dex:(int)dex con:(int)con intel:(int)intel wis:(int)wis cha:(int)cha;

@end
