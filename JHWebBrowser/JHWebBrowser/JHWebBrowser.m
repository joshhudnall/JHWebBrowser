//
//  MAWebBrowser.m
//
//  Copyright 2012 Josh Hudnall.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "JHWebBrowser.h"

@interface JHWebBrowser ()

@property (nonatomic, strong) UIBarButtonItem *_backButton;
@property (nonatomic, strong) UIBarButtonItem *_forwardButton;
@property (nonatomic, strong) UIBarButtonItem *_stopButton;
@property (nonatomic, strong) UIBarButtonItem *_refreshButton;
@property (nonatomic, strong) UIBarButtonItem *_actionButton;
@property (nonatomic, strong) UIBarButtonItem *_doneButton;
@property (nonatomic) BOOL _firstRequest;
@property (nonatomic, strong) NSString *_dataMimeType;

@end

@implementation JHWebBrowser

// Public
@synthesize webView = _webView;
@synthesize titleToolbar;
@synthesize titleLabel;
@synthesize loadingIndicator;
@synthesize addressToolbar;
@synthesize urlField;
@synthesize toolbar;
@synthesize showTitleBar;
@synthesize showAddressBar;
@synthesize showToolbar;
@synthesize showDoneButton;
@synthesize url;
@synthesize html;
@synthesize data;

// Private
@synthesize _backButton;
@synthesize _forwardButton;
@synthesize _stopButton;
@synthesize _refreshButton;
@synthesize _actionButton;
@synthesize _doneButton;
@synthesize _firstRequest;
@synthesize _dataMimeType;


#pragma mark - Utility
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

- (id)init {
    if ( (self = [super init]) ) {
        showTitleBar = YES;
        showAddressBar = YES;
        showToolbar = YES;
        _firstRequest = YES;
    }
    return self;
}


#pragma mark - View lifecycle
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Default to loading text
	titleLabel.text = @"Loading...";
	
	urlField.clearButtonMode = UITextFieldViewModeAlways;
	urlField.keyboardType = UIKeyboardTypeURL;
	urlField.returnKeyType = UIReturnKeyGo;
	urlField.delegate = self;

    [self setToolbarButtons];
    [self loadContent];
}

- (void)viewWillAppear:(BOOL)animated {
	//self.view.frame = self.view.superview.bounds;
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	_webView.delegate = nil;
	[_webView stopLoading];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}
#else
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}
#endif


#pragma mark - Setters
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

- (void)setUrl:(NSURL *)inUrl {
    self->url = inUrl;
    self->data = nil;
    self->html = nil;
    
    if (self.view) {
        [self loadContent];
    }
}

- (void)setData:(NSData *)inData forMimeType:(NSString *)mimeType {
    self->data = inData;
    self->url = nil;
    self->html = nil;
    
    if ( ! mimeType) {
        mimeType = @"text/html";
    }
    
    self->_dataMimeType = mimeType;

    if (self.view) {
        [self loadContent];
    }
}

- (void)setHtml:(NSString *)inHtml {
    self->html = inHtml;
    self->data = nil;
    self->html = nil;

    if (self.view) {
        [self loadContent];
    }
}

- (void)setShowDoneButton:(BOOL)inShowDoneButton {
    self->showDoneButton = inShowDoneButton;
    
    [self setToolbarButtons];
}

- (void)setShowTitleBar:(BOOL)inShowTitleBar {
    [self setShowTitleBar:inShowTitleBar animated:YES];
}

- (void)setShowTitleBar:(BOOL)inShowTitleBar animated:(BOOL)animated {
    self->showTitleBar = inShowTitleBar;
    [self setVisibleComponentsAnimated:animated];
}

- (void)setShowAddressBar:(BOOL)inShowAddressBar {
    [self setShowAddressBar:inShowAddressBar animated:YES];
}

- (void)setShowAddressBar:(BOOL)inShowAddressBar animated:(BOOL)animated {
    self->showAddressBar = inShowAddressBar;
    [self setVisibleComponentsAnimated:animated];
}

- (void)setShowToolbar:(BOOL)inShowToolbar {
    [self setShowToolbar:inShowToolbar animated:YES];
}

- (void)setShowToolbar:(BOOL)inShowToolbar animated:(BOOL)animated {
    self->showToolbar = inShowToolbar;
    [self setVisibleComponentsAnimated:animated];
}

- (void)setVisibleComponentsAnimated:(BOOL)animated {
    CGRect titleFrame = self.titleToolbar.frame;
    CGRect addressFrame = self.addressToolbar.frame;
    CGRect toolbarFrame = self.toolbar.frame;
    CGRect webFrame = self.view.bounds;
    
    // Title Bar
    if (showTitleBar) {
        titleFrame.origin.y = 0;
        
        webFrame.origin.y += 24;
        webFrame.size.height -= 24;
    } else {
        titleFrame.origin.y = 0 - titleFrame.size.height;
    }
    
    // Address Bar
    if (showAddressBar) {
        addressFrame.origin.y = (showTitleBar) ? 24 : 0;

        webFrame.origin.y += 44;
        webFrame.size.height -= 44;
    } else {
        addressFrame.origin.y = 0 - addressFrame.size.height;
    }
    
    // Toolbar
    if (showToolbar) {
        webFrame.size.height -= 44;
    }
    toolbarFrame.origin.y = webFrame.origin.y + webFrame.size.height;
    
    // Set frame
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             _webView.frame = webFrame;
                             titleToolbar.frame = titleFrame;
                             addressToolbar.frame = addressFrame;
                             toolbar.frame = toolbarFrame;
                         }];
    } else {
        _webView.frame = webFrame;
        titleToolbar.frame = titleFrame;
        addressToolbar.frame = addressFrame;
        toolbar.frame = toolbarFrame;
    }
}


