//
//  DKCharacter5E.m
//  DungeonKit
//
//  Created by Christopher Dodge on 1/3/15.
//  Copyright (c) 2015 Dodge. All rights reserved.
//

#import "DKCharacter5E.h"
#import "DKModifierBuilder.h"
#import "DKStatisticIDs5E.h"
#import "DKModifierGroupIDs5E.h"
#import "DKModifierGroupTags5E.h"
#import "DKStatisticGroupIDs5E.h"

@implementation DKCharacter5E

@synthesize name = _name;
@synthesize level = _level;
@synthesize experiencePoints = _experiencePoints;
@synthesize race = _race;
@synthesize subrace = _subrace;
@synthesize className = _className;
@synthesize size = _size;
@synthesize alignment = _alignment;
@synthesize inspiration = _inspiration;
@synthesize proficiencyBonus = _proficiencyBonus;
@synthesize hitPointsMax = _hitPointsMax;
@synthesize hitPointsTemporary = _hitPointsTemporary;
@synthesize hitPointsCurrent = _hitPointsCurrent;
@synthesize hitDiceMax = _hitDiceMax;
@synthesize hitDiceCurrent = _hitDiceCurrent;
@synthesize armorClass = _armorClass;
@synthesize initiativeBonus = _initiativeBonus;
@synthesize movementSpeed = _movementSpeed;
@synthesize darkvisionRange = _darkvisionRange;
@synthesize deathSaveSuccesses = _deathSaveSuccesses;
@synthesize deathSaveFailures = _deathSaveFailures;
@synthesize weaponProficiencies = _weaponProficiencies;
@synthesize armorProficiencies = _armorProficiencies;
@synthesize toolProficiencies = _toolProficiencies;
@synthesize languages = _languages;
@synthesize resistances = _resistances;
@synthesize immunities = _immunities;
@synthesize otherTraits = _otherTraits;

@synthesize classes = _classes;
@synthesize abilities = _abilities;
@synthesize savingThrows = _savingThrows;
@synthesize skills = _skills;
@synthesize spells = _spells;
@synthesize currency = _currency;
@synthesize equipment = _equipment;

#pragma mark -

- (void)chooseClass:(DKClassType5E)classType {
    
    DKChoiceModifierGroup* classChoice = (DKChoiceModifierGroup*)[self firstModifierGroupWithTag:DKChoiceClass];
    NSDictionary* typeToIndex = @{ @(kDKClassType5E_Cleric) : @0,
                                   @(kDKClassType5E_Fighter) : @1,
                                   @(kDKClassType5E_Rogue) : @2,
                                   @(kDKClassType5E_Wizard) : @3 };
    
    //Unload all the existing class modifiers
    for (NSNumber* type in typeToIndex.allKeys) {
        [self.classes classForClassType:type.integerValue].classModifiers = nil;
    }
    
    NSNumber* index = typeToIndex[@(classType)];
    if ([index integerValue] < classChoice.choices.count) {
        [classChoice choose:classChoice.choices[index.integerValue]];
        [[self.classes classForClassType:classType] loadClassModifiersForCharacter:self];
    } else {
        NSLog(@"DKCharacter5E: Attempted to choose invalid class type: %li", (long)classType);
        return;
    }
}

#pragma mark -
#pragma mark DKStatisticGroup5E override

- (NSDictionary*) statisticKeyPaths {
    return @{
             DKStatIDName: @"name",
             DKStatIDLevel: @"level",
             DKStatIDExperiencePoints: @"experiencePoints",
             DKStatIDRace: @"race",
             DKStatIDSubrace: @"subrace",
             DKStatIDClassName: @"className",
             DKStatIDInspiration: @"inspiration",
             DKStatIDProficiencyBonus: @"proficiencyBonus",
             DKStatIDSize: @"size",
             DKStatIDAlignment: @"alignment",
             
             DKStatIDHitPointsMax: @"hitPointsMax",
             DKStatIDHitPointsTemporary: @"hitPointsTemporary",
             DKStatIDHitPointsCurrent: @"hitPointsCurrent",
             
             DKStatIDHitDiceMax: @"hitDiceMax",
             DKStatIDHitDiceCurrent: @"hitDiceCurrent",
             
             DKStatIDArmorClass: @"armorClass",
             DKStatIDInitiative: @"initiativeBonus",
             DKStatIDMoveSpeed: @"movementSpeed",
             DKStatIDDarkvision: @"darkvisionRange",
             
             DKStatIDDeathSaveSuccesses: @"deathSaveSuccesses",
             DKStatIDDeathSaveFailures: @"deathSaveFailures",
             
             DKStatIDWeaponProficiencies: @"weaponProficiencies",
             DKStatIDArmorProficiencies: @"armorProficiencies",
             DKStatIDToolProficiencies: @"toolProficiencies",

             DKStatIDLanguages: @"languages",
             
             DKStatIDResistances: @"resistances",
             DKStatIDImmunities: @"immunities",
             
             DKStatIDOtherTraits: @"otherTraits",
             };
}

