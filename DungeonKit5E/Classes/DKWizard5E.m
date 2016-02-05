//
//  DKWizard5E.m
//  DungeonKit
//
//  Created by Christopher Dodge on 7/1/15.
//  Copyright (c) 2015 Dodge. All rights reserved.
//

#import "DKWizard5E.h"
#import "DKStatisticIDs5E.h"
#import "DKModifierGroup.h"
#import "DKModifierGroupTags5E.h"
#import "DKAbilities5E.h"
#import "DKModifierBuilder.h"
#import "DKWeapon5E.h"
#import "DKSpellbook5E.h"
#import "DKCharacter5E.h"

@implementation DKWizard5E

@synthesize arcaneRecoveryUsesCurrent = _arcaneRecoveryUsesCurrent;
@synthesize arcaneRecoveryUsesMax = _arcaneRecoveryUsesMax;
@synthesize arcaneRecoverySpellSlots = _arcaneRecoverySpellSlots;
@synthesize spellMasterySpells = _spellMasterySpells;
@synthesize signatureSpellUsesCurrent = _signatureSpellUsesCurrent;
@synthesize signatureSpellUsesMax = _signatureSpellUsesMax;
@synthesize signatureSpells = _signatureSpells;

+ (DKModifierGroup*)wizardWithLevel:(DKNumericStatistic*)level
                          abilities:(DKAbilities5E*)abilities
                    signatureSpells:(DKSetStatistic*)signatureSpells {
    
    DKModifierGroup* class = [[DKModifierGroup alloc] init];
    [class addDependency:level forKey:@"level"];
    class.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:1];
    class.explanation = @"Wizard class modifiers";
    
    [class addModifier:[DKModifier stringModifierWithNewString:@"Wizard"] forStatisticID:DKStatIDClassName];
    [class addModifier:[DKClass5E hitDiceModifierForSides:6 level:level] forStatisticID:DKStatIDWizardHitDice];
    [class addSubgroup:[DKClass5E hitPointsMaxIncreasesForSides:6 level:level]];
    
    [class addModifier:[abilities.intelligence modifierFromAbilityScoreWithExplanation:@"Wizard spellcasting ability: Intelligence"]
        forStatisticID:DKStatIDSpellSaveDC];
    [class addModifier:[abilities.intelligence modifierFromAbilityScoreWithExplanation:@"Wizard spellcasting ability: Intelligence"]
        forStatisticID:DKStatIDSpellAttackBonus];
    [class addModifier:[abilities.intelligence modifierFromAbilityScoreWithExplanation:@"Wizard spellcasting ability: Intelligence"]
        forStatisticID:DKStatIDPreparedSpellsMax];
    
    DKModifier* preparedSpellsModifier = [DKModifier numericModifierAddedFromSource:level];
    preparedSpellsModifier.explanation = @"Wizard level";
    [class addModifier:preparedSpellsModifier forStatisticID:DKStatIDPreparedSpellsMax];
    
    DKModifier* minimumPreparedSpells = [DKModifier numericModifierWithMin:1];
    minimumPreparedSpells.explanation = @"Minimum of 1 prepared spell";
    [class addModifier:minimumPreparedSpells forStatisticID:DKStatIDPreparedSpellsMax];
    
    [class addModifier:[DKModifier setModifierWithAppendedObject:@"Ritual Casting" explanation:@"You can cast a wizard spell as a ritual if that spell has the ritual tag and you have the spell prepared"]
        forStatisticID:DKStatIDWizardTraits];
    [class addModifier:[DKModifier setModifierWithAppendedObject:@"Spellcasting Focus" explanation:@"You can use an arcane focus as a spellcasting focus for your wizard spells"]
        forStatisticID:DKStatIDWizardTraits];
    
    [class addModifier:[DKModifier numericModifierWithClampBetween:1 and:1 explanation:@"Wizard Saving Throw Proficiency: Wisdom"]
        forStatisticID:DKStatIDSavingThrowWisdomProficiency];
    [class addModifier:[DKModifier numericModifierWithClampBetween:1 and:1 explanation:@"Wizard Saving Throw Proficiency: Intelligence"]
        forStatisticID:DKStatIDSavingThrowIntelligenceProficiency];
    
    NSArray* weaponProficiencies = @[ @(kDKWeaponType5E_Dagger),
                                      @(kDKWeaponType5E_Dart),
                                      @(kDKWeaponType5E_Sling),
                                      @(kDKWeaponType5E_Quarterstaff),
                                      @(kDKWeaponType5E_LightCrossbow) ];
    for (NSNumber* weaponProficiency in weaponProficiencies) {
        [class addModifier:[DKModifier setModifierWithAppendedObject:[DKWeaponBuilder5E proficiencyNameForWeapon:weaponProficiency.integerValue]
                                                         explanation:@"Wizard Weapon Proficiencies"]
            forStatisticID:DKStatIDWeaponProficiencies];
    }
    
    NSArray* skillProficiencyStatIDs = @[ DKStatIDSkillArcanaProficiency,
                                          DKStatIDSkillHistoryProficiency,
                                          DKStatIDSkillInsightProficiency,
                                          DKStatIDSkillInvestigationProficiency,
                                          DKStatIDSkillMedicineProficiency,
                                          DKStatIDSkillReligionProficiency ];
    DKModifierGroup* skillProficiencyGroup = [DKClass5E skillProficienciesWithStatIDs:skillProficiencyStatIDs
                                                                       choiceGroupTag:DKChoiceWizardSkillProficiency];
    skillProficiencyGroup.explanation = @"Wizard Skill Proficiencies: Choose two from Arcana, History, Insight, Investigation, Medicine, and Religion";
    [class addSubgroup:skillProficiencyGroup];
    
    DKModifierGroup* cantripsGroup = [DKWizard5E cantripsWithLevel:level];
    [class addSubgroup:cantripsGroup];
    
    DKModifierGroup* spellbookGroup = [DKWizard5E spellbookWithWizardLevel:level];
    [class addSubgroup:spellbookGroup];
    
    DKModifierGroup* spellSlotsGroup = [DKWizard5E spellSlotsWithLevel:level];
    [class addSubgroup:spellSlotsGroup];
    
    DKModifierGroup* arcaneRecoveryGroup = [DKWizard5E arcaneRecoveryWithWizardLevel:level];
    [class addSubgroup:arcaneRecoveryGroup];
    
    DKModifierGroup* spellMasteryGroup = [DKWizard5E spellMasteryWithWizardLevel:level];
    [class addSubgroup:spellMasteryGroup];
    
    DKModifierGroup* signatureSpellsGroup = [DKWizard5E signatureSpellsWithWizardLevel:level
                                                                       signatureSpells:signatureSpells];
    [class addSubgroup:signatureSpellsGroup];
    
    DKModifierGroup* arcaneTraditionGroup = [DKWizard5E arcaneTraditionChoiceWithWizardLevel:level];
    [class addSubgroup:arcaneTraditionGroup];
    
    NSArray* abilityScoreImprovementLevels = @[ @4, @8, @12, @16, @19];
    for (NSNumber* abilityScoreLevel in abilityScoreImprovementLevels) {
        DKModifierGroup* abilityScoreGroup = [DKClass5E abilityScoreImprovementForThreshold:abilityScoreLevel.integerValue level:level];
        [class addSubgroup:abilityScoreGroup];
    }
    
    [class addModifier:[DKModifier numericModifierWithAdditiveBonus:100 explanation:@"Wizard starting gold"] forStatisticID:DKStatIDCurrencyGold];
    
    return class;
}