#pragma mark - Toolbar Buttons
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

- (void)setToolbarButtons {
    UIBarButtonItem *vSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil];
	UIBarButtonItem *fSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                            target:nil
                                                                            action:nil];
	fSpace.width = 28.0f;
	
	_backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon.png"]
                                                  style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(backAction)];
	
	_forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forwardIcon.png"]
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(forwardAction)];
	
	_actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                 target:self
                                                                 action:@selector(actionButtonPressed)];
	
	_refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																  target:self
																  action:@selector(refreshAction)];
	_refreshButton.tag = 3;
	
	_stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
															   target:self
															   action:@selector(stopAction)];
	_stopButton.tag = 3;
	
    _doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered
                                                  target:self
                                                  action:@selector(doneButtonPressed)];
    
	NSMutableArray *toolBarItems;
    toolBarItems = [NSMutableArray arrayWithObjects:
                    _backButton,
                    fSpace,
                    _forwardButton,
                    fSpace,
                    _refreshButton,
                    vSpace,
                    _actionButton,
                    nil];
    
	if (showDoneButton) {
        [toolBarItems addObject:fSpace];
        [toolBarItems addObject:_doneButton];
    }
	
	[toolbar setItems:toolBarItems];
}

- (void)doneButtonPressed {
	if (self.navigationController) {
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (IBAction)actionButtonPressed {
	UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Open in Safari" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Yes", nil];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (self.view.superview) {
            [as showInView:self.view.superview];
        } else {
            [as showInView:self.view];
        }
    } else {
        [as showFromBarButtonItem:_actionButton animated:YES];
    }
}

- (void)backAction {
	[_webView goBack];
}

- (void)forwardAction {
	[_webView goForward];
}

- (void)refreshAction {
	[_webView reload];
}

- (void)stopAction {
	[_webView stopLoading];
}


#pragma mark - UIWebView Methods and Delegate
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

- (void)loadContent {
    if (url) {
        if ([_webView isLoading]) [_webView stopLoading];
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
        urlField.text = [url absoluteString];
    } else if (data) {
        [_webView loadData:data MIMEType:_dataMimeType textEncodingName:@"utf-8" baseURL:nil];
    } else if (html) {
        NSString *wrapperHTML = @"<html><head><meta name = \"viewport\" content = \"width = device-width\"><link rel=\"stylesheet\" media=\"all\" href=\"WebView.css\" /></head><body>%@</body></html>";
        
        NSString *finalHtml;
        if ([html rangeOfString:@"<html"].location == NSNotFound) {
            finalHtml = [NSString stringWithFormat:wrapperHTML, html];
        } else {
            finalHtml = html;
        }
        
        [_webView loadHTMLString:finalHtml baseURL:[[NSBundle mainBundle] bundleURL]];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	_backButton.enabled = _webView.canGoBack;
	_forwardButton.enabled = _webView.canGoForward;
	[toolbar replaceItem:_refreshButton withItem:_stopButton];
	
	[loadingIndicator startAnimating];
	titleLabel.text = @"Loading...";
	urlField.text = [[webView.request URL] absoluteString];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	_backButton.enabled = _webView.canGoBack;
	_forwardButton.enabled = _webView.canGoForward;
	[toolbar replaceItem:_stopButton withItem:_refreshButton];
	
	[loadingIndicator stopAnimating];
	titleLabel.text = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	urlField.text = [[webView.request URL] absoluteString];
	
	_firstRequest = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	if ([error code] != -999) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not connect to server." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
		[alert show];
	}

	[self webViewDidFinishLoad:webView];
}


#pragma mark - UITextFieldDelegate
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

- (BOOL)textFieldShouldReturn:(UITextField *)textField {	
	NSString *urlString;
	
	if ([textField.text rangeOfString:@"://"].length == 0) {
		urlString = [NSString stringWithFormat:@"http://%@", textField.text];
	} else {
		urlString = textField.text;
	}
	
	self.url = [NSURL URLWithString:urlString];
	
	[textField resignFirstResponder];
	return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	[textField becomeFirstResponder];
	
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([_webView isLoading])
        [_webView stopLoading];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if ([textField.text isEqualToString:@""]) {
		textField.text = [[[_webView request] URL] absoluteString];
	}
}


#pragma mark - UIActionSheetDelegate
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0 && ! [[[[_webView request] URL] absoluteString] isEqualToString:@""]) {
		[[UIApplication sharedApplication] openURL:[[_webView request] URL]];
	}
}

@end



#pragma mark - UIToolbar (TTCategory)
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation UIToolbar (JHWebBrowser)

- (void)replaceItem:(UIBarButtonItem *)oldItem withItem:(UIBarButtonItem *)item {
	NSInteger buttonIndex = 0;
	for (UIBarButtonItem *button in self.items) {
		if (button == oldItem) {
			NSMutableArray* newItems = [NSMutableArray arrayWithArray:self.items];
			[newItems replaceObjectAtIndex:buttonIndex withObject:item];
			self.items = newItems;
			break;
		}
		++buttonIndex;
	}
}

@end
