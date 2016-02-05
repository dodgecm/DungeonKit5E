//
//  DKFighter5E.m
//  DungeonKit
//
//  Created by Christopher Dodge on 5/5/15.
//  Copyright (c) 2015 Dodge. All rights reserved.
//

#import "DKFighter5E.h"
#import "DKAbilities5E.h"
#import "DKModifierBuilder.h"
#import "DKChoiceModifierGroup.h"
#import "DKModifierGroupTags5E.h"
#import "DKStatisticIDs5E.h"
#import "DKEquipment5E.h"
#import "DKWeapon5E.h"
#import "DKArmor5E.h"
#import "DKSkills5E.h"
#import "DKCharacter5E.h"

@implementation DKFighter5E

@synthesize secondWindUsesCurrent = _secondWindUsesCurrent;
@synthesize secondWindUsesMax = _secondWindUsesMax;
@synthesize actionSurgeUsesCurrent = _actionSurgeUsesCurrent;
@synthesize actionSurgeUsesMax = _actionSurgeUsesMax;
@synthesize indomitableUsesCurrent = _indomitableUsesCurrent;
@synthesize indomitableUsesMax = _indomitableUsesMax;

#pragma mark -

+ (DKModifierGroup*)fighterWithLevel:(DKNumericStatistic*)level
                           abilities:(DKAbilities5E*)abilities
                              skills:(DKSkills5E*)skills
                           equipment:(DKEquipment5E*)equipment
                    proficiencyBonus:(DKNumericStatistic*)proficiencyBonus
{
    DKModifierGroup* class = [[DKModifierGroup alloc] init];
    [class addDependency:level forKey:@"level"];
    class.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:1];
    class.explanation = @"Fighter class modifiers";
    
    [class addModifier:[DKModifier stringModifierWithNewString:@"Fighter"] forStatisticID:DKStatIDClassName];
    [class addModifier:[DKClass5E hitDiceModifierForSides:10 level:level] forStatisticID:DKStatIDFighterHitDice];
    [class addSubgroup:[DKClass5E hitPointsMaxIncreasesForSides:10 level:level]];
    
    [class addModifier:[DKModifier numericModifierWithClampBetween:1 and:1 explanation:@"Fighter Saving Throw Proficiency: Strength"]
        forStatisticID:DKStatIDSavingThrowStrengthProficiency];
    [class addModifier:[DKModifier numericModifierWithClampBetween:1 and:1 explanation:@"Fighter Saving Throw Proficiency: Constitution"]
        forStatisticID:DKStatIDSavingThrowConstitutionProficiency];
    
    [class addModifier:[DKModifier setModifierWithAppendedObject:[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Simple]
                                                     explanation:@"Fighter Weapon Proficiencies"]
        forStatisticID:DKStatIDWeaponProficiencies];
    [class addModifier:[DKModifier setModifierWithAppendedObject:[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial]
                                                     explanation:@"Fighter Weapon Proficiencies"]
        forStatisticID:DKStatIDWeaponProficiencies];
    
    NSArray* armorProficiencies = @[ @(kDKArmorCategory5E_Light),
                                     @(kDKArmorCategory5E_Medium),
                                     @(kDKArmorCategory5E_Heavy),
                                     @(kDKArmorCategory5E_Shield) ];
    for (NSNumber* armorProficiency in armorProficiencies) {
        [class addModifier:[DKModifier setModifierWithAppendedObject:[DKArmorBuilder5E proficiencyNameForArmorCategory:armorProficiency.integerValue]
                                                         explanation:@"Fighter Armor Proficiencies"]
            forStatisticID:DKStatIDArmorProficiencies];
    }
    
    NSArray* skillProficiencyStatIDs = @[ DKStatIDSkillAcrobaticsProficiency,
                                          DKStatIDSkillAnimalHandlingProficiency,
                                          DKStatIDSkillAthleticsProficiency,
                                          DKStatIDSkillHistoryProficiency,
                                          DKStatIDSkillInsightProficiency,
                                          DKStatIDSkillIntimidationProficiency,
                                          DKStatIDSkillPerceptionProficiency,
                                          DKStatIDSkillSurvivalProficiency,
                                          ];
    DKModifierGroup* skillProficiencyGroup = [DKClass5E skillProficienciesWithStatIDs:skillProficiencyStatIDs
                                                                       choiceGroupTag:DKChoiceFighterSkillProficiency];
    skillProficiencyGroup.explanation = @"Fighter Skill Proficiencies: Choose two from Acrobatics, Animal Handling, Athletics, History, Insight, Intimidation, Perception, and Survival";
    [class addSubgroup:skillProficiencyGroup];
    
    DKModifierGroup* fightingStyleChoice = [DKFighter5E fightingStyleChoiceWithLevel:level
                                                                            minLevel:@1
                                                                           equipment:equipment];
    fightingStyleChoice.explanation = @"Fighting style";
    [class addSubgroup:fightingStyleChoice];
    
    DKModifierGroup* secondWindGroup = [DKFighter5E secondWindGroupWithFighterLevel:level];
    [class addSubgroup:secondWindGroup];
    
    DKModifierGroup* actionSurgeGroup = [DKFighter5E actionSurgeGroupWithFighterLevel:level];
    [class addSubgroup:actionSurgeGroup];
    
    DKModifierGroup* martialArchetypeGroup = [DKFighter5E martialArchetypeChoiceWithFighterLevel:level
                                                                                          skills:skills
                                                                                       equipment:equipment
                                                                                proficiencyBonus:proficiencyBonus];
    [class addSubgroup:martialArchetypeGroup];
    
    NSExpression* extraAttacksValue = [DKExpressionBuilder valueFromPiecewiseFunctionRanges:
                                       @{ [DKExpressionBuilder rangeValueWithMin:0 max:4] : @(0),
                                          [DKExpressionBuilder rangeValueWithMin:5 max:10] : @(1),
                                          [DKExpressionBuilder rangeValueWithMin:11 max:19] : @(2),
                                          [DKExpressionBuilder rangeValueWithMin:20 max:20] : @(3) }
                                                                            usingDependency:@"source"];
    DKModifier* extraAttacksModifier = [[DKModifier alloc] initWithSource:level
                                                                    value:extraAttacksValue
                                                                  enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                   isGreaterThanOrEqualTo:5]
                                                                 priority:kDKModifierPriority_Additive
                                                               expression:[DKExpressionBuilder additionExpression]];
    DKModifier* offHandAttacksModifier = [extraAttacksModifier copy];
    [class addModifier:extraAttacksModifier forStatisticID:DKStatIDMainHandWeaponAttacksPerAction];
    [class addModifier:offHandAttacksModifier forStatisticID:DKStatIDOffHandWeaponAttacksPerAction];
    
    DKModifierGroup* indomitableGroup = [DKFighter5E indomitableGroupWithFighterLevel:level];
    [class addSubgroup:indomitableGroup];
    
    NSArray* abilityScoreImprovementLevels = @[ @4, @6, @8, @12, @14, @16, @19];
    for (NSNumber* abilityScoreLevel in abilityScoreImprovementLevels) {
        DKModifierGroup* abilityScoreGroup = [DKClass5E abilityScoreImprovementForThreshold:abilityScoreLevel.integerValue level:level];
        [class addSubgroup:abilityScoreGroup];
    }
    
    DKModifier* startingGold = [DKModifier numericModifierWithAdditiveBonus:125];
    startingGold.explanation = @"Fighter starting gold";
    [class addModifier:startingGold forStatisticID:DKStatIDCurrencyGold];
    
    return class;
}

