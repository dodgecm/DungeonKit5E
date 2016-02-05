//
//  DKCleric5E.m
//  DungeonKit
//
//  Created by Christopher Dodge on 4/27/15.
//  Copyright (c) 2015 Dodge. All rights reserved.
//

#import "DKCleric5E.h"
#import "DKModifierBuilder.h"
#import "DKChoiceModifierGroup.h"
#import "DKModifierGroupTags5E.h"
#import "DKStatisticIDs5E.h"
#import "DKSkills5E.h"
#import "DKAbilities5E.h"
#import "DKWeapon5E.h"
#import "DKArmor5E.h"
#import "DKSpellbook5E.h"
#import "DKCharacter5E.h"

@implementation DKCleric5E

@synthesize channelDivinityUsesCurrent = _channelDivinityUsesCurrent;
@synthesize channelDivinityUsesMax = _channelDivinityUsesMax;
@synthesize destroyUndeadCR = _destroyUndeadCR;

#pragma mark -

+ (DKModifierGroup*)clericWithLevel:(DKNumericStatistic*)level abilities:(DKAbilities5E*)abilities {
    
    DKModifierGroup* class = [[DKModifierGroup alloc] init];
    [class addDependency:level forKey:@"level"];
    class.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:1];
    class.explanation = @"Cleric class modifiers";
    
    [class addModifier:[DKModifier stringModifierWithNewString:@"Cleric"] forStatisticID:DKStatIDClassName];
    [class addModifier:[DKClass5E hitDiceModifierForSides:8 level:level] forStatisticID:DKStatIDClericHitDice];
    [class addSubgroup:[DKClass5E hitPointsMaxIncreasesForSides:8 level:level]];
    
    [class addModifier:[abilities.wisdom modifierFromAbilityScoreWithExplanation:@"Cleric spellcasting ability: Wisdom"]
        forStatisticID:DKStatIDSpellSaveDC];
    [class addModifier:[abilities.wisdom modifierFromAbilityScoreWithExplanation:@"Cleric spellcasting ability: Wisdom"]
        forStatisticID:DKStatIDSpellAttackBonus];
    [class addModifier:[abilities.wisdom modifierFromAbilityScoreWithExplanation:@"Cleric spellcasting ability: Wisdom"]
        forStatisticID:DKStatIDPreparedSpellsMax];
    
    DKModifier* preparedSpellsModifier = [DKModifier numericModifierAddedFromSource:level];
    preparedSpellsModifier.explanation = @"Cleric level";
    [class addModifier:preparedSpellsModifier forStatisticID:DKStatIDPreparedSpellsMax];
    
    DKModifier* minimumPreparedSpells = [DKModifier numericModifierWithMin:1];
    minimumPreparedSpells.explanation = @"Minimum of 1 prepared spell";
    [class addModifier:minimumPreparedSpells forStatisticID:DKStatIDPreparedSpellsMax];
    
    [class addModifier:[DKModifier setModifierWithAppendedObject:@"Ritual Casting" explanation:@"You can cast a cleric spell as a ritual if that spell has the ritual tag and you have the spell prepared"]
        forStatisticID:DKStatIDClericTraits];
    
    [class addModifier:[DKModifier numericModifierWithClampBetween:1 and:1 explanation:@"Cleric Saving Throw Proficiency: Wisdom"]
        forStatisticID:DKStatIDSavingThrowWisdomProficiency];
    [class addModifier:[DKModifier numericModifierWithClampBetween:1 and:1 explanation:@"Cleric Saving Throw Proficiency: Charisma"]
        forStatisticID:DKStatIDSavingThrowCharismaProficiency];
    [class addModifier:[DKModifier setModifierWithAppendedObject:[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Simple]
                                                     explanation:@"Cleric Weapon Proficiencies"]
        forStatisticID:DKStatIDWeaponProficiencies];
    
    NSArray* armorProficiencies = @[ @(kDKArmorCategory5E_Light),
                                     @(kDKArmorCategory5E_Medium),
                                     @(kDKArmorCategory5E_Shield) ];
    for (NSNumber* armorProficiency in armorProficiencies) {
        [class addModifier:[DKModifier setModifierWithAppendedObject:[DKArmorBuilder5E proficiencyNameForArmorCategory:armorProficiency.integerValue]
                                                         explanation:@"Cleric Armor Proficiencies"]
            forStatisticID:DKStatIDArmorProficiencies];
    }
    
    [class addModifier:[DKModifier setModifierWithAppendedObject:@"Channel Divinity" explanation:@"You have the ability to channel divine energy directly from your deity, using that energy to fuel magical effects.  When you use your Channel Divinity, you choose which effect to create.  You must then finish a short or long rest to use your Channel Divinity again."]
        forStatisticID:DKStatIDClericTraits];
    
    NSExpression* channelDivinityValue = [DKExpressionBuilder valueFromPiecewiseFunctionRanges:
                                          @{ [DKExpressionBuilder rangeValueWithMin:0 max:1] : @(0),
                                             [DKExpressionBuilder rangeValueWithMin:2 max:5] : @(1),
                                             [DKExpressionBuilder rangeValueWithMin:6 max:17] : @(2),
                                             [DKExpressionBuilder rangeValueWithMin:18 max:20] : @(3) }
                                                                               usingDependency:@"source"];
    DKModifier* channelDivinityUses = [[DKModifier alloc] initWithSource:level
                                                                   value:channelDivinityValue
                                                                priority:kDKModifierPriority_Additive
                                                              expression:[DKExpressionBuilder additionExpression]];
    [class addModifier:channelDivinityUses forStatisticID:DKStatIDChannelDivinityUsesMax];
    
    DKModifierGroup* turnUndeadGroup = [DKCleric5E turnUndeadWithLevel:level];
    [class addSubgroup:turnUndeadGroup];
    
    DKModifierGroup* divineInterventionGroup = [DKCleric5E divineInterventionWithLevel:level];
    [class addSubgroup:divineInterventionGroup];
    
    DKChoiceModifierGroup* divineDomainGroup = [DKCleric5E divineDomainChoiceWithLevel:level];
    [class addSubgroup:divineDomainGroup];
    
    NSArray* skillProficiencyStatIDs = @[ DKStatIDSkillHistoryProficiency,
                                          DKStatIDSkillInsightProficiency,
                                          DKStatIDSkillMedicineProficiency,
                                          DKStatIDSkillPersuasionProficiency,
                                          DKStatIDSkillReligionProficiency ];
    DKModifierGroup* skillProficiencyGroup = [DKClass5E skillProficienciesWithStatIDs:skillProficiencyStatIDs
                                                                       choiceGroupTag:DKChoiceClericSkillProficiency];
    skillProficiencyGroup.explanation = @"Cleric Skill Proficiencies: Choose two from History, Insight, Medicine, Persuasion, and Religion";
    [class addSubgroup:skillProficiencyGroup];
    
    DKModifierGroup* cantripsGroup = [DKCleric5E cantripsWithLevel:level];
    [class addSubgroup:cantripsGroup];
    
    DKModifierGroup* spellSlotsGroup = [DKCleric5E spellSlotsWithLevel:level];
    [class addSubgroup:spellSlotsGroup];
    
    for (int i = 1; i <= 9; i++) {
        DKModifierGroup* clericSpells = [DKClericSpellBuilder5E spellListForSpellLevel:i
                                                                           clericLevel:level];
        [class addSubgroup:clericSpells];
    }
    
    NSArray* abilityScoreImprovementLevels = @[ @4, @8, @12, @16, @19];
    for (NSNumber* abilityScoreLevel in abilityScoreImprovementLevels) {
        DKModifierGroup* abilityScoreGroup = [DKClass5E abilityScoreImprovementForThreshold:abilityScoreLevel.integerValue level:level];
        [class addSubgroup:abilityScoreGroup];
    }
    
    DKModifier* startingGold = [DKModifier numericModifierWithAdditiveBonus:125];
    startingGold.explanation = @"Cleric starting gold";
    [class addModifier:startingGold forStatisticID:DKStatIDCurrencyGold];
    
    return class;
}

