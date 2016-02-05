//
//  DKWeapon5E.m
//  DungeonKit
//
//  Created by Christopher Dodge on 6/17/15.
//  Copyright (c) 2015 Dodge. All rights reserved.
//

#import "DKWeapon5E.h"
#import "DKAbilities5E.h"
#import "DKModifierBuilder.h"
#import "DKStatisticIDs5E.h"
#import "DKCharacter5E.h"

@implementation DKWeaponBuilder5E

+ (NSString*)weaponDamageStatIDForMainHand:(BOOL)isMainHand {
    if (isMainHand) { return DKStatIDMainHandWeaponDamage; }
    else { return DKStatIDOffHandWeaponDamage; }
}

+ (NSString*)weaponAttackBonusStatIDForMainHand:(BOOL)isMainHand {
    if (isMainHand) { return DKStatIDMainHandWeaponAttackBonus; }
    else { return DKStatIDOffHandWeaponAttackBonus; }
}

+ (NSString*)weaponRangeStatIDForMainHand:(BOOL)isMainHand {
    if (isMainHand) { return DKStatIDMainHandWeaponRange; }
    else { return DKStatIDOffHandWeaponRange; }
}

+ (NSString*)weaponAttacksPerActionStatIDForMainHand:(BOOL)isMainHand {
    if (isMainHand) { return DKStatIDMainHandWeaponAttacksPerAction; }
    else { return DKStatIDOffHandWeaponAttacksPerAction; }
}

+ (NSString*)weaponAttributesStatIDForMainHand:(BOOL)isMainHand {
    if (isMainHand) { return DKStatIDMainHandWeaponAttributes; }
    else { return DKStatIDOffHandWeaponAttributes; }
}


+ (DKModifier*)proficiencyModifierFromBonus:(DKNumericStatistic*)proficiencyBonus
                        weaponProficiencies:(DKSetStatistic*)weaponProficiencies
                           proficiencyTypes:(NSArray*)proficiencyTypes {
    
    NSDictionary* dependencies = @{ @"bonus" : proficiencyBonus,
                                    @"proficiencies" : weaponProficiencies };
    DKModifier* modifier = [[DKModifier alloc] initWithDependencies:dependencies
                                                              value:[DKExpressionBuilder valueFromDependency:@"bonus"]
                                                            enabled:[DKPredicateBuilder enabledWhen:@"proficiencies"containsAnyFromObjects:proficiencyTypes]
                                                           priority:kDKModifierPriority_Additive
                                                         expression:[DKExpressionBuilder additionExpression]];
    modifier.explanation = @"Proficiency bonus";
    return modifier;
}

+ (DKModifier*)finesseAttackBonusModifierFromAbilities:(DKAbilities5E*)abilities {
    
    NSDictionary* dependencies = @{ @"str" : abilities.strength,
                                    @"dex" : abilities.dexterity};
    NSExpression* strExpression = [DKAbilityScore abilityScoreValueForDependency:@"str"];
    NSExpression* dexExpression = [DKAbilityScore abilityScoreValueForDependency:@"dex"];
    NSExpression* valueExpression = [NSExpression expressionForFunction:@"max:" arguments:@[ [NSExpression expressionForAggregate:@[strExpression, dexExpression]] ]];
    
    return [[DKModifier alloc] initWithDependencies:dependencies
                                              value:valueExpression
                                            enabled:nil
                                           priority:kDKModifierPriority_Additive
                                         expression:[DKExpressionBuilder additionExpression]];
}

