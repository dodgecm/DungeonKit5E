//
//  DKProficientStatistic.h
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <Foundation/Foundation.h>
#import <DungeonKit/DungeonKit.h>

@class DKCharacter5E;

@interface DKProficientStatistic : DKNumericStatistic <NSCoding>

/** The proficiency level of this statistic.  A standard proficiency level value is 1.  A value of 2 corresponds with a double proficiency. 
 The character's proficiency bonus will be added to this statistic once for each proficiency level. */
@property (nonatomic, strong, readonly) DKNumericStatistic* proficiencyLevel;

+ (id)statisticWithInt:(int)base __unavailable;
+ (id)statisticWithBase:(int)base proficiencyBonus:(DKNumericStatistic*)proficiencyBonus;
- (id)initWithInt:(int)base __unavailable;
- (id)initWithBase:(int)base proficiencyBonus:(DKNumericStatistic*)proficiencyBonus;

@end
