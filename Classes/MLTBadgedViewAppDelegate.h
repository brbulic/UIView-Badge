//
//  MLTBadgedViewAppDelegate.h
//  MLTBadgedView
//
//  Created by Robert Rasmussen on 10/2/10.
//  Copyright 2010 Moonlight Tower. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLTBadgedViewViewController;

@interface MLTBadgedViewAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MLTBadgedViewViewController *viewController;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet MLTBadgedViewViewController *viewController;

@end

