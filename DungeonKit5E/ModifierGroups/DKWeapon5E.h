//
//  DKWeapon5E.h
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <Foundation/Foundation.h>
#import <DungeonKit/DungeonKit.h>

@class DKCharacter5E;
@class DKAbilities5E;

typedef NS_ENUM(NSInteger, DKWeaponCategory5E) {
    
    kDKWeaponCategory5E_Simple = 1,
    kDKWeaponCategory5E_Martial,
};

typedef NS_ENUM(NSInteger, DKWeaponType5E) {
    
    //Simple melee weapons
    kDKWeaponType5E_Unarmed = 1,
    kDKWeaponType5E_Club,
    kDKWeaponType5E_Dagger,
    kDKWeaponType5E_Greatclub,
    kDKWeaponType5E_Handaxe,
    kDKWeaponType5E_Javelin,
    kDKWeaponType5E_LightHammer,
    kDKWeaponType5E_Mace,
    kDKWeaponType5E_Quarterstaff,
    kDKWeaponType5E_Sickle,
    kDKWeaponType5E_Spear,
    
    //Simple ranged weapons
    kDKWeaponType5E_LightCrossbow,
    kDKWeaponType5E_Dart,
    kDKWeaponType5E_Shortbow,
    kDKWeaponType5E_Sling,
    
    //Martial Melee Weapons
    kDKWeaponType5E_Battleaxe,
    kDKWeaponType5E_Flail,
    kDKWeaponType5E_Glaive,
    kDKWeaponType5E_Greataxe,
    kDKWeaponType5E_Greatsword,
    kDKWeaponType5E_Halberd,
    kDKWeaponType5E_Lance,
    kDKWeaponType5E_Longsword,
    kDKWeaponType5E_Maul,
    kDKWeaponType5E_Morningstar,
    kDKWeaponType5E_Pike,
    kDKWeaponType5E_Rapier,
    kDKWeaponType5E_Scimitar,
    kDKWeaponType5E_Shortsword,
    kDKWeaponType5E_Trident,
    kDKWeaponType5E_WarPick,
    kDKWeaponType5E_Warhammer,
    kDKWeaponType5E_Whip,
    
    //Martial Ranged Weapons
    kDKWeaponType5E_Blowgun,
    kDKWeaponType5E_HandCrossbow,
    kDKWeaponType5E_HeavyCrossbow,
    kDKWeaponType5E_Longbow,
    kDKWeaponType5E_Net,
};

@compatibility_alias DKWeapon5E DKModifierGroup;

@interface DKWeaponBuilder5E : NSObject

+ (NSString*)proficiencyNameForWeaponCategory:(DKWeaponCategory5E)category;
+ (NSString*)proficiencyNameForWeapon:(DKWeaponType5E)type;

+ (DKWeapon5E*)weaponOfType:(DKWeaponType5E)type
               forCharacter:(DKCharacter5E*)character
                 isMainHand:(BOOL)isMainHand;

+ (DKWeapon5E*)weaponOfType:(DKWeaponType5E)type
                  abilities:(DKAbilities5E*)abilities
           proficiencyBonus:(DKNumericStatistic*)proficiencyBonus
              characterSize:(DKStringStatistic*)characterSize
        weaponProficiencies:(DKSetStatistic*)weaponProficiencies
            offHandOccupied:(DKNumericStatistic*)offHandOccupied
                 isMainHand:(BOOL)isMainHand;
@end