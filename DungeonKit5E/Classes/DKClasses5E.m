//
//  DKClasses5E.m
//  DungeonKit
//
//  Created by Christopher Dodge on 4/28/15.
//  Copyright (c) 2015 Dodge. All rights reserved.
//

#import "DKClasses5E.h"
#import "DKStatisticGroupIDs5E.h"
#import "DKCharacter5E.h"

@implementation DKClasses5E

@synthesize cleric = _cleric;
@synthesize fighter = _fighter;
@synthesize rogue = _rogue;
@synthesize wizard = _wizard;

- (id)init {
    self = [super init];
    if (self) {
    
        self.cleric = [[DKCleric5E alloc] init];
        self.fighter = [[DKFighter5E alloc] init];
        self.rogue = [[DKRogue5E alloc] init];
        self.wizard = [[DKWizard5E alloc] init];
    }
    return self;
}

- (DKClass5E*)classForClassType:(DKClassType5E)classType {
    
    switch (classType) {
        case kDKClassType5E_Cleric: {
            return self.cleric;
            break;
        }
        case kDKClassType5E_Fighter: {
            return self.fighter;
            break;
        }
        case kDKClassType5E_Rogue: {
            return self.rogue;
            break;
        }
        case kDKClassType5E_Wizard: {
            return self.wizard;
            break;
        }
            
        default:
            break;
    }
}

- (NSDictionary*) statisticGroupKeyPaths {
    return @{
             DKStatisticGroupIDCleric: @"cleric",
             DKStatisticGroupIDFighter: @"fighter",
             DKStatisticGroupIDRogue: @"rogue",
             DKStatisticGroupIDWizard: @"wizard",
             };
}

@end