+ (DKSubgroupChoiceModifierGroup*)fightingStyleChoiceWithLevel:(DKNumericStatistic*)level
                                                      minLevel:(NSNumber*)minLevel
                                                     equipment:(DKEquipment5E*)equipment {
    
    DKSubgroupChoiceModifierGroup* fightingStyleChoice = [[DKSubgroupChoiceModifierGroup alloc] initWithTag:DKChoiceFighterFightingStyle];
    [fightingStyleChoice addDependency:level forKey:@"level"];
    fightingStyleChoice.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:minLevel.integerValue];
    
    NSArray* fightingStyles = @[ @(kDKFightingStyle5E_Archery),
                                 @(kDKFightingStyle5E_Defense),
                                 @(kDKFightingStyle5E_Dueling),
                                 @(kDKFightingStyle5E_GreatWeapon),
                                 @(kDKFightingStyle5E_Protection),
                                 @(kDKFightingStyle5E_TwoWeapon) ];
    for (NSNumber* fightingStyle in fightingStyles) {
        [fightingStyleChoice addSubgroup:[DKFighter5E fightingStyle:fightingStyle.integerValue
                                                          equipment:equipment]];
    }
    
    return fightingStyleChoice;
}

+ (DKModifierGroup*)fightingStyle:(DKFightingStyle5E)fightingStyle
                        equipment:(DKEquipment5E*)equipment {
    
    DKModifierGroup* fightingStyleGroup = [[DKModifierGroup alloc] init];
    switch (fightingStyle) {
        case kDKFightingStyle5E_Archery:
        {
            fightingStyleGroup.explanation = @"Archery fighting style";
            
            NSPredicate* rangedPredicate = [DKPredicateBuilder enabledWhen:@"source" containsObject:@"Ranged"];
            DKModifier* mainHandModifier = [[DKModifier alloc] initWithDependencies:@{ @"source" : equipment.mainHandWeaponAttributes }
                                                                              value:[DKExpressionBuilder valueFromInteger:2]
                                                                            enabled:rangedPredicate
                                                                           priority:kDKModifierPriority_Additive
                                                                         expression:[DKExpressionBuilder additionExpression]];
            mainHandModifier.explanation = @"Archery fighting style (fighter) attack bonus";
            [fightingStyleGroup addModifier:mainHandModifier forStatisticID:DKStatIDMainHandWeaponAttackBonus];
            
            DKModifier* offHandModifier = [[DKModifier alloc] initWithDependencies:@{ @"source" : equipment.offHandWeaponAttributes }
                                                                             value:[DKExpressionBuilder valueFromInteger:2]
                                                                           enabled:[rangedPredicate copy]
                                                                          priority:kDKModifierPriority_Additive
                                                                        expression:[DKExpressionBuilder additionExpression]];
            offHandModifier.explanation = @"Archery fighting style (fighter) attack bonus";
            [fightingStyleGroup addModifier:offHandModifier forStatisticID:DKStatIDOffHandWeaponAttackBonus];
            break;
        }
            
        case kDKFightingStyle5E_Defense:
        {
            fightingStyleGroup.explanation = @"Defense fighting style";
            NSPredicate* defensePredicate = [DKPredicateBuilder enabledWhen:@"source" isGreaterThanOrEqualTo:1];
            DKModifier* armorClassModifier = [[DKModifier alloc] initWithDependencies:@{ @"source" : equipment.armorSlotOccupied }
                                                                                value:[DKExpressionBuilder valueFromInteger:1]
                                                                              enabled:defensePredicate
                                                                             priority:kDKModifierPriority_Additive
                                                                           expression:[DKExpressionBuilder additionExpression]];
            armorClassModifier.explanation = @"Defense fighting style (fighter) armor class bonus";
            [fightingStyleGroup addModifier:armorClassModifier forStatisticID:DKStatIDArmorClass];
            break;
        }
            
        case kDKFightingStyle5E_Dueling: {
            fightingStyleGroup.explanation = @"Dueling fighting style";
            NSExpression* damageBonusExpression = [DKExpressionBuilder valueAsDiceCollectionFromExpression:
                                                   [NSExpression expressionForConstantValue:@2]];
            NSPredicate* meleeWeaponPredicate = [DKPredicateBuilder enabledWhen:@"mainHand" containsObject:@"Melee"];
            NSPredicate* offHandIsShieldPredicate = [DKPredicateBuilder enabledWhen:@"offHand" containsObject:@"Shield"];
            NSPredicate* offHandOnlyHasShield = [DKPredicateBuilder enabledWhen:@"offHandOccupied" isEqualToOrBetween:1 and:1];
            NSPredicate* offHandIsEmptyPredicate = [DKPredicateBuilder enabledWhen:@"offHandOccupied" isEqualToOrBetween:0 and:0];
            NSCompoundPredicate* shieldPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[offHandOnlyHasShield, offHandIsShieldPredicate]];
            NSCompoundPredicate* offHandPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[offHandIsEmptyPredicate, shieldPredicate]];
            NSCompoundPredicate* enabledPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[meleeWeaponPredicate, offHandPredicate]];
            DKModifier* damageModifier = [[DKModifier alloc] initWithDependencies:@{ @"mainHand": equipment.mainHandWeaponAttributes,
                                                                                     @"offHand": equipment.offHandWeaponAttributes,
                                                                                     @"offHandOccupied": equipment.offHandOccupied }
                                                                            value:damageBonusExpression
                                                                          enabled:enabledPredicate
                                                                         priority:kDKModifierPriority_Additive
                                                                       expression:[DKExpressionBuilder addDiceExpression]];
            damageModifier.explanation = @"Dueling fighting style (fighter) damage bonus";
            [fightingStyleGroup addModifier:damageModifier forStatisticID:DKStatIDMainHandWeaponDamage];
            break;
        }
            
        case kDKFightingStyle5E_GreatWeapon: {
            fightingStyleGroup.explanation = @"Great Weapon fighting style";
            NSPredicate* twoHandedPredicate = [DKPredicateBuilder enabledWhen:@"mainHand" containsObject:@"Two-handed"];
            NSPredicate* versatilePredicate = [DKPredicateBuilder enabledWhen:@"mainHand" containsObject:@"Versatile"];
            NSPredicate* meleePredicate = [DKPredicateBuilder enabledWhen:@"mainHand" containsObject:@"Melee"];
            NSPredicate* offHandIsEmptyPredicate = [DKPredicateBuilder enabledWhen:@"offHandOccupied" isEqualToOrBetween:0 and:0];
            NSCompoundPredicate* versatileActivePredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[versatilePredicate, offHandIsEmptyPredicate]];
            NSCompoundPredicate* usingTwoHandsPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[twoHandedPredicate, versatileActivePredicate]];
            NSCompoundPredicate* enabledPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[usingTwoHandsPredicate, meleePredicate]];
            DKModifier* damageModifier = [[DKModifier alloc] initWithDependencies:@{ @"mainHand": equipment.mainHandWeaponAttributes,
                                                                                     @"offHandOccupied": equipment.offHandOccupied }
                                                                            value:nil
                                                                          enabled:enabledPredicate
                                                                         priority:kDKModifierPriority_Informational
                                                                       expression:nil];
            damageModifier.explanation = @"Great Weapon Fighting: When you roll a 1 or 2 on a damage die for an attack you make with a melee weapon that you are wielding with two hands, you can reroll the die and must use the new roll, even if the new roll is a 1 or a 2.";
            [fightingStyleGroup addModifier:damageModifier forStatisticID:DKStatIDMainHandWeaponDamage];
            break;
        }
            
        case kDKFightingStyle5E_Protection: {
            fightingStyleGroup.explanation = @"Protection fighting style";
            
            NSString* protectionExplanation = @"When a creature you can see attacks a target other than you that is within 5 feet of you, you can use your reaction to impose disadvantage on the attack roll.";
            NSPredicate* shieldPredicate = [DKPredicateBuilder enabledWhen:@"source" containsObject:@"Shield"];
            DKModifier* protectionModifier = [[DKModifier alloc] initWithDependencies:@{ @"source": equipment.offHandWeaponAttributes }
                                                                                value:[NSExpression expressionForConstantValue:@"Protection"]
                                                                              enabled:shieldPredicate
                                                                             priority:kDKModifierPriority_Additive
                                                                           expression:[DKExpressionBuilder appendExpression]];
            protectionModifier.explanation = protectionExplanation;
            [fightingStyleGroup addModifier:protectionModifier forStatisticID:DKStatIDFighterTraits];
            break;
        }
            
        case kDKFightingStyle5E_TwoWeapon: {
            fightingStyleGroup.explanation = @"Two-Weapon fighting style";
            DKModifier* twoWeaponModifier = [DKModifier setModifierWithAppendedObject:@"Two-Weapon Fighting"
                                                                          explanation:@"Two-Weapon fighting style (fighter) offhand damage bonus"];
            [fightingStyleGroup addModifier:twoWeaponModifier forStatisticID:DKStatIDWeaponProficiencies];
        }
            
        default:
            break;
    }
    
    return fightingStyleGroup;
}

