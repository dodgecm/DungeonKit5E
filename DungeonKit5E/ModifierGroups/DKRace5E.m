//
//  DKRace5E.m
//  DungeonKit
//
//  Created by Christopher Dodge on 1/26/15.
//  Copyright (c) 2015 Dodge. All rights reserved.
//

#import "DKRace5E.h"
#import "DKStatisticIDs5E.h"
#import "DKModifierGroupTags5E.h"
#import "DKCharacter5E.h"
#import "DKWeapon5E.h"
#import "DKLanguage5E.h"
#import "DKModifierBuilder.h"
#import "DKWizard5E.h"

@implementation DKRace5EBuilder

+ (DKSubgroupChoiceModifierGroup*)raceChoiceForCharacter:(DKCharacter5E*)character {
    
    DKSubgroupChoiceModifierGroup* raceChoiceGroup = [[DKSubgroupChoiceModifierGroup alloc] initWithTag:DKChoiceRace];
    [raceChoiceGroup addSubgroup:[DKRace5EBuilder dwarfWithCharacter:character]];
    [raceChoiceGroup addSubgroup:[DKRace5EBuilder elf]];
    [raceChoiceGroup addSubgroup:[DKRace5EBuilder halfling]];
    [raceChoiceGroup addSubgroup:[DKRace5EBuilder human]];
    return raceChoiceGroup;
}

+ (DKRace5E*)dwarfWithCharacter:(DKCharacter5E*)character {
    
    DKRace5E* race = [[DKRace5E alloc] init];
    race.explanation = @"Dwarven racial modifiers";
    [race addModifier:[DKModifier numericModifierWithAdditiveBonus:2 explanation:@"Dwarven racial trait"]
       forStatisticID:DKStatIDConstitution];
    [race addModifier:[DKModifier stringModifierWithNewString:@"Dwarf"] forStatisticID:DKStatIDRace];
    [race addModifier:[DKModifier stringModifierWithNewString:@"Medium"] forStatisticID:DKStatIDSize];
    [race addModifier:[DKModifier numericModifierWithAdditiveBonus:25 explanation:@"Dwarven base movement speed"]
       forStatisticID:DKStatIDMoveSpeed];
    [race addModifier:[DKModifier setModifierWithAppendedObject:@"Dwarven Heavy Armor Proficiency"
                                                        explanation:@"Movement speed is not reduced by wearing heavy armor"]
       forStatisticID:DKStatIDArmorProficiencies];
    [race addModifier:[DKModifier numericModifierWithAdditiveBonus:60 explanation:@"Dwarven darkvision range"]
       forStatisticID:DKStatIDDarkvision];
    [race addModifier:[DKModifier setModifierWithAppendedObject:@"Poison" explanation:@"Dwarven Resilience: Resistance against poison damage"]
       forStatisticID:DKStatIDResistances];
    [race addModifier:[DKModifier modifierWithExplanation:@"Dwarven Resilience: Advantage on saving throws against poison"]
       forStatisticID:DKStatIDSavingThrowOther];
    [race addModifier:[DKModifier setModifierWithAppendedObject:[DKWeaponBuilder5E proficiencyNameForWeapon:kDKWeaponType5E_Battleaxe]
                                                        explanation:@"Dwarven Combat Training"] forStatisticID:DKStatIDWeaponProficiencies];
    [race addModifier:[DKModifier setModifierWithAppendedObject:[DKWeaponBuilder5E proficiencyNameForWeapon:kDKWeaponType5E_Handaxe]
                                                        explanation:@"Dwarven Combat Training"] forStatisticID:DKStatIDWeaponProficiencies];
    [race addModifier:[DKModifier setModifierWithAppendedObject:[DKWeaponBuilder5E proficiencyNameForWeapon:kDKWeaponType5E_LightHammer]
                                                        explanation:@"Dwarven Combat Training"] forStatisticID:DKStatIDWeaponProficiencies];
    [race addModifier:[DKModifier setModifierWithAppendedObject:[DKWeaponBuilder5E proficiencyNameForWeapon:kDKWeaponType5E_Warhammer]
                                                        explanation:@"Dwarven Combat Training"] forStatisticID:DKStatIDWeaponProficiencies];
    
    DKChoiceModifierGroup* toolSubgroup = [[DKSingleChoiceModifierGroup alloc] initWithTag:DKChoiceDwarfToolProficiency];
    toolSubgroup.explanation = @"Dwarven Tool Proficiency: Proficiency with one of the following: smith's tools, brewer's supplies, or mason's tools";
    [toolSubgroup addModifier:[DKModifier setModifierWithAppendedObject:@"Smith's Tools" explanation:@"Dwarven Tool Proficiency"]
               forStatisticID:DKStatIDToolProficiencies];
    [toolSubgroup addModifier:[DKModifier setModifierWithAppendedObject:@"Brewer's Supplies" explanation:@"Dwarven Tool Proficiency"]
               forStatisticID:DKStatIDToolProficiencies];
    [toolSubgroup addModifier:[DKModifier setModifierWithAppendedObject:@"Mason's Tools" explanation:@"Dwarven Tool Proficiency"]
               forStatisticID:DKStatIDToolProficiencies];
    [race addSubgroup:toolSubgroup];
    
    [race addModifier:[DKModifier modifierWithExplanation:@"Dwarven Stonecunning: When making a History check related to the origin of stonework, "
                       "you are considered proficient in the History skill and add double your proficiency bonus to the check, instead of your normal proficiency bonus"]
       forStatisticID:DKStatIDSkillHistory];
    [race addModifier:[DKModifier setModifierWithAppendedObject:@"Common" explanation:@"Dwarven Languages"]
       forStatisticID:DKStatIDLanguages];
    [race addModifier:[DKModifier setModifierWithAppendedObject:@"Dwarvish" explanation:@"Dwarven Languages"]
       forStatisticID:DKStatIDLanguages];
    
    DKSubgroupChoiceModifierGroup* subraceChoice = [[DKSubgroupChoiceModifierGroup alloc] initWithTag:DKChoiceSubrace];
    [subraceChoice addSubgroup:[DKSubrace5EBuilder hillDwarfFromCharacter:character]];
    [subraceChoice addSubgroup:[DKSubrace5EBuilder mountainDwarf]];
    [race addSubgroup:subraceChoice];
    
    return race;
}