+ (DKModifierGroup*)cantripsWithLevel:(DKNumericStatistic*)level {
    
    DKModifierGroup* cantripsGroup = [[DKModifierGroup alloc] init];
    cantripsGroup.explanation = @"Wizard cantrips";
    
    for (int i = 0; i < 3; i++) {
        [cantripsGroup addSubgroup:[DKWizardSpellBuilder5E cantripChoiceWithLevel:level
                                                                        threshold:1
                                                                      explanation:@"First level Wizard cantrip"]];
    }
    
    [cantripsGroup addSubgroup:[DKWizardSpellBuilder5E cantripChoiceWithLevel:level
                                                                    threshold:4
                                                                  explanation:@"Fourth level Wizard cantrip"]];
    
    [cantripsGroup addSubgroup:[DKWizardSpellBuilder5E cantripChoiceWithLevel:level
                                                                    threshold:10
                                                                  explanation:@"Tenth level Wizard cantrip"]];
    
    return cantripsGroup;
}

+ (DKModifierGroup*)spellSlotsWithLevel:(DKNumericStatistic*)level {
    
    DKModifierGroup* spellSlotsGroup = [[DKModifierGroup alloc] init];
    spellSlotsGroup.explanation = @"Wizard spell slots";
    
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

+ (DKModifierGroup*)spellbookWithWizardLevel:(DKNumericStatistic*)level {
    
    DKModifierGroup* spellbookGroup = [[DKModifierGroup alloc] init];
    spellbookGroup.explanation = @"Wizard spellbook";
    
    DKModifierGroup* firstLevelSpells = [DKWizardSpellBuilder5E spellListForSpellLevel:1];
    for (int i = 0; i < 6; i++) {
        
        DKSingleChoiceModifierGroup* initialSpell = [[DKSingleChoiceModifierGroup alloc] initWithTag:DKChoiceWizardSpellbook];
        initialSpell.choicesSource = firstLevelSpells;
        initialSpell.explanation = @"Starting Wizard spell.";
        [spellbookGroup addSubgroup:initialSpell];
    }
    
    NSInteger spellLevel = 1;
    DKModifierGroup* spellList = [DKWizardSpellBuilder5E spellListUpToAndIncludingSpellLevel:1];
    for (NSInteger i = 2; i <= 20; i++) {
        NSInteger newSpellLevel = MIN(9, (i+1)/2);
        if (spellLevel != newSpellLevel) {
            //Caching the spell list so that we can use fewer objects; helps keep encoded object size down
            spellLevel = newSpellLevel;
            spellList = [DKWizardSpellBuilder5E spellListUpToAndIncludingSpellLevel:spellLevel];
        }
        
        for (NSInteger j = 0; j < 2; j++) {
            //Wizard gets two spell choices at each level
            DKSingleChoiceModifierGroup* spellChoice = [[DKSingleChoiceModifierGroup alloc] initWithTag:DKChoiceWizardSpellbook];
            [spellChoice addDependency:level forKey:@"level"];
            spellChoice.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:i];
            spellChoice.choicesSource = spellList;
            spellChoice.explanation = [NSString stringWithFormat:@"Spell learned at Wizard level %li.", (long)i];
            [spellbookGroup addSubgroup:spellChoice];
        }
    }
    
    return spellbookGroup;
}