+ (DKModifierGroup*)cantripsWithLevel:(DKNumericStatistic*)level {
    
    DKModifierGroup* cantripsGroup = [[DKModifierGroup alloc] init];
    cantripsGroup.explanation = @"Cleric cantrips";
    
    for (int i = 0; i < 3; i++) {
        [cantripsGroup addSubgroup:[DKClericSpellBuilder5E cantripChoiceWithLevel:level
                                                                        threshold:1
                                                                      explanation:@"First level Cleric cantrip"]];
    }
    
    [cantripsGroup addSubgroup:[DKClericSpellBuilder5E cantripChoiceWithLevel:level
                                                                    threshold:4
                                                                  explanation:@"Fourth level Cleric cantrip"]];
    
    [cantripsGroup addSubgroup:[DKClericSpellBuilder5E cantripChoiceWithLevel:level
                                                                    threshold:10
                                                                  explanation:@"Tenth level Cleric cantrip"]];
    
    return cantripsGroup;
}

+ (DKModifierGroup*)spellSlotsWithLevel:(DKNumericStatistic*)level {
    
    DKModifierGroup* spellSlotsGroup = [[DKModifierGroup alloc] init];
    spellSlotsGroup.explanation = @"Cleric spell slots";
    
    NSExpression* firstLevelSpellSlotsValue = [DKExpressionBuilder valueFromPiecewiseFunctionRanges:
                                               @{ [DKExpressionBuilder rangeValueWithMin:0 max:0] : @(0),
                                                  [DKExpressionBuilder rangeValueWithMin:1 max:1] : @(2),
                                                  [DKExpressionBuilder rangeValueWithMin:2 max:2] : @(3),
                                                  [DKExpressionBuilder rangeValueWithMin:3 max:20] : @(4) }
                                                                                    usingDependency:@"source"];
    DKModifier* firstLevelSpellSlots = [[DKModifier alloc] initWithSource:level
                                                                    value:firstLevelSpellSlotsValue
                                                                 priority:kDKModifierPriority_Additive
                                                               expression:[DKExpressionBuilder additionExpression]];
    [spellSlotsGroup addModifier:firstLevelSpellSlots forStatisticID:DKStatIDFirstLevelSpellSlotsMax];
    
    NSExpression* secondLevelSpellSlotsValue = [DKExpressionBuilder valueFromPiecewiseFunctionRanges:
                                                @{ [DKExpressionBuilder rangeValueWithMin:0 max:2] : @(0),
                                                   [DKExpressionBuilder rangeValueWithMin:3 max:3] : @(2),
                                                   [DKExpressionBuilder rangeValueWithMin:4 max:20] : @(3) }
                                                                                     usingDependency:@"source"];
    DKModifier* secondLevelSpellSlots = [[DKModifier alloc] initWithSource:level
                                                                     value:secondLevelSpellSlotsValue
                                                                  priority:kDKModifierPriority_Additive
                                                                expression:[DKExpressionBuilder additionExpression]];
    [spellSlotsGroup addModifier:secondLevelSpellSlots forStatisticID:DKStatIDSecondLevelSpellSlotsMax];
    
    NSExpression* thirdLevelSpellSlotsValue = [DKExpressionBuilder valueFromPiecewiseFunctionRanges:
                                               @{ [DKExpressionBuilder rangeValueWithMin:0 max:4] : @(0),
                                                  [DKExpressionBuilder rangeValueWithMin:5 max:5] : @(2),
                                                  [DKExpressionBuilder rangeValueWithMin:6 max:20] : @(3) }
                                                                                    usingDependency:@"source"];
    DKModifier* thirdLevelSpellSlots = [[DKModifier alloc] initWithSource:level
                                                                    value:thirdLevelSpellSlotsValue
                                                                 priority:kDKModifierPriority_Additive
                                                               expression:[DKExpressionBuilder additionExpression]];
    [spellSlotsGroup addModifier:thirdLevelSpellSlots forStatisticID:DKStatIDThirdLevelSpellSlotsMax];
    
    NSExpression* fourthLevelSpellSlotsValue = [DKExpressionBuilder valueFromPiecewiseFunctionRanges:
                                                @{ [DKExpressionBuilder rangeValueWithMin:0 max:6] : @(0),
                                                   [DKExpressionBuilder rangeValueWithMin:7 max:7] : @(1),
                                                   [DKExpressionBuilder rangeValueWithMin:8 max:8] : @(2),
                                                   [DKExpressionBuilder rangeValueWithMin:9 max:20] : @(3) }
                                                                                     usingDependency:@"source"];
    DKModifier* fourthLevelSpellSlots = [[DKModifier alloc] initWithSource:level
                                                                     value:fourthLevelSpellSlotsValue
                                                                  priority:kDKModifierPriority_Additive
                                                                expression:[DKExpressionBuilder additionExpression]];
    [spellSlotsGroup addModifier:fourthLevelSpellSlots forStatisticID:DKStatIDFourthLevelSpellSlotsMax];
    
    NSExpression* fifthLevelSpellSlotsValue = [DKExpressionBuilder valueFromPiecewiseFunctionRanges:
                                               @{ [DKExpressionBuilder rangeValueWithMin:0 max:8] : @(0),
                                                  [DKExpressionBuilder rangeValueWithMin:9 max:9] : @(1),
                                                  [DKExpressionBuilder rangeValueWithMin:10 max:17] : @(2),
                                                  [DKExpressionBuilder rangeValueWithMin:18 max:20] : @(3) }
                                                                                    usingDependency:@"source"];
    DKModifier* fifthLevelSpellSlots = [[DKModifier alloc] initWithSource:level
                                                                    value:fifthLevelSpellSlotsValue
                                                                 priority:kDKModifierPriority_Additive
                                                               expression:[DKExpressionBuilder additionExpression]];
    [spellSlotsGroup addModifier:fifthLevelSpellSlots forStatisticID:DKStatIDFifthLevelSpellSlotsMax];
    
    NSExpression* sixthLevelSpellSlotsValue = [DKExpressionBuilder valueFromPiecewiseFunctionRanges:
                                               @{ [DKExpressionBuilder rangeValueWithMin:0 max:10] : @(0),
                                                  [DKExpressionBuilder rangeValueWithMin:11 max:18] : @(1),
                                                  [DKExpressionBuilder rangeValueWithMin:19 max:20] : @(2) }
                                                                                    usingDependency:@"source"];
    DKModifier* sixthLevelSpellSlots = [[DKModifier alloc] initWithSource:level
                                                                    value:sixthLevelSpellSlotsValue
                                                                 priority:kDKModifierPriority_Additive
                                                               expression:[DKExpressionBuilder additionExpression]];
    [spellSlotsGroup addModifier:sixthLevelSpellSlots forStatisticID:DKStatIDSixthLevelSpellSlotsMax];
    
    NSExpression* seventhLevelSpellSlotsValue = [DKExpressionBuilder valueFromPiecewiseFunctionRanges:
                                                 @{ [DKExpressionBuilder rangeValueWithMin:0 max:12] : @(0),
                                                    [DKExpressionBuilder rangeValueWithMin:13 max:19] : @(1),
                                                    [DKExpressionBuilder rangeValueWithMin:20 max:20] : @(2) }
                                                                                      usingDependency:@"source"];
    DKModifier* seventhLevelSpellSlots = [[DKModifier alloc] initWithSource:level
                                                                      value:seventhLevelSpellSlotsValue
                                                                   priority:kDKModifierPriority_Additive
                                                                 expression:[DKExpressionBuilder additionExpression]];
    [spellSlotsGroup addModifier:seventhLevelSpellSlots forStatisticID:DKStatIDSeventhLevelSpellSlotsMax];
    
    NSExpression* eighthLevelSpellSlotsValue = [DKExpressionBuilder valueFromPiecewiseFunctionRanges:
                                                @{ [DKExpressionBuilder rangeValueWithMin:0 max:14] : @(0),
                                                   [DKExpressionBuilder rangeValueWithMin:15 max:20] : @(1) }
                                                                                     usingDependency:@"source"];
    DKModifier* eighthLevelSpellSlots = [[DKModifier alloc] initWithSource:level
                                                                     value:eighthLevelSpellSlotsValue
                                                                  priority:kDKModifierPriority_Additive
                                                                expression:[DKExpressionBuilder additionExpression]];
    [spellSlotsGroup addModifier:eighthLevelSpellSlots forStatisticID:DKStatIDEighthLevelSpellSlotsMax];
    
    NSExpression* ninthLevelSpellSlotsValue = [DKExpressionBuilder valueFromPiecewiseFunctionRanges:
                                               @{ [DKExpressionBuilder rangeValueWithMin:0 max:16] : @(0),
                                                  [DKExpressionBuilder rangeValueWithMin:17 max:20] : @(1) }
                                                                                    usingDependency:@"source"];
    DKModifier* ninthLevelSpellSlots = [[DKModifier alloc] initWithSource:level
                                                                    value:ninthLevelSpellSlotsValue
                                                                 priority:kDKModifierPriority_Additive
                                                               expression:[DKExpressionBuilder additionExpression]];
    [spellSlotsGroup addModifier:ninthLevelSpellSlots forStatisticID:DKStatIDNinthLevelSpellSlotsMax];
    
    return spellSlotsGroup;
}

