//
//  DKProficientStatistic.m
//  DungeonKit
//
//  Created by Christopher Dodge on 1/16/15.
//  Copyright (c) 2015 Dodge. All rights reserved.
//

#import "DKProficientStatistic.h"
#import "DKCharacter5E.h"
#import "DKModifierBuilder.h"

@implementation DKProficientStatistic

@synthesize proficiencyLevel = _proficiencyLevel;

+ (id)statisticWithBase:(int)base proficiencyBonus:(DKNumericStatistic*)proficiencyBonus {
    
    DKProficientStatistic* newStat = [[[self class] alloc] initWithBase:base proficiencyBonus:proficiencyBonus];
    return newStat;
}

- (id)initWithBase:(int)base proficiencyBonus:(DKNumericStatistic*)proficiencyBonus {
    
    self = [super initWithInt:base];
    if (self) {
        _proficiencyLevel = [DKNumericStatistic statisticWithInt:0];
        DKModifier* proficiencyModifier = [[DKModifier alloc] initWithDependencies: @{ @"bonus": proficiencyBonus,
                                                                                       @"level": _proficiencyLevel }
                                                                             value:[NSExpression expressionWithFormat:@"$bonus*$level"]
                                                                           enabled:nil
                                                                          priority:kDKModifierPriority_Additive
                                                                        expression:[DKExpressionBuilder additionExpression]];
        [self applyModifier:proficiencyModifier];
    }
    return self;
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_proficiencyLevel forKey:@"proficiencyLevel"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _proficiencyLevel = [aDecoder decodeObjectForKey:@"proficiencyLevel"];
    }
    
    return self;
}

@end