+ (DKModifierGroup*)arcaneRecoveryWithWizardLevel:(DKNumericStatistic*)level {
    
    DKModifierGroup* arcaneRecoveryGroup = [[DKModifierGroup alloc] init];
    [arcaneRecoveryGroup addDependency:level forKey:@"level"];
    arcaneRecoveryGroup.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:1];
    arcaneRecoveryGroup.explanation = @"Arcane Recovery ability";
    
    NSString* arcaneRecoveryExplanation = @"Once per day when you finish a short rest, you can choose expended spell slots to recover. The spell slots cannot be 6th level or higher.  For example, if you’re a 4th-level wizard, you can recover up to two levels worth of spell slots. You can recover either a 2nd-level spell slot or two 1st-level spell slots.";
    DKModifier* arcaneRecoveryAbility = [DKModifier setModifierWithAppendedObject:@"Arcane Recovery"
                                                                      explanation:arcaneRecoveryExplanation];
    [arcaneRecoveryGroup addModifier:arcaneRecoveryAbility forStatisticID:DKStatIDWizardTraits];
    
    DKModifier* arcaneRecoveryUses = [DKModifier numericModifierWithAdditiveBonus:1];
    arcaneRecoveryUses.explanation = @"Once per day when you finish a short rest, you can choose expended spell slots to recover.";
    [arcaneRecoveryGroup addModifier:arcaneRecoveryUses forStatisticID:DKStatIDArcaneRecoveryUsesMax];
    
    NSExpression* divisionExpression = [NSExpression expressionForFunction:@"divide:by:" arguments:@[[NSExpression expressionForVariable:@"source"], [NSExpression expressionForConstantValue:@(2.0)]]];
    NSExpression* roundUpExpression = [NSExpression expressionForFunction:@"ceiling:" arguments:@[divisionExpression]];
    DKModifier* arcaneRecoverySlots = [[DKModifier alloc] initWithSource:level
                                                                   value:roundUpExpression
                                                                priority:kDKModifierPriority_Additive
                                                              expression:[DKExpressionBuilder additionExpression]];
    arcaneRecoverySlots.explanation = @"The spell slots can have a combined level that is equal to or less than half your wizard level (rounded up).";
    [arcaneRecoveryGroup addModifier:arcaneRecoverySlots forStatisticID:DKStatIDArcaneRecoverySpellSlots];
    
    return arcaneRecoveryGroup;
}