+ (DKModifierGroup*)turnUndeadWithLevel:(DKNumericStatistic*)level {
    
    DKModifierGroup* turnUndeadGroup = [[DKModifierGroup alloc] init];
    [turnUndeadGroup addDependency:level forKey:@"level"];
    turnUndeadGroup.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:2];
    
    DKModifier* turnUndeadAbility = [DKModifier setModifierWithAppendedObject:@"Channel Divinity - Turn Undead"];
    turnUndeadAbility.explanation = @"As an action, you present your holy symbol and speak a prayer censuring the undead.  "
    "Each undead that can see or hear you within 30 feet of you must make a Wisdom saving throw.  If the creature fails its saving throw, "
    "it is turned for 1 minute or until it takes any damage.";
    [turnUndeadGroup addModifier:turnUndeadAbility forStatisticID:DKStatIDClericTraits];
    
    
    NSString* destroyUndeadExplanation = @"When an undead fails its saving throw against your Turn Undead feature, "
    "the creature is instantly destroyed if its challenge rating is at or below a certain threshold.";
    DKModifier* destroyUndeadAbility = [DKModifier setModifierAppendedFromSource:level
                                                                   constantValue:@"Destroy Undead"
                                                                         enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                          isGreaterThanOrEqualTo:5]
                                                                     explanation:destroyUndeadExplanation];
    [turnUndeadGroup addModifier:destroyUndeadAbility forStatisticID:DKStatIDClericTraits];
    
    DKModifier* firstCRThreshold = [[DKModifier alloc] initWithSource:level
                                                                value:[DKExpressionBuilder valueFromObject:@"1/2"]
                                                              enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                   isEqualToOrBetween:5 and:7]
                                                             priority:kDKModifierPriority_Additive
                                                           expression:[DKExpressionBuilder replaceStringExpression]];
    firstCRThreshold.explanation = @"Destroy Undead destroys undead creatures of CR 1/2 or lower.";
    [turnUndeadGroup addModifier:firstCRThreshold forStatisticID:DKStatIDDestroyUndeadCR];
    
    DKModifier* secondCRThreshold = [[DKModifier alloc] initWithSource:level
                                                                 value:[DKExpressionBuilder valueFromObject:@"1"]
                                                               enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                    isEqualToOrBetween:8 and:10]
                                                              priority:kDKModifierPriority_Additive
                                                            expression:[DKExpressionBuilder replaceStringExpression]];
    secondCRThreshold.explanation = @"Destroy Undead destroys undead creatures of CR 1 or lower.";
    [turnUndeadGroup addModifier:secondCRThreshold forStatisticID:DKStatIDDestroyUndeadCR];
    
    DKModifier* thirdCRThreshold = [[DKModifier alloc] initWithSource:level
                                                                value:[DKExpressionBuilder valueFromObject:@"2"]
                                                              enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                   isEqualToOrBetween:11 and:13]
                                                             priority:kDKModifierPriority_Additive
                                                           expression:[DKExpressionBuilder replaceStringExpression]];
    
    thirdCRThreshold.explanation = @"Destroy Undead destroys undead creatures of CR 2 or lower.";
    [turnUndeadGroup addModifier:thirdCRThreshold forStatisticID:DKStatIDDestroyUndeadCR];
    
    DKModifier* fourthCRThreshold = [[DKModifier alloc] initWithSource:level
                                                                 value:[DKExpressionBuilder valueFromObject:@"3"]
                                                               enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                    isEqualToOrBetween:14 and:16]
                                                              priority:kDKModifierPriority_Additive
                                                            expression:[DKExpressionBuilder replaceStringExpression]];
    
    fourthCRThreshold.explanation = @"Destroy Undead destroys undead creatures of CR 3 or lower.";
    [turnUndeadGroup addModifier:fourthCRThreshold forStatisticID:DKStatIDDestroyUndeadCR];
    
    DKModifier* fifthCRThreshold = [[DKModifier alloc] initWithSource:level
                                                                value:[DKExpressionBuilder valueFromObject:@"4"]
                                                              enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                               isGreaterThanOrEqualTo:17]
                                                             priority:kDKModifierPriority_Additive
                                                           expression:[DKExpressionBuilder replaceStringExpression]];
    fifthCRThreshold.explanation = @"Destroy Undead destroys undead creatures of CR 4 or lower.";
    [turnUndeadGroup addModifier:fifthCRThreshold forStatisticID:DKStatIDDestroyUndeadCR];
    
    return turnUndeadGroup;
}

