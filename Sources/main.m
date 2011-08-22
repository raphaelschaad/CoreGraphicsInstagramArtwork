//
//  main.m
//  CoreGraphicsInstagramArtwork
//
//  Created by Raphael Schaad on 2010-11-27.
//


#import "RSApplicationDelegate.h"


int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([RSApplicationDelegate class]));
	[pool release];
	return retVal;
}