+ (DKModifierGroup*)secondWindGroupWithFighterLevel:(DKNumericStatistic*)level {
    
    DKModifierGroup* secondWindGroup = [[DKModifierGroup alloc] init];
    [secondWindGroup addDependency:level forKey:@"level"];
    secondWindGroup.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:1];
    
    NSString* secondWindExplanation = @"You have a limited well of stamina that you can draw on to protect yourself from harm. On your turn, you can use a bonus action to regain hit points equal to 1d10 + your fighter level.";
    DKModifier* secondWindModifier = [DKModifier setModifierWithAppendedObject:@"Second Wind" explanation:secondWindExplanation];
    [secondWindGroup addModifier:secondWindModifier forStatisticID:DKStatIDFighterTraits];
    
    DKModifier* secondWindChargesModifier = [DKModifier numericModifierWithAdditiveBonus:1];
    secondWindChargesModifier.explanation = @"Once you use this feature, you must finish a short or long rest before you can use it again.";
    [secondWindGroup addModifier:secondWindChargesModifier forStatisticID:DKStatIDSecondWindUsesMax];
    
    return secondWindGroup;
}

+ (DKModifierGroup*)actionSurgeGroupWithFighterLevel:(DKNumericStatistic*)level {
    
    DKModifierGroup* actionSurgeGroup = [[DKModifierGroup alloc] init];
    [actionSurgeGroup addDependency:level forKey:@"level"];
    actionSurgeGroup.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:2];
    
    NSString* actionSurgeExplanation = @"You can push yourself beyond your normal limits for a moment. On your turn, you can take one additional action on top of your regular action and a possible bonus action.  This feature may only be used only once per turn.";
    DKModifier* actionSurgeModifier = [DKModifier setModifierWithAppendedObject:@"Action Surge" explanation:actionSurgeExplanation];
    [actionSurgeGroup addModifier:actionSurgeModifier forStatisticID:DKStatIDFighterTraits];
    
    NSExpression* actionSurgeChargesValue = [DKExpressionBuilder valueFromPiecewiseFunctionRanges:
                                             @{ [DKExpressionBuilder rangeValueWithMin:0 max:1] : @(0),
                                                [DKExpressionBuilder rangeValueWithMin:2 max:16] : @(1),
                                                [DKExpressionBuilder rangeValueWithMin:17 max:20] : @(2) }
                                                                                  usingDependency:@"source"];
    DKModifier* actionSurgeChargesModifier = [[DKModifier alloc] initWithSource:level
                                                                          value:actionSurgeChargesValue
                                                                       priority:kDKModifierPriority_Additive
                                                                     expression:[DKExpressionBuilder additionExpression]];
    actionSurgeChargesModifier.explanation = @"You must finish a short or long rest before you regain your uses of this feature.";
    [actionSurgeGroup addModifier:actionSurgeChargesModifier forStatisticID:DKStatIDActionSurgeUsesMax];
    
    return actionSurgeGroup;
}