+ (DKRace5E*)elf {
    
    DKRace5E* race = [[DKRace5E alloc] init];
    race.explanation = @"Elven racial modifiers";
    [race addModifier:[DKModifier numericModifierWithAdditiveBonus:2 explanation:@"Elven racial dexterity bonus"]
       forStatisticID:DKStatIDDexterity];
    [race addModifier:[DKModifier stringModifierWithNewString:@"Elf"] forStatisticID:DKStatIDRace];
    [race addModifier:[DKModifier stringModifierWithNewString:@"Medium"] forStatisticID:DKStatIDSize];
    [race addModifier:[DKModifier numericModifierWithClampBetween:1 and:1 explanation:@"Elven Keen Senses: Proficiency in the Perception skill"]
       forStatisticID:DKStatIDSkillPerceptionProficiency];
    [race addModifier:[DKModifier numericModifierWithAdditiveBonus:30 explanation:@"Elven base movement speed"]
       forStatisticID:DKStatIDMoveSpeed];
    [race addModifier:[DKModifier numericModifierWithAdditiveBonus:60 explanation:@"Elven darkvision range"]
       forStatisticID:DKStatIDDarkvision];
    [race addModifier:[DKModifier setModifierWithAppendedObject:@"Sleep" explanation:@"Elven Fey Ancestry: Immune to magical sleep effects"]
       forStatisticID:DKStatIDImmunities];
    [race addModifier:[DKModifier modifierWithExplanation:@"Elven Fey Ancestry: Advantage on saving throws against being charmed"]
       forStatisticID:DKStatIDSavingThrowOther];
    [race addModifier:[DKModifier setModifierWithAppendedObject:@"Elven Trance" explanation:@"Meditate deeply for 4 hours to gain the same benefit as 8 hours of human sleep"]
       forStatisticID:DKStatIDOtherTraits];
    [race addModifier:[DKModifier setModifierWithAppendedObject:@"Common" explanation:@"Elven Languages"]
       forStatisticID:DKStatIDLanguages];
    [race addModifier:[DKModifier setModifierWithAppendedObject:@"Elvish" explanation:@"Elven Languages"]
       forStatisticID:DKStatIDLanguages];
    
    DKSubgroupChoiceModifierGroup* subraceChoice = [[DKSubgroupChoiceModifierGroup alloc] initWithTag:DKChoiceSubrace];
    [subraceChoice addSubgroup:[DKSubrace5EBuilder highElf]];
    [subraceChoice addSubgroup:[DKSubrace5EBuilder woodElf]];
    [race addSubgroup:subraceChoice];
    
    return race;
}

