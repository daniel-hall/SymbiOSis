//
//  UINavigationController+SymbiOSis.m
//  Pods
//
//  Created by Dan Hall on 4/13/15.
//
//

#import "UINavigationController+SymbiOSis.h"
#import "SYMViewController.h"

@implementation UINavigationController (SymbiOSis)

-(NSArray *)dataSourcesWithIdentifier:(NSString *)dataIdentifier {
    if ([self.topViewController isKindOfClass:[SYMViewController class]]) {
        return [((SYMViewController *)self.topViewController) dataSourcesWithIdentifier:dataIdentifier];
    }

    return nil;
}

@end
