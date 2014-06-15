//
//  LYRSampleParticipant.m
//  LYRSampleData
//
//  Created by Kevin Coleman on 6/4/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRSampleParticipant.h"

@implementation LYRSampleParticipant

@synthesize fullName = _fullName;
@synthesize identifier = _identifier;

+ (NSSet *)participants:(int)number
{
    NSMutableSet *participants = [[NSMutableSet alloc] init];
    for (int i = 0; i < number; i++) {
        [participants addObject:[self participantWithNumber:i]];
    }
    return participants;
}

+ (instancetype)participantWithNumber:(int)number
{
    LYRSampleParticipant *participant = [[LYRSampleParticipant alloc] init];
    switch (number) {
        case 0:
            participant.fullName = @"Kevin Coleman";
            break;
        case 1:
            participant.fullName = @"Drew Moxon";
            break;
        case 2:
            participant.fullName = @"Blake Watters";
            break;
        case 3:
            participant.fullName = @"Nil Gradisnik";
            break;
        case 4:
            participant.fullName = @"Klemen Verdnik";
            break;
        case 5:
            participant.fullName = @"Andy Vyrros";
            break;
        case 6:
            participant.fullName = @"Tomza Stolfa";
            break;
        case 7:
            participant.fullName = @"Ron Palmeri";
            break;
        case 8:
            participant.fullName = @"Stevie Case";
            break;
        case 9:
            participant.fullName = @"Sara Wood";
            break;
        case 10:
            participant.fullName = @"Steven Jones";
            break;
        default:
            break;
    }
    participant.identifier = [NSString stringWithFormat:@"%d", number];
    return participant;
}

@end

