//
//  DKClass5E.m
//  DungeonKit
//
//  Created by Christopher Dodge on 4/25/15.
//  Copyright (c) 2015 Dodge. All rights reserved.
//

#import "DKClass5E.h"
#import "DKStatisticIDs5E.h"
#import "DKModifierGroupTags5E.h"
#import "DKModifierBuilder.h"
#import "DKChoiceModifierGroup.h"

@implementation DKClass5E

@synthesize classLevel = _classLevel;
@synthesize classTraits = _classTraits;
@synthesize classModifiers = _classModifiers;
@synthesize classHitDice = _classHitDice;

#pragma mark -

+ (DKModifierGroup*)abilityScoreModifiers {
    static dispatch_once_t pred;
    static DKModifierGroup *modifiers = nil;
    dispatch_once(&pred, ^{
        modifiers = [[DKModifierGroup alloc] init];
        NSArray* statIDs = @[DKStatIDStrength, DKStatIDDexterity, DKStatIDConstitution, DKStatIDIntelligence, DKStatIDWisdom, DKStatIDCharisma];
        for (NSString* statID in statIDs) {
            
            DKModifier* modifier = [DKModifier modifierWithValue:@(1)
                                                        priority:kDKModifierPriority_Additive
                                                      expression:[NSExpression expressionWithFormat:@"min:({ max:({ 20, $input}), $input+$value })"]];
            [modifiers addModifier:modifier forStatisticID:statID];
        }
    });
    return modifiers;
}

+ (DKModifierGroup*)abilityScoreImprovementForThreshold:(NSInteger)threshold level:(DKNumericStatistic*)classLevel {
    
    DKSingleChoiceModifierGroup* firstAbilityScoreChoice = [[DKSingleChoiceModifierGroup alloc] initWithTag:DKChoiceAbilityScoreImprovement];
    firstAbilityScoreChoice.choicesSource = [DKClass5E abilityScoreModifiers];
    firstAbilityScoreChoice.explanation = [NSString stringWithFormat:@"Ability score improvement choice for level %li", (long)threshold];
    
    DKSingleChoiceModifierGroup* secondAbilityScoreChoice = [[DKSingleChoiceModifierGroup alloc] initWithTag:DKChoiceAbilityScoreImprovement];
    secondAbilityScoreChoice.choicesSource = [DKClass5E abilityScoreModifiers];
    secondAbilityScoreChoice.explanation = [NSString stringWithFormat:@"Ability score improvement choice for level %li", (long)threshold];
    
    DKModifierGroup* abilityScoreGroup = [[DKModifierGroup alloc] init];
    [abilityScoreGroup addDependency:classLevel forKey:@"level"];
    abilityScoreGroup.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:threshold];
    abilityScoreGroup.explanation = [NSString stringWithFormat:@"Ability score improvements for level %li", (long)threshold];
    
    [abilityScoreGroup addSubgroup:firstAbilityScoreChoice];
    [abilityScoreGroup addSubgroup:secondAbilityScoreChoice];
    
    return abilityScoreGroup;
}

+ (DKModifierGroup*)skillProficienciesWithStatIDs:(NSArray*)statIDs
                                   choiceGroupTag:(NSString*)tag {
    
    DKChoiceModifierGroup* firstSkillProficiencyChoice = [[DKSingleChoiceModifierGroup alloc] initWithTag:tag];
    firstSkillProficiencyChoice.explanation = @"Class skill proficiency choice";
    DKChoiceModifierGroup* secondSkillProficiencyChoice = [[DKSingleChoiceModifierGroup alloc] initWithTag:tag];
    secondSkillProficiencyChoice.explanation = @"Class skill proficiency choice";
    for (NSString* statID in statIDs) {
        DKModifier* modifier = [DKModifier numericModifierWithClampBetween:1 and:1 explanation:@"Class skill proficiency"];
        [firstSkillProficiencyChoice addModifier:modifier forStatisticID:statID];
        [secondSkillProficiencyChoice addModifier:[modifier copy] forStatisticID:statID];
    }
    
    DKModifierGroup* skillProficiencyGroup = [[DKModifierGroup alloc] init];
    [skillProficiencyGroup addSubgroup:firstSkillProficiencyChoice];
    [skillProficiencyGroup addSubgroup:secondSkillProficiencyChoice];
    
    return skillProficiencyGroup;
}

+ (DKModifier*)hitDiceModifierForSides:(NSInteger)sides level:(DKNumericStatistic*)classLevel {
    
    NSExpression* value = [NSExpression expressionForFunction:[NSExpression expressionForConstantValue: [DKDiceCollection diceCollection]]
                                                 selectorName:@"diceByAddingQuantity:sides:"
                                                    arguments:@[ [NSExpression expressionForVariable:@"source"],
                                                                 [NSExpression expressionForConstantValue:@(sides)] ] ];
    
    DKModifier* hitDiceModifier = [DKModifier diceModifierAddedFromSource:classLevel
                                                                    value:value
                                                                  enabled:nil];
    hitDiceModifier.explanation = @"Class hit die";
    return hitDiceModifier;
}

+ (DKModifierGroup*)hitPointsMaxIncreasesForSides:(NSInteger)sides level:(DKNumericStatistic*)classLevel {
    
    DKModifierGroup* hitPointsGroup = [[DKModifierGroup alloc] init];
    
    DKModifierGroup* possibleValues = [[DKModifierGroup alloc] init];
    for (int i = 1; i <= sides; i++) {
        [possibleValues addModifier:[DKModifier numericModifierWithAdditiveBonus:i] forStatisticID:DKStatIDHitPointsMax];
    }
    
    //Level 1 gives HP increase as the maximum value of the hit dice
    [hitPointsGroup addModifier:[DKModifier numericModifierWithAdditiveBonus:sides] forStatisticID:DKStatIDHitPointsMax];
    
    //Remaining levels can be anywhere between 1 and the maximum value of the hit dice
    for (int level = 2; level <= 20; level++) {
        DKSingleChoiceModifierGroup* hitPointIncrease = [[DKSingleChoiceModifierGroup alloc] initWithTag:DKChoiceHitPointsMax];
        hitPointIncrease.choicesSource = possibleValues;
        [hitPointIncrease addDependency:classLevel forKey:@"level"];
        hitPointIncrease.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:level];
        hitPointIncrease.explanation = [NSString stringWithFormat:@"Hit points increase from level %i", level];
        
        [hitPointsGroup addSubgroup:hitPointIncrease];
    }
    
    return hitPointsGroup;
}

#pragma mark -

- (void)loadClassModifiersForCharacter:(DKCharacter5E*)character { }

#pragma DKStatisticGroup5E override
- (void)loadStatistics {
    
    self.classLevel = [DKNumericStatistic statisticWithInt:0];
    self.classTraits = [DKSetStatistic statisticWithEmptySet];
    self.classHitDice = [DKDiceStatistic statisticWithNoDice];
}

@end