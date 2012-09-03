//
//  MainViewController.m
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

#import "MainViewController.h"
#import "JHWebBrowser.h"

@interface MainViewController ()

@property (nonatomic, strong) JHWebBrowser *browser;

@end

@implementation MainViewController
@synthesize browser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    browser = [JHWebBrowser new];
    browser.url = [NSURL URLWithString:@"http://apple.com"];
    CGRect frame = self.view.bounds;
    frame.size.height -= 50;
    browser.view.frame = frame;
    [self.view addSubview:browser.view];
    
    UIButton *button;
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Title Bar" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(titlebar) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, self.view.frame.size.height - 50, 80, 40);
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Add Bar" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addressbar) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(85, self.view.frame.size.height - 50, 75, 40);
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Toolbar" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(toolbar) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(165, self.view.frame.size.height - 50, 80, 40);
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Modal" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showmodal) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(250, self.view.frame.size.height - 50, 70, 40);
    [self.view addSubview:button];
    
}

- (void)showmodal {
    JHWebBrowser *modalBrowser = [JHWebBrowser new];
    modalBrowser.showDoneButton = YES;
    modalBrowser.url = [NSURL URLWithString:@"http://apple.com"];
    [self presentModalViewController:modalBrowser animated:YES];
}

- (void)titlebar {
    browser.showTitleBar = ! browser.isTitleBarVisible;
}

- (void)addressbar {
    browser.showAddressBar = ! browser.isAddressBarVisible;
}

- (void)toolbar {
    browser.showToolbar = ! browser.isToolbarVisible;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
