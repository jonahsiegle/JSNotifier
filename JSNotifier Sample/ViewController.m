//
//  ViewController.m
//  JSNotifier Sample
//
//  Created by Jonah Siegle on 12-01-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)succsess:(id)sender{
    
    JSNotifier *notify = [[JSNotifier alloc]initWithTitle:@"Upload Succeeded"];
    notify.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"NotifyCheck.png"]];
    [notify showFor:2.0];
    
}
- (IBAction)error:(id)sender{
    
    JSNotifier *notify = [[JSNotifier alloc]initWithTitle:@"Upload Failed"];
    notify.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"NotifyX.png"]];
    [notify showFor:2.0];


}
- (IBAction)activity:(id)sender{
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator startAnimating];
    
    JSNotifier *notify = [[JSNotifier alloc]initWithTitle:@"Uploading..."];
    notify.accessoryView = activityIndicator;
    [notify showFor:6.0];
}
- (IBAction)loop:(id)sender{
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator startAnimating];
    
    JSNotifier *notify = [[JSNotifier alloc]initWithTitle:@"Uploading..."];
    notify.accessoryView = activityIndicator;
    [notify show];
    
    //A sample six second delay.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6.0 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        
        [notify setAccessoryView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"NotifyCheck.png"]] animated:YES];
        [notify setTitle:@"Upload Succeeded" animated:YES];
        
        [notify hideIn:4.0];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