+ (DKModifierGroup*)divineInterventionWithLevel:(DKNumericStatistic*)level {
    
    DKModifierGroup* divineInterventionGroup = [[DKModifierGroup alloc] init];
    [divineInterventionGroup addDependency:level forKey:@"level"];
    divineInterventionGroup.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:10];
    
    NSString* divineInterventionExplanation = @"You can call on your deity to intervene on your behalf when your need is great.  "
    "Imploring your deity's aid requires you to use your action.  Describe the assistance you seek, and roll percentile dice.  If you roll a number "
    "equal to or lower than your cleric level, your deity intervenes.  If your deity intervenes, you can't use this feature again for 7 days.  Otherwise, "
    "you can use it again after you finish a long rest.";
    DKModifier* divineInterventionAbility = [[DKModifier alloc] initWithSource:level
                                                                         value:[DKExpressionBuilder valueFromObject:@"Divine Intervention"]
                                                                       enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                            isEqualToOrBetween:10 and:19]
                                                                      priority:kDKModifierPriority_Additive
                                                                    expression:[DKExpressionBuilder appendExpression]];
    divineInterventionAbility.explanation = divineInterventionExplanation;
    [divineInterventionGroup addModifier:divineInterventionAbility forStatisticID:DKStatIDClericTraits];
    
    NSString* autoInterveneExplanation = @"You can call on your deity to intervene on your behalf when your need is great.  Imploring your deity's aid requires you to use your action.  Describe the assistance you seek.  Your call for intervention succeeds automatically, no roll required.  You can't use this feature again for 7 days.";
    DKModifier* autoInterveneAbility = [[DKModifier alloc] initWithSource:level
                                                                    value:[DKExpressionBuilder valueFromObject:@"Divine Intervention"]
                                                                  enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                   isGreaterThanOrEqualTo:20]
                                                                 priority:kDKModifierPriority_Additive
                                                               expression:[DKExpressionBuilder appendExpression]];
    autoInterveneAbility.explanation = autoInterveneExplanation;
    [divineInterventionGroup addModifier:autoInterveneAbility forStatisticID:DKStatIDClericTraits];
    
    return divineInterventionGroup;
}

