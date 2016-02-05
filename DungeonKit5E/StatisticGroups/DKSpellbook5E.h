//
//  DKSpellbook5E.h
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <Foundation/Foundation.h>
#import <DungeonKit/DungeonKit.h>
#import "DKStatisticGroup5E.h"

@interface DKSpellbook5E : DKStatisticGroup5E

@property (nonatomic, strong) DKSetStatistic* cantrips;
@property (nonatomic, strong) DKSetStatistic* firstLevelSpells;
@property (nonatomic, strong) DKSetStatistic* secondLevelSpells;
@property (nonatomic, strong) DKSetStatistic* thirdLevelSpells;
@property (nonatomic, strong) DKSetStatistic* fourthLevelSpells;
@property (nonatomic, strong) DKSetStatistic* fifthLevelSpells;
@property (nonatomic, strong) DKSetStatistic* sixthLevelSpells;
@property (nonatomic, strong) DKSetStatistic* seventhLevelSpells;
@property (nonatomic, strong) DKSetStatistic* eighthLevelSpells;
@property (nonatomic, strong) DKSetStatistic* ninthLevelSpells;

+ (NSString*)statIDForSpellLevel:(NSInteger)spellLevel;

- (DKSetStatistic*)statForSpellLevel:(NSInteger)spellLevel;

@end
