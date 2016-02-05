//
//  DKStatisticGroup5E.m
//  DungeonKit
//
//  Created by Christopher Dodge on 7/1/15.
//  Copyright (c) 2015 Dodge. All rights reserved.
//

#import "DKStatisticGroup5E.h"

@implementation DKStatisticGroup5E

- (id)init {
    self = [super init];
    if (self) {
        
        NSDictionary* statKeyPaths = [self statisticKeyPaths];
        for (NSString* statID in [statKeyPaths allKeys]) {
            [self addKeyPath:statKeyPaths[statID] forStatisticID:statID];
        }
        
        NSDictionary* statGroupKeyPaths = [self statisticGroupKeyPaths];
        for (NSString* statGroupID in [statGroupKeyPaths allKeys]) {
            [self addKeyPath:statGroupKeyPaths[statGroupID] forStatisticGroupID:statGroupID];
        }
        
        NSDictionary* groupKeyPaths = [self modifierGroupKeyPaths];
        for (NSString* groupID in [groupKeyPaths allKeys]) {
            [self addKeyPath:groupKeyPaths[groupID] forModifierGroupID:groupID];
        }
        
        [self loadStatistics];
        [self loadStatisticGroups];
        [self loadModifiers];
    }
    
    return self;
}

- (NSDictionary*) statisticKeyPaths { return @{}; }
- (NSDictionary*) statisticGroupKeyPaths { return @{}; }
- (NSDictionary*) modifierGroupKeyPaths { return @{}; }

- (void)loadStatistics { }
- (void)loadStatisticGroups { }
- (void)loadModifiers { }

@end
