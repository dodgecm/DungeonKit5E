//
//  DKLanguage5E.m
//  DungeonKit
//
//  Created by Christopher Dodge on 7/8/15.
//  Copyright (c) 2015 Dodge. All rights reserved.
//

#import "DKLanguage5E.h"
#import "DKModifierBuilder.h"
#import "DKModifierGroupTags5E.h"
#import "DKStatisticIDs5E.h"

@implementation DKLanguageBuilder5E

+ (DKChoiceModifierGroup*)languageChoiceWithExplanation:(NSString*)explanation {
    DKChoiceModifierGroup* languageGroup = [[DKSingleChoiceModifierGroup alloc] initWithTag:DKChoiceLanguage];
    
    NSArray* languageNames = @[ @"Common",
                                @"Dwarvish",
                                @"Elvish",
                                @"Giant",
                                @"Gnomish",
                                @"Goblin",
                                @"Halfling",
                                @"Orc",
                                @"Abyssal",
                                @"Celestial",
                                @"Draconic",
                                @"Deep Speech",
                                @"Infernal",
                                @"Primordial",
                                @"Sylvan",
                                @"Undercommon" ];
    for (NSString* language in languageNames) {
        [languageGroup addModifier:[DKModifier setModifierWithAppendedObject:language explanation:explanation]
                    forStatisticID:DKStatIDLanguages];
    }
    
    return languageGroup;
}

@end
