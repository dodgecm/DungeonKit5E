
### Using the 5E Module

Creating a character is easy.
```objc
#import <DungeonKit5E/DungeonKit5E.h>
DKCharacter5E* character = [[DKCharacter5E alloc] init];
```

Edit statistics by changing their base value.
```objc
character.name.base = @"Madagascar the Wise";
character.abilities.intelligence.base = @17;
```

#### Making Choices
Make choices for your character.  You can query for a specific choice by using its [identifier](https://github.com/dodgecm/DungeonKit5E/blob/master/DungeonKit5E/ModifierGroups/DKModifierGroupTags5E.h).
```objc
NSLog(@"My character has an intelligence score of %@.", character.abilities.intelligence.value);
// My character has an intelligence score of 17.

DKChoiceModifierGroup* chooseRace = [character firstUnallocatedChoiceWithTag:DKChoiceRace];
NSArray* possibleRaces = chooseRace.choices;
[chooseRace choose:possibleRaces[3]]; //Human
NSLog(@"My human character now has an intelligence score of %@.", character.abilities.intelligence.value);
// My human character now has an intelligence score of 18.
```

There is a special method for choosing your character's class.
```objc
NSLog(@"My character has %@ 1st level spell slots.", character.spells.firstLevelSpellSlotsMax.value);
// My character has 0 1st level spell slots.

[character chooseClass:kDKClassType5E_Wizard];
NSLog(@"My wizard now has %@ 1st level spell slots.", character.spells.firstLevelSpellSlotsMax.value);
// My wizard now has 2 1st level spell slots.
```

#### Leveling Up
Level up by increasing your experience points statistic.
```objc
NSLog(@"My wizard is level %@.", character.level.value);
// My wizard is level 1.

character.experiencePoints.base = @6500;
NSLog(@"My wizard is now level %@.", character.level.value);
// My wizard is now level 5.
NSLog(@"My proficiency bonus is +%@.", character.proficiencyBonus.value);
// My proficiency bonus is +3.
```

#### Equipment
You can also equip weapons and armor.  DungeonKit will keep track of your proficiencies and update your attack bonus, damage, and armor class (among others) appropriately.
```objc
NSLog(@"My wizard can use %@ as weapons.", character.weaponProficiencies.value);
/*  My wizard can use {(
    Crossbows,
    Darts,
    Quarterstaves,
    Daggers,
    Slings
)} as weapons. */
[character.equipment equipMainHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Quarterstaff
                                                             forCharacter:character
                                                               isMainHand:YES]];
NSLog(@"My attack bonus for my quarterstaff is +%@ at level 5.", character.equipment.mainHandWeaponAttackBonus.value);
// My attack bonus for my quarterstaff is +3 at level 5.
NSLog(@"My versatile quarterstaff does %@ damage per attack.", character.equipment.mainHandWeaponDamage.value);
// My versatile quarterstaff does 1d8 damage per attack.

[character.equipment equipOffHandWeapon:[DKWeaponBuilder5E weaponOfType:kDKWeaponType5E_Shortsword
                                                            forCharacter:character
                                                              isMainHand:NO]];
NSLog(@"My non-proficient attack bonus for my short sword is +%@.", character.equipment.offHandWeaponAttackBonus.value);
// My non-proficient attack bonus for my short sword is +0.
NSLog(@"My quarterstaff, held in only one hand, now does %@ damage per attack.", character.equipment.mainHandWeaponDamage.value);
// My quarterstaff, held in only one hand, now does 1d6 damage per attack.
```

#### Exploring DungeonKit5E
The 5E module contains [unit tests](https://github.com/dodgecm/DungeonKit5E/tree/master/DungeonKit5ETests) with more in-depth code samples than this guide.  
You may also find the list of all [statistics](https://github.com/dodgecm/DungeonKit5E/blob/master/DungeonKit5E/DKStatisticIDs5E.h) in this module helpful.