+ (DKModifierGroup*)damageAbilityScoreModifierFromAbilities:(DKAbilities5E*)abilities
                                        weaponProficiencies:(DKSetStatistic*)weaponProficiencies
                                                   mainHand:(BOOL)isMainHand
                                                     ranged:(BOOL)isRanged
                                                    finesse:(BOOL)isFinesse {
    DKModifierGroup* damage = [[DKModifierGroup alloc] init];
    damage.explanation = @"Weapon damage modifier from ability score";
    
    NSDictionary* dependencies;
    NSExpression* valueExpression;
    if (isFinesse) {
        dependencies = @{ @"str" : abilities.strength,
                          @"dex" : abilities.dexterity,
                          @"proficiencies" : weaponProficiencies };
        NSExpression* strExpression = [DKAbilityScore abilityScoreValueForDependency:@"str"];
        NSExpression* dexExpression = [DKAbilityScore abilityScoreValueForDependency:@"dex"];
        valueExpression = [NSExpression expressionForFunction:@"max:" arguments:@[ [NSExpression expressionForAggregate:@[strExpression, dexExpression]] ]];
    } else if (isRanged) {
        dependencies = @{ @"dex" : abilities.dexterity,
                          @"proficiencies" : weaponProficiencies };
        valueExpression = [DKAbilityScore abilityScoreValueForDependency:@"dex"];
    } else {
        dependencies = @{ @"str" : abilities.strength,
                          @"proficiencies" : weaponProficiencies };
        valueExpression = [DKAbilityScore abilityScoreValueForDependency:@"str"];
        
    }
    
    NSPredicate* enabled;
    if (isMainHand) {
        enabled = nil;
    } else {
        enabled = [DKPredicateBuilder enabledWhen:@"proficiencies" containsObject:@"Two-Weapon Fighting"];
    }
    
    [damage addModifier:[[DKModifier alloc] initWithDependencies:dependencies
                                                           value:[DKExpressionBuilder valueAsDiceCollectionFromExpression:valueExpression]
                                                         enabled:enabled
                                                        priority:kDKModifierPriority_Additive
                                                      expression:[DKExpressionBuilder addDiceExpression]]
         forStatisticID:[DKWeaponBuilder5E weaponDamageStatIDForMainHand:isMainHand]];
    
    if (!isMainHand) {
        //For non proficient off-hand weapon, the ability score only gets applied if it is negative
        valueExpression = [NSExpression expressionForFunction:@"min:" arguments:@[ [NSExpression expressionForAggregate:@[ valueExpression, [NSExpression expressionForConstantValue:@(0)]]] ]];
        DKModifier* nonProficientModifier = [[DKModifier alloc] initWithDependencies:dependencies
                                                                               value:[DKExpressionBuilder valueAsDiceCollectionFromExpression:valueExpression]
                                                                             enabled:[DKPredicateBuilder enabledWhen:@"proficiencies" doesNotContainAnyFromObjects:@[ @"Two-Weapon Fighting"] ]
                                                                            priority:kDKModifierPriority_Additive
                                                                          expression:[DKExpressionBuilder addDiceExpression]];
        nonProficientModifier.explanation = @"Off-hand weapons do not receive ability score bonuses to damage unless the ability score is negative or the character is proficient in Two-Weapon Fighting.";
        [damage addModifier:nonProficientModifier
             forStatisticID:[DKWeaponBuilder5E weaponDamageStatIDForMainHand:isMainHand]];
        
    }
    
    return damage;
}

