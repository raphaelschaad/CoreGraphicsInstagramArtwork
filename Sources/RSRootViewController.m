//
//  RSRootViewController.m
//  CoreGraphicsInstagramArtwork
//
//  Created by Raphael Schaad on 2010-11-27.
//


#import "RSRootViewController.h"

#import "RSInstagramArtworkView.h"


@interface RSRootViewController ()

@property (nonatomic, retain) RSInstagramArtworkView *instagramArtworkView;

@end


@implementation RSRootViewController

#pragma mark -
#pragma mark Accessors

@synthesize instagramArtworkView;


#pragma mark -
#pragma mark Life Cycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor lightGrayColor];
	
	if (!self.instagramArtworkView) {
		instagramArtworkView = [[RSInstagramArtworkView alloc] initWithFrame:CGRectMake(0.0, 0.0, 400.0, 400.0)];
		// always center
		self.instagramArtworkView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		// clear background
		self.instagramArtworkView.opaque = NO;
	}
	
	[self.view addSubview:self.instagramArtworkView];
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	// `superview` (window) is now set and we can convert the center to local coordinates for the subview.
	self.instagramArtworkView.center = [self.view convertPoint:self.view.center fromView:self.view.superview];
}


- (void)viewDidUnload {
	[instagramArtworkView release]; instagramArtworkView = nil;
	
	[super viewDidUnload];
}


#pragma mark -
#pragma mark UIViewController Method Overrides

#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)theInterfaceOrientation {
	return YES;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.instagramArtworkView setNeedsDisplay];
}


@end
