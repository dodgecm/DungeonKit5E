//
//  DKStatisticGroup5E.h
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <Foundation/Foundation.h>
#import <DungeonKit/DKStatisticGroup.h>

@interface DKStatisticGroup5E : DKStatisticGroup

- (NSDictionary*) statisticKeyPaths;
- (NSDictionary*) statisticGroupKeyPaths;
- (NSDictionary*) modifierGroupKeyPaths;

- (void)loadStatistics;
- (void)loadStatisticGroups;
- (void)loadModifiers;

@end