+ (DKModifierGroup*)spellMasteryWithWizardLevel:(DKNumericStatistic*)level {
    
    DKModifierGroup* spellMasteryGroup = [[DKModifierGroup alloc] init];
    [spellMasteryGroup addDependency:level forKey:@"level"];
    spellMasteryGroup.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:18];
    spellMasteryGroup.explanation = @"Spell Mastery ability";
    
    NSString* spellMasteryExplanation = @"Choose a 1st-level wizard spell and a 2nd-level wizard spell that are in your spellbook. You can cast those spells at their lowest level without expending a spell slot when you have them prepared. If you want to cast either spell at a higher level, you must expend a spell slot as normal.  By spending 8 hours in study, you can exchange one or both of the spells you chose for different spells of the same levels.";
    DKModifier* spellMasteryAbility = [DKModifier setModifierWithAppendedObject:@"Spell Mastery"
                                                                    explanation:spellMasteryExplanation];
    [spellMasteryGroup addModifier:spellMasteryAbility forStatisticID:DKStatIDWizardTraits];
    
    DKChoiceModifierGroup* firstLevelSpellChoice = [[DKSingleChoiceModifierGroup alloc] initWithTag:DKChoiceWizardSpellMastery];
    firstLevelSpellChoice.explanation = @"Choose a 1st-level wizard spell that is in your spellbook.";
    NSArray* firstLevelSpells = @[ @"Burning Hands",
                                   @"Charm Person",
                                   @"Comprehend Languages",
                                   @"Disguise Self",
                                   @"Identify",
                                   @"Mage Armor",
                                   @"Magic Missile",
                                   @"Shield",
                                   @"Silent Image",
                                   @"Sleep",
                                   @"Thunderwave" ];
    for (NSString* spellName in firstLevelSpells) {
        
        DKModifier* firstLevelSpell = [DKModifier setModifierWithAppendedObject:spellName
                                                                    explanation:@"Wizard Spell Mastery"];
        [firstLevelSpellChoice addModifier:firstLevelSpell forStatisticID:DKStatIDSpellMasterySpells];
    }
    
    [spellMasteryGroup addSubgroup:firstLevelSpellChoice];
    
    DKChoiceModifierGroup* secondLevelSpellChoice = [[DKSingleChoiceModifierGroup alloc] initWithTag:DKChoiceWizardSpellMastery];
    secondLevelSpellChoice.explanation = @"Choose a 2nd-level wizard spell that is in your spellbook.";
    NSArray* secondLevelSpells = @[ @"Arcane Lock",
                                    @"Blur",
                                    @"Darkness",
                                    @"Flaming Sphere",
                                    @"Hold Person",
                                    @"Invisibility",
                                    @"Knock",
                                    @"Levitate",
                                    @"Magic Weapon",
                                    @"Misty Step",
                                    @"Shatter",
                                    @"Spider Climb",
                                    @"Suggestion",
                                    @"Web" ];
    for (NSString* spellName in secondLevelSpells) {
        
        DKModifier* secondLevelSpell = [DKModifier setModifierWithAppendedObject:spellName
                                                                     explanation:@"Wizard Spell Mastery"];
        [secondLevelSpellChoice addModifier:secondLevelSpell forStatisticID:DKStatIDSpellMasterySpells];
    }
    [spellMasteryGroup addSubgroup:secondLevelSpellChoice];
    
    return spellMasteryGroup;
}

