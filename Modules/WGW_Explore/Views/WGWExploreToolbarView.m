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
        
        view.returnKeyType = UIReturnKeySearch;
        
        [view addTarget:self
                      action:@selector(textFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
        
        view.delegate = self;
        
        self.searchTextField = view;
        [self addSubview:view];
    }
    {
        
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


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives

- (void)setQueryString:(NSString *)queryString andYield:(BOOL)yield
{
    self.searchTextField.text = queryString;
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
    
    CGFloat x = 9;
    CGFloat y = 26;
    self.searchTextField.frame = CGRectMake(x, y, self.bounds.size.width - x*2, self.bounds.size.height - y - 10);
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
    [self _searchQueryTextChangedToString:self.searchTextField.text];
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
