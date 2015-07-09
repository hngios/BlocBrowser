//
//  BLCWebBrowserViewController.m
//  BlocBrowser
//
//  Created by HILDA NG on 6/24/15.
//  Copyright © 2015 hng. All rights reserved.
//

#import "BLCWebBrowserViewController.h"

@interface BLCWebBrowserViewController () <UIWebViewDelegate,UITextFieldDelegate>
    //Inorder to use our VC as delegate for UIView, need to declare VC conforms to <UIWebViewDelegate> protocol:, added UITextFieldDelegate,

@property (nonatomic, strong) UIWebView *webview;      //Add UIWebView as private property
@property (nonatomic, strong) UITextField *textField;  //Add UITextField
@property (nonatomic, strong) UIButton *backButton;    //Add UIButton, backbutton
@property (nonatomic, strong) UIButton *forwardButton; //Add UIButton, forwardbutton
@property (nonatomic, strong) UIButton *stopButton;    //Add UIButton, stopbutton
@property (nonatomic, strong) UIButton *reloadButton;  //Add UIButton, reloadbutton
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator; //Add UIButton activity indicator

//@property (nonatomic, assign) BOOL isLoading; //Added to enable stop and refresh buttons: next(remove and add NSUInteger to keep tally of increments of start-finish loading frames especially when there are mutiple frames
@property (nonatomic, assign) NSUInteger frameCount; //Added

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
    
    //add buttons
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

    
#pragma  mark - remove individual subview, add loop
    /*
    [mainView addSubview:self.webview];
    [mainView addSubview:self.textField];
    [mainView addSubview:self.backButton];
    [mainView addSubview:self.forwardButton];
    [mainView addSubview:self.stopButton];
    [mainView addSubview:self.reloadButton];
    */
    
    //make a loop for adding subviews instead adding subview individually
    for (UIView *viewToAdd in @[self.webview, self.textField, self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        [mainView addSubview:viewToAdd];
    }
    
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
    //CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight; //remove
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight - itemHeight; //add to accommodate buttons
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 4;
    
    //now, assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    //add loop to handle positioning of each button
    CGFloat currentButtonX = 0;
    
    for (UIButton *thisButton in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        thisButton.frame = CGRectMake(currentButtonX, CGRectGetMaxY(self.webview.frame), buttonWidth, itemHeight);
        currentButtonX += buttonWidth;
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
        // if text field has spaces in it:
        NSArray *urlComponents = [URLString componentsSeparatedByString:@" "];
        BOOL textFieldHasSpaces = [urlComponents count] > 1;
        if (textFieldHasSpaces) {
            // convert spaces to +
            NSString *urlWithoutSpaces = [URLString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            // add "http://google.com/search?q=" to beginning of it
            
        }
        
        
        
        
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

    //next forward and back buttons
    self.backButton.enabled = [self.webview canGoBack];
    self.forwardButton.enabled = [self.webview canGoForward];
    //change buttons' enabled state based on current value of isLoading
    //self.stopButton.enabled = self.isLoading;   //removed
    //self.reloadButton.enabled = !self.isLoading; //removed
    self.stopButton.enabled = self.frameCount > 0;  //added for frameCount
    self.reloadButton.enabled = self.frameCount == 0;  //added for FrameCount
    
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


@end
