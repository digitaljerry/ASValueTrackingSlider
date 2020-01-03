//
//  ASValuePopUpViewDetailed.h
//  ASValueTrackingSlider
//
//  Created by Mihai-Ionut Ghete on 12/30/19.
//

#import <UIKit/UIKit.h>
#import "ASSliderDetails.h"

NS_ASSUME_NONNULL_BEGIN

@interface ASValuePopUpViewDetailed : UIView

@property (assign, nonatomic) UIImage *coverImage;

- (UIColor *)color;
- (void)setColor:(UIColor *)color;
- (UIColor *)opaqueColor;

- (void)setTextColor:(UIColor *)textColor;
- (void)setFont:(UIFont *)font;
- (void)setText:(NSString *)text;

- (void)setAnimatedColors:(NSArray *)animatedColors withKeyTimes:(NSArray *)keyTimes;

- (void)setAnimationOffset:(CGFloat)animOffset returnColor:(void (^)(UIColor *opaqueReturnColor))block;

- (void)setFrame:(CGRect)frame arrowOffset:(CGFloat)arrowOffset details:(ASSliderDetails *)details;

- (void)animateBlock:(void (^)(CFTimeInterval duration))block;

- (CGSize)popUpSizeForString:(NSString *)string;

- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated completionBlock:(void (^)(void))block;

@end

NS_ASSUME_NONNULL_END