+ (DKModifierGroup*)indomitableGroupWithFighterLevel:(DKNumericStatistic*)level {
    
    DKModifierGroup* indomitableGroup = [[DKModifierGroup alloc] init];
    [indomitableGroup addDependency:level forKey:@"level"];
    indomitableGroup.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:9];
    
    NSString* indomitableExplanation = @"You can reroll a saving throw that you fail.  If you do so, you must use the new roll.";
    DKModifier* indomitableModifier = [DKModifier setModifierWithAppendedObject:@"Indomitable" explanation:indomitableExplanation];
    [indomitableGroup addModifier:indomitableModifier forStatisticID:DKStatIDFighterTraits];
    
    NSExpression* indomitableChargesValue = [DKExpressionBuilder valueFromPiecewiseFunctionRanges:
                                             @{ [DKExpressionBuilder rangeValueWithMin:0 max:8] : @(0),
                                                [DKExpressionBuilder rangeValueWithMin:9 max:12] : @(1),
                                                [DKExpressionBuilder rangeValueWithMin:13 max:16] : @(2),
                                                [DKExpressionBuilder rangeValueWithMin:17 max:20] : @(3) }
                                                                                  usingDependency:@"source"];
    DKModifier* indomitableChargesModifier = [[DKModifier alloc] initWithSource:level
                                                                          value:indomitableChargesValue
                                                                       priority:kDKModifierPriority_Additive
                                                                     expression:[DKExpressionBuilder additionExpression]];
    indomitableChargesModifier.explanation = @"You must finish a short or long rest before you regain your uses of this feature.";
    [indomitableGroup addModifier:indomitableChargesModifier forStatisticID:DKStatIDIndomitableUsesMax];
    
    return indomitableGroup;
}

