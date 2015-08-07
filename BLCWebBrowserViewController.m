//
//  BLCWebBrowserViewController.m
//  BlocBrowser
//
//  Created by HILDA NG on 6/24/15.
//  Copyright © 2015 hng. All rights reserved.
//

#import "BLCWebBrowserViewController.h"
#import "BLCAwesomeFloatingToolbar.h"


#pragma mark - Define Directives for BLCAwesomeFloatingToolbar

#define kBLCWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kBLCWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kBLCWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kBLCWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")


@interface BLCWebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate, BLCAwesomeFloatingToolBarDelegate>
    //Inorder to use our VC as delegate for UIView, need to declare VC conforms to <UIWebViewDelegate> protocol:, added UITextFieldDelegate, added BLCAwesomeFloatingToobarDelegate

@property (nonatomic, strong) UIWebView *webview;      //Add UIWebView as private property
@property (nonatomic, strong) UITextField *textField;  //Add UITextField

//Delete four button properties
//@property (nonatomic, strong) UIButton *backButton;    //Add UIButton, backbutton
//@property (nonatomic, strong) UIButton *forwardButton; //Add UIButton, forwardbutton
//@property (nonatomic, strong) UIButton *stopButton;    //Add UIButton, stopbutton
//@property (nonatomic, strong) UIButton *reloadButton;  //Add UIButton, reloadbutton

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator; //Add UIButton activity indicator

//@property (nonatomic, assign) BOOL isLoading; //Added to enable stop and refresh buttons: next(remove and add NSUInteger to keep tally of increments of start-finish loading frames especially when there are mutiple frames
@property (nonatomic, assign) NSUInteger frameCount; //Added

//Delete four button properties above and add one property for our toolbar
@property (nonatomic, strong) BLCAwesomeFloatingToolbar *awesomeToolbar;





@end

@implementation BLCWebBrowserViewController

#pragma mark - UIViewController

- (void)loadView {
    UIView *mainView = [UIView new];
    
    self.webview = [[UIWebView alloc] init];
    self.webview.delegate = self;
    
    //build textField and add it as a subview of mainview
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Website URL", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/225.0f alpha:1];
    self.textField.delegate = self;
    
    //add buttons: delete buttons now removed button properties
    /*
     self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setEnabled:NO];
                       
    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.forwardButton setEnabled:NO];
    
    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton setEnabled:NO];
    
    self.reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.reloadButton setEnabled:NO];

    [self.backButton setTitle:NSLocalizedString(@"Back", @"Back comnmand") forState:UIControlStateNormal];
    [self.backButton addTarget:self.webview action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    [self.forwardButton setTitle:NSLocalizedString(@"Forward", @"Forward comnmand") forState:UIControlStateNormal];
    [self.forwardButton addTarget:self.webview action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    
    [self.stopButton setTitle:NSLocalizedString(@"Stop", @"Stop comnmand") forState:UIControlStateNormal];
    [self.stopButton addTarget:self.webview action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    
    [self.reloadButton setTitle:NSLocalizedString(@"Refresh", @"Reload comnmand") forState:UIControlStateNormal];
    [self.reloadButton addTarget:self.webview action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];

    [self addButtonTargets];
    */
    
    //add for new awesome toolbar property
    self.awesomeToolbar = [[BLCAwesomeFloatingToolbar alloc] initWithFourTitles:@[kBLCWebBrowserBackString, kBLCWebBrowserForwardString, kBLCWebBrowserStopString, kBLCWebBrowserRefreshString]];
    self.awesomeToolbar.delegate = self;
    
    
#pragma  mark - remove individual subview, add loop
    /*
    [mainView addSubview:self.webview];
    [mainView addSubview:self.textField];
    [mainView addSubview:self.backButton];
    [mainView addSubview:self.forwardButton];
    [mainView addSubview:self.stopButton];
    [mainView addSubview:self.reloadButton];
    */
    
    //make a loop for adding subviews instead adding subview individually: now removed button properties and add awesomeToolbar
    /*for (UIView *viewToAdd in @[self.webview, self.textField, self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        [mainView addSubview:viewToAdd];
    }
    */
    
    for (UIView *viewToAdd in @[self.webview, self.textField, self.awesomeToolbar]) {
          [mainView addSubview:viewToAdd];    }
    
    self.view = mainView;
    
#pragma mark - request URL to load in web view: next(remove hardcore URL)
    
    /*  NSString *urlString = @"http://wikipedia.org";
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webview loadRequest:request];
    */
    
    //[mainView addSubview:self.webview];     //add subView to mainView: next (remove due to added above)
    //[mainView addSubview:self.textField];   //add subView to mainView: next (remove due to added above)
    
    self.view = mainView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //set edgesForExtendedLayout property on our vc
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //set activity indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    //[self.activityIndicator startAnimating]; //test turn on: next(remove)
    
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //make the webview fill the main view
    self.webview.frame = self.view.frame;
    
    //first, calculate some dimensions for url bar
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight; //remove; add again due to removal of buttons
    //CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight - itemHeight; //add to accommodate buttons; //remove
    //CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 4; //remove due to removal of buttons
    
    
    //now, assign the frames; already assigned first time
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    
    
    //add loop to handle positioning of each button; remove due to removal of buttons
    /*
     CGFloat currentButtonX = 0;
    
    for (UIButton *thisButton in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        thisButton.frame = CGRectMake(currentButtonX, CGRectGetMaxY(self.webview.frame), buttonWidth, itemHeight);
        currentButtonX += buttonWidth;
    }
    */
    // add
//    self.awesomeToolbar.frame = CGRectMake(20, 100, 280, 60);
//    self.awesomeToolbar.frame = CGRectMake(20, 100, 280, 90);
      self.awesomeToolbar.frame = CGRectMake(50, 100, 260, 100);

}

