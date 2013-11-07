//
//  UIView+Badge.m
//  MLTBadgedView
//
//  Created by Robert Rasmussen on 10/2/10.
//  Copyright 2010 Moonlight Tower. All rights reserved.
//

#import "UIView+Badge.h"

static int MLT_BADGE_TAG = 6546;

@implementation MLTBadgeView

@synthesize verticalAlign = _vertAlign;
@synthesize horizontalAlign = _horAlign;
@synthesize centerOffset = _centerOffset;

-(void)dealloc {
    self.font = nil;
    self.badgeColor = nil;
    self.textColor = nil;
    self.outlineColor = nil;
}

-(id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.font = [UIFont boldSystemFontOfSize:13.0];
        self.badgeColor = [UIColor redColor];
        self.textColor = [UIColor whiteColor];
        self.outlineColor = [UIColor whiteColor];
        self.outlineWidth = 2.0;
        self.backgroundColor = [UIColor clearColor];
        self.minimumDiameter = 20.0;
        self.verticalAlign = MLTVerticalAlignmentCenter;
        self.horizontalAlign = MLTHorizontalAlignmentLeft;
        self.opaque = YES;
    }
    return self;
}

- (void)setVertAlign:(MLTVerticalAlignment)verticalAlign {
    _vertAlign = verticalAlign;
    [self recalculatePositions];
}

- (void)setHorAlign:(MLTHorizontalAlignment)horizontalAlign {
    _horAlign = horizontalAlign;
    [self recalculatePositions];
}

- (void)setCenterOffset:(CGSize)margin {
    _centerOffset = margin;
    [self recalculatePositions];
}

- (void)recalculatePositions
{
    if(self.badgeValue != 0 || self.displayWhenZero) {
        NSDictionary * attributes = @{
                                      NSFontAttributeName : self.font
                                      };
        NSString * badgeValue = [NSString stringWithFormat:@"%d", self.badgeValue];
        CGSize numberSize = [badgeValue sizeWithAttributes:attributes];
        
        float diameterForNumber = numberSize.width > numberSize.height ? numberSize.width : numberSize.height;
        float diameter = diameterForNumber + 6 + (self.outlineWidth * 2);
        if(diameter < self.minimumDiameter) {
            diameter = self.minimumDiameter;
        }
        
        //We know the size of the badge circle. If no explicit placement for the badge has been set, we'll
        //see if it works on the right side first.
        CGPoint center;
        
        CGFloat (*pHFunc)(CGRect);
        CGFloat (*pVFunc)(CGRect);
        
        switch (self.horizontalAlign) {
            case MLTHorizontalAlignmentCenter:
                pHFunc = &CGRectGetMidX;
                break;
            case MLTHorizontalAlignmentLeft:
                pHFunc = &CGRectGetMinX;
                break;
            case MLTHorizontalAlignmentRight:
                pHFunc = &CGRectGetMaxX;
                break;
            default:
                break;
        }
        
        switch (self.verticalAlign) {
            case MLTVerticalAlignmentBottom:
                pVFunc = &CGRectGetMaxY;
                break;
            case MLTVerticalAlignmentCenter:
                pVFunc = &CGRectGetMidY;
                break;
            case MLTVerticalAlignmentTop:
                pVFunc = &CGRectGetMinY;
                break;
            default:
                break;
        }
        
        center.x = pHFunc(self.superview.bounds) + self.centerOffset.width;
        center.y = pVFunc(self.superview.bounds) + self.centerOffset.height;
        
        self.bounds = CGRectMake(0, 0, diameter, diameter);
        self.center = center;
    } else {
        self.frame = CGRectZero;
    }
    
    [self setNeedsDisplay];
}

- (void)setBadgeValue:(NSInteger)value {
    _badgeValue = value;
    [self recalculatePositions];
    [self setNeedsDisplay];
}

-(void)setMinimumDiameter:(float)f {
    _minimumDiameter = f;
    self.bounds = CGRectMake(0, 0, f, f);
}

-(void)drawRect:(CGRect)rect {
    if(self.badgeValue != 0 || self.displayWhenZero) {
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.outlineColor set];
        CGContextFillEllipseInRect(context, CGRectInset(rect, 1, 1));
        [self.badgeColor set];
        CGContextFillEllipseInRect(context, CGRectInset(rect, self.outlineWidth + 1, self.outlineWidth + 1));
        [self.textColor set];
        
        NSDictionary * attributes = @{
                                      NSFontAttributeName : self.font
                                      };
        NSString * badgeValue = [NSString stringWithFormat:@"%d", self.badgeValue];
        CGSize numberSize = [badgeValue sizeWithAttributes:attributes];
        
        
        CGRect drawableRect = CGRectMake(self.outlineWidth + 3, (rect.size.height / 2.0) - (numberSize.height / 2.0), rect.size.width - (self.outlineWidth * 2) - 6, numberSize.height);
        
        NSMutableParagraphStyle * paragraph = [NSMutableParagraphStyle new];
        paragraph.lineBreakMode = NSLineBreakByClipping;
        paragraph.alignment = NSTextAlignmentCenter;
        
        NSDictionary * drawRectAttributes = @{
                                              NSFontAttributeName: self.font,
                                              NSForegroundColorAttributeName : self.textColor,
                                              NSParagraphStyleAttributeName : paragraph
                                              };
        
        [badgeValue drawInRect:drawableRect withAttributes:drawRectAttributes];
    }
}

@end


@implementation UIView(Badged)

-(MLTBadgeView *)badge
{
    UIView *existingView = [self viewWithTag:MLT_BADGE_TAG];
    if(existingView) {
        if(![existingView isKindOfClass:[MLTBadgeView class]]) {
            NSLog(@"Unexpected view of class %@ found with badge tag.", NSStringFromClass([existingView class]));
            return nil;
        } else {
            return (MLTBadgeView *)existingView;
        }
    }
    MLTBadgeView *badgeView = [[MLTBadgeView alloc]initWithFrame:CGRectZero];
    badgeView.tag = MLT_BADGE_TAG;
    [self addSubview:badgeView];
    return badgeView;
}

@end
