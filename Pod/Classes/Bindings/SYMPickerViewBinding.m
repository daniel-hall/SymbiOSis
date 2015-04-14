//
//  SYMPickerViewBinding.m
//  Pods
//
//  Created by Dan Hall on 4/9/15.
//
//

#import "SYMPickerViewBinding.h"
#import "SYMDataSource.h"

@interface SYMPickerViewBinding ()

@property (nonatomic, strong) SYMDataSource *alternateDataSource;

@end


@implementation SYMPickerViewBinding

@dynamic value;
@dynamic view;
@synthesize sourceValue = _sourceValue;

-(void)awakeFromNib {

}

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
    // There seems to be a bug with UIPickerView related to passing in retained views through this delegate method.  The work around is to create unowned copies of each label in our array, rather than passing in references to the original labels.  This archive / unarchive is a workaround for the lack of a -[UILabel copy] implementation.
    NSData *archive = [NSKeyedArchiver archivedDataWithRootObject: self.dataSource.value[row]];
    UILabel *labelCopy =   [NSKeyedUnarchiver unarchiveObjectWithData: archive];
    return labelCopy;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    UILabel *label = (UILabel *)[self pickerView:pickerView viewForRow:row forComponent:component reusingView:nil];
    if (label) {
        self.sourceValue = label.text;
    }
    else {
        self.sourceValue = [self pickerView:pickerView titleForRow:row forComponent:component];
    }
}

@end