+ (DKModifierGroup*)domainSpellsGroupClericLevel:(DKNumericStatistic*)level spellDictionary:(NSDictionary*)spellsDict {
    
    DKModifierGroup* domainSpellsGroup = [[DKModifierGroup alloc] init];
    
    for (NSNumber* levelThreshold in spellsDict.allKeys) {
        NSArray* spellExplanations = spellsDict[levelThreshold];
        for (NSString* spellName in spellExplanations) {
            
            DKModifier* modifier = [DKModifier setModifierAppendedFromSource:level
                                                                       value:[DKExpressionBuilder valueFromObject:spellName]
                                                                     enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                      isGreaterThanOrEqualTo:levelThreshold.intValue]];
            modifier.explanation = [NSString stringWithFormat:@"Level %@ Divine Domain Spell", levelThreshold];
            [domainSpellsGroup addModifier:modifier forStatisticID:DKStatIDPreparedSpells];
        }
    }
    
    return domainSpellsGroup;
}

#pragma mark -

+ (DKChoiceModifierGroup*)divineDomainChoiceWithLevel:(DKNumericStatistic*)level {
    
    DKSubgroupChoiceModifierGroup* divineDomainGroup = [[DKSubgroupChoiceModifierGroup alloc] initWithTag:DKChoiceClericDivineDomain];
    divineDomainGroup.explanation = @"Cleric divine domain";
    [divineDomainGroup addDependency:level forKey:@"level"];
    divineDomainGroup.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:1];
    
    [divineDomainGroup addSubgroup:[DKCleric5E lifeDomainWithLevel:level]];
    
    return divineDomainGroup;
}