+ (DKModifierGroup*)signatureSpellsWithWizardLevel:(DKNumericStatistic*)level
                                   signatureSpells:(DKSetStatistic*)signatureSpells {
    
    DKModifierGroup* signatureSpellsGroup = [[DKModifierGroup alloc] init];
    [signatureSpellsGroup addDependency:level forKey:@"level"];
    signatureSpellsGroup.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:20];
    signatureSpellsGroup.explanation = @"Signature Spells ability";
    
    NSString* signatureSpellsExplanation = @"Choose two 3rd-level wizard spells in your spellbook as your signature spells. You always have these spells prepared, they don’t count against the number of spells you have prepared, and you can cast each of them once at 3rd level without expending a spell slot. When you do so, you can’t do so again until you finish a short or long rest.  If you want to cast either spell at a higher level, you must expend a spell slot as normal.";
    DKModifier* signatureSpellsAbility = [DKModifier setModifierWithAppendedObject:@"Signature Spells"
                                                                       explanation:signatureSpellsExplanation];
    [signatureSpellsGroup addModifier:signatureSpellsAbility forStatisticID:DKStatIDWizardTraits];
    
    DKSingleChoiceModifierGroup* thirdLevelSpellChoice = [[DKSingleChoiceModifierGroup alloc] initWithTag:DKChoiceWizardSignatureSpell];
    thirdLevelSpellChoice.explanation = @"Choose a 3rd-level wizard spell in your spellbook as one of your signature spells.";
    
    DKSingleChoiceModifierGroup* otherThirdLevelSpellChoice = [[DKSingleChoiceModifierGroup alloc] initWithTag:DKChoiceWizardSignatureSpell];
    otherThirdLevelSpellChoice.explanation = @"Choose a 3rd-level wizard spell in your spellbook as one of your signature spells.";
    
    NSArray* thirdLevelSpells = @[ @"Counterspell",
                                   @"Dispel Magic",
                                   @"Fireball",
                                   @"Fly",
                                   @"Haste",
                                   @"Lightning Bolt",
                                   @"Major Image",
                                   @"Protection from Energy" ];
    DKModifierGroup* thirdLevelSpellGroup = [[DKModifierGroup alloc] init];
    for (NSString* spellName in thirdLevelSpells) {
        
        DKModifier* thirdLevelSpell = [DKModifier setModifierWithAppendedObject:spellName
                                                                    explanation:@"Wizard Signature Spell"];
        [thirdLevelSpellGroup addModifier:thirdLevelSpell forStatisticID:DKStatIDSignatureSpells];
    }
    
    thirdLevelSpellChoice.choicesSource = thirdLevelSpellGroup;
    otherThirdLevelSpellChoice.choicesSource = thirdLevelSpellGroup;
    [signatureSpellsGroup addSubgroup:thirdLevelSpellChoice];
    [signatureSpellsGroup addSubgroup:otherThirdLevelSpellChoice];
    
    DKModifier* preparedSpellsBonus = [DKModifier numericModifierWithAdditiveBonus:2];
    preparedSpellsBonus.explanation = @"Signature spells don’t count against the number of spells you have prepared";;
    [signatureSpellsGroup addModifier:preparedSpellsBonus forStatisticID:DKStatIDPreparedSpellsMax];
    
    NSString* preparedSpellsExplanation = @"Wizard's Signature Spells are always prepared.";
    DKModifier* preparedSpellsModifier = [[DKModifier alloc] initWithSource:signatureSpells
                                                                      value:[DKExpressionBuilder valueFromDependency:@"source"]
                                                                   priority:kDKModifierPriority_Additive
                                                                 expression:[DKExpressionBuilder appendObjectsInSetExpression]];
    preparedSpellsModifier.explanation = preparedSpellsExplanation;
    [signatureSpellsGroup addModifier:preparedSpellsModifier forStatisticID:DKStatIDPreparedSpells];
    
    NSString* signatureSpellRecharge = @"Once you cast a signature spell using this feature, you can’t use it again without a spell slot "
    "until you finish a short or long rest.";
    DKModifier* signatureSpellUsesModifier = [DKModifier numericModifierWithAdditiveBonus:2
                                                                              explanation:signatureSpellRecharge];
    [signatureSpellsGroup addModifier:signatureSpellUsesModifier forStatisticID:DKStatIDSignatureSpellUsesMax];
    
    return signatureSpellsGroup;
}

