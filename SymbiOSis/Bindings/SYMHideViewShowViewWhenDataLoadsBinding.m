//
// SYMHideViewShowViewWhenDataLoadsBinding.m
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


#import "SYMHideViewShowViewWhenDataLoadsBinding.h"


@implementation SYMHideViewShowViewWhenDataLoadsBinding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.allowEmptyArrays = YES;
    return self;
}

- (void)awakeFromNib {
    // The below silliness exists because bindings have to subclass UIView in order to be added to prototype cells, but we don't want them visible
    self.frame = CGRectZero;
    self.backgroundColor = [UIColor clearColor];
    self.hidden = YES;
    self.alpha = 0;

    __weak typeof(self) weakSelf = self;
    for (SYMDataSource *dataSource in self.dataSources) {
        [dataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    }
    if (self.timeoutInterval.floatValue > .01) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf checkIfTimedOut];
        });
    }
}

- (void)checkIfTimedOut {
    for (SYMDataSource *dataSource in self.dataSources) {
        if ([dataSource valueForIndexPath:self.dataSourceIndexPath] == nil) {
            for (UIView *timeoutView in self.timeoutViews) {
                timeoutView.hidden = NO;
            }
            return;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self resetViews];
}

- (void)handleDataLoaded {
    for (UIView *timeoutView in self.timeoutViews) {
        timeoutView.hidden = YES;
    }

    for (UIView *hideView in self.viewsToHide) {
        hideView.hidden = YES;
    }

    for (UIView *showView in self.viewsToUnhide) {
        showView.hidden = NO;
    }
}

- (void)resetViews {
    __weak typeof(self) weakSelf = self;

    for (UIView *hideView in self.viewsToHide) {
        hideView.hidden = NO;
    }

    for (UIView *showView in self.viewsToUnhide) {
        showView.hidden = YES;
    }

    for (SYMDataSource *dataSource in self.dataSources) {
        if (dataSource.value == nil || (!self.allowEmptyArrays && [dataSource.value isKindOfClass:[NSArray class]] && ((NSArray *) dataSource.value).count == 0)) {
            return;
        }
    }

    [self handleDataLoaded];
}

- (void)dealloc {
    for (SYMDataSource *dataSource in self.dataSources) {
        [dataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(value))];
    }
}

@end
