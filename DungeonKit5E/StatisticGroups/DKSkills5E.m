//
//  DKSkills5E.m
//  DungeonKit
//
//  Created by Christopher Dodge on 1/16/15.
//  Copyright (c) 2015 Dodge. All rights reserved.
//

#import "DKSkills5E.h"
#import "DKStatisticIDs5E.h"
#import "DKModifierBuilder.h"

@implementation DKSkills5E

@synthesize acrobatics = _acrobatics;
@synthesize animalHandling = _animalHandling;
@synthesize arcana = _arcana;
@synthesize athletics = _athletics;
@synthesize deception = _deception;
@synthesize history = _history;
@synthesize insight = _insight;
@synthesize intimidation = _intimidation;
@synthesize investigation = _investigation;
@synthesize medicine = _medicine;
@synthesize nature = _nature;
@synthesize perception = _perception;
@synthesize performance = _performance;
@synthesize persuasion = _persuasion;
@synthesize religion = _religion;
@synthesize sleightOfHand = _sleightOfHand;
@synthesize stealth = _stealth;
@synthesize survival = _survival;
@synthesize passivePerception = _passivePerception;

+ (NSArray*)skillProficiencyStatIDs {
    return @[ DKStatIDSkillAcrobaticsProficiency,
              DKStatIDSkillAnimalHandlingProficiency,
              DKStatIDSkillArcanaProficiency,
              DKStatIDSkillAthleticsProficiency,
              DKStatIDSkillDeceptionProficiency,
              DKStatIDSkillHistoryProficiency,
              DKStatIDSkillInsightProficiency,
              DKStatIDSkillIntimidationProficiency,
              DKStatIDSkillInvestigationProficiency,
              DKStatIDSkillMedicineProficiency,
              DKStatIDSkillNatureProficiency,
              DKStatIDSkillPerceptionProficiency,
              DKStatIDSkillPerformanceProficiency,
              DKStatIDSkillPersuasionProficiency,
              DKStatIDSkillReligionProficiency,
              DKStatIDSkillSleightOfHandProficiency,
              DKStatIDSkillStealthProficiency,
              DKStatIDSkillSurvivalProficiency ];
}

- (id)initWithAbilities:(DKAbilities5E*)abilities proficiencyBonus:(DKNumericStatistic*)proficiencyBonus {
    
    self = [super init];
    if (self) {
        
        if (!abilities || !proficiencyBonus) {
            NSLog(@"DKSkills5E: Expected non-nil abilities: %@ and proficiency bonus: %@", abilities, proficiencyBonus);
            return nil;
        }
        
        self.acrobatics = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
        self.animalHandling = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
        self.arcana = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
        self.athletics = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
        self.deception = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
        self.history = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
        self.insight = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
        self.intimidation = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
        self.investigation = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
        self.medicine = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
        self.nature = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
        self.perception = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
        self.performance = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
        self.persuasion = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
        self.religion = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
        self.sleightOfHand = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
        self.stealth = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
        self.survival = [DKProficientStatistic statisticWithBase:0 proficiencyBonus:proficiencyBonus];
        self.passivePerception = [DKNumericStatistic statisticWithInt:10];
        
        //Apply modifiers from the abilities block to the skills
        [_acrobatics applyModifier:[abilities.dexterity modifierFromAbilityScore]];
        [_animalHandling applyModifier:[abilities.wisdom modifierFromAbilityScore]];
        [_arcana applyModifier:[abilities.intelligence modifierFromAbilityScore]];
        [_athletics applyModifier:[abilities.strength modifierFromAbilityScore]];
        [_deception applyModifier:[abilities.charisma modifierFromAbilityScore]];
        [_history applyModifier:[abilities.intelligence modifierFromAbilityScore]];
        [_insight applyModifier:[abilities.wisdom modifierFromAbilityScore]];
        [_intimidation applyModifier:[abilities.charisma modifierFromAbilityScore]];
        [_investigation applyModifier:[abilities.intelligence modifierFromAbilityScore]];
        [_medicine applyModifier:[abilities.wisdom modifierFromAbilityScore]];
        [_nature applyModifier:[abilities.intelligence modifierFromAbilityScore]];
        [_perception applyModifier:[abilities.wisdom modifierFromAbilityScore]];
        [_performance applyModifier:[abilities.charisma modifierFromAbilityScore]];
        [_persuasion applyModifier:[abilities.charisma modifierFromAbilityScore]];
        [_religion applyModifier:[abilities.intelligence modifierFromAbilityScore]];
        [_sleightOfHand applyModifier:[abilities.dexterity modifierFromAbilityScore]];
        [_stealth applyModifier:[abilities.dexterity modifierFromAbilityScore]];
        [_survival applyModifier:[abilities.wisdom modifierFromAbilityScore]];
        [_passivePerception applyModifier:[DKModifier numericModifierAddedFromSource:_perception]];
    }
    return self;
}

- (NSDictionary*) statisticKeyPaths {
    return @{
             DKStatIDSkillAcrobatics: @"acrobatics",
             DKStatIDSkillAnimalHandling: @"animalHandling",
             DKStatIDSkillArcana: @"arcana",
             DKStatIDSkillAthletics: @"athletics",
             DKStatIDSkillDeception: @"deception",
             DKStatIDSkillHistory: @"history",
             DKStatIDSkillInsight: @"insight",
             DKStatIDSkillIntimidation: @"intimidation",
             DKStatIDSkillInvestigation: @"investigation",
             DKStatIDSkillMedicine: @"medicine",
             DKStatIDSkillNature: @"nature",
             DKStatIDSkillPerception: @"perception",
             DKStatIDSkillPerformance: @"performance",
             DKStatIDSkillPersuasion: @"persuasion",
             DKStatIDSkillReligion: @"religion",
             DKStatIDSkillSleightOfHand: @"sleightOfHand",
             DKStatIDSkillStealth: @"stealth",
             DKStatIDSkillSurvival: @"survival",
             DKStatIDSkillPassivePerception: @"passivePerception",
             
             DKStatIDSkillAcrobaticsProficiency: @"acrobatics.proficiencyLevel",
             DKStatIDSkillAnimalHandlingProficiency: @"animalHandling.proficiencyLevel",
             DKStatIDSkillArcanaProficiency: @"arcana.proficiencyLevel",
             DKStatIDSkillAthleticsProficiency: @"athletics.proficiencyLevel",
             DKStatIDSkillDeceptionProficiency: @"deception.proficiencyLevel",
             DKStatIDSkillHistoryProficiency: @"history.proficiencyLevel",
             DKStatIDSkillInsightProficiency: @"insight.proficiencyLevel",
             DKStatIDSkillIntimidationProficiency: @"intimidation.proficiencyLevel",
             DKStatIDSkillInvestigationProficiency: @"investigation.proficiencyLevel",
             DKStatIDSkillMedicineProficiency: @"medicine.proficiencyLevel",
             DKStatIDSkillNatureProficiency: @"nature.proficiencyLevel",
             DKStatIDSkillPerceptionProficiency: @"perception.proficiencyLevel",
             DKStatIDSkillPerformanceProficiency: @"performance.proficiencyLevel",
             DKStatIDSkillPersuasionProficiency: @"persuasion.proficiencyLevel",
             DKStatIDSkillReligionProficiency: @"religion.proficiencyLevel",
             DKStatIDSkillSleightOfHandProficiency: @"sleightOfHand.proficiencyLevel",
             DKStatIDSkillStealthProficiency: @"stealth.proficiencyLevel",
             DKStatIDSkillSurvivalProficiency: @"survival.proficiencyLevel",
             };
}

@end