+ (DKModifierGroup*)lifeDomainWithLevel:(DKNumericStatistic*)level {
    
    DKModifierGroup* lifeDomainGroup = [[DKModifierGroup alloc] init];
    lifeDomainGroup.explanation = @"Divine Domain: Life";
    
    [lifeDomainGroup addModifier:[DKModifier setModifierWithAppendedObject:[DKArmorBuilder5E proficiencyNameForArmorCategory:kDKArmorCategory5E_Heavy]
                                                               explanation:@"Life Domain Armor Proficiencies"]
                  forStatisticID:DKStatIDArmorProficiencies];
    
    NSDictionary* spells = @{ @(1): @[ @"Bless", @"Cure Wounds" ],
                              @(3): @[ @"Lesser Restoration", @"Spiritual Weapon" ],
                              @(5): @[ @"Beacon of Hope", @"Revivify" ],
                              @(7): @[ @"Death Ward", @"Guardian of Faith" ],
                              @(9): @[ @"Mass Cure Wounds", @"Raise Dead" ] };
    DKModifierGroup* lifeDomainSpellsGroup = [DKCleric5E domainSpellsGroupClericLevel:level spellDictionary:spells];
    [lifeDomainGroup addSubgroup:lifeDomainSpellsGroup];
    
    NSExpression* preparedSpellsValue = [DKExpressionBuilder valueFromPiecewiseFunctionRanges:
                                         @{ [DKExpressionBuilder rangeValueWithMin:0 max:0] : @(0),
                                            [DKExpressionBuilder rangeValueWithMin:1 max:2] : @(2),
                                            [DKExpressionBuilder rangeValueWithMin:3 max:4] : @(4),
                                            [DKExpressionBuilder rangeValueWithMin:5 max:6] : @(6),
                                            [DKExpressionBuilder rangeValueWithMin:7 max:8] : @(8),
                                            [DKExpressionBuilder rangeValueWithMin:9 max:20] : @(10) }
                                                                              usingDependency:@"source"];
    DKModifier* preparedSpellsBonus = [[DKModifier alloc] initWithSource:level
                                                                   value:preparedSpellsValue
                                                                priority:kDKModifierPriority_Additive
                                                              expression:[DKExpressionBuilder additionExpression]];
    preparedSpellsBonus.explanation = @"Spells granted by your Divine Domain do not count against your prepared spells limit.";
    [lifeDomainGroup addModifier:preparedSpellsBonus forStatisticID:DKStatIDPreparedSpellsMax];
    
    DKModifier* discipleOfLife = [DKModifier setModifierWithAppendedObject:@"Disciple of Life" explanation:@"Whenever you use a spell of 1st level or higher to restore hit points to a creature, the creature regains additional hit points equal to 2 + the spell's level."];
    [lifeDomainGroup addModifier:discipleOfLife forStatisticID:DKStatIDClericTraits];
    
    NSString* preserveLifeExplanation = @"As an action, you present your holy symbol and evoke healing energy that "
    "can restore a number of hit points equal to five times your cleric level.  Choose any creatures within 30 feet of you, and divide those hit points "
    "among them.  This feature can restore a creature to no more than half of its hit point maximum.  You can't use this feature on an undead or "
    "a construct.";
    DKModifier* preserveLifeAbility = [DKModifier setModifierAppendedFromSource:level
                                                                  constantValue:@"Channel Divinity - Preserve Life"
                                                                        enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                         isGreaterThanOrEqualTo:2]
                                                                    explanation:preserveLifeExplanation];
    [lifeDomainGroup addModifier:preserveLifeAbility forStatisticID:DKStatIDClericTraits];
    
    NSString* blessedHealerExplanation = @"The healing spells you cast on others heal you as well.  When you cast a spell of 1st "
    "level or higher that restores hit points to a creature other than you, you regain hit points equal to 2 + the spell’s level.";
    
    DKModifier* blessedHealerAbility = [DKModifier setModifierAppendedFromSource:level
                                                                   constantValue:@"Blessed Healer"
                                                                         enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                          isGreaterThanOrEqualTo:6]
                                                                     explanation:blessedHealerExplanation];
    [lifeDomainGroup addModifier:blessedHealerAbility forStatisticID:DKStatIDClericTraits];
    
    NSString* divineStrikeExplanation = @"You gain the ability to infuse your weapon strikes with divine energy. Once on each of your "
    "turns when you hit a creature with a weapon attack, you can cause the attack to deal an extra 1d8 radiant damage to the target. When you reach 14th "
    "level, the extra damage increases to 2d8.";
    DKModifier* divineStrikeAbility = [DKModifier setModifierAppendedFromSource:level
                                                                  constantValue:@"Divine Strike"
                                                                        enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                         isGreaterThanOrEqualTo:8]
                                                                    explanation:divineStrikeExplanation];
    [lifeDomainGroup addModifier:divineStrikeAbility forStatisticID:DKStatIDClericTraits];
    
    NSString* supremeHealingExplanation = @"When you would normally roll one or more dice to restore hit points with a spell, you "
    "instead use the highest number possible for each die.";
    DKModifier* supremeHealingAbility = [DKModifier setModifierAppendedFromSource:level
                                                                    constantValue:@"Supreme Healing"
                                                                          enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                           isGreaterThanOrEqualTo:17]
                                                                      explanation:supremeHealingExplanation];
    [lifeDomainGroup addModifier:supremeHealingAbility forStatisticID:DKStatIDClericTraits];
    
    return lifeDomainGroup;
}

