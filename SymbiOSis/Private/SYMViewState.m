//
// SYMViewState.m
//
// Copyright (c) 2015 Dan Hall
// Twitter: @_danielhall
// GitHub: https://github.com/daniel-hall
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


#import "SYMViewState.h"


@implementation SYMViewState

@end

@implementation SYMLabelState

@end

@implementation SYMButtonState

@end

@implementation SYMImageState

@end

@implementation UIView (SYMViewState)


- (SYMViewState *)symViewState {
    SYMViewState *viewState;

    if ([self isKindOfClass:[UILabel class]]) {
        viewState = [SYMLabelState new];
    }

    else if ([self isKindOfClass:[UIButton class]]) {
        viewState = [SYMButtonState new];
    }

    else if ([self isKindOfClass:[UIImageView class]]) {
        viewState = [SYMImageState new];
    }

    else {
        viewState = [SYMViewState new];
    }

    viewState.view = self;
    viewState.clipsToBounds = self.clipsToBounds;
    viewState.backgroundColor = self.backgroundColor;
    viewState.alpha = self.alpha;
    viewState.hidden = self.hidden;
    viewState.contentMode = self.contentMode;
    viewState.tintColor = self.tintColor;
    viewState.tintAdjustmentMode = self.tintAdjustmentMode;
    viewState.userInteractionEnabled = self.userInteractionEnabled;
    viewState.layerBackgroundColor = [UIColor colorWithCGColor:self.layer.backgroundColor];
    viewState.layerCornerRadius = self.layer.cornerRadius;
    viewState.layerBorderWidth = self.layer.borderWidth;
    viewState.layerBorderColor = [UIColor colorWithCGColor:self.layer.borderColor];

    return viewState;
}

- (void)setSymViewState:(SYMViewState *)viewState {

    self.clipsToBounds = viewState.clipsToBounds;
    self.backgroundColor = viewState.backgroundColor;
    self.alpha = viewState.alpha;
    self.hidden = viewState.hidden;
    self.contentMode = viewState.contentMode;
    self.tintColor = viewState.tintColor;
    self.tintAdjustmentMode = viewState.tintAdjustmentMode;
    self.userInteractionEnabled = viewState.userInteractionEnabled;
    if ([self.layer isMemberOfClass:[CALayer class]]) {
        self.layer.backgroundColor = viewState.layerBackgroundColor.CGColor;
        self.layer.borderColor = viewState.layerBorderColor.CGColor;
    }
    self.layer.cornerRadius = viewState.layerCornerRadius;
    self.layer.borderWidth = viewState.layerBorderWidth;

    [self layoutIfNeeded];
}

@end


@implementation UILabel (SYMViewState)

- (SYMLabelState *)symViewState {

    SYMLabelState *viewState = (SYMLabelState *) [super symViewState];
    viewState.text = self.text;
    viewState.font = self.font;
    viewState.textColor = self.textColor;
    viewState.shadowColor = self.shadowColor;
    viewState.shadowOffset = self.shadowOffset;
    viewState.textAlignment = self.textAlignment;
    viewState.lineBreakMode = self.lineBreakMode;
    viewState.attributedText = self.attributedText;
    viewState.highlightedTextColor = self.highlightedTextColor;
    viewState.highlighted = self.highlighted;
    viewState.enabled = self.enabled;
    viewState.numberOfLines = self.numberOfLines;
    viewState.adjustsFontSizeToFitWidth = self.adjustsFontSizeToFitWidth;
    viewState.baselineAdjustment = self.baselineAdjustment;
    viewState.minimumScaleFactor = self.minimumScaleFactor;
    viewState.preferredMaxLayoutWidth = self.preferredMaxLayoutWidth;

    return viewState;
}