- (NSDictionary*) statisticGroupKeyPaths {
    return @{
             DKStatisticGroupIDAbilities: @"abilities",
             DKStatisticGroupIDClasses: @"classes",
             DKStatisticGroupIDCurrency: @"currency",
             DKStatisticGroupIDEquipment: @"equipment",
             DKStatisticGroupIDSavingThrows: @"savingThrows",
             DKStatisticGroupIDSkills: @"skills",
             DKStatisticGroupIDSpells: @"spells",
             };
}

- (NSDictionary*) modifierGroupKeyPaths {
    return @{
             DKModifierGroupIDClericClass: @"classes.cleric.classModifiers",
             DKModifierGroupIDFighterClass: @"classes.fighter.classModifiers",
             DKModifierGroupIDRogueClass: @"classes.rogue.classModifiers",
             DKModifierGroupIDWizardClass: @"classes.wizard.classModifiers",
             
             DKModifierGroupIDMainHandWeapon: @"equipment.mainHandWeapon",
             DKModifierGroupIDOffHandWeapon: @"equipment.offHandWeapon",
             DKModifierGroupIDArmor: @"equipment.armor",
             DKModifierGroupIDShield: @"equipment.shield",
             DKModifierGroupIDOtherEquipment: @"equipment.otherEquipment",
             };
}

- (void)loadStatistics {
    
    self.name = [DKStringStatistic statisticWithString:@""];
    self.level = [DKNumericStatistic statisticWithInt:0];
    self.experiencePoints = [DKNumericStatistic statisticWithInt:0];
    self.race = [DKStringStatistic statisticWithString:@""];
    self.subrace = [DKStringStatistic statisticWithString:@""];
    self.className = [DKStringStatistic statisticWithString:@""];
    self.size = [DKStringStatistic statisticWithString:@""];
    self.alignment = [DKStringStatistic statisticWithString:@""];
    
    self.inspiration = [DKNumericStatistic statisticWithInt:0];
    self.proficiencyBonus = [DKNumericStatistic statisticWithInt:2];
    
    self.hitPointsMax = [DKNumericStatistic statisticWithInt:0];
    self.hitPointsTemporary = [DKNumericStatistic statisticWithInt:0];
    self.hitPointsCurrent = [DKNumericStatistic statisticWithInt:0];
    self.hitDiceMax = [DKDiceStatistic statisticWithNoDice];
    self.hitDiceCurrent = [DKDiceStatistic statisticWithNoDice];
    
    self.armorClass = [DKNumericStatistic statisticWithInt:10];
    self.initiativeBonus = [DKNumericStatistic statisticWithInt:0];
    
    self.movementSpeed = [DKNumericStatistic statisticWithInt:0];
    self.darkvisionRange = [DKNumericStatistic statisticWithInt:0];
    
    self.weaponProficiencies = [DKSetStatistic statisticWithEmptySet];
    self.armorProficiencies = [DKSetStatistic statisticWithEmptySet];
    self.toolProficiencies = [DKSetStatistic statisticWithEmptySet];
    
    self.languages = [DKSetStatistic statisticWithEmptySet];
    self.resistances = [DKSetStatistic statisticWithEmptySet];
    self.immunities = [DKSetStatistic statisticWithEmptySet];
    
    self.otherTraits = [DKSetStatistic statisticWithEmptySet];
    
    self.deathSaveSuccesses = [DKNumericStatistic statisticWithInt:0];
    self.deathSaveFailures = [DKNumericStatistic statisticWithInt:0];
}

