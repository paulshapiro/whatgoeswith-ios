//
//  WGWExploreToolbarView.m
//  Whatgoeswith
//
//  Created by Paul Shapiro on 12/21/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import "WGWExploreToolbarView.h"
#import "WGWExploreSearchTextField.h"


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants



////////////////////////////////////////////////////////////////////////////////
#pragma mark - C



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interface

@interface WGWExploreToolbarView ()
<
    UITextFieldDelegate
>

@property (nonatomic, strong) UIVisualEffectView *backgroundVisualEffectView;
@property (nonatomic, strong) WGWExploreSearchTextField *searchTextField;

@property (nonatomic, strong) UIButton *exportButton;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation WGWExploreToolbarView


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle - Imperatives - Entrypoints

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)dealloc
{
    [self teardown];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle - Imperatives - Setup

- (void)setup
{
    [self _setup_views];
    
    [self startObserving];
}

- (void)_setup_views
{
//    self.backgroundColor = [UIColor whiteColor];
    
    { // Add visual effect view
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        self.backgroundVisualEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        _backgroundVisualEffectView.frame = self.bounds;
        [self addSubview:_backgroundVisualEffectView];
    }
    { // Add bottom line - background decoration
        CGFloat lineHeight = 1.0 / [UIScreen mainScreen].scale;
        CGRect frame = CGRectMake(0, self.bounds.size.height - lineHeight, self.bounds.size.width, lineHeight);
        UIView *view = [[UIView alloc] initWithFrame:frame];
        {
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        }
        [self addSubview:view];
    }
    { // Add text field
        WGWExploreSearchTextField *view = [[WGWExploreSearchTextField alloc] init];
        view.autoresizingMask = UIViewAutoresizingNone;
        view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.07];
        view.layer.cornerRadius = 5;
        view.font = [UIFont systemFontOfSize:15];
        view.placeholder = NSLocalizedString(@"What goes with…?", nil);
        
        view.clearButtonMode = UITextFieldViewModeNever;
        
        view.returnKeyType = UIReturnKeySearch;
        
        [view addTarget:self
                      action:@selector(textFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
        
        view.delegate = self;
        
        self.searchTextField = view;
        [self addSubview:view];
    }
    { // Export button
        self.tintColor = [UIColor purpleColor];
        UIButton *view = [UIButton buttonWithType:UIButtonTypeSystem]; // system for tint color?
        self.exportButton = view;
        
        [view setTitle:@"Export" forState:UIControlStateNormal];
        
        [self addSubview:view];
    }
}

- (void)startObserving
{
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle - Imperatives - Teardown

- (void)teardown
{
    [self stopObserving];
}

- (void)stopObserving
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Accessors

- (CGRect)_new_searchTextField_frame
{
    CGFloat x = 9;
    CGFloat y = 26;
    CGFloat w = self.bounds.size.width - x*2;
    {
        if (self.searchTextField.text.length > 0) {
            w -= self.exportButton.frame.size.width + 9;
        }
    }
    
    
    return CGRectMake(x, y, w, self.bounds.size.height - y - 10);
}

- (CGRect)_new_exportButtonFrame
{
    CGFloat x = self.searchTextField.frame.origin.x + self.searchTextField.frame.size.width + 9;
    CGFloat y = 20;
    CGFloat side = self.bounds.size.height - y;
    
    return CGRectMake(x, y, 10 + side, side - 6);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives

- (void)setQueryString:(NSString *)queryString andYield:(BOOL)yield
{
    self.searchTextField.text = queryString;
    [self refreshTextContentVaryingUIElements];
    if (self.searchTextField.isFirstResponder) {
        NSRange range = NSMakeRange(queryString.length, 0);

        UITextPosition *start = [self.searchTextField positionFromPosition:[self.searchTextField beginningOfDocument]
                                                                    offset:range.location];
        UITextPosition *end = [self.searchTextField positionFromPosition:start
                                                                  offset:range.length];
        [self.searchTextField setSelectedTextRange:[self.searchTextField textRangeFromPosition:start toPosition:end]];
    }
    if (yield) {
        [self _searchQueryTextChangedToString:queryString];
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives - Overrides

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundVisualEffectView.frame = self.bounds;
    self.backgroundVisualEffectView.contentView.frame = self.bounds;
    self.searchTextField.frame = [self _new_searchTextField_frame];

    
    self.exportButton.frame = [self _new_exportButtonFrame];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives

- (void)refreshTextContentVaryingUIElements
{
    [self refreshClearButtonVisibility];
    [self refreshTextFieldSiblingButtonVisibility];
}

- (void)refreshClearButtonVisibility
{
    if (self.searchTextField.text.length > 0) {
        self.searchTextField.clearButtonMode = UITextFieldViewModeAlways;
    } else {
        self.searchTextField.clearButtonMode = UITextFieldViewModeNever;
    }
}

- (void)refreshTextFieldSiblingButtonVisibility
{
    CGRect newFrame = [self _new_searchTextField_frame];
    if (CGRectEqualToRect(newFrame, self.searchTextField.frame) == NO) {
        
        [self.searchTextField.layer removeAllAnimations];
        [self.exportButton.layer removeAllAnimations];
        
        BOOL isTextFieldExpandingRatherThanShrinking = newFrame.size.width >= self.searchTextField.frame.size.width; // == just to catch case
        
        CGFloat damping = isTextFieldExpandingRatherThanShrinking ? 0.6 : 0.65;
        CGFloat initialSpringVelocity = isTextFieldExpandingRatherThanShrinking ? 0.4 : 1;
        
        typeof(self) __weak weakSelf = self;
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:damping initialSpringVelocity:initialSpringVelocity options:0 animations:^{
            weakSelf.searchTextField.frame = newFrame;
            weakSelf.exportButton.frame = [weakSelf _new_exportButtonFrame];
        } completion:^(BOOL finished)
        {
            
        }];
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidChange:(id)sender
{
    [self refreshTextContentVaryingUIElements];
    {
        [self _searchQueryTextChangedToString:self.searchTextField.text];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation

- (void)viewControllerAppeared
{
    [self.searchTextField becomeFirstResponder];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation - Searching

- (void)_searchQueryTextChangedToString:(NSString *)queryString
{
    self.searchQueryTextChanged(queryString);
}

- (void)externalControlWasEngaged
{
    [self.searchTextField endEditing:YES];
//    DDLogInfo(@"is first? %d", self.searchTextField.isFirstResponder);
}

@end