- (void)setSymViewState:(SYMLabelState *)viewState {
    self.text = viewState.text;
    self.font = viewState.font;
    self.textColor = viewState.textColor;
    self.shadowColor = viewState.shadowColor;
    self.shadowOffset = viewState.shadowOffset;
    self.textAlignment = viewState.textAlignment;
    self.lineBreakMode= viewState.lineBreakMode;
    self.attributedText = viewState.attributedText;
    self.highlightedTextColor = viewState.highlightedTextColor;
    self.highlighted = viewState.highlighted;
    self.enabled = viewState.enabled;
    self.numberOfLines = viewState.numberOfLines;
    self.adjustsFontSizeToFitWidth = viewState.adjustsFontSizeToFitWidth;
    self.baselineAdjustment = viewState.baselineAdjustment;
    self.minimumScaleFactor = viewState.minimumScaleFactor;
    self.preferredMaxLayoutWidth = viewState.preferredMaxLayoutWidth;
    [super setSymViewState:viewState];
}


@end


@implementation UIButton (SYMViewState)


- (SYMButtonState *)symViewState {
    SYMButtonState *viewState = (SYMButtonState *) [super symViewState];

    viewState.enabled = self.enabled;
    viewState.contentEdgeInsets = self.contentEdgeInsets;
    viewState.titleEdgeInsets = self.titleEdgeInsets;
    viewState.reversesTitleShadowWhenHighlighted = self.reversesTitleShadowWhenHighlighted;
    viewState.imageEdgeInsets = self.imageEdgeInsets;
    viewState.adjustsImageWhenHighlighted = self.adjustsImageWhenHighlighted;
    viewState.adjustsImageWhenDisabled = self.adjustsImageWhenDisabled;
    viewState.showsTouchWhenHighlighted = self.showsTouchWhenHighlighted;

    viewState.stateTitles = [NSMutableDictionary dictionary];
    viewState.stateTitleColors = [NSMutableDictionary dictionary];
    viewState.stateTitleShadowColors = [NSMutableDictionary dictionary];
    viewState.stateImages = [NSMutableDictionary dictionary];
    viewState.stateBackgroundImages = [NSMutableDictionary dictionary];
    viewState.stateAttributedTitles = [NSMutableDictionary dictionary];

    [self readToTitles:viewState.stateTitles titleColors:viewState.stateTitleColors titleShadowColors:viewState.stateTitleShadowColors images:viewState.stateImages backgroundImages:viewState.stateBackgroundImages attributedTitles:viewState.stateAttributedTitles forState:UIControlStateNormal];
    [self readToTitles:viewState.stateTitles titleColors:viewState.stateTitleColors titleShadowColors:viewState.stateTitleShadowColors images:viewState.stateImages backgroundImages:viewState.stateBackgroundImages attributedTitles:viewState.stateAttributedTitles forState:UIControlStateDisabled];
    [self readToTitles:viewState.stateTitles titleColors:viewState.stateTitleColors titleShadowColors:viewState.stateTitleShadowColors images:viewState.stateImages backgroundImages:viewState.stateBackgroundImages attributedTitles:viewState.stateAttributedTitles forState:UIControlStateHighlighted];
    [self readToTitles:viewState.stateTitles titleColors:viewState.stateTitleColors titleShadowColors:viewState.stateTitleShadowColors images:viewState.stateImages backgroundImages:viewState.stateBackgroundImages attributedTitles:viewState.stateAttributedTitles forState:UIControlStateSelected];

    return viewState;
}