#pragma mark -

- (void)loadClassModifiersWithAbilities:(DKAbilities5E*)abilities {
    
    self.classModifiers = [DKCleric5E clericWithLevel:self.classLevel abilities:abilities];
    
    DKModifier* hitDiceModifier = [DKModifier diceModifierAddedFromSource:self.classHitDice];
    hitDiceModifier.explanation = @"Cleric hit dice";
    [self.classModifiers addModifier:hitDiceModifier forStatisticID:DKStatIDHitDiceMax];
}

#pragma DKClass5E override
- (void)loadClassModifiersForCharacter:(DKCharacter5E*)character {
    [self loadClassModifiersWithAbilities:character.abilities];
}

#pragma mark -
#pragma DKStatisticGroup5E override
- (NSDictionary*) statisticKeyPaths {
    return @{
             DKStatIDClericLevel: @"classLevel",
             DKStatIDClericTraits: @"classTraits",
             DKStatIDClericHitDice: @"classHitDice",
             DKStatIDChannelDivinityUsesCurrent: @"channelDivinityUsesCurrent",
             DKStatIDChannelDivinityUsesMax: @"channelDivinityUsesMax",
             DKStatIDDestroyUndeadCR: @"destroyUndeadCR",
             };
}

- (void)loadStatistics {
    
    [super loadStatistics];
    self.channelDivinityUsesMax = [DKNumericStatistic statisticWithInt:0];
    self.channelDivinityUsesCurrent = [DKNumericStatistic statisticWithInt:0];
    self.destroyUndeadCR = [DKStringStatistic statisticWithString:@""];
}

