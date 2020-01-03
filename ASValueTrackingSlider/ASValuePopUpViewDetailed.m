//
//  ASValuePopUpViewDetailed.m
//  ASValueTrackingSlider
//
//  Created by Mihai-Ionut Ghete on 12/30/19.
//

#import "ASValuePopUpViewDetailed.h"

@implementation CALayer (ASAnimationAdditions)

- (void)animateKey:(NSString *)animationName fromValue:(id)fromValue toValue:(id)toValue
         customize:(void (^)(CABasicAnimation *animation))block
{
    [self setValue:toValue forKey:animationName];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:animationName];
    anim.fromValue = fromValue ?: [self.presentationLayer valueForKey:animationName];
    anim.toValue = toValue;
    if (block) block(anim);
    [self addAnimation:anim forKey:animationName];
}
@end

NSString *const SliderFillColorAnim2 = @"fillColor";

@interface ASValuePopUpViewDetailed() {
    BOOL _shouldAnimate;
    CFTimeInterval _animDuration;
    
    NSMutableAttributedString *_attributedString;
    CAShapeLayer *_pathLayer;
    
    CATextLayer *_textLayer;
    CGFloat _arrowCenterOffset;
    
    // never actually visible, its purpose is to interpolate color values for the popUpView color animation
    // using shape layer because it has a 'fillColor' property which is consistent with _backgroundLayer
    CAShapeLayer *_colorAnimLayer;
    CGRect arrowOriginalFrame;
}
@property (weak, nonatomic) IBOutlet UILabel *chapterTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) UIView *arrowView;

@end

@implementation ASValuePopUpViewDetailed

+ (Class)layerClass {
    return [CAShapeLayer class];
}

// if ivar _shouldAnimate) is YES then return an animation
// otherwise return NSNull (no animation)
- (id <CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)key
{
    if (_shouldAnimate) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
        anim.beginTime = CACurrentMediaTime();
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        anim.fromValue = [layer.presentationLayer valueForKey:key];
        anim.duration = _animDuration;
        return anim;
    } else return (id <CAAction>)[NSNull null];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    [self applyShadow];
    
    NSBundle *bundle = [NSBundle bundleForClass: [self class]];
    
     [bundle loadNibNamed: @"ASValuePopUpViewDetailed" owner: self options: nil];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview: self.contentView];
    NSDictionary *views = @{@"contentView":self.contentView};
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[contentView]|" options: 0 metrics: nil views: views]];
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[contentView]-20-|" options: 0 metrics: nil views: views]];
    [self drawArrow];
}

- (void)drawArrow {
    UIBezierPath* trianglePath = [UIBezierPath bezierPath];
    /*
     a    b
     -----
     \   /
      \ /
       c
     */
    
    CGPoint a = CGPointMake(0, 0);
    CGPoint b = CGPointMake(20, 0);
    CGPoint c = CGPointMake(10, 10);
    
    [trianglePath moveToPoint:a];
    [trianglePath addLineToPoint:b];
    [trianglePath addLineToPoint:c];
    [trianglePath closePath];

    CAShapeLayer *triangleMaskLayer = [CAShapeLayer layer];
    [triangleMaskLayer setPath:trianglePath.CGPath];

    arrowOriginalFrame = CGRectMake(self.center.x-10.0,self.frame.size.height-21, 20, 10);
    UIView *view = [[UIView alloc] initWithFrame:arrowOriginalFrame];

    view.backgroundColor = [UIColor colorWithWhite:1 alpha:1.0];
    view.layer.mask = triangleMaskLayer;
    [self addSubview:view];
    self.arrowView = view;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.layer.cornerRadius = 10.0;
    self.coverImageView.layer.cornerRadius = 10.0;
//    self.layer.masksToBounds = YES;
    [self applyShadow];
}

- (void)applyShadow {
    self.contentView.layer.shadowColor = UIColor.blackColor.CGColor;
    self.contentView.layer.shadowOpacity = 0.8;
    self.contentView.layer.shadowRadius = 30;
}

