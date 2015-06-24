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

@end

@implementation BLCWebBrowserViewController

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

    //request URL to load in web view
    NSString *urlString = @"http://wikipedia.org";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest:request];

    [mainView addSubview:self.webview];     //add subView to mainView
    self.view = mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //set edgesForExtendedLayout property on our vc
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //make the webview fill the main view
    self.webview.frame = self.view.frame;
    
    //first, calculate some dimensions for url bar
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    //now, assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
}


@end