#pragma mark -

+ (DKChoiceModifierGroup*)arcaneTraditionChoiceWithWizardLevel:(DKNumericStatistic*)level {
    
    DKSubgroupChoiceModifierGroup* arcaneTraditionGroup = [[DKSubgroupChoiceModifierGroup alloc] initWithTag:DKChoiceWizardArcaneTradition];
    arcaneTraditionGroup.explanation = @"Wizard arcane archetype";
    [arcaneTraditionGroup addDependency:level forKey:@"level"];
    arcaneTraditionGroup.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:2];
    
    [arcaneTraditionGroup addSubgroup:[DKWizard5E evocationArcaneTraditionWithLevel:level]];
    
    return arcaneTraditionGroup;
}

+ (DKModifierGroup*)evocationArcaneTraditionWithLevel:(DKNumericStatistic*)level {
    
    DKModifierGroup* evocationGroup = [[DKModifierGroup alloc] init];
    evocationGroup.explanation = @"Evocation Arcane Tradition";
    
    //Evocation Savant
    NSString* evocationSavantExplanation = @"No attack roll has advantage against you while you aren’t incapacitated.";
    DKModifier* evocationSavantModifier = [DKModifier setModifierAppendedFromSource:level
                                                                      constantValue:@"Evocation Savant"
                                                                            enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                             isGreaterThanOrEqualTo:2]
                                                                        explanation:evocationSavantExplanation];
    [evocationGroup addModifier:evocationSavantModifier forStatisticID:DKStatIDWizardTraits];
    
    //Sculpt Spells
    NSString* sculptSpellsExplanation = @"When you cast an evocation spell that affects other creatures that you can see, you can choose a number of them equal to 1 + the spell’s level. The chosen creatures automatically succeed on their saving throws against the spell, and they take no damage if they would normally take half damage on a successful save.";
    DKModifier* sculptSpellsModifier = [DKModifier setModifierAppendedFromSource:level
                                                                   constantValue:@"Sculpt Spells"
                                                                         enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                          isGreaterThanOrEqualTo:2]
                                                                     explanation:sculptSpellsExplanation];
    [evocationGroup addModifier:sculptSpellsModifier forStatisticID:DKStatIDWizardTraits];
    
    //Potent Cantrip
    NSString* potentCantripExplanation = @"When a creature succeeds on a saving throw against your cantrip, the creature takes half the cantrip’s damage (if any) but suffers no additional effect from the cantrip.";
    DKModifier* potentCantripModifier = [DKModifier setModifierAppendedFromSource:level
                                                                    constantValue:@"Potent Cantrip"
                                                                          enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                           isGreaterThanOrEqualTo:6]
                                                                      explanation:potentCantripExplanation];
    [evocationGroup addModifier:potentCantripModifier forStatisticID:DKStatIDWizardTraits];
    
    //Empowered Evocation
    NSString* empoweredEvocationExplanation = @"You can add your Intelligence modifier to one damage roll of any wizard evocation spell you cast.";
    DKModifier* empoweredEvocationModifier = [DKModifier setModifierAppendedFromSource:level
                                                                         constantValue:@"Empowered Evocation"
                                                                               enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                                isGreaterThanOrEqualTo:10]
                                                                           explanation:empoweredEvocationExplanation];
    [evocationGroup addModifier:empoweredEvocationModifier forStatisticID:DKStatIDWizardTraits];
    
    //Overchannel
    NSString* overchannelExplanation = @"When you cast a wizard spell of 1st through 5th level that deals damage, you can deal maximum damage with that spell.  The first time you do so, you suffer no adverse effect. If you use this feature again before you finish a long rest, you take 2d12 necrotic damage for each level of the spell, immediately after you cast it. Each time you use this feature again before finishing a long rest, the necrotic damage per spell level increases by 1d12. This damage ignores resistance and immunity.";
    DKModifier* overchannelModifier = [DKModifier setModifierAppendedFromSource:level
                                                                  constantValue:@"Overchannel"
                                                                        enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                         isGreaterThanOrEqualTo:14]
                                                                    explanation:overchannelExplanation];
    [evocationGroup addModifier:overchannelModifier forStatisticID:DKStatIDWizardTraits];
    
    return evocationGroup;
}