+ (DKWeapon5E*)weaponWithName:(NSString*)name
                   damageDice:(DKDiceCollection*)damageDice
          versatileDamageDice:(DKDiceCollection*)versatileDamageDiceOrNil
                   damageType:(NSString*)damageType
             proficiencyTypes:(NSArray*)proficiencyTypes
                   isMainHand:(BOOL)isMainHand
                   meleeReach:(NSInteger)meleeReach
                  rangedReach:(NSValue*)rangedReachOrNil
              otherAttributes:(NSArray*)attributes
                    abilities:(DKAbilities5E*)abilities
             proficiencyBonus:(DKNumericStatistic*)proficiencyBonus
                characterSize:(DKStringStatistic*)characterSize
          weaponProficiencies:(DKSetStatistic*)weaponProficiencies
              offHandOccupied:(DKNumericStatistic*)offHandOccupied {
    
    BOOL hasAmmunition = [attributes containsObject:@"Ammunition"];
    BOOL isFinesse = [attributes containsObject:@"Finesse"];
    BOOL isTwoHanded = [attributes containsObject:@"Two-handed"];
    BOOL isLight = [attributes containsObject:@"Light"];
    BOOL isHeavy = [attributes containsObject:@"Heavy"];
    BOOL isLoading = [attributes containsObject:@"Loading"];
    BOOL isUnarmed = [attributes containsObject:@"Unarmed"];
    BOOL isRanged = [attributes containsObject:@"Ranged"];
    
    NSAssert(isMainHand || isLight, @"Weapon cannot be off-handed unless it is a light weapon");
    
    DKModifierGroup* weapon = [[DKModifierGroup alloc] init];
    weapon.explanation = [name copy];
    
    //Weapon attributes
    for (NSString* weaponAttribute in attributes) {
        [weapon addModifier:[DKModifier setModifierWithAppendedObject:weaponAttribute]
             forStatisticID:[DKWeaponBuilder5E weaponAttributesStatIDForMainHand:isMainHand]];
    }
    
    //Damage dice
    if (!versatileDamageDiceOrNil || !isMainHand) {
        [weapon addModifier:[DKModifier diceModifierWithAddedDice:damageDice]
             forStatisticID:[DKWeaponBuilder5E weaponDamageStatIDForMainHand:isMainHand]];
    } else {
        
        //Versatile weapon damage dice
        DKModifier* normalWeaponDamage = [DKModifier diceModifierAddedFromSource:offHandOccupied
                                                                           value:[DKExpressionBuilder valueFromObject:damageDice]
                                                                         enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                          isGreaterThanOrEqualTo:1]];
        normalWeaponDamage.explanation = @"Versatile damage bonus requires a free off hand";
        [weapon addModifier:normalWeaponDamage forStatisticID:[DKWeaponBuilder5E weaponDamageStatIDForMainHand:isMainHand]];
        
        DKModifier* versatileWeaponDamage = [DKModifier diceModifierAddedFromSource:offHandOccupied
                                                                                              value:[DKExpressionBuilder valueFromObject:versatileDamageDiceOrNil]
                                                                                            enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                                                                 isEqualToOrBetween:0 and:0]];
        versatileWeaponDamage.explanation = @"Versatile damage bonus";
        [weapon addModifier:versatileWeaponDamage forStatisticID:[DKWeaponBuilder5E weaponDamageStatIDForMainHand:isMainHand]];
        
        [weapon addModifier:[DKModifier setModifierWithAppendedObject:@"Versatile"]
             forStatisticID:[DKWeaponBuilder5E weaponAttributesStatIDForMainHand:isMainHand]];
    }
    
    //Damage type
    [weapon addModifier:[DKModifier modifierWithExplanation:[NSString stringWithFormat:@"%@ damage", damageType]]
         forStatisticID:[DKWeaponBuilder5E weaponDamageStatIDForMainHand:isMainHand]];
    
    //Ability score bonus to damage
    [weapon addSubgroup:[DKWeaponBuilder5E damageAbilityScoreModifierFromAbilities:abilities
                                                               weaponProficiencies:weaponProficiencies
                                                                          mainHand:isMainHand
                                                                            ranged:isRanged
                                                                           finesse:isFinesse]];
    
    //Ability score bonus to hit
    if (isFinesse) {
        [weapon addModifier:[DKWeaponBuilder5E finesseAttackBonusModifierFromAbilities:abilities]
             forStatisticID:[DKWeaponBuilder5E weaponAttackBonusStatIDForMainHand:isMainHand]];
    } else {
        [weapon addModifier:[abilities.strength modifierFromAbilityScoreWithExplanation:@"Strength bonus to hit"]
             forStatisticID:[DKWeaponBuilder5E weaponAttackBonusStatIDForMainHand:isMainHand]];
    }
    
    //Proficiency bonus to hit
    [weapon addModifier:[DKWeaponBuilder5E proficiencyModifierFromBonus:proficiencyBonus
                                                    weaponProficiencies:weaponProficiencies
                                                       proficiencyTypes:proficiencyTypes]
         forStatisticID:[DKWeaponBuilder5E weaponAttackBonusStatIDForMainHand:isMainHand]];
    
    //Melee reach
    [weapon addModifier:[DKModifier numericModifierWithAdditiveBonus:meleeReach]
         forStatisticID:[DKWeaponBuilder5E weaponRangeStatIDForMainHand:isMainHand]];
    
    //Ranged reach
    if (rangedReachOrNil) {
        NSRange range = [rangedReachOrNil rangeValue];
        [weapon addModifier:[DKModifier numericModifierWithAdditiveBonus:range.location
                                                             explanation:[NSString stringWithFormat:@"%@ thrown range limit", name]]
             forStatisticID:[DKWeaponBuilder5E weaponRangeStatIDForMainHand:isMainHand]];
        [weapon addModifier:[DKModifier modifierWithExplanation:
                             [NSString stringWithFormat:@"Roll at disadvantage to throw at targets between %lul and %lul feet away",
                              (unsigned long)range.location, (unsigned long)NSMaxRange(range)]]
             forStatisticID:[DKWeaponBuilder5E weaponRangeStatIDForMainHand:isMainHand]];
    }
    
    //Number of attacks per action
    [weapon addModifier:[DKModifier numericModifierWithAdditiveBonus:1]
         forStatisticID:[DKWeaponBuilder5E weaponAttacksPerActionStatIDForMainHand:isMainHand]];
    
    if (!isLight) {
        [weapon addModifier:[DKModifier numericModifierWithClampBetween:0 and:0 explanation:@"Off hand weapons may not be used to attack unless the main hand weapon is a light weapon."]
             forStatisticID:[DKWeaponBuilder5E weaponAttacksPerActionStatIDForMainHand:NO]];
    }
    
    //Ammunition weapons
    if (hasAmmunition) {
        [weapon addModifier:[DKModifier modifierWithExplanation:@"This weapon requires ammunition in order to execute a ranged attack."]
             forStatisticID:[DKWeaponBuilder5E weaponAttackBonusStatIDForMainHand:isMainHand]];
    }
    
    //Loading weapons
    if (isLoading) {
        [weapon addModifier:[DKModifier numericModifierWithClampBetween:1 and:1 explanation:@"Weapons that need to be loaded may only be fired once per action, bonus action, or reaction."]
             forStatisticID:[DKWeaponBuilder5E weaponAttacksPerActionStatIDForMainHand:isMainHand]];
    }
    
    //Heavy weapons
    if (isHeavy) {
        [weapon addModifier:[DKModifier modifierFromSource:characterSize
                                                   enabled:[DKPredicateBuilder enabledWhen:@"source"
                                                                   isEqualToAnyFromStrings:@[@"Small", @"Tiny"]]
                                               explanation:@"Small creatures have disadvantage on attack rolls with heavy weapons."]
             forStatisticID:[DKWeaponBuilder5E weaponAttackBonusStatIDForMainHand:isMainHand]];
    }
    
    //Occupy hands as appropriate
    if (isMainHand && !isUnarmed) {
        [weapon addModifier:[DKModifier numericModifierWithAdditiveBonus:1] forStatisticID:DKStatIDMainHandOccupied];
    }
    if (!isMainHand || isTwoHanded) {
        [weapon addModifier:[DKModifier numericModifierWithAdditiveBonus:1] forStatisticID:DKStatIDOffHandOccupied];
    }
    
    return weapon;
}