- (void)setSymViewState:(SYMButtonState *)viewState {
    self.enabled = viewState.enabled;
    self.contentEdgeInsets = viewState.contentEdgeInsets;
    self.titleEdgeInsets = viewState.titleEdgeInsets;
    self.reversesTitleShadowWhenHighlighted = viewState.reversesTitleShadowWhenHighlighted;
    self.imageEdgeInsets = viewState.imageEdgeInsets;
    self.adjustsImageWhenHighlighted = viewState.adjustsImageWhenHighlighted;
    self.adjustsImageWhenDisabled = viewState.adjustsImageWhenDisabled;
    self.showsTouchWhenHighlighted = viewState.showsTouchWhenHighlighted;

    viewState.stateTitles = [NSMutableDictionary dictionary];
    viewState.stateTitleColors = [NSMutableDictionary dictionary];
    viewState.stateTitleShadowColors = [NSMutableDictionary dictionary];
    viewState.stateImages = [NSMutableDictionary dictionary];
    viewState.stateBackgroundImages = [NSMutableDictionary dictionary];
    viewState.stateAttributedTitles = [NSMutableDictionary dictionary];

    [self writeFromTitles:viewState.stateTitles titleColors:viewState.stateTitleColors titleShadowColors:viewState.stateTitleShadowColors images:viewState.stateImages backgroundImages:viewState.stateBackgroundImages attributedTitles:viewState.stateAttributedTitles forState:UIControlStateNormal];
    [self writeFromTitles:viewState.stateTitles titleColors:viewState.stateTitleColors titleShadowColors:viewState.stateTitleShadowColors images:viewState.stateImages backgroundImages:viewState.stateBackgroundImages attributedTitles:viewState.stateAttributedTitles forState:UIControlStateDisabled];
    [self writeFromTitles:viewState.stateTitles titleColors:viewState.stateTitleColors titleShadowColors:viewState.stateTitleShadowColors images:viewState.stateImages backgroundImages:viewState.stateBackgroundImages attributedTitles:viewState.stateAttributedTitles forState:UIControlStateHighlighted];
    [self writeFromTitles:viewState.stateTitles titleColors:viewState.stateTitleColors titleShadowColors:viewState.stateTitleShadowColors images:viewState.stateImages backgroundImages:viewState.stateBackgroundImages attributedTitles:viewState.stateAttributedTitles forState:UIControlStateSelected];

    [super setSymViewState:viewState];
}

-(void)readToTitles:(NSMutableDictionary *)titles titleColors:(NSMutableDictionary *)titleColors titleShadowColors:(NSMutableDictionary *)titleShadowColors images:(NSMutableDictionary *)images backgroundImages:(NSMutableDictionary *)backgroundImages attributedTitles:(NSMutableDictionary *)attributedTitles forState:(UIControlState)state {
    if ([self titleForState:state]) {
        titles[@(state)] = [self titleForState:state];
    }
    if ([self titleColorForState:state]) {
        titleColors[@(state)] = [self titleColorForState:state];
    }
    if ([self titleShadowColorForState:state]) {
        titleShadowColors[@(state)] = [self titleShadowColorForState:state];
    }
    if ([self imageForState:state]) {
        images[@(state)] = [self imageForState:state];
    }
    if ([self backgroundImageForState:state]) {
        backgroundImages[@(state)] = [self backgroundImageForState:state];
    }
    if ([self attributedTitleForState:state]) {
        attributedTitles[@(state)] = [self attributedTitleForState:state];
    }
}

-(void)writeFromTitles:(NSMutableDictionary *)titles titleColors:(NSMutableDictionary *)titleColors titleShadowColors:(NSMutableDictionary *)titleShadowColors images:(NSMutableDictionary *)images backgroundImages:(NSMutableDictionary *)backgroundImages attributedTitles:(NSMutableDictionary *)attributedTitles forState:(UIControlState)state {
    [self setTitle:titles[@(state)] forState:state];
    [self setTitleColor:titleColors[@(state)] forState:state];
    [self setTitleShadowColor:titleShadowColors[@(state)] forState:state];
    [self setImage:images[@(state)] forState:state];
    [self setBackgroundImage:backgroundImages[@(state)] forState:state];
    [self setAttributedTitle:attributedTitles[@(state)] forState:state];
}


@end


@implementation UIImageView (SYMViewState)


- (SYMImageState *)symViewState {

    SYMImageState *viewState = (SYMImageState *) [super symViewState];
    viewState.image = self.image;
    viewState.highlightedImage = self.highlightedImage;
    viewState.highlighted = self.highlighted;
    viewState.animationImages = self.animationImages;
    viewState.highlightedAnimationImages = self.highlightedAnimationImages;
    viewState.animationDuration = self.animationDuration;
    viewState.animationRepeatCount = self.animationRepeatCount;

    return viewState;
}

- (void)setSymViewState:(SYMImageState *)viewState {
    self.image = viewState.image;
    self.highlightedImage = viewState.highlightedImage;
    self.highlighted = viewState.highlighted;
    self.animationImages = viewState.animationImages;
    self.highlightedAnimationImages = viewState.highlightedAnimationImages;
    self.animationDuration = viewState.animationDuration;
    self.animationRepeatCount = viewState.animationRepeatCount;
    [super setSymViewState:viewState];
}


@end