#pragma mark -

+ (DKChoiceModifierGroup*)martialArchetypeChoiceWithFighterLevel:(DKNumericStatistic*)level
                                                          skills:(DKSkills5E*)skills
                                                       equipment:(DKEquipment5E*)equipment
                                                proficiencyBonus:(DKNumericStatistic*)proficiencyBonus {
    
    DKSubgroupChoiceModifierGroup* martialArchetypeGroup = [[DKSubgroupChoiceModifierGroup alloc] initWithTag:DKChoiceFighterMartialArchetype];
    martialArchetypeGroup.explanation = @"Fighter martial archetype";
    [martialArchetypeGroup addDependency:level forKey:@"level"];
    martialArchetypeGroup.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:3];
    
    [martialArchetypeGroup addSubgroup:[DKFighter5E championArchetypeWithFighterLevel:level
                                                                               skills:skills
                                                                            equipment:equipment
                                                                     proficiencyBonus:proficiencyBonus]];
    
    return martialArchetypeGroup;
}

+ (DKModifierGroup*)championArchetypeWithFighterLevel:(DKNumericStatistic*)level
                                               skills:(DKSkills5E*)skills
                                            equipment:(DKEquipment5E*)equipment
                                     proficiencyBonus:(DKNumericStatistic*)proficiencyBonus {
    
    DKModifierGroup* championGroup = [[DKModifierGroup alloc] init];
    championGroup.explanation = @"Champion martial archetype";
    
    NSString* improvedCriticalExplanation = @"Your weapon attacks score a critical hit on a roll of 19 or 20.";
    DKModifier* improvedCriticalAbility = [DKModifier setModifierAppendedFromSource:level
                                                                      constantValue:@"Improved Critical"
                                                                            enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                                 isEqualToOrBetween:3 and:14]
                                                                        explanation:improvedCriticalExplanation];
    [championGroup addModifier:improvedCriticalAbility forStatisticID:DKStatIDFighterTraits];
    
    DKModifierGroup* remarkableAthleteAbility = [DKFighter5E remarkableAthleteWithFighterLevel:level
                                                                                        skills:skills
                                                                              proficiencyBonus:proficiencyBonus];
    [championGroup addSubgroup:remarkableAthleteAbility];
    
    DKModifierGroup* bonusFightingStyle = [DKFighter5E fightingStyleChoiceWithLevel:level
                                                                           minLevel:@10
                                                                          equipment:equipment];
    bonusFightingStyle.explanation = @"Fighting style from Champion archetype";
    [championGroup addSubgroup:bonusFightingStyle];
    
    NSString* superiorCriticalExplanation = @"Your weapon attacks score a critical hit on a roll of 18, 19, or 20.";
    DKModifier* superiorCriticalAbility = [DKModifier setModifierAppendedFromSource:level
                                                                      constantValue:@"Superior Critical"
                                                                            enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                             isGreaterThanOrEqualTo:15]
                                                                        explanation:superiorCriticalExplanation];
    [championGroup addModifier:superiorCriticalAbility forStatisticID:DKStatIDFighterTraits];
    
    NSString* survivorExplanation = @"At the start of each of your turns, you regain hit points equal to 5 + your Constitution modifier if you have no more than half of your hit points left. You don’t gain this benefit if you have 0 hit points.";
    DKModifier* survivorAbility = [DKModifier setModifierAppendedFromSource:level
                                                              constantValue:@"Survivor"
                                                                    enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                     isGreaterThanOrEqualTo:18]
                                                                explanation:survivorExplanation];
    [championGroup addModifier:survivorAbility forStatisticID:DKStatIDFighterTraits];
    
    return championGroup;
}