- (void)loadModifiers {
    
    [super loadModifiers];
    [_channelDivinityUsesCurrent applyModifier:[DKModifier numericModifierAddedFromSource:_channelDivinityUsesMax]];
}

@end

#pragma mark -

@implementation DKClericSpellBuilder5E

+ (DKChoiceModifierGroup*)cantripChoiceWithLevel:(DKNumericStatistic*)level
                                       threshold:(NSInteger)threshold
                                     explanation:(NSString*)explanation {
    
    DKChoiceModifierGroup* cantripGroup = [[DKSingleChoiceModifierGroup alloc] initWithTag:DKChoiceClericCantrip];
    [cantripGroup addDependency:level forKey:@"level"];
    cantripGroup.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:threshold];
    
    NSArray* spellNames = @[ @"Guidance",
                             @"Light",
                             @"Resistance",
                             @"Sacred Flame",
                             @"Spare the Dying",
                             @"Thaumaturgy" ];
    for (NSString* spell in spellNames) {
        DKModifier* modifier = [DKModifier setModifierAppendedFromSource:level
                                                           constantValue:spell
                                                                 enabled:nil
                                                             explanation:explanation];
        [cantripGroup addModifier:modifier forStatisticID:DKStatIDCantrips];
    }
    
    return cantripGroup;
}

+ (DKModifierGroup*)spellListForSpellLevel:(NSInteger)spellLevel
                               clericLevel:(DKNumericStatistic*)level {
    
    DKModifierGroup* spellGroup = [[DKModifierGroup alloc] init];
    [spellGroup addDependency:level forKey:@"level"];
    spellGroup.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:spellLevel*2 - 1];
    spellGroup.explanation = [NSString stringWithFormat:@"Cleric level %li spells", (long)spellLevel];
    
    NSArray* spellNames = nil;
    switch (spellLevel) {
        case 1: {
            spellNames = @[ @"Bless",
                            @"Command",
                            @"Cure Wounds",
                            @"Detect Magic",
                            @"Guiding Bolt",
                            @"Healing Word",
                            @"Inflict Wounds",
                            @"Sanctuary",
                            @"Shield of Faith" ];
            break;
        }
            
        case 2: {
            spellNames = @[ @"Aid",
                            @"Augury",
                            @"Hold Person",
                            @"Lesser Restoration",
                            @"Prayer of Healing",
                            @"Silence",
                            @"Spiritual Weapon",
                            @"Warding Bond" ];
            break;
        }
            
        case 3: {
            spellNames = @[ @"Beacon of Hope",
                            @"Dispel Magic",
                            @"Cure Wounds",
                            @"Mass Healing Word",
                            @"Protection from Energy",
                            @"Remove Curse",
                            @"Revivify",
                            @"Speak with Dead",
                            @"Spirit Guardians" ];
            break;
        }
            
        case 4: {
            spellNames = @[ @"Death Ward",
                            @"Divination",
                            @"Freedom of Movement",
                            @"Guardian of Faith",
                            @"Locate Creature" ];
            break;
        }
            
        case 5: {
            spellNames = @[ @"Commune",
                            @"Flame Strike",
                            @"Greater Restoration",
                            @"Mass Cure Wounds",
                            @"Raise Dead" ];
            break;
        }
            
        case 6: {
            spellNames = @[ @"Blade Barrier",
                            @"Find the Path",
                            @"Harm",
                            @"Heal",
                            @"Heroes’ Feast",
                            @"True Seeing" ];
            break;
        }
            
        case 7: {
            spellNames = @[ @"Etherealness",
                            @"Fire Storm",
                            @"Regenerate",
                            @"Resurrection" ];
            break;
        }
            
        case 8: {
            spellNames = @[ @"Antimagic Field",
                            @"Earthquake",
                            @"Holy Aura" ];
            break;
        }
            
        case 9: {
            spellNames = @[ @"Astral Projection",
                            @"Gate",
                            @"Mass Heal",
                            @"True Resurrection" ];
            break;
        }
            
        default:
            break;
    }
    
    for (NSString* spell in spellNames) {
        DKModifier* modifier = [DKModifier setModifierAppendedFromSource:level
                                                           constantValue:spell
                                                                 enabled:nil
                                                             explanation:[NSString stringWithFormat:@"Cleric level %li spell", (long)spellLevel]];
        [spellGroup addModifier:modifier forStatisticID:[DKSpellbook5E statIDForSpellLevel:spellLevel]];
    }
    
    return spellGroup;
}

@end