+ (DKRace5E*)halfling {
    
    DKRace5E* race = [[DKRace5E alloc] init];
    race.explanation = @"Halfling racial modifiers";
    [race addModifier:[DKModifier numericModifierWithAdditiveBonus:2 explanation:@"Halfling racial dexterity bonus"]
       forStatisticID:DKStatIDDexterity];
    [race addModifier:[DKModifier stringModifierWithNewString:@"Halfling"] forStatisticID:DKStatIDRace];
    [race addModifier:[DKModifier stringModifierWithNewString:@"Small"] forStatisticID:DKStatIDSize];
    [race addModifier:[DKModifier numericModifierWithAdditiveBonus:25 explanation:@"Halfling base movement speed"]
       forStatisticID:DKStatIDMoveSpeed];
    [race addModifier:[DKModifier setModifierWithAppendedObject:@"Lucky" explanation:@"On a roll of 1 on an attack roll, ability check, or saving throw, reroll the die and use the new roll"]
       forStatisticID:DKStatIDOtherTraits];
    [race addModifier:[DKModifier setModifierWithAppendedObject:@"Halfling Nimbleness" explanation:@"Able to move through the space of any creature that is of a size larger than yours"]
       forStatisticID:DKStatIDOtherTraits];
    [race addModifier:[DKModifier modifierWithExplanation:@"Halfling Bravery: Advantage on saving throws against being frightened"]
       forStatisticID:DKStatIDSavingThrowOther];
    [race addModifier:[DKModifier setModifierWithAppendedObject:@"Common" explanation:@"Halfling Languages"]
       forStatisticID:DKStatIDLanguages];
    [race addModifier:[DKModifier setModifierWithAppendedObject:@"Halfling" explanation:@"Halfling Languages"]
       forStatisticID:DKStatIDLanguages];
    
    DKSubgroupChoiceModifierGroup* subraceChoice = [[DKSubgroupChoiceModifierGroup alloc] initWithTag:DKChoiceSubrace];
    [subraceChoice addSubgroup:[DKSubrace5EBuilder lightfootHalfling]];
    [subraceChoice addSubgroup:[DKSubrace5EBuilder stoutHalfling]];
    [race addSubgroup:subraceChoice];
     
    return race;
}

+ (DKRace5E*)human {
    
    DKRace5E* race = [[DKRace5E alloc] init];
    race.explanation = @"Human racial modifiers";
    [race addModifier:[DKModifier numericModifierWithAdditiveBonus:1 explanation:@"Human racial strength bonus"]
       forStatisticID:DKStatIDStrength];
    [race addModifier:[DKModifier numericModifierWithAdditiveBonus:1 explanation:@"Human racial dexterity bonus"]
       forStatisticID:DKStatIDDexterity];
    [race addModifier:[DKModifier numericModifierWithAdditiveBonus:1 explanation:@"Human racial constitution bonus"]
       forStatisticID:DKStatIDConstitution];
    [race addModifier:[DKModifier numericModifierWithAdditiveBonus:1 explanation:@"Human racial intelligence bonus"]
       forStatisticID:DKStatIDIntelligence];
    [race addModifier:[DKModifier numericModifierWithAdditiveBonus:1 explanation:@"Human racial wisdom bonus"]
       forStatisticID:DKStatIDWisdom];
    [race addModifier:[DKModifier numericModifierWithAdditiveBonus:1 explanation:@"Human racial charisma bonus"]
       forStatisticID:DKStatIDCharisma];
    [race addModifier:[DKModifier stringModifierWithNewString:@"Human"] forStatisticID:DKStatIDRace];
    [race addModifier:[DKModifier stringModifierWithNewString:@"Medium"] forStatisticID:DKStatIDSize];
    [race addModifier:[DKModifier numericModifierWithAdditiveBonus:30  explanation:@"Human base movement speed"]
       forStatisticID:DKStatIDMoveSpeed];
    [race addModifier:[DKModifier setModifierWithAppendedObject:@"Common" explanation:@"Human Languages"]
       forStatisticID:DKStatIDLanguages];
    
    DKChoiceModifierGroup* languageSubgroup = [DKLanguageBuilder5E languageChoiceWithExplanation:@"Human bonus language"];
    languageSubgroup.tag = DKChoiceHumanBonusLanguage;
    languageSubgroup.explanation = @"Human Language Proficiency: Knowledge of one chosen language";
    [race addSubgroup:languageSubgroup];
    
    return race;
}

