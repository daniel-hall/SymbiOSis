//
//  SYMMoveToNextTextFieldResponder.m
//  Pods
//
//  Created by Dan Hall on 4/13/15.
//
//

#import "SYMMoveToNextControlTextFieldResponder.h"

@implementation SYMMoveToNextControlTextFieldResponder

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    for (NSUInteger index = 0; index < self.nextResponders.count; index++) {
        if (self.nextResponders[index] == textField && index < self.nextResponders.count - 1) {
            [textField resignFirstResponder];
            [self.nextResponders[index + 1] becomeFirstResponder];
            return YES;
        }
    }
    
    [textField resignFirstResponder];
    return YES;
}

@end
