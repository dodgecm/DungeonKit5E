//
//  DKCurrency5E.m
//  DungeonKit
//
//  Created by Christopher Dodge on 1/23/15.
//  Copyright (c) 2015 Dodge. All rights reserved.
//

#import "DKCurrency5E.h"
#import "DKStatisticIDs5E.h"

@implementation DKCurrency5E

@synthesize copper = _copper;
@synthesize silver = _silver;
@synthesize electrum = _electrum;
@synthesize gold = _gold;
@synthesize platinum = _platinum;

- (NSDictionary*) statisticKeyPaths {
    return @{
             DKStatIDCurrencyCopper: @"copper",
             DKStatIDCurrencySilver: @"silver",
             DKStatIDCurrencyElectrum: @"electrum",
             DKStatIDCurrencyGold: @"gold",
             DKStatIDCurrencyPlatinum: @"platinum",
             };
}

- (void)loadStatistics {
    
    self.copper = [DKNumericStatistic statisticWithInt:0];
    self.silver = [DKNumericStatistic statisticWithInt:0];
    self.electrum = [DKNumericStatistic statisticWithInt:0];
    self.gold = [DKNumericStatistic statisticWithInt:0];
    self.platinum = [DKNumericStatistic statisticWithInt:0];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"PP: %i GP: %i EP: %i SP: %i CP: %i",
            _platinum.value.intValue, _gold.value.intValue,
            _electrum.value.intValue, _silver.value.intValue, _copper.value.intValue];
}

@end
