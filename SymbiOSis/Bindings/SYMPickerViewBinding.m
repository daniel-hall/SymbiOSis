//
// SYMPickerViewBinding.m
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


#import "SYMPickerViewBinding.h"
#import "SYMPickerViewSelectionResponder.h"
#import "UIView+SymbiOSisPrivate.h"

@interface SYMPickerViewBinding ()

@property (nonatomic, strong) SYMDataSource *alternateDataSource;

@end


@implementation SYMPickerViewBinding

@dynamic value;
@dynamic view;

@synthesize sourceValue = _sourceValue;


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return ((NSArray *)self.dataSource.value).count;
}


-(SYMDataSource *)dataSource {
    return [super dataSource] ? : self.alternateDataSource;
}


-(SYMDataSource *)alternateDataSource {
    if (_alternateDataSource == nil) {
        _alternateDataSource = [[SYMDataSource alloc] init];
         _alternateDataSource.value = self.pickerLabels.count ? self.pickerLabels : [self.pickerValues componentsSeparatedByString:@","];
    }
    
    return _alternateDataSource;
}


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.dataSource.value[row];
}


-(BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(pickerView:viewForRow:forComponent:reusingView:)) {
        return self.pickerLabels.count > 0;
    }
    if (aSelector == @selector(pickerView:titleForRow:forComponent:)) {
        return self.pickerLabels.count == 0;
    }
    return [super respondsToSelector:aSelector];
}


-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    return [self.dataSource.value[row] copy];
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    UILabel *label = (UILabel *)[self pickerView:pickerView viewForRow:row forComponent:component reusingView:nil];
    if (label) {
        self.sourceValue = label.text;
        for (SYMPickerViewSelectionResponder *responder in self.itemSelectionResponders) {
            [responder pickerView:self.view selectedValue:self.sourceValue withLabel:label fromIndexPath:[NSIndexPath indexPathForRow:row inSection:component]];
        }
    }
    else {
        self.sourceValue = [self pickerView:pickerView titleForRow:row forComponent:component];
        for (SYMPickerViewSelectionResponder *responder in self.itemSelectionResponders) {
            [responder pickerView:self.view selectedValue:self.sourceValue withLabel:nil fromIndexPath:[NSIndexPath indexPathForRow:row inSection:component]];
        }
    }
}


@end
