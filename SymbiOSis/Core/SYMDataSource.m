//
// SYMDataSource.m
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


#import "SYMDataSource.h"

@interface SYMDataSource ()

@end

@implementation SYMDataSource

@synthesize sourceValue = _sourceValue;
@synthesize value = _value;

- (void)awakeFromNib {
    for (SYMDataSource *dataSource in self.sectionDataSources) {
        [dataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    }

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self update];
}


-(void)update {
    NSMutableArray *arrayOfSections = [NSMutableArray arrayWithCapacity:self.sectionDataSources.count];
    for (NSUInteger index = 0; index < self.sectionDataSources.count; index++) {
        NSArray *sectionValue = ((SYMDataSource *)self.sectionDataSources[index]).value;
        if ([sectionValue isKindOfClass:[NSArray class]] && sectionValue.count) {
            [arrayOfSections addObject:sectionValue];
        }
    }
    self.value = [arrayOfSections copy];
}


-(id)valueForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath != nil && [self.value isKindOfClass:[NSArray class]]) {

        //handle the case where our value is a one-dimensional array of values that populate a single table view / collection view section, or a single picker view component.
        if (indexPath.section == 0) {
            NSArray *valueArray = self.value;
            if (valueArray.count > 0 && ![valueArray[0] isKindOfClass:[NSArray class]] && indexPath.item < valueArray.count) {
                return valueArray[indexPath.item];
            }
        }

        //otherwise, attempt to handle our value as a two dimensional array with sections and rows / items, and safely retrieve the value at self.value[indexPath.section][indexPath.item].
        NSArray *sections = self.value;
        if (indexPath.section < sections.count && [sections[indexPath.section] isKindOfClass:[NSArray class]]) {
            NSArray *items = sections[indexPath.section];
            if (indexPath.item < items.count) {
                return items[indexPath.item];
            }
        }

        //if there is no corresponding value for the indexPath provided, return nil
        return nil;
    }

    //if our value isn't an array at all, or no indexPath is provided, return our value as is.
    return self.value;
}


- (NSInteger)numberOfSections {
    if ([self.value isKindOfClass:[NSArray class]]) {
        NSArray *sections = self.value;
        // If our value is a two dimensional array (array of arrays), return the number of arrays it contains
        if ([sections.firstObject isKindOfClass:[NSArray class]]) {
            return sections.count;
        }
        // Otherwise, if it is just an array of values, return 1 as it represents a single section
        else {
            return 1;
        }
    }
    // If our value isn't an array at all, then it has no sections
    return 0;
}


- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    if (section < [self numberOfSections]) {
        NSArray *sections = self.value;
        // If our value is a two dimensional array (array of arrays), return the number of items in the array for the given section
        if ([sections.firstObject isKindOfClass:[NSArray class]]) {
            NSArray *items = sections[section];
            return items.count;
        }
        // Otherwise, if it is just an array of values, return the number of values it contains
        else {
            return sections.count;
        }
    }
    // If there is no section at all at the provided index, then there are no items in that section
    return 0;
}


-(void)setValue:(id)value {
    _value = value;
    self.sourceValue = value;
}

-(id)sourceValue {
    return _sourceValue ?: self.value;
}


- (void)dealloc {
    for (SYMDataSource *dataSource in self.sectionDataSources) {
        [dataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(value))];
    }
}


@end