@end


@implementation DKSubrace5EBuilder

+ (DKSubrace5E*)hillDwarfFromCharacter:(DKCharacter5E*)character {
    
    DKSubrace5E* subrace = [[DKSubrace5E alloc] init];
    subrace.explanation = @"Hill Dwarf racial modifiers";
    [subrace addModifier:[DKModifier stringModifierWithNewString:@"Hill Dwarf"] forStatisticID:DKStatIDSubrace];
    [subrace addModifier:[DKModifier numericModifierWithAdditiveBonus:1 explanation:@"Hill Dwarf racial wisdom bonus"] forStatisticID:DKStatIDWisdom];
    
    DKModifier* hpModifier = [DKModifier numericModifierAddedFromSource:character.level];
    hpModifier.explanation = @"Hill Dwarf racial hit point bonus";
    [subrace addModifier:hpModifier forStatisticID:DKStatIDHitPointsMax];
    
    return subrace;
}

+ (DKSubrace5E*)mountainDwarf {
    
    DKSubrace5E* subrace = [[DKSubrace5E alloc] init];
    subrace.explanation = @"Mountain Dwarf racial modifiers";
    [subrace addModifier:[DKModifier stringModifierWithNewString:@"Mountain Dwarf"] forStatisticID:DKStatIDSubrace];
    [subrace addModifier:[DKModifier numericModifierWithAdditiveBonus:2 explanation:@"Mountain Dwarf racial strength bonus"]
          forStatisticID:DKStatIDStrength];
    [subrace addModifier:[DKModifier setModifierWithAppendedObject:[DKArmorBuilder5E proficiencyNameForArmorCategory:kDKArmorCategory5E_Light]
                                                           explanation:@"Mountain Dwarf Armor Training"]
                   forStatisticID:DKStatIDArmorProficiencies];
    [subrace addModifier:[DKModifier setModifierWithAppendedObject:[DKArmorBuilder5E proficiencyNameForArmorCategory:kDKArmorCategory5E_Medium]
                                                           explanation:@"Mountain Dwarf Armor Training"]
          forStatisticID:DKStatIDArmorProficiencies];
    return subrace;
}

+ (DKSubrace5E*)highElf {
    
    DKSubrace5E* subrace = [[DKSubrace5E alloc] init];
    subrace.explanation = @"High Elf racial modifiers";
    [subrace addModifier:[DKModifier stringModifierWithNewString:@"High Elf"] forStatisticID:DKStatIDSubrace];
    [subrace addModifier:[DKModifier numericModifierWithAdditiveBonus:1 explanation:@"High Elf racial intelligence bonus"]
          forStatisticID:DKStatIDIntelligence];
    [subrace addModifier:[DKModifier setModifierWithAppendedObject:[DKWeaponBuilder5E proficiencyNameForWeapon:kDKWeaponType5E_Longsword]
                                                           explanation:@"High Elf Weapon Training"] forStatisticID:DKStatIDWeaponProficiencies];
    [subrace addModifier:[DKModifier setModifierWithAppendedObject:[DKWeaponBuilder5E proficiencyNameForWeapon:kDKWeaponType5E_Shortsword]
                                                           explanation:@"High Elf Weapon Training"] forStatisticID:DKStatIDWeaponProficiencies];
    [subrace addModifier:[DKModifier setModifierWithAppendedObject:[DKWeaponBuilder5E proficiencyNameForWeapon:kDKWeaponType5E_Shortbow]
                                                           explanation:@"High Elf Weapon Training"] forStatisticID:DKStatIDWeaponProficiencies];
    [subrace addModifier:[DKModifier setModifierWithAppendedObject:[DKWeaponBuilder5E proficiencyNameForWeapon:kDKWeaponType5E_Longbow]
                                                           explanation:@"High Elf Weapon Training"] forStatisticID:DKStatIDWeaponProficiencies];
    
    DKChoiceModifierGroup* cantripSubgroup = [DKWizardSpellBuilder5E cantripChoiceWithExplanation:@"High Elf bonus cantrip"];
    cantripSubgroup.tag = DKChoiceHighElfCantrip;
    cantripSubgroup.explanation = @"You know one cantrip of your choice from the wizard spell list.  Intelligence is your spellcasting ability for it.";
    [subrace addSubgroup:cantripSubgroup];
    
    DKChoiceModifierGroup* languageSubgroup = [DKLanguageBuilder5E languageChoiceWithExplanation:@"High Elf bonus language"];
    languageSubgroup.tag = DKChoiceHighElfBonusLanguage;
    languageSubgroup.explanation = @"High Elf Language Proficiency: Knowledge of one chosen language";
    [subrace addSubgroup:languageSubgroup];

    return subrace;
}

