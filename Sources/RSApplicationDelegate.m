//
//  RSApplicationDelegate.m
//  CoreGraphicsInstagramArtwork
//
//  Created by Raphael Schaad on 2010-11-27.
//


#import "RSApplicationDelegate.h"

#import "RSRootViewController.h"


@interface RSApplicationDelegate ()

@property (nonatomic, retain) RSRootViewController *rootViewController;

@end


@implementation RSApplicationDelegate

#pragma mark -
#pragma mark Accessors

@synthesize window;
@synthesize rootViewController;


#pragma mark -
#pragma Life Cycle

- (id)init {
	self = [super init];
	if (self != nil) {
		window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
		rootViewController = [[RSRootViewController alloc] init];
	}
	return self;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[self.window addSubview:self.rootViewController.view];
	[self.window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
	[rootViewController release];
	[window release];
	
	[super dealloc];
}


@end
