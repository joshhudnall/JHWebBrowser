JHWebBrowser
-------

http://joshhudnall.com

A simple web browser with a few customization options. There's no documentation at this point, but the gist is pretty simple. There's plenty that could be done to make it better, but it's functional. Requires ARC.

    JHWebBrowser *browser = [JHWebBrowser new];
    browser.url = [NSURL URLWithString:@"http://apple.com"];

You can show/remove toolbars with the following

    browser.showTitleBar = YES;
		
    browser.showAddressBar = NO;
		
    browser.showToolbar = YES;

Cheers.

License: http://www.apache.org/licenses/LICENSE-2.0.html
