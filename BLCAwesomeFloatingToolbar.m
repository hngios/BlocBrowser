//
//  BLCAwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by HILDA NG on 6/25/15.
//  Copyright (c) 2015 hng. All rights reserved.
//

#import "BLCAwesomeFloatingToolbar.h"

@interface BLCAwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, weak) UILabel *currentLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressedGesture;

/*
Inherit from UILongPressGestureRecognzier:
@property (nonatomic) CFTimeInterval minimumPressedDuraction;  // default is 0.5 seconds.
@property (nonatomic) NSUInteger numberOfTouchesRequired; // default finger is 1.
@property (nonatomic) NSUInteger numberOfTapsRequired; // default taps is 0.
@property (nonatomic) CGFloat allowableMovement; // default distance is 10 points.
*/

@end


@implementation BLCAwesomeFloatingToolbar

//Create and initialize recognizer at end of initWithFourTitles:
- (instancetype) initWithFourTitles:(NSArray *)titles {
    // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
    self = [super init];
    
    if (self) {
        
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *labelsArray = [[NSMutableArray alloc] init];
        
        // Make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UILabel *label = [[UILabel alloc] init];
            label.userInteractionEnabled = NO;
            label.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:10];
            label.text = titleForThisLabel;
            label.backgroundColor = colorForThisLabel;
            label.textColor = [UIColor whiteColor];
            
            [labelsArray addObject:label];
        }
        
        self.labels = labelsArray;
        
        for (UILabel *thisLabel in self.labels) {
            [self addSubview:thisLabel];
        }
        
 //       self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedGestureDetected:)];
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        [self addGestureRecognizer:self.tapGesture];
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureDetected:)];
        [self addGestureRecognizer:self.pinchGesture];
        self.longPressedGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedGestureDetected:)];
        self.longPressedGesture.numberOfTapsRequired = 1;
        self.longPressedGesture.minimumPressDuration = 0.5;
        [self addGestureRecognizer:self.longPressedGesture];
    }
    return self;
}

- (void) layoutSubviews {
    // set the frames for the 4 labels
    
    for (UILabel *thisLabel in self.labels) {
        NSUInteger currentLabelIndex = [self.labels indexOfObject:thisLabel];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        // adjust labelX and labelY for each label
        if (currentLabelIndex < 2) {
            // 0 or 1, so on top
            labelY = 0;
        } else {
            // 2 or 3, so on bottom
            labelY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentLabelIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
            // 0 or 2, so on the left
            labelX = 0;
        } else {
            // 1 or 3, so on the right
            labelX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    }
}

- (void) tapFired:(UITapGestureRecognizer *)recognizer {
    NSLog(@"Tap Fired");
    if (recognizer.state == UIGestureRecognizerStateRecognized) {  // first, check proper state,  in our case, tap completed and recognized                              state was switched to UIGestureRecognizerStateRecognized
      
        CGPoint location = [recognizer locationInView:self];        //gives us x,y coordinate where gesture occurred with respect to our bounds
        UIView *tappedView = [self hitTest:location withEvent:nil]; //to discover which view received the tap at that given location
        
        if ([self.labels containsObject:tappedView]) {              //check view tapped in fact one of our toolbar labels, if so, verify                  delegate for compatibility before performing the appropriate method call.
            
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
            }
        }
    }
}

//how far user's finger moved in each direction since touch event began, small linear collection of small pans traveling a few pixels at a time
//again, check proper state, recognized, and switch to UIGestureRecognizerStateChanged
//reset to get difference of each mini-pan everytime method is called

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
       
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

// Finally, we need to implement floatingToolbar:didTryToPanWithOffset in BLCWebBrowserViewController because that's where the BLCAwesomeFloatingToolbar will actually be assigned a new frame:
//  We begin by getting the top-left corner of where the toolbar is currently located. newPoint is where the future top-left corner is stored by adding the difference in x and the difference in y to the original top-left coordinate. Then we create a new CGRect which represents the toolbars potential new frame.We say potential because we want to make sure that we don't push the toolbar off the screen. CGRectContainsRect(CGRect rect1, CGRect rect2) will return YES if the rect2's bounds are contained entirely by rect1, or NO otherwise. If the test passes, we set the toolbar's new frame and it's done.


- (void) longPressedGestureDetected: (UILongPressGestureRecognizer *)recognizer{
    NSLog(@"Long Press Gesture Detected");
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateEnded)
    {
     
    }
    else if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [self rotateColors];
    }

}

NSInteger colorOffset = 1;

- (void) rotateColors {
    
    for (NSInteger i = 0; i < [self.labels count]; i++) {
        UIColor *colorForThisLabel = [self.colors objectAtIndex:(i+colorOffset%4)];

        UILabel *thisLabel = self.labels[i];
        thisLabel.backgroundColor = colorForThisLabel;
        
        

    }

    colorOffset++;
    
}






#pragma mark - Touch Handling

- (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    return (UILabel *)subview;
}


/* NO LONGER NEED
 
 - (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UILabel *label = [self labelFromTouches:touches withEvent:event];
    
    self.currentLabel = label;
    self.currentLabel.alpha = 0.5;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UILabel *label = [self labelFromTouches:touches withEvent:event];
    
    if (self.currentLabel != label) {
        // The label being touched is no longer the initial label
        self.currentLabel.alpha = 1;
    } else {
        // The label being touched is the initial label
        self.currentLabel.alpha = 0.5;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UILabel *label = [self labelFromTouches:touches withEvent:event];
    
    if (self.currentLabel == label) {
        NSLog(@"Label tapped: %@", self.currentLabel.text);
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
            [self.delegate floatingToolbar:self didSelectButtonWithTitle:self.currentLabel.text];
        }
    }
    
    self.currentLabel.alpha = 1;
    self.currentLabel = nil;
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.currentLabel.alpha = 1;
    self.currentLabel = nil;
}
*/

#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UILabel *label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 : 0.25;
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
