//
//  BLCAwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by HILDA NG on 6/25/15.
//  Copyright (c) 2015 hng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCAwesomeFloatingToolbar;

@protocol BLCAwesomeFloatingToolBarDelegate <NSObject>  //add because class isn't defined when placed before @interface, promise to complier that we will learn this delegate later

@optional

- (void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title; //if delegate implements it, it will be called when user taps a button
- (void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset; // add delegate to be moved the direction it wishes to move
- (void) pinchGestureDetected:(UIPinchGestureRecognizer *)recognizer; // add delegate to implement pinch gesture
    
@end  // definition of delegate protocol has ended


#pragma mark -interface toolbar itself, which declares: 1,2,3

@interface BLCAwesomeFloatingToolbar : UIView

- (instancetype) initWithFourTitles:(NSArray *)titles;  // 1. a custom initializer to use, which take array of four titles as a argument

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;  // 2. method enables/disables buton based on title passed in

@property (nonatomic, weak) id <BLCAwesomeFloatingToolBarDelegate> delegate; // 3. a delegate property use if a delegate is desired

@end


