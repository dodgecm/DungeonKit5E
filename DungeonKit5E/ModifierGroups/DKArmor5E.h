//
//  DKArmor5E.h
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <Foundation/Foundation.h>
#import <DungeonKit/DungeonKit.h>

@class DKCharacter5E;
@class DKAbilities5E;
@class DKEquipment5E;

typedef NS_ENUM(NSInteger, DKArmorCategory5E) {
    
    kDKArmorCategory5E_Light = 1,
    kDKArmorCategory5E_Medium,
    kDKArmorCategory5E_Heavy,
    kDKArmorCategory5E_Shield,
};

typedef NS_ENUM(NSInteger, DKArmorType5E) {
    
    //Unarmored
    kDKArmorType5E_Unarmored = 1,
    
    //Light Armor
    kDKArmorType5E_Padded,
    kDKArmorType5E_Leather,
    kDKArmorType5E_StuddedLeather,
    
    //Medium Armor
    kDKArmorType5E_Hide,
    kDKArmorType5E_ChainShirt,
    kDKArmorType5E_ScaleMail,
    kDKArmorType5E_Breastplate,
    kDKArmorType5E_HalfPlate,
    
    //Heavy Armor
    kDKArmorType5E_RingMail,
    kDKArmorType5E_ChainMail,
    kDKArmorType5E_Splint,
    kDKArmorType5E_Plate,
};

@compatibility_alias DKArmor5E DKModifierGroup;

@interface DKArmorBuilder5E : NSObject

+ (NSString*)proficiencyNameForArmorCategory:(DKArmorCategory5E)type;

+ (DKArmor5E*)armorOfType:(DKArmorType5E)type
             forCharacter:(DKCharacter5E*)character;

+ (DKArmor5E*)armorOfType:(DKArmorType5E)type
                abilities:(DKAbilities5E*)abilities
       armorProficiencies:(DKSetStatistic*)armorProficiencies;

+ (DKArmor5E*)shieldForCharacter:(DKCharacter5E*)character;

+ (DKArmor5E*)shieldWithEquipment:(DKEquipment5E*)equipment
               armorProficiencies:(DKSetStatistic*)armorProficiencies;

@end