#pragma mark -

- (void)loadClassModifiersWithAbilities:(DKAbilities5E*)abilities {
    
    self.classModifiers = [DKWizard5E wizardWithLevel:self.classLevel
                                            abilities:abilities
                                      signatureSpells:_signatureSpells];
    
    DKModifier* hitDiceModifier = [DKModifier diceModifierAddedFromSource:self.classHitDice];
    hitDiceModifier.explanation = @"Wizard hit dice";
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
             DKStatIDWizardLevel: @"classLevel",
             DKStatIDWizardTraits: @"classTraits",
             DKStatIDWizardHitDice: @"classHitDice",
             DKStatIDArcaneRecoveryUsesCurrent: @"arcaneRecoveryUsesCurrent",
             DKStatIDArcaneRecoveryUsesMax: @"arcaneRecoveryUsesMax",
             DKStatIDArcaneRecoverySpellSlots: @"arcaneRecoverySpellSlots",
             DKStatIDSpellMasterySpells: @"spellMasterySpells",
             DKStatIDSignatureSpellUsesCurrent: @"signatureSpellUsesCurrent",
             DKStatIDSignatureSpellUsesMax: @"signatureSpellUsesMax",
             DKStatIDSignatureSpells: @"signatureSpells",
             };
}

- (void)loadStatistics {
    
    [super loadStatistics];
    self.arcaneRecoveryUsesCurrent = [DKNumericStatistic statisticWithInt:0];
    self.arcaneRecoveryUsesMax = [DKNumericStatistic statisticWithInt:0];
    self.arcaneRecoverySpellSlots = [DKNumericStatistic statisticWithInt:0];
    self.spellMasterySpells = [DKSetStatistic statisticWithEmptySet];
    self.signatureSpellUsesCurrent = [DKNumericStatistic statisticWithInt:0];
    self.signatureSpellUsesMax = [DKNumericStatistic statisticWithInt:0];
    self.signatureSpells = [DKSetStatistic statisticWithEmptySet];
}

- (void)loadModifiers {
    
    [super loadModifiers];
    [_arcaneRecoveryUsesCurrent applyModifier:[DKModifier numericModifierAddedFromSource:_arcaneRecoveryUsesMax]];
    [_signatureSpellUsesCurrent applyModifier:[DKModifier numericModifierAddedFromSource:_signatureSpellUsesMax]];
}

@end


@implementation DKWizardSpellBuilder5E

+ (DKChoiceModifierGroup*)cantripChoiceWithExplanation:(NSString*)explanation {
    
    return [DKWizardSpellBuilder5E cantripChoiceWithLevel:nil threshold:0 explanation:explanation];
}

+ (DKChoiceModifierGroup*)cantripChoiceWithLevel:(DKNumericStatistic*)level
                                       threshold:(NSInteger)threshold
                                     explanation:(NSString*)explanation {
    
    DKChoiceModifierGroup* cantripGroup = [[DKSingleChoiceModifierGroup alloc] initWithTag:DKChoiceWizardCantrip];
    if (level && threshold > 0) {
        [cantripGroup addDependency:level forKey:@"level"];
        cantripGroup.enabledPredicate = [DKPredicateBuilder enabledWhen:@"level" isGreaterThanOrEqualTo:threshold];
    }
    
    NSArray* spellNames = @[ @"Acid Splash",
                             @"Dancing Lights",
                             @"Fire Bolt",
                             @"Light",
                             @"Mage Hand",
                             @"Minor Illusion",
                             @"Poison Spray",
                             @"Prestidigitation",
                             @"Ray of Frost",
                             @"Shocking Grasp" ];
    for (NSString* spell in spellNames) {
        
        DKModifier* modifier = [DKModifier setModifierWithAppendedObject:spell
                                                             explanation:explanation];
        [cantripGroup addModifier:modifier forStatisticID:DKStatIDCantrips];
    }
    
    return cantripGroup;
}

