//
//  DKCharacter5E.h
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <DungeonKit/DungeonKit.h>
#import "DKStatisticGroup5E.h"
#import "DKRace5E.h"
#import "DKClasses5E.h"
#import "DKAbilities5E.h"
#import "DKSavingThrows5E.h"
#import "DKSkills5E.h"
#import "DKSpellcasting5E.h"
#import "DKCurrency5E.h"
#import "DKEquipment5E.h"

@interface DKCharacter5E : DKStatisticGroup5E

//Statistics
@property (nonatomic, strong) DKStringStatistic* name;
@property (nonatomic, strong) DKNumericStatistic* level;
@property (nonatomic, strong) DKNumericStatistic* experiencePoints;
@property (nonatomic, strong) DKStringStatistic* race;
@property (nonatomic, strong) DKStringStatistic* subrace;
@property (nonatomic, strong) DKStringStatistic* className;
@property (nonatomic, strong) DKStringStatistic* size;
@property (nonatomic, strong) DKStringStatistic* alignment;

@property (nonatomic, strong) DKNumericStatistic* inspiration;
@property (nonatomic, strong) DKNumericStatistic* proficiencyBonus;

@property (nonatomic, strong) DKNumericStatistic* hitPointsMax;
@property (nonatomic, strong) DKNumericStatistic* hitPointsTemporary;
@property (nonatomic, strong) DKNumericStatistic* hitPointsCurrent;
@property (nonatomic, strong) DKDiceStatistic* hitDiceMax;
@property (nonatomic, strong) DKDiceStatistic* hitDiceCurrent;

@property (nonatomic, strong) DKNumericStatistic* armorClass;
@property (nonatomic, strong) DKNumericStatistic* initiativeBonus;
@property (nonatomic, strong) DKNumericStatistic* movementSpeed;
@property (nonatomic, strong) DKNumericStatistic* darkvisionRange;

@property (nonatomic, strong) DKNumericStatistic* deathSaveSuccesses;
@property (nonatomic, strong) DKNumericStatistic* deathSaveFailures;

@property (nonatomic, strong) DKSetStatistic* weaponProficiencies;
@property (nonatomic, strong) DKSetStatistic* armorProficiencies;
@property (nonatomic, strong) DKSetStatistic* toolProficiencies;

@property (nonatomic, strong) DKSetStatistic* languages;

@property (nonatomic, strong) DKSetStatistic* resistances;
@property (nonatomic, strong) DKSetStatistic* immunities;

@property (nonatomic, strong) DKSetStatistic* otherTraits;

//Statistic Groups
@property (nonatomic, strong) DKClasses5E* classes;
@property (nonatomic, strong) DKAbilities5E* abilities;
@property (nonatomic, strong) DKSavingThrows5E* savingThrows;
@property (nonatomic, strong) DKSkills5E* skills;
@property (nonatomic, strong) DKSpellcasting5E* spells;
@property (nonatomic, strong) DKCurrency5E* currency;
@property (nonatomic, strong) DKEquipment5E* equipment;

- (void)chooseClass:(DKClassType5E)classType;

@end
