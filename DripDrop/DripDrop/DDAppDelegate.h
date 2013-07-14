//
//  DDAppDelegate.h
//  DripDrop
//
//  Created by Matt Stanton on 7/13/13.
//  Copyright (c) 2013 Matt Stanton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface DDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) CMMotionManager *motionManager;


@end