+ (DKModifierGroup*)remarkableAthleteWithFighterLevel:(DKNumericStatistic*)level
                                               skills:(DKSkills5E*)skills
                                     proficiencyBonus:(DKNumericStatistic*)proficiencyBonus {
    
    DKModifierGroup* remarkableAthleteGroup = [[DKModifierGroup alloc] init];
    remarkableAthleteGroup.explanation = @"Remarkable athlete ability";
    [remarkableAthleteGroup addDependency:level forKey:@"level"];
    remarkableAthleteGroup.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:7];
    
    NSExpression* divExpression = [NSExpression expressionForFunction:@"divide:by:" arguments:@[[NSExpression expressionForVariable:@"proficiencyBonus"],
                                                                                                [NSExpression expressionForConstantValue:@(2.0)]]];
    NSExpression* valueExpression = [NSExpression expressionForFunction:@"ceiling:" arguments:@[ divExpression ]];
    
    NSPredicate* proficiencyRequirement = [DKPredicateBuilder enabledWhen:@"proficiencyLevel" isEqualToOrBetween:0 and:0];
    
    NSArray* skillsForBonus = @[ skills.acrobatics, skills.athletics, skills.sleightOfHand, skills.stealth ];
    NSArray* skillStatIDs = @[ DKStatIDSkillAcrobatics, DKStatIDSkillAthletics, DKStatIDSkillSleightOfHand, DKStatIDSkillStealth ];
    for (int i = 0; i < skillsForBonus.count; i++) {
        DKProficientStatistic* skill = skillsForBonus[i];
        NSString* statID = skillStatIDs[i];
        DKModifier* skillBonus = [[DKModifier alloc] initWithDependencies:@{ @"proficiencyBonus": proficiencyBonus,
                                                                             @"proficiencyLevel": skill.proficiencyLevel }
                                                                    value:[valueExpression copy]
                                                                  enabled:[proficiencyRequirement copy]
                                                                 priority:kDKModifierPriority_Additive
                                                               expression:[DKExpressionBuilder additionExpression]];
        skillBonus.explanation = @"Remarkable Athlete bonus";
        [remarkableAthleteGroup addModifier:skillBonus forStatisticID:statID];
    }
    
    NSString* remarkableAthleteExplanation = @"When you make a running long jump, the distance you can cover increases by a number of feet equal to your Strength modifier.";
    DKModifier* remarkableAthleteAbility = [DKModifier setModifierWithAppendedObject:@"Remarkable Athlete" explanation:remarkableAthleteExplanation];
    [remarkableAthleteGroup addModifier:remarkableAthleteAbility forStatisticID:DKStatIDFighterTraits];
    
    return remarkableAthleteGroup;
}

