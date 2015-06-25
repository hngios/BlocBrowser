//
//  BLCWebBrowserViewController.h
//  BlocBrowser
//
//  Created by HILDA NG on 6/24/15.
//  Copyright © 2015 hng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLCWebBrowserViewController : UIViewController

/*
 
Replace the web view with a fresh one, erasing all history.  Also updates the URL field and toolbar button appropriately
*/

- (void) resetWebView;

@end
