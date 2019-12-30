//
//  ASSliderDetails.m
//  ASValueTrackingSlider
//
//  Created by Mihai-Ionut Ghete on 12/30/19.
//

#import "ASSliderDetails.h"

@implementation ASSliderDetails

+ (ASSliderDetails*)detailsFromDict:(NSDictionary *)dict {
    ASSliderDetails *details = [ASSliderDetails new];
    details.title = dict[@"title"];
    details.percentage = [dict[@"percentage"] doubleValue];
    return details;
}

@end
