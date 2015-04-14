//
//  SYMDismissKeyboardResponder.m
//  Pods
//
//  Created by Dan Hall on 4/13/15.
//
//

#import "SYMDismissKeyboardResponder.h"
#import "SYMViewController.h"

@implementation SYMDismissKeyboardResponder

-(void)performActionWithSender:(id)sender {
    [self.viewController.view endEditing:YES];
}

@end
