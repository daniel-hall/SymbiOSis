//
//  SYMDismissViewControllerResponder.m
//  Pods
//
//  Created by Daniel Hall on 4/8/15.
//
//

#import "SYMDismissViewControllerResponder.h"
#import "SYMViewController.h"

@implementation SYMDismissViewControllerResponder

-(void)performActionWithSender:(id)sender {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
