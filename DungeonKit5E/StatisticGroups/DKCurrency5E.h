//
//  DKCurrency5E.h
//  DungeonKit
//
//  Copyright (c) 2015 Chris Dodge
//

#import <Foundation/Foundation.h>
#import <DungeonKit/DungeonKit.h>
#import "DKStatisticGroup5E.h"

@interface DKCurrency5E : DKStatisticGroup5E

@property (nonatomic, strong) DKNumericStatistic* copper;
@property (nonatomic, strong) DKNumericStatistic* silver;
@property (nonatomic, strong) DKNumericStatistic* electrum;
@property (nonatomic, strong) DKNumericStatistic* gold;
@property (nonatomic, strong) DKNumericStatistic* platinum;

@end