- (void)setAnimationOffset:(CGFloat)animOffset returnColor:(void (^)(UIColor *opaqueReturnColor))block
{
    if ([_colorAnimLayer animationForKey:SliderFillColorAnim2]) {
        _colorAnimLayer.timeOffset = animOffset;
        _pathLayer.fillColor = [_colorAnimLayer.presentationLayer fillColor];
        block([self opaqueColor]);
    }
}

- (void)setFrame:(CGRect)frame arrowOffset:(CGFloat)arrowOffset details:(ASSliderDetails *)details
{
    _arrowCenterOffset = arrowOffset;
    
    CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, self.frame.size.width, self.frame.size.height);
    self.frame = newFrame;
    
    CGRect arrowFrame = CGRectMake(arrowOriginalFrame.origin.x+arrowOffset, arrowOriginalFrame.origin.y, arrowOriginalFrame.size.width, arrowOriginalFrame.size.height);
    _arrowView.frame = arrowFrame;
    [self setText: details.title];
    self.positionLabel.text = [NSString stringWithFormat:@"%.0f\%%", details.percentage*100];
}

- (void)setText:(NSString *)text {
    self.chapterTitleLabel.text = text;
}

- (void)setCoverImage:(UIImage *)coverImage {
    _coverImage = coverImage;
    self.coverImageView = coverImage;
}

// _shouldAnimate = YES; causes 'actionForLayer:' to return an animation for layer property changes
// call the supplied block, then set _shouldAnimate back to NO
- (void)animateBlock:(void (^)(CFTimeInterval duration))block
{
    _shouldAnimate = YES;
    _animDuration = 0.5;
    
    CAAnimation *anim = [self.layer animationForKey:@"position"];
    if ((anim)) { // if previous animation hasn't finished reduce the time of new animation
        CFTimeInterval elapsedTime = MIN(CACurrentMediaTime() - anim.beginTime, anim.duration);
        _animDuration = _animDuration * elapsedTime / anim.duration;
    }
    
    block(_animDuration);
    _shouldAnimate = NO;
}

- (void)showAnimated:(BOOL)animated
{
    if (!animated) {
        self.layer.opacity = 1.0;
        return;
    }
    
    [CATransaction begin]; {
        // start the transform animation from scale 0.5, or its current value if it's already running
        NSValue *fromValue = [self.layer animationForKey:@"transform"] ? [self.layer.presentationLayer valueForKey:@"transform"] : [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1)];
        
        [self.layer animateKey:@"transform" fromValue:fromValue toValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]
                     customize:^(CABasicAnimation *animation) {
                         animation.duration = 0.4;
                         animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.8 :2.5 :0.35 :0.5];
         }];
        
        [self.layer animateKey:@"opacity" fromValue:nil toValue:@1.0 customize:^(CABasicAnimation *animation) {
            animation.duration = 0.1;
        }];
    } [CATransaction commit];
}

- (void)hideAnimated:(BOOL)animated completionBlock:(void (^)(void))block
{
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            block();
            self.layer.transform = CATransform3DIdentity;
        }];
        if (animated) {
            [self.layer animateKey:@"transform" fromValue:nil
                           toValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1)]
                         customize:^(CABasicAnimation *animation) {
                             animation.duration = 0.55;
                             animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.1 :-2 :0.3 :3];
                         }];
            
            [self.layer animateKey:@"opacity" fromValue:nil toValue:@0.0 customize:^(CABasicAnimation *animation) {
                animation.duration = 0.75;
            }];
        } else { // not animated - just set opacity to 0.0
            self.layer.opacity = 0.0;
        }
    } [CATransaction commit];
}

#pragma mark - CAAnimation delegate

// set the speed to zero to freeze the animation and set the offset to the correct value
// the animation can now be updated manually by explicity setting its 'timeOffset'
//- (void)animationDidStart:(CAAnimation *)animation
//{
//    _colorAnimLayer.speed = 0.0;
//    _colorAnimLayer.timeOffset = [self.delegate currentValueOffset];
//    
//    _pathLayer.fillColor = [_colorAnimLayer.presentationLayer fillColor];
//    [self.delegate colorDidUpdate:[self opaqueColor]];
//}

@end