#pragma mark -

+ (NSString*)proficiencyNameForWeaponCategory:(DKWeaponCategory5E)category {
    
    static dispatch_once_t once;
    static NSDictionary* weaponCategoryToNameMap;
    dispatch_once(&once, ^ {
        
        weaponCategoryToNameMap = @{    @(kDKWeaponCategory5E_Simple)       : @"Simple Weapons",
                                        @(kDKWeaponCategory5E_Martial)      : @"Martial Weapons",
                                    };
    });
    
    return weaponCategoryToNameMap[@(category)];
}

+ (NSString*)proficiencyNameForWeapon:(DKWeaponType5E)type {
    
    static dispatch_once_t once;
    static NSDictionary* weaponTypeToNameMap;
    dispatch_once(&once, ^ {
        
        weaponTypeToNameMap = @{ @(kDKWeaponType5E_Club)            : @"Clubs",
                                 @(kDKWeaponType5E_Dagger)          : @"Daggers",
                                 @(kDKWeaponType5E_Greatclub)       : @"Clubs",
                                 @(kDKWeaponType5E_Handaxe)         : @"Axes",
                                 @(kDKWeaponType5E_Javelin)         : @"Javelins",
                                 @(kDKWeaponType5E_LightHammer)     : @"Light Hammers",
                                 @(kDKWeaponType5E_Mace)            : @"Maces",
                                 @(kDKWeaponType5E_Quarterstaff)    : @"Quarterstaves",
                                 @(kDKWeaponType5E_Sickle)          : @"Sickles",
                                 @(kDKWeaponType5E_Spear)           : @"Spears",
                                 
                                 @(kDKWeaponType5E_LightCrossbow)   : @"Crossbows",
                                 @(kDKWeaponType5E_Dart)            : @"Darts",
                                 @(kDKWeaponType5E_Shortbow)        : @"Shortbows",
                                 @(kDKWeaponType5E_Sling)           : @"Slings",
                                 
                                 @(kDKWeaponType5E_Battleaxe)       : @"Axes",
                                 @(kDKWeaponType5E_Flail)           : @"Flails",
                                 @(kDKWeaponType5E_Glaive)          : @"Glaives",
                                 @(kDKWeaponType5E_Greataxe)        : @"Greataxes",
                                 @(kDKWeaponType5E_Greatsword)      : @"Greatswords",
                                 @(kDKWeaponType5E_Halberd)         : @"Halberds",
                                 @(kDKWeaponType5E_Lance)           : @"Lances",
                                 @(kDKWeaponType5E_Longsword)       : @"Longswords",
                                 @(kDKWeaponType5E_Maul)            : @"Mauls",
                                 @(kDKWeaponType5E_Morningstar)     : @"Morningstars",
                                 @(kDKWeaponType5E_Pike)            : @"Pikes",
                                 @(kDKWeaponType5E_Rapier)          : @"Rapiers",
                                 @(kDKWeaponType5E_Scimitar)        : @"Scimitars",
                                 @(kDKWeaponType5E_Shortsword)      : @"Shortswords",
                                 @(kDKWeaponType5E_Trident)         : @"Tridents",
                                 @(kDKWeaponType5E_WarPick)         : @"Picks",
                                 @(kDKWeaponType5E_Warhammer)       : @"Warhammers",
                                 @(kDKWeaponType5E_Whip)            : @"Whips",
                                 
                                 @(kDKWeaponType5E_Blowgun)         : @"Blowguns",
                                 @(kDKWeaponType5E_HandCrossbow)    : @"Crossbows",
                                 @(kDKWeaponType5E_HeavyCrossbow)   : @"Crossbows",
                                 @(kDKWeaponType5E_Longbow)         : @"Longbows",
                                 @(kDKWeaponType5E_Net)             : @"Nets",
                                };
    });
    
    return weaponTypeToNameMap[@(type)];
}

