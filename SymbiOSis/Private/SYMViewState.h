//
// SYMViewState.h
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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** These classes are used to copy and store the state of UIView properties and properties for UIView subclasses, so they can be restored at a later time without having the overhead of copying and retaining the entire view.  Used specifically in SymbiOSis framework for resetting bound views to their original storyboard state when preparing cells for reuse */
@interface SYMViewState : NSObject

@property (nonatomic, weak) UIView *view;

@property (nonatomic) BOOL clipsToBounds;
@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) CGFloat alpha;
@property (nonatomic) BOOL hidden;
@property (nonatomic) UIViewContentMode contentMode;
@property (nonatomic) UIColor *tintColor;
@property (nonatomic) UIViewTintAdjustmentMode tintAdjustmentMode;
@property (nonatomic) BOOL userInteractionEnabled;

//Layer properties

@property UIColor *layerBackgroundColor;
@property CGFloat layerCornerRadius;
@property CGFloat layerBorderWidth;
@property UIColor *layerBorderColor;

@end


@interface SYMLabelState : SYMViewState

@property(nonatomic, copy) NSString *text;
@property(nonatomic) UIFont *font;
@property(nonatomic) UIColor *textColor;
@property(nonatomic) UIColor *shadowColor;
@property(nonatomic) CGSize shadowOffset;
@property(nonatomic) NSTextAlignment textAlignment;
@property(nonatomic) NSLineBreakMode lineBreakMode;
@property(nonatomic, copy) NSAttributedString *attributedText;
@property(nonatomic) UIColor *highlightedTextColor;
@property(nonatomic) BOOL highlighted;
@property(nonatomic) BOOL enabled;
@property(nonatomic) NSInteger numberOfLines;
@property(nonatomic) BOOL adjustsFontSizeToFitWidth;
@property(nonatomic) UIBaselineAdjustment baselineAdjustment;
@property(nonatomic) CGFloat minimumScaleFactor;
@property(nonatomic) CGFloat preferredMaxLayoutWidth;

@end


@interface SYMButtonState : SYMViewState

@property(nonatomic) BOOL enabled;
@property(nonatomic) UIEdgeInsets contentEdgeInsets;
@property(nonatomic) UIEdgeInsets titleEdgeInsets;
@property(nonatomic) BOOL reversesTitleShadowWhenHighlighted;
@property(nonatomic) UIEdgeInsets imageEdgeInsets;
@property(nonatomic) BOOL adjustsImageWhenHighlighted;
@property(nonatomic) BOOL adjustsImageWhenDisabled;
@property(nonatomic) BOOL showsTouchWhenHighlighted;
@property(nonatomic) NSMutableDictionary *stateTitles;
@property(nonatomic) NSMutableDictionary *stateTitleColors;
@property(nonatomic) NSMutableDictionary *stateTitleShadowColors;
@property(nonatomic) NSMutableDictionary *stateImages;
@property(nonatomic) NSMutableDictionary *stateBackgroundImages;
@property(nonatomic) NSMutableDictionary *stateAttributedTitles;

@end


@interface SYMImageState : SYMViewState

@property(nonatomic) UIImage *image;
@property(nonatomic) UIImage *highlightedImage;
@property(nonatomic) BOOL highlighted;
@property(nonatomic,copy) NSArray *animationImages;
@property(nonatomic,copy) NSArray *highlightedAnimationImages;
@property(nonatomic) NSTimeInterval animationDuration;
@property(nonatomic) NSInteger animationRepeatCount;

@end


@interface UIView (SYMViewState)

@property (nonatomic) SYMViewState *symViewState;

@end


@interface UILabel (SYMViewState)

@property (nonatomic) SYMLabelState *symViewState;

@end


@interface UIButton (SYMViewState)

@property (nonatomic) SYMButtonState *symViewState;

@end


@interface UIImageView (SYMViewState)

@property (nonatomic) SYMImageState *symViewState;

@end
