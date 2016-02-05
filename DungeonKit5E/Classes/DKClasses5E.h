//
//  DKClasses5E.h
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <Foundation/Foundation.h>
#import "DKStatisticGroup5E.h"
#import "DKCleric5E.h"
#import "DKFighter5E.h"
#import "DKRogue5E.h"
#import "DKWizard5E.h"

typedef NS_ENUM(NSInteger, DKClassType5E) {
    
    kDKClassType5E_Cleric = 1,
    kDKClassType5E_Fighter,
    kDKClassType5E_Rogue,
    kDKClassType5E_Wizard,
};

@class DKCharacter5E;

@interface DKClasses5E : DKStatisticGroup5E

@property (nonatomic, strong) DKCleric5E* cleric;
@property (nonatomic, strong) DKFighter5E* fighter;
@property (nonatomic, strong) DKRogue5E* rogue;
@property (nonatomic, strong) DKWizard5E* wizard;

- (id)init;
- (DKClass5E*)classForClassType:(DKClassType5E)classType;

@end