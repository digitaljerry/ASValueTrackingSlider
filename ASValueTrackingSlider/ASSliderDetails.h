//
//  ASSliderDetails.h
//  ASValueTrackingSlider
//
//  Created by Mihai-Ionut Ghete on 12/30/19.
//

#import <Foundation/Foundation.h>

@interface ASSliderDetails : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) double percentage;

+ (ASSliderDetails*)detailsFromDict:(NSDictionary *)dict;

@end