- (void) resetWebView {
    [self.webview removeFromSuperview];
    
    UIWebView *newWebView = [[UIWebView alloc] init];
    newWebView.delegate = self;
    [self.view addSubview:newWebView];
    
    self.webview = newWebView;
    
    //remove due to removal of buttons
    //[self addButtonTargets];
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
}


#pragma mark - Add addButtonTargets; removed after removal of buttons
/*- (void) addButtonTargets {
    for (UIButton *button in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        [button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.backButton addTarget:self.webview action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton addTarget:self.webview action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self.webview action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    [self.reloadButton addTarget:self.webview action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
}
*/



#pragma mark - BLCAwesomeFloatingToolbarDelegate
//update use constant defined in beginning
- (void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
    if ([title isEqual:kBLCWebBrowserBackString]) {
        [self.webview goBack];
    } else if ([title isEqual:kBLCWebBrowserForwardString]) {
        [self.webview goForward];
    } else if ([title isEqual:kBLCWebBrowserStopString]) {
        [self.webview stopLoading];
    } else if ([title isEqual:kBLCWebBrowserRefreshString]) {
        [self.webview reload];
    }
}

#pragma mark - UITextFieldDelegate

//to make UIWebView load URL we enter into the text field
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *URLString = textField.text;
    
    NSURL *URL = [NSURL URLWithString:URLString];
    
    //The user didn't type http: or https:
    if (!URL.scheme) {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
    }
    
    if (URL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webview loadRequest:request];
    }
    
    return NO;
}

#pragma mark - UIWebViewDelegate

//will call if web page fails to load
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *) error {
    if (error.code != -999) {   //added
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                    message:[error localizedDescription]
                                                    delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                    otherButtonTitles:nil];
    [alert show];
}
    
//update buttons and titles
    [self updateButtonsAndTitle];
    self.frameCount--;  //added for frameCount
    }
#pragma mark - Miscellaneous
//update title in UINavigationBar

- (void) updateButtonsAndTitle {
    NSString *webpageTitle = [self.webview stringByEvaluatingJavaScriptFromString:@"document.title"];

    if (webpageTitle) {
        self.title = webpageTitle;
    } else {
        self.title = self.webview.request.URL.absoluteString;
    }
    
    //if (self.isLoading) {   //removed for frameCount
    if (self.frameCount > 0) {
    [self.activityIndicator startAnimating];
        
    } else {
        [self.activityIndicator stopAnimating];
}
/*
    //next forward and back buttons; remove buttons
    //self.backButton.enabled = [self.webview canGoBack];
    //self.forwardButton.enabled = [self.webview canGoForward];
     
    //change buttons' enabled state based on current value of isLoading
    //self.stopButton.enabled = self.isLoading;   //removed
    //self.reloadButton.enabled = !self.isLoading; //removed
     
    //self.stopButton.enabled = self.frameCount > 0;  //added for frameCount; now removed
    //self.reloadButton.enabled = self.frameCount == 0;  //added for FrameCount; now removed
*/
    //now make sure button's enabled state is updated in updateButtonsAndTitle
    [self.awesomeToolbar setEnabled:[self.webview canGoBack] forButtonWithTitle:kBLCWebBrowserBackString];
    [self.awesomeToolbar setEnabled:[self.webview canGoForward] forButtonWithTitle:kBLCWebBrowserForwardString];
    [self.awesomeToolbar setEnabled:self.frameCount > 0 forButtonWithTitle:kBLCWebBrowserStopString];
    [self.awesomeToolbar setEnabled:self.webview.request.URL && self.frameCount == 0 forButtonWithTitle:kBLCWebBrowserRefreshString];
    
    
}

//need to call this method whenever page starts or stops loading.
- (void)webViewDidStartLoad:(UIWebView *)webView {
    //self.isLoading = YES; //removed to add frameCount below
    self.frameCount++; //added to keep tally of start frame loading
    [self updateButtonsAndTitle];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //self.isLoading = NO; //removed to add frameCount below
    self.frameCount++; //added to keep tally of finished frame loading
    [self updateButtonsAndTitle];
}

- (void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset {
    CGPoint startingPoint = toolbar.frame.origin;
    CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, startingPoint.y + offset.y);
    
    CGRect potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(toolbar.frame), CGRectGetHeight(toolbar.frame));
    
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) {
        toolbar.frame = potentialNewFrame;
    }
}

- (void) pinchGestureDetected:(UIPinchGestureRecognizer *)recognizer{
    
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat scale = [recognizer scale];
        
        [recognizer.view setTransform:CGAffineTransformScale(recognizer.view.transform, scale, scale)];
        [recognizer setScale:1.0];
        
    }

}

@end