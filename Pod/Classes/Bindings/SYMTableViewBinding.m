//
// SYMTableViewBinding.m
//
// Copyright (c) 2015 Dan Hall
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


#import "SYMTableViewBinding.h"
#import "UITableView+SymbiOSis.h"

typedef NS_ENUM(NSUInteger, SYMTableViewCellType){
    SYMTableViewCellTypeContent,
     SYMTableViewCellTypeHeader,
    SYMTableViewCellTypeFooter
};

@implementation SYMTableViewBinding

@dynamic value;
@dynamic view;
@synthesize sourceValue = _sourceValue;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    // If we know about a specific data source for headers and footers (we don't necessarily, since the bindings in the table cell link directly to their own data sources) and a header count hasn't been specified (i.e. it is 0), then we will use the count from the data source as the number of header / footer rows.  Otherwise, just use the numbers specified in the storyboard for the headerCount / footerCount properties.
    
    NSUInteger headerCount = self.headerCount == 0 && self.headerDataSource && [self.headerDataSource.value isKindOfClass:[NSArray class]] ? ((NSArray *)self.headerDataSource.value).count : self.headerCount;
    
     NSUInteger footerCount = self.footerCount == 0 && self.footerDataSource && [self.footerDataSource.value isKindOfClass:[NSArray class]] ? ((NSArray *)self.footerDataSource.value).count : self.footerCount;
    
    return headerCount + footerCount + self.value.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch ([self cellTypeForIndexPath:indexPath]) {
        case SYMTableViewCellTypeHeader :
            return self.headerHeight ? : tableView.rowHeight;
            break;
            
        case SYMTableViewCellTypeFooter :
            return self.footerHeight ? : tableView.rowHeight;
            break;
            
        case SYMTableViewCellTypeContent :
            return self.cellHeight ? : tableView.rowHeight;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ([self cellTypeForIndexPath:indexPath]) {
        case SYMTableViewCellTypeHeader :
            return [tableView dequeueReusableCellWithIdentifier:self.headerReuseIdentifier andDataSourceIndex:indexPath.row];
            break;
            
        case SYMTableViewCellTypeFooter :
            return [tableView dequeueReusableCellWithIdentifier:self.footerReuseIdentifier andDataSourceIndex:indexPath.row - self.headerCount - self.value.count];
            break;
            
        case SYMTableViewCellTypeContent :
            return [tableView dequeueReusableCellWithIdentifier:self.cellReuseIdentifier andDataSourceIndex:indexPath.row - self.headerCount];
            break;
    }
}


-(SYMTableViewCellType)cellTypeForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.headerCount) {
        return SYMTableViewCellTypeHeader;
    }
    else if (indexPath.row >= ([self tableView:nil numberOfRowsInSection:0] - self.footerCount)) {
        return SYMTableViewCellTypeFooter;
    }
    
    else return SYMTableViewCellTypeContent;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    id value;
    
    switch ([self cellTypeForIndexPath:indexPath]) {
        case SYMTableViewCellTypeHeader :
            value = [self.headerDataSourceForSegues valueForIndex:indexPath.row];
            for (SYMCellSelectionResponder *responder in self.headerSelectionResponders) {
                [responder selectedCell:cell atIndexPath:indexPath withValue:value];
            }
            self.sourceValue = value;
            break;
            
        case SYMTableViewCellTypeFooter :
            value = [self.footerDataSourceForSegues valueForIndex:(indexPath.row - self.headerCount - self.value.count)];
            for (SYMCellSelectionResponder *responder in self.footerSelectionResponders) {
                [responder selectedCell:cell atIndexPath:indexPath withValue:value];
            }
            self.sourceValue = value;
            break;
            
        case SYMTableViewCellTypeContent :
            value = [self.cellDataSourceForSegues valueForIndex:(indexPath.row - self.headerCount)];
            for (SYMCellSelectionResponder *responder in self.cellSelectionResponders) {
                [responder selectedCell:cell atIndexPath:indexPath withValue:value];
            }
            self.sourceValue = value;
            break;
    }
}


-(void)awakeFromNib {
    // The below silliness exists because bindings have to subclass UIView in order to be added to prototype cells, but we don't want them visible
    self.hidden = YES;
    self.alpha = 0;
    
    [self setup];
    
    if (self.dataSource) {
        [self.dataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options:NSKeyValueObservingOptionInitial context:nil];
    }
    
    if (self.headerDataSource) {
        [self.headerDataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options: NSKeyValueObservingOptionNew context:nil];
    }
    
    if (self.footerDataSource) {
        [self.footerDataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options: NSKeyValueObservingOptionNew context:nil];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [super setValue:self.dataSource.value];
    [self update];
}


-(BOOL)isContainedInCell:(UIView *)view {
    
    if (!view.superview) {
        return NO;
    }
    
    if ([view.superview isKindOfClass:[UITableViewCell class]] || [self.superview isKindOfClass:[UICollectionViewCell class]]) {
        return YES;
    }
    
    return [self isContainedInCell:view.superview];
}


- (void)dealloc {
    [self.dataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(value))];
    [self.headerDataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(value))];
    [self.footerDataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(value))];
}


-(void)update {
    [self.view reloadData];
}


@end