+ (DKWeapon5E*)weaponOfType:(DKWeaponType5E)type
               forCharacter:(DKCharacter5E*)character
                 isMainHand:(BOOL)isMainHand {
    
    return [DKWeaponBuilder5E weaponOfType:type
                                 abilities:character.abilities
                          proficiencyBonus:character.proficiencyBonus
                             characterSize:character.size
                       weaponProficiencies:character.weaponProficiencies
                           offHandOccupied:character.equipment.offHandOccupied
                                isMainHand:isMainHand];
}

+ (DKWeapon5E*)weaponOfType:(DKWeaponType5E)type
                  abilities:(DKAbilities5E*)abilities
           proficiencyBonus:(DKNumericStatistic*)proficiencyBonus
              characterSize:(DKStringStatistic*)characterSize
        weaponProficiencies:(DKSetStatistic*)weaponProficiencies
            offHandOccupied:(DKNumericStatistic*)offHandOccupied
                 isMainHand:(BOOL)isMainHand {
    
    switch (type) {
            
        case kDKWeaponType5E_Unarmed: {
            return [DKWeaponBuilder5E weaponWithName:@"Unarmed"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:0 sides:0 modifier:1]
                                 versatileDamageDice:nil
                                          damageType:@"Bludgeoning"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Simple]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:nil
                                     otherAttributes:@[@"Unarmed", @"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Club: {
            return [DKWeaponBuilder5E weaponWithName:@"Club"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:4 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Bludgeoning"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Simple],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:nil
                                     otherAttributes:@[@"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Dagger: {
            return [DKWeaponBuilder5E weaponWithName:@"Dagger"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:4 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Piercing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Simple],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:[NSValue valueWithRange:NSMakeRange(20, 60)]
                                     otherAttributes:@[@"Finesse", @"Light", @"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Greatclub: {
            return [DKWeaponBuilder5E weaponWithName:@"Greatclub"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:8 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Bludgeoning"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Simple],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:nil
                                     otherAttributes:@[@"Two-handed", @"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Handaxe: {
            return [DKWeaponBuilder5E weaponWithName:@"Handaxe"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:6 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Slashing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Simple],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:[NSValue valueWithRange:NSMakeRange(20, 60)]
                                     otherAttributes:@[@"Light", @"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Javelin: {
            return [DKWeaponBuilder5E weaponWithName:@"Javelin"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:6 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Piercing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Simple],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:[NSValue valueWithRange:NSMakeRange(30, 120)]
                                     otherAttributes:@[@"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_LightHammer: {
            return [DKWeaponBuilder5E weaponWithName:@"Light hammer"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:4 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Bludgeoning"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Simple],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:[NSValue valueWithRange:NSMakeRange(20, 60)]
                                     otherAttributes:@[@"Light", @"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Mace: {
            return [DKWeaponBuilder5E weaponWithName:@"Mace"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:6 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Bludgeoning"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Simple],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:nil
                                     otherAttributes:@[@"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Quarterstaff: {
            return [DKWeaponBuilder5E weaponWithName:@"Quarterstaff"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:6 modifier:0]
                                 versatileDamageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:8 modifier:0]
                                          damageType:@"Bludgeoning"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Simple],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:nil
                                     otherAttributes:@[@"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Sickle: {
            return [DKWeaponBuilder5E weaponWithName:@"Sickle"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:4 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Slashing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Simple],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:nil
                                     otherAttributes:@[@"Light", @"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Spear: {
            return [DKWeaponBuilder5E weaponWithName:@"Spear"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:6 modifier:0]
                                 versatileDamageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:8 modifier:0]
                                          damageType:@"Piercing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Simple],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:[NSValue valueWithRange:NSMakeRange(20, 60)]
                                     otherAttributes:@[@"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_LightCrossbow: {
            return [DKWeaponBuilder5E weaponWithName:@"Light Crossbow"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:8 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Piercing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Simple],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:[NSValue valueWithRange:NSMakeRange(80, 320)]
                                     otherAttributes:@[@"Ammunition", @"Loading", @"Two-handed", @"Ranged"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Dart: {
            return [DKWeaponBuilder5E weaponWithName:@"Dart"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:4 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Piercing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Simple],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:[NSValue valueWithRange:NSMakeRange(20, 60)]
                                     otherAttributes:@[@"Finesse", @"Ranged"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Shortbow: {
            return [DKWeaponBuilder5E weaponWithName:@"Shortbow"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:6 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Piercing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Simple],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:[NSValue valueWithRange:NSMakeRange(80, 320)]
                                     otherAttributes:@[@"Ammunition", @"Two-handed", @"Ranged"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Sling: {
            return [DKWeaponBuilder5E weaponWithName:@"Sling"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:4 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Bludgeoning"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Simple],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:[NSValue valueWithRange:NSMakeRange(30, 120)]
                                     otherAttributes:@[@"Ammunition", @"Ranged"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Battleaxe: {
            return [DKWeaponBuilder5E weaponWithName:@"Battleaxe"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:8 modifier:0]
                                 versatileDamageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:10 modifier:0]
                                          damageType:@"Slashing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:nil
                                     otherAttributes:@[@"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Flail: {
            return [DKWeaponBuilder5E weaponWithName:@"Flail"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:8 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Bludgeoning"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:nil
                                     otherAttributes:@[@"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Glaive: {
            return [DKWeaponBuilder5E weaponWithName:@"Glaive"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:10 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Slashing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:10
                                         rangedReach:nil
                                     otherAttributes:@[@"Heavy", @"Two-handed", @"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Greataxe: {
            return [DKWeaponBuilder5E weaponWithName:@"Greataxe"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:12 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Slashing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:nil
                                     otherAttributes:@[@"Heavy", @"Two-handed", @"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Greatsword: {
            return [DKWeaponBuilder5E weaponWithName:@"Greatsword"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:2 sides:6 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Slashing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:nil
                                     otherAttributes:@[@"Heavy", @"Two-handed", @"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Halberd: {
            return [DKWeaponBuilder5E weaponWithName:@"Halberd"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:10 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Slashing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:10
                                         rangedReach:nil
                                     otherAttributes:@[@"Heavy", @"Two-handed", @"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Lance: {
            DKWeapon5E* lance = [DKWeaponBuilder5E weaponWithName:@"Lance"
                                                       damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:12 modifier:0]
                                              versatileDamageDice:nil
                                                       damageType:@"Piercing"
                                                 proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                                    [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                                       isMainHand:isMainHand
                                                       meleeReach:10
                                                      rangedReach:nil
                                                  otherAttributes:@[@"Melee"]
                                                        abilities:abilities
                                                 proficiencyBonus:proficiencyBonus
                                                    characterSize:characterSize
                                              weaponProficiencies:weaponProficiencies
                                                  offHandOccupied:offHandOccupied];
            [lance addModifier:[DKModifier modifierWithExplanation:@"A lance requires two hands to wield when you aren't mounted."]
                                                           forStatisticID:DKStatIDOffHandOccupied];
            [lance addModifier:[DKModifier modifierWithExplanation:@"You have disadvantage when you use a lance to attack a target within 5 feet of you."]
                 forStatisticID:[DKWeaponBuilder5E weaponRangeStatIDForMainHand:isMainHand]];
            
            return lance;
            break;
        }
            
        case kDKWeaponType5E_Longsword: {
            return [DKWeaponBuilder5E weaponWithName:@"Longsword"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:8 modifier:0]
                                 versatileDamageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:10 modifier:0]
                                          damageType:@"Slashing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:nil
                                     otherAttributes:@[@"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Maul: {
            return [DKWeaponBuilder5E weaponWithName:@"Maul"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:2 sides:6 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Bludgeoning"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:nil
                                     otherAttributes:@[@"Heavy", @"Two-handed", @"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Morningstar: {
            return [DKWeaponBuilder5E weaponWithName:@"Morningstar"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:8 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Piercing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:nil
                                     otherAttributes:@[@"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Pike: {
            return [DKWeaponBuilder5E weaponWithName:@"Pike"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:10 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Piercing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:10
                                         rangedReach:nil
                                     otherAttributes:@[@"Heavy", @"Two-handed", @"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Rapier: {
            return [DKWeaponBuilder5E weaponWithName:@"Rapier"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:8 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Piercing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:nil
                                     otherAttributes:@[@"Finesse", @"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Scimitar: {
            return [DKWeaponBuilder5E weaponWithName:@"Scimitar"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:6 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Slashing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:nil
                                     otherAttributes:@[@"Finesse", @"Light", @"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Shortsword: {
            return [DKWeaponBuilder5E weaponWithName:@"Shortsword"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:6 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Piercing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:nil
                                     otherAttributes:@[@"Finesse", @"Light", @"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Trident: {
            return [DKWeaponBuilder5E weaponWithName:@"Trident"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:6 modifier:0]
                                 versatileDamageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:8 modifier:0]
                                          damageType:@"Piercing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:[NSValue valueWithRange:NSMakeRange(20, 60)]
                                     otherAttributes:@[@"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_WarPick: {
            return [DKWeaponBuilder5E weaponWithName:@"War Pick"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:8 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Piercing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:nil
                                     otherAttributes:@[@"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Warhammer: {
            return [DKWeaponBuilder5E weaponWithName:@"Warhammer"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:8 modifier:0]
                                 versatileDamageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:10 modifier:0]
                                          damageType:@"Bludgeoning"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:nil
                                     otherAttributes:@[@"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Whip: {
            return [DKWeaponBuilder5E weaponWithName:@"Whip"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:4 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Slashing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:10
                                         rangedReach:nil
                                     otherAttributes:@[@"Finesse", @"Melee"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Blowgun: {
            return [DKWeaponBuilder5E weaponWithName:@"Blowgun"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:0 sides:0 modifier:1]
                                 versatileDamageDice:nil
                                          damageType:@"Piercing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:[NSValue valueWithRange:NSMakeRange(25, 100)]
                                     otherAttributes:@[@"Ammunition", @"Loading", @"Ranged"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_HandCrossbow: {
            return [DKWeaponBuilder5E weaponWithName:@"Hand Crossbow"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:6 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Piercing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:[NSValue valueWithRange:NSMakeRange(30, 120)]
                                     otherAttributes:@[@"Ammunition", @"Light", @"Loading", @"Ranged"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_HeavyCrossbow: {
            return [DKWeaponBuilder5E weaponWithName:@"Heavy Crossbow"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:10 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Piercing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:[NSValue valueWithRange:NSMakeRange(100, 400)]
                                     otherAttributes:@[@"Ammunition", @"Heavy", @"Loading", @"Two-handed", @"Ranged"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Longbow: {
            return [DKWeaponBuilder5E weaponWithName:@"Longbow"
                                          damageDice:[DKDiceCollection diceCollectionWithQuantity:1 sides:8 modifier:0]
                                 versatileDamageDice:nil
                                          damageType:@"Piercing"
                                    proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                       [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                          isMainHand:isMainHand
                                          meleeReach:5
                                         rangedReach:[NSValue valueWithRange:NSMakeRange(150, 600)]
                                     otherAttributes:@[@"Ammunition", @"Heavy", @"Two-handed", @"Ranged"]
                                           abilities:abilities
                                    proficiencyBonus:proficiencyBonus
                                       characterSize:characterSize
                                 weaponProficiencies:weaponProficiencies
                                     offHandOccupied:offHandOccupied];
            break;
        }
            
        case kDKWeaponType5E_Net: {
            DKWeapon5E* net = [DKWeaponBuilder5E weaponWithName:@"Net"
                                                     damageDice:[DKDiceCollection diceCollectionWithQuantity:0 sides:0 modifier:0]
                                            versatileDamageDice:nil
                                                     damageType:@""
                                               proficiencyTypes:@[[DKWeaponBuilder5E proficiencyNameForWeaponCategory:kDKWeaponCategory5E_Martial],
                                                                  [DKWeaponBuilder5E proficiencyNameForWeapon:type]]
                                                     isMainHand:isMainHand
                                                     meleeReach:5
                                                    rangedReach:[NSValue valueWithRange:NSMakeRange(5, 15)]
                                                otherAttributes:@[@"Ranged"]
                                                      abilities:abilities
                                               proficiencyBonus:proficiencyBonus
                                                  characterSize:characterSize
                                            weaponProficiencies:weaponProficiencies
                                                offHandOccupied:offHandOccupied];
            [net addModifier:[DKModifier modifierWithExplanation:@"A Large or smaller creature hit by a net is restrained until it is freed. A net has no effect on creatures that are formless, or creatures that are Huge or larger.  A creature can use its action to make a DC 10 Strength check, freeing itself or another creature within its reach on a success.  Dealing 5 slashing damage to the net (AC 10) also frees the creature without harming it, ending the effect and destroying the net."]
              forStatisticID:[DKWeaponBuilder5E weaponDamageStatIDForMainHand:isMainHand]];
            [net addModifier:[DKModifier numericModifierWithClampBetween:1 and:1 explanation:@"Nets may only be used to attack once per action, bonus action, or reaction."]
                 forStatisticID:[DKWeaponBuilder5E weaponAttacksPerActionStatIDForMainHand:isMainHand]];
            return net;
            break;
        }
            
        default:
            break;
    }
    
    NSLog(@"DKWeaponBuilder5E: Unrecognized weapon type: %li", (long)type);
    return nil;
}

@end
