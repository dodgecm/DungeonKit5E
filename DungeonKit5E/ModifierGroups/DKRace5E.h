//
//  DKRace5E.h
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <Foundation/Foundation.h>
#import <DungeonKit/DungeonKit.h>

@class DKCharacter5E;

//Normally I would just use a typedef here, but KVO explodes after the use of C style unions.  Beware.
@compatibility_alias DKRace5E DKModifierGroup;
@compatibility_alias DKSubrace5E DKModifierGroup;

@interface DKRace5EBuilder : NSObject

+ (DKSubgroupChoiceModifierGroup*)raceChoiceForCharacter:(DKCharacter5E*)character;
+ (DKRace5E*)dwarfWithCharacter:(DKCharacter5E*)character;
+ (DKRace5E*)elf;
+ (DKRace5E*)halfling;
+ (DKRace5E*)human;

@end

@interface DKSubrace5EBuilder : NSObject

+ (DKSubrace5E*)hillDwarfFromCharacter:(DKCharacter5E*)character;
+ (DKSubrace5E*)mountainDwarf;

+ (DKSubrace5E*)highElf;
+ (DKSubrace5E*)woodElf;

+ (DKSubrace5E*)lightfootHalfling;
+ (DKSubrace5E*)stoutHalfling;

@end