+ (DKSubrace5E*)woodElf {
    
    DKSubrace5E* subrace = [[DKSubrace5E alloc] init];
    subrace.explanation = @"Wood Elf racial modifiers";
    [subrace addModifier:[DKModifier stringModifierWithNewString:@"Wood Elf"] forStatisticID:DKStatIDSubrace];
    [subrace addModifier:[DKModifier numericModifierWithAdditiveBonus:1 explanation:@"Wood Elf racial wisdom bonus"] forStatisticID:DKStatIDWisdom];
    [subrace addModifier:[DKModifier setModifierWithAppendedObject:[DKWeaponBuilder5E proficiencyNameForWeapon:kDKWeaponType5E_Longsword]
                                                           explanation:@"Wood Elf Weapon Training"] forStatisticID:DKStatIDWeaponProficiencies];
    [subrace addModifier:[DKModifier setModifierWithAppendedObject:[DKWeaponBuilder5E proficiencyNameForWeapon:kDKWeaponType5E_Shortsword]
                                                           explanation:@"Wood Elf Weapon Training"] forStatisticID:DKStatIDWeaponProficiencies];
    [subrace addModifier:[DKModifier setModifierWithAppendedObject:[DKWeaponBuilder5E proficiencyNameForWeapon:kDKWeaponType5E_Shortbow]
                                                           explanation:@"Wood Elf Weapon Training"] forStatisticID:DKStatIDWeaponProficiencies];
    [subrace addModifier:[DKModifier setModifierWithAppendedObject:[DKWeaponBuilder5E proficiencyNameForWeapon:kDKWeaponType5E_Longbow]
                                                           explanation:@"Wood Elf Weapon Training"] forStatisticID:DKStatIDWeaponProficiencies];
    [subrace addModifier:[DKModifier numericModifierWithAdditiveBonus:5 explanation:@"Wood Elf racial movement speed bonus"] forStatisticID:DKStatIDMoveSpeed];
    [subrace addModifier:[DKModifier modifierWithExplanation:@"Wood Elf Mask of the Wild: Can attempt to hide even when lightly obscured by foliage, "
                          "heavy rain, falling snow, mist, and other natural phenomena"]
          forStatisticID:DKStatIDSkillStealth];
    return subrace;
}

+ (DKSubrace5E*)lightfootHalfling {
    
    DKSubrace5E* subrace = [[DKSubrace5E alloc] init];
    subrace.explanation = @"Lightfoot Halfling racial modifiers";
    [subrace addModifier:[DKModifier stringModifierWithNewString:@"Lightfoot Halfling"] forStatisticID:DKStatIDSubrace];
    [subrace addModifier:[DKModifier numericModifierWithAdditiveBonus:1 explanation:@"Lightfoot Halfling racial charisma bonus"]
          forStatisticID:DKStatIDCharisma];
    [subrace addModifier:[DKModifier setModifierWithAppendedObject:@"Naturally Stealthy" explanation:@"Able to attempt to hide when obscured by a creature that is at least one size larger than you"]
       forStatisticID:DKStatIDOtherTraits];
    return subrace;
}

+ (DKSubrace5E*)stoutHalfling {
    
    DKSubrace5E* subrace = [[DKSubrace5E alloc] init];
    subrace.explanation = @"Stout Halfling racial modifiers";
    [subrace addModifier:[DKModifier stringModifierWithNewString:@"Stout Halfling"] forStatisticID:DKStatIDSubrace];
    [subrace addModifier:[DKModifier numericModifierWithAdditiveBonus:1 explanation:@"Stout halfling racial constitution bonus"]
          forStatisticID:DKStatIDConstitution];
    [subrace addModifier:[DKModifier setModifierWithAppendedObject:@"Poison" explanation:@"Stout Halfling Resilience"]
       forStatisticID:DKStatIDResistances];
    [subrace addModifier:[DKModifier modifierWithExplanation:@"Stout Halfling Resilience: Advantage on saving throws against poison"]
       forStatisticID:DKStatIDSavingThrowOther];
    return subrace;
}

@end