+ (DKModifierGroup*)spellListUpToAndIncludingSpellLevel:(NSInteger)spellLevel {
    
    DKModifierGroup* spellGroup = [[DKModifierGroup alloc] init];
    for (int i = 1; i <= spellLevel; i++) {
        DKModifierGroup* spellList = [DKWizardSpellBuilder5E spellListForSpellLevel:i];
        [spellGroup addSubgroup:spellList];
    }
    
    return spellGroup;
}

+ (DKModifierGroup*)spellListForSpellLevel:(NSInteger)spellLevel {
    
    DKModifierGroup* spellGroup = [[DKModifierGroup alloc] init];
    spellGroup.explanation = [NSString stringWithFormat:@"Wizard level %li spells", (long)spellLevel];
    
    NSArray* spellNames = nil;
    switch (spellLevel) {
        case 1: {
            
            spellNames = @[ @"Burning Hands",
                            @"Charm Person",
                            @"Comprehend Languages",
                            @"Detect Magic",
                            @"Disguise Self",
                            @"Identify",
                            @"Mage Armor",
                            @"Magic Missile",
                            @"Shield",
                            @"Silent Image",
                            @"Sleep",
                            @"Thunderwave" ];
            break;
        }
            
        case 2: {
            spellNames = @[ @"Arcane Lock",
                            @"Blur",
                            @"Darkness",
                            @"Flaming Sphere",
                            @"Hold Person",
                            @"Invisibility",
                            @"Knock",
                            @"Levitate",
                            @"Magic Weapon",
                            @"Misty Step",
                            @"Shatter",
                            @"Spider Climb",
                            @"Suggestion",
                            @"Web" ];
            break;
        }
            
        case 3: {
            spellNames = @[ @"Counterspell",
                            @"Dispel Magic",
                            @"Fireball",
                            @"Fly",
                            @"Haste",
                            @"Lightning Bolt",
                            @"Major Image",
                            @"Protection from Energy" ];
            break;
        }
            
        case 4: {
            spellNames = @[ @"Arcane Eye",
                            @"Dimension Door",
                            @"Greater Invisibility",
                            @"Ice Storm",
                            @"Stoneskin",
                            @"Wall of Fire" ];
            break;
        }
            
        case 5: {
            spellNames = @[ @"Cone of Cold",
                            @"Dominate Person",
                            @"Dream",
                            @"Passwall",
                            @"Wall of Stone" ];
            break;
        }
            
        case 6: {
            spellNames = @[ @"Chain Lightning",
                            @"Disintegrate",
                            @"Globe of Invulnerability",
                            @"Mass Suggestion",
                            @"Otto’s Irresistible Dance",
                            @"True Seeing" ];
            break;
        }
            
        case 7: {
            spellNames = @[ @"Delayed Blast",
                            @"Fireball",
                            @"Finger of Death",
                            @"Mordenkainen’s Sword",
                            @"Teleport" ];
            break;
        }
            
        case 8: {
            spellNames = @[ @"Dominate Monster",
                            @"Maze",
                            @"Power Word Stun",
                            @"Sunburst" ];
            break;
        }
            
        case 9: {
            spellNames = @[ @"Foresight",
                            @"Imprisonment",
                            @"Meteor Swarm",
                            @"Power Word Kill",
                            @"Time Stop" ];
            break;
        }
            
        default:
            break;
    }
    
    for (NSString* spell in spellNames) {
        DKModifier* modifier = [DKModifier setModifierWithAppendedObject:spell
                                                             explanation:[NSString stringWithFormat:@"Wizard level %li spell", (long)spellLevel]];
        [spellGroup addModifier:modifier forStatisticID:[DKSpellbook5E statIDForSpellLevel:spellLevel]];
    }
    
    return spellGroup;
}

@end