#pragma mark -

- (void)loadClassModifiersWithAbilities:(DKAbilities5E*)abilities
                                 skills:(DKSkills5E*)skills
                              equipment:(DKEquipment5E*)equipment
                       proficiencyBonus:(DKNumericStatistic*)proficiencyBonus {
    
    self.classModifiers = [DKFighter5E fighterWithLevel:self.classLevel
                                              abilities:abilities
                                                 skills:skills
                                              equipment:equipment
                                       proficiencyBonus:proficiencyBonus];
    
    DKModifier* hitDiceModifier = [DKModifier diceModifierAddedFromSource:self.classHitDice];
    hitDiceModifier.explanation = @"Fighter hit dice";
    [self.classModifiers addModifier:hitDiceModifier forStatisticID:DKStatIDHitDiceMax];
}

#pragma DKClass5E override
- (void)loadClassModifiersForCharacter:(DKCharacter5E*)character {
    [self loadClassModifiersWithAbilities:character.abilities
                                   skills:character.skills
                                equipment:character.equipment
                         proficiencyBonus:character.proficiencyBonus];
}

#pragma mark -
#pragma DKStatisticGroup5E override

- (NSDictionary*) statisticKeyPaths {
    return @{
             DKStatIDFighterLevel: @"classLevel",
             DKStatIDFighterTraits: @"classTraits",
             DKStatIDFighterHitDice: @"classHitDice",
             DKStatIDSecondWindUsesCurrent: @"secondWindUsesCurrent",
             DKStatIDSecondWindUsesMax: @"secondWindUsesMax",
             DKStatIDActionSurgeUsesCurrent: @"actionSurgeUsesCurrent",
             DKStatIDActionSurgeUsesMax: @"actionSurgeUsesMax",
             DKStatIDIndomitableUsesCurrent: @"indomitableUsesCurrent",
             DKStatIDIndomitableUsesMax: @"indomitableUsesMax",
             };
}

- (void)loadStatistics {
    
    [super loadStatistics];
    self.secondWindUsesCurrent = [DKNumericStatistic statisticWithInt:0];
    self.secondWindUsesMax = [DKNumericStatistic statisticWithInt:0];
    self.actionSurgeUsesCurrent = [DKNumericStatistic statisticWithInt:0];
    self.actionSurgeUsesMax = [DKNumericStatistic statisticWithInt:0];
    self.indomitableUsesCurrent = [DKNumericStatistic statisticWithInt:0];
    self.indomitableUsesMax = [DKNumericStatistic statisticWithInt:0];
}

- (void)loadModifiers {
    
    [super loadModifiers];
    [_secondWindUsesCurrent applyModifier:[DKModifier numericModifierAddedFromSource:_secondWindUsesMax]];
    [_actionSurgeUsesCurrent applyModifier:[DKModifier numericModifierAddedFromSource:_actionSurgeUsesMax]];
    [_indomitableUsesCurrent applyModifier:[DKModifier numericModifierAddedFromSource:_indomitableUsesMax]];
}

@end