- (void)loadStatisticGroups {
    
    //Initialize ability score block and saving throws
    self.abilities = [[DKAbilities5E alloc] initWithStr:10 dex:10 con:10 intel:10 wis:10 cha:10];
    self.savingThrows = [[DKSavingThrows5E alloc] initWithAbilities:_abilities proficiencyBonus:_proficiencyBonus];
    self.skills = [[DKSkills5E alloc] initWithAbilities:_abilities proficiencyBonus:_proficiencyBonus];
    self.spells = [[DKSpellcasting5E alloc] initWithProficiencyBonus:_proficiencyBonus];
    self.currency = [[DKCurrency5E alloc] init];
    
    self.equipment = [[DKEquipment5E alloc] initWithAbilities:_abilities
                                             proficiencyBonus:_proficiencyBonus
                                                characterSize:_size
                                          weaponProficiencies:_weaponProficiencies
                                           armorProficiencies:_armorProficiencies];
    
    self.classes = [[DKClasses5E alloc] init];
}

- (void)loadModifiers {
    
    //Inspiration is binary
    [_inspiration applyModifier:[DKModifier numericModifierWithClampBetween:0 and:1]];
    
    //Set up proficiency bonus to increase based on the level automatically
    DKModifier* levelModifier = [[DKModifier alloc] initWithSource:_level
                                                             value:[NSExpression expressionWithFormat:
                                                                    @"max:({ 0, ($source - 1) / 4 })"]
                                                          priority:kDKModifierPriority_Additive
                                                        expression:[DKExpressionBuilder additionExpression]];
    [_proficiencyBonus applyModifier:levelModifier];
    
    //Link maximum and current HP so that current HP value will update when max HP value changes
    [_hitPointsCurrent applyModifier:[DKModifier numericModifierAddedFromSource:_hitPointsMax]];
    [_hitPointsCurrent applyModifier:[DKModifier numericModifierAddedFromSource:_hitPointsTemporary]];
    
    [_initiativeBonus applyModifier:[_abilities.dexterity modifierFromAbilityScore]];
    
    [_deathSaveSuccesses applyModifier:[DKModifier numericModifierWithClampBetween:0 and:3]];
    [_deathSaveFailures applyModifier:[DKModifier numericModifierWithClampBetween:0 and:3]];
    
    [self addModifierGroup:[DKRace5EBuilder raceChoiceForCharacter:self] forGroupID:DKChoiceRace];
    
    DKModifierGroup* experiencePointsGroup = [[DKModifierGroup alloc] init];
    NSDictionary* experienceTable = @{
                                      @1: [NSValue valueWithRange:NSMakeRange(0, 300)],
                                      @2: [NSValue valueWithRange:NSMakeRange(300, 600)],
                                      @3: [NSValue valueWithRange:NSMakeRange(900, 1800)],
                                      @4: [NSValue valueWithRange:NSMakeRange(2700, 3800)],
                                      @5: [NSValue valueWithRange:NSMakeRange(6500, 7500)],
                                      @6: [NSValue valueWithRange:NSMakeRange(14000, 9000)],
                                      @7: [NSValue valueWithRange:NSMakeRange(23000, 11000)],
                                      @8: [NSValue valueWithRange:NSMakeRange(34000, 14000)],
                                      @9: [NSValue valueWithRange:NSMakeRange(48000, 16000)],
                                      @10: [NSValue valueWithRange:NSMakeRange(64000, 21000)],
                                      @11: [NSValue valueWithRange:NSMakeRange(85000, 15000)],
                                      @12: [NSValue valueWithRange:NSMakeRange(100000, 20000)],
                                      @13: [NSValue valueWithRange:NSMakeRange(120000, 20000)],
                                      @14: [NSValue valueWithRange:NSMakeRange(140000, 25000)],
                                      @15: [NSValue valueWithRange:NSMakeRange(165000, 30000)],
                                      @16: [NSValue valueWithRange:NSMakeRange(195000, 30000)],
                                      @17: [NSValue valueWithRange:NSMakeRange(225000, 40000)],
                                      @18: [NSValue valueWithRange:NSMakeRange(265000, 40000)],
                                      @19: [NSValue valueWithRange:NSMakeRange(305000, 50000)],
                                      @20: [NSValue valueWithRange:NSMakeRange(355000, NSIntegerMax)],
                                      };
    for (NSNumber* level in experienceTable.allKeys) {
        NSRange expRange = [experienceTable[level] rangeValue];
        DKModifier* levelModifier = [DKModifier numericModifierAddedFromSource:_experiencePoints
                                                                 constantValue:level
                                                                       enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                            isEqualToOrBetween:expRange.location
                                                                                                           and:NSMaxRange(expRange)-1]];
        [experiencePointsGroup addModifier:levelModifier forStatisticID:DKStatIDLevel];
    }
    [self addModifierGroup:experiencePointsGroup forGroupID:DKModifierGroupIDExperiencePoints];
    
    DKSingleChoiceModifierGroup* classChoice = [[DKSingleChoiceModifierGroup alloc] initWithTag:DKChoiceClass];
    [classChoice addModifier:[DKModifier numericModifierAddedFromSource:_level] forStatisticID:DKStatIDClericLevel];
    [classChoice addModifier:[DKModifier numericModifierAddedFromSource:_level] forStatisticID:DKStatIDFighterLevel];
    [classChoice addModifier:[DKModifier numericModifierAddedFromSource:_level] forStatisticID:DKStatIDRogueLevel];
    [classChoice addModifier:[DKModifier numericModifierAddedFromSource:_level] forStatisticID:DKStatIDWizardLevel];
    [self addModifierGroup:classChoice forGroupID:DKChoiceClass];
    
    NSExpression* hpExpression = [NSExpression expressionForFunction:@"multiply:by:"
                                                           arguments:@[[DKAbilityScore abilityScoreValueForDependency:@"constitution"],
                                                                       [NSExpression expressionForVariable:@"level"]]];
    DKModifier* hpMaxModifier = [[DKModifier alloc] initWithDependencies:@{ @"constitution" : _abilities.constitution,
                                                                            @"level" : _level }
                                                                   value:hpExpression
                                                                 enabled:nil
                                                                priority:kDKModifierPriority_Additive
                                                              expression:[DKExpressionBuilder additionExpression]];
    hpMaxModifier.explanation = @"Max HP bonus from Constitution.";
    [self applyModifier:hpMaxModifier toStatisticWithID:DKStatIDHitPointsMax];
    
    DKSingleChoiceModifierGroup* alignmentChoice = [[DKSingleChoiceModifierGroup alloc] initWithTag:DKChoiceAlignment];
    [alignmentChoice addModifier:[DKModifier stringModifierWithNewString:@"Lawful Good"] forStatisticID:DKStatIDAlignment];
    [alignmentChoice addModifier:[DKModifier stringModifierWithNewString:@"Neutral Good"] forStatisticID:DKStatIDAlignment];
    [alignmentChoice addModifier:[DKModifier stringModifierWithNewString:@"Chaotic Good"] forStatisticID:DKStatIDAlignment];
    [alignmentChoice addModifier:[DKModifier stringModifierWithNewString:@"Lawful Neutral"] forStatisticID:DKStatIDAlignment];
    [alignmentChoice addModifier:[DKModifier stringModifierWithNewString:@"True Neutral"] forStatisticID:DKStatIDAlignment];
    [alignmentChoice addModifier:[DKModifier stringModifierWithNewString:@"Chaotic Neutral"] forStatisticID:DKStatIDAlignment];
    [alignmentChoice addModifier:[DKModifier stringModifierWithNewString:@"Lawful Evil"] forStatisticID:DKStatIDAlignment];
    [alignmentChoice addModifier:[DKModifier stringModifierWithNewString:@"Neutral Evil"] forStatisticID:DKStatIDAlignment];
    [alignmentChoice addModifier:[DKModifier stringModifierWithNewString:@"Chaotic Evil"] forStatisticID:DKStatIDAlignment];
    [self addModifierGroup:alignmentChoice forGroupID:DKChoiceAlignment];
}

@end
