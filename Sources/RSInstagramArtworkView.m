//
//  RSInstagramArtworkView.m
//  CoreGraphicsInstagramArtwork
//
//  Created by Raphael Schaad on 2010-11-27.
//


#import "RSInstagramArtworkView.h"


@implementation RSInstagramArtworkView


- (void)drawRect:(CGRect)rect {
	// Conditions:
	// - 400x400
	// - single function call (i.e. no animation/interaction possible)
	// - no pixel graphic ressources
	// - no external code besides SDK
	// - not too many fix coordinates (e.g. export vector drawing of a castle from Ai)
	// - no copy cat'ing
	// - no fractals (impressive, but not in this context)
	// - do something "magical"
	// - favor adhering conditions over software engineering best practises (e.g. decoupling)
	// - finish under 4h
	// Let's start: my goal is to approximate the Instagram iTunes Artwork.
	
	const CGFloat kSideLength = 400.0;
	NSAssert(CGSizeEqualToSize(CGSizeMake(kSideLength, kSideLength), rect.size), @"This view must be rendered 400x400 points.");
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// We allow to be drawn on the phone and in this case scale down.
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		
		CGContextSaveGState(context);
		
		const CGFloat kMargin = 20.0;
		CGFloat sideLengthMax = (MIN(self.superview.bounds.size.width, self.superview.bounds.size.height) - 2*kMargin);
		CGFloat scale = sideLengthMax / kSideLength;
		if (scale < 1.0) {
			CGFloat translate = rintf((kSideLength - sideLengthMax) / 2);
			
			CGContextTranslateCTM(context, translate, translate);
			CGContextScaleCTM(context, scale, scale);
		}
	}
	
	
	//
	// Camera Top
	//
	UIGraphicsBeginImageContext(rect.size);
	
	CGContextRef bitmapContext = UIGraphicsGetCurrentContext();
	
	const CGFloat kCameraTopHeight = 130.0;
	CGRect cameraTopBezierPathRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, kCameraTopHeight);
	CGSize cameraBezierPathCornerRadii = CGSizeMake(50.0, 50.0);
	UIBezierPath *cameraTopBezierPath = [UIBezierPath bezierPathWithRoundedRect:cameraTopBezierPathRect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:cameraBezierPathCornerRadii];
	[[UIColor colorWithRed:0.332 green:0.245 blue:0.198 alpha:1.000] setFill];
	[cameraTopBezierPath fill];
	
	
	// color stripes
	const CGFloat kColorStripeX     = 68.0;
	const CGFloat kColorStripeWidth = 11.0;
	
	CGRect colorStripeBezierPathRect = CGRectMake(kColorStripeX, rect.origin.y, kColorStripeWidth, kCameraTopHeight);
	[[UIColor colorWithRed:0.900 green:0.027 blue:0.171 alpha:1.000] setFill];
	[[UIBezierPath bezierPathWithRect:colorStripeBezierPathRect] fill];
	
	colorStripeBezierPathRect.origin.x += kColorStripeWidth;
	[[UIColor colorWithRed:0.938 green:0.733 blue:0.000 alpha:1.000] setFill];
	[[UIBezierPath bezierPathWithRect:colorStripeBezierPathRect] fill];
	
	colorStripeBezierPathRect.origin.x += kColorStripeWidth;
	[[UIColor colorWithRed:0.346 green:0.734 blue:0.373 alpha:1.000] setFill];
	[[UIBezierPath bezierPathWithRect:colorStripeBezierPathRect] fill];
	
	colorStripeBezierPathRect.origin.x += kColorStripeWidth;
	[[UIColor colorWithRed:0.235 green:0.281 blue:1.000 alpha:1.000] setFill];
	[[UIBezierPath bezierPathWithRect:colorStripeBezierPathRect] fill];
	
	
	// add noise
	UInt8 *data = CGBitmapContextGetData(bitmapContext);
	
	size_t w = rect.size.width;
	size_t h = rect.size.height;
	size_t comps = CGBitmapContextGetBitsPerPixel(bitmapContext) / CGBitmapContextGetBitsPerComponent(bitmapContext);
	
	for (UInt8 *data_curr = data, *data_end = data + w*h*comps; data_curr < data_end; data_curr += comps*2) { // *2: Box-Muller gives 2 Gauss at once and thus treating 2 pixels per loop
		// random numbers uniform distributed
		float u1 = (float)arc4random() / UINT32_MAX;
		float u2 = (float)arc4random() / UINT32_MAX;
		
		// random numbers standard normal distributed (Box-Muller)
		float sn1 = sqrtf(-2*log2f(u1)) * cosf(2*M_PI*u2);
		float sn2 = sqrtf(-2*log2f(u1)) * sinf(2*M_PI*u2);
		
		// transform distribution with mean, standard deviation (with m=1.0,sd=0.1 normal distributed ~[0.7, 1.3])
		const float m = 1.0;
		const float sd = 0.04;
		
		float n1 = m + sn1 * sd;
		float n2 = m + sn2 * sd;
		
		// multiplicative noise on pixel intensity (every channel BGR(A), monochrome), doesn't noise black (B=G=R=0)
		UInt8 *b = data_curr;
		UInt8 *g = (data_curr+1);
		UInt8 *r = (data_curr+2);
		
		// saturate to pixel intensity max (255)
		*b = MIN((*b * n1)+0.5, UINT8_MAX);
		*g = MIN((*g * n1)+0.5, UINT8_MAX);
		*r = MIN((*r * n1)+0.5, UINT8_MAX);
		
		b = (data_curr+4);
		g = (data_curr+5);
		r = (data_curr+6);
		
		*b = MIN((*b * n2)+0.5, UINT8_MAX);
		*g = MIN((*g * n2)+0.5, UINT8_MAX);
		*r = MIN((*r * n2)+0.5, UINT8_MAX);
	}
	
	CGContextSaveGState(context);
	// compensate coordinate system of bitmap context for drawing to the graphics context ("Drawing to a Graphics Context in iOS")
	CGContextScaleCTM(context, 1.0, -1.0); // invert y-axis
	CGContextTranslateCTM(context, 0.0, -rect.size.height); // shift origin from bottom-left to top-left
	
	CGContextDrawImage(context, rect, UIGraphicsGetImageFromCurrentImageContext().CGImage);
	
	CGContextRestoreGState(context);
	
	UIGraphicsEndImageContext();
	

	//
	// Camera Bottom
	//
	UIGraphicsBeginImageContext(rect.size);
	
	bitmapContext = UIGraphicsGetCurrentContext();
	
	CGRect cameraBottomBezierPathRect = CGRectMake(rect.origin.x, kCameraTopHeight, rect.size.width, rect.size.height - kCameraTopHeight);
	UIBezierPath *cameraBottomBezierPath = [UIBezierPath bezierPathWithRoundedRect:cameraBottomBezierPathRect byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:cameraBezierPathCornerRadii];
	[[UIColor colorWithRed:0.752 green:0.717 blue:0.666 alpha:1.000] setFill];
	[cameraBottomBezierPath fill];
	
	data = CGBitmapContextGetData(bitmapContext);
	
	// except smaller standard deviation (less noise), exactly same code as above, omitting comments
	for (UInt8 *data_curr = data, *data_end = data + w*h*comps; data_curr < data_end; data_curr += comps*2) {
		float u1 = (float)arc4random() / UINT32_MAX;
		float u2 = (float)arc4random() / UINT32_MAX;
		
		float sn1 = sqrtf(-2*log2f(u1)) * cosf(2*M_PI*u2);
		float sn2 = sqrtf(-2*log2f(u1)) * sinf(2*M_PI*u2);
		
		const float m = 1.0;
		const float sd = 0.01;
		
		float n1 = m + sn1 * sd;
		float n2 = m + sn2 * sd;
		
		UInt8 *b = data_curr;
		UInt8 *g = (data_curr+1);
		UInt8 *r = (data_curr+2);
		
		*b = MIN((*b * n1)+0.5, UINT8_MAX);
		*g = MIN((*g * n1)+0.5, UINT8_MAX);
		*r = MIN((*r * n1)+0.5, UINT8_MAX);
		
		b = (data_curr+4);
		g = (data_curr+5);
		r = (data_curr+6);
		
		*b = MIN((*b * n2)+0.5, UINT8_MAX);
		*g = MIN((*g * n2)+0.5, UINT8_MAX);
		*r = MIN((*r * n2)+0.5, UINT8_MAX);
	}
	
	CGContextSaveGState(context);
	
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextTranslateCTM(context, 0.0, -rect.size.height);
	
	CGContextDrawImage(context, rect, UIGraphicsGetImageFromCurrentImageContext().CGImage);
	
	CGContextRestoreGState(context);
	
	UIGraphicsEndImageContext();
	
	
	//
	// Bezel
	//
	UIBezierPath *bezelBezierPath = [UIBezierPath bezierPath];
	[bezelBezierPath moveToPoint:CGPointMake(rect.origin.x, kCameraTopHeight - 2.0)];
	[bezelBezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(rect), kCameraTopHeight - 2.0)];
	bezelBezierPath.lineWidth = 3.0;
	[[UIColor colorWithRed:0.106 green:0.087 blue:0.083 alpha:1.000] setStroke];
	[bezelBezierPath strokeWithBlendMode:kCGBlendModeSoftLight alpha:0.8];
	
	[bezelBezierPath removeAllPoints];
	[bezelBezierPath moveToPoint:CGPointMake(rect.origin.x, kCameraTopHeight + 1.0)];
	[bezelBezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(rect), kCameraTopHeight + 1.0)];
	bezelBezierPath.lineWidth = 1.0;
	[[UIColor colorWithRed:0.955 green:0.920 blue:0.876 alpha:1.000] setStroke];
	[bezelBezierPath strokeWithBlendMode:kCGBlendModeHardLight alpha:0.9];
	
	
	//
	// Badge
	//
	const CGFloat kBadgeWidth   = 78.0;
	const CGFloat kBadgeHeight  = 30.0;
	CGRect badgeBezierPathRect = CGRectMake(kColorStripeX + rintf(((CGRectGetMaxX(colorStripeBezierPathRect) - kColorStripeX) - kBadgeWidth) / 2), CGRectGetMaxY(cameraTopBezierPathRect) - rintf(kBadgeHeight / 2), kBadgeWidth, kBadgeHeight); // centered horizontally with color stripes, vertically with bezel
	CGFloat badgeBezierPathCornerRadius = floorf(badgeBezierPathRect.size.height / 2); // fully rounded corners
	UIBezierPath *badgeBezierPath = [UIBezierPath bezierPathWithRoundedRect:badgeBezierPathRect cornerRadius:badgeBezierPathCornerRadius];
	
	CGContextSaveGState(context);
	
	CGSize badgeTopShadowOffset	= CGSizeMake(0.0, -3.0);
	const CGFloat kBadgeShadowBlur = 1.0;
	CGColorRef badgeTopShadowColor = [UIColor colorWithRed:0.552 green:0.519 blue:0.468 alpha:1.000].CGColor;
	CGContextSetShadowWithColor(context, badgeTopShadowOffset, kBadgeShadowBlur, badgeTopShadowColor);
	
	[[UIColor colorWithRed:0.302 green:0.234 blue:0.210 alpha:1.000] setFill];
	[badgeBezierPath fill];
	
	CGSize badgeBottomShadowOffset = CGSizeMake(0.0, 3.0);
	CGColorRef badgeBottomShadowColor = [UIColor colorWithRed:0.145 green:0.115 blue:0.108 alpha:1.000].CGColor;
	CGContextSetShadowWithColor(context, badgeBottomShadowOffset, kBadgeShadowBlur, badgeBottomShadowColor);
	
	[[UIColor colorWithRed:0.302 green:0.234 blue:0.210 alpha:1.000] setFill];
	[badgeBezierPath fill];
	
	CGContextRestoreGState(context);
	
	NSString *const kBadgeString = @"INST";
	
	[[UIColor colorWithRed:0.111 green:0.090 blue:0.086 alpha:0.6] setFill];
	[kBadgeString drawInRect:badgeBezierPathRect withFont:[UIFont boldSystemFontOfSize:27.0] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
	[[UIColor colorWithRed:0.962 green:0.971 blue:0.955 alpha:0.9] setFill];
	[kBadgeString drawInRect:badgeBezierPathRect withFont:[UIFont boldSystemFontOfSize:24.0] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
	
	
	//
	// Lens Fitting With Shadow
	//
	CGContextSaveGState(context);
	
	CGSize lensFittingShadowOffset = CGSizeMake(0.0, 9.0);
	const CGFloat kLensFittingShadowBlur = 6.0;
	CGColorRef lensFittingShadowColor = [UIColor colorWithRed:0.247 green:0.086 blue:0.000 alpha:2.0/3.0].CGColor;
	CGContextSetShadowWithColor(context, lensFittingShadowOffset, kLensFittingShadowBlur, lensFittingShadowColor);
	
	CGFloat kLensFittingSize = rintf(rect.size.width / 2);
	CGRect lensFittingBezierPathRect = CGRectMake(rintf(rect.size.width/2 - kLensFittingSize/2), rintf(rect.size.height/2 - kLensFittingSize/2), kLensFittingSize, kLensFittingSize);
	UIBezierPath *lensFittingBezierPath = [UIBezierPath bezierPathWithOvalInRect:lensFittingBezierPathRect];
	[[UIColor colorWithRed:0.985 green:0.986 blue:0.975 alpha:1.000] setFill];
	[lensFittingBezierPath fill];
	
	CGContextRestoreGState(context);
	
	CGContextSaveGState(context);
	
	CGContextAddEllipseInRect(context, lensFittingBezierPathRect); // clipping is a trick to smooth radial gradient
	CGContextClip(context);
	
	CGColorSpaceRef lensFittingColorSpace = CGColorSpaceCreateDeviceRGB();
	
	const CGFloat kLensFittingColors[] = {
		0.871, 0.837, 0.795, 1.000, // 1 color per line
		0.747, 0.686, 0.669, 1.000, // 3 color comps for the specified color space (RGB) followed by the alpha component
		0.956, 0.940, 0.849, 1.000
	};
	
	const CGFloat kLensFittingLocations[] = {
		0.45,
		0.55,
		1.0
	};
	
	size_t lensFittingNumberOfLocations = sizeof(kLensFittingLocations) / sizeof(kLensFittingLocations[0]);
	
	CGGradientRef lensFittingGradient = CGGradientCreateWithColorComponents(lensFittingColorSpace,
																			kLensFittingColors,
																			kLensFittingLocations,
																			lensFittingNumberOfLocations);
	CGPoint lensFittingGradientCenter		= CGPointMake(rintf(lensFittingBezierPathRect.origin.x + lensFittingBezierPathRect.size.width/2), rintf(lensFittingBezierPathRect.origin.y + lensFittingBezierPathRect.size.height/2));
	CGFloat lensFittingGradientStartRadius	= rintf(kLensFittingSize / 2) + 1.0;
	CGFloat lensFittingGradientEndRadius	= rintf(kLensFittingSize / 2) - 10.0;
	CGContextDrawRadialGradient(context,
								lensFittingGradient,
								lensFittingGradientCenter, // in this case start and end center are both the same
								lensFittingGradientStartRadius,
								lensFittingGradientCenter,
								lensFittingGradientEndRadius,
								0);
	
	CGGradientRelease(lensFittingGradient);
	
	CGContextSetBlendMode(context, kCGBlendModeSoftLight);
	
	const CGFloat kLensFittingLightningColors[] = {
		0.9, 0.9, 0.9, 1.0,
		0.4, 0.4, 0.4, 1.0
	};
	
	lensFittingGradient = CGGradientCreateWithColorComponents(lensFittingColorSpace, kLensFittingLightningColors, NULL, 2);
	CGPoint lensFittingGradientStartPoint	= lensFittingBezierPathRect.origin;
	CGPoint lensFittingGradientEndPoint		= CGPointMake(lensFittingGradientStartPoint.x, CGRectGetMaxY(lensFittingBezierPathRect));
	CGContextDrawLinearGradient(context, lensFittingGradient, lensFittingGradientStartPoint, lensFittingGradientEndPoint, 0);
	
	CGColorSpaceRelease(lensFittingColorSpace);
	CGGradientRelease(lensFittingGradient);
	
	CGContextRestoreGState(context);
	
	
	//
	// Lens
	//
	CGRect lensBezierPathRect = CGRectInset(lensFittingBezierPathRect, 10.0, 10.0);
	UIBezierPath *lensBezierPath = [UIBezierPath bezierPathWithOvalInRect:lensBezierPathRect];
	[[UIColor colorWithRed:0.056 green:0.062 blue:0.094 alpha:1.000] setFill];
	[lensBezierPath fill];
	
	lensBezierPathRect = CGRectInset(lensBezierPathRect, 24.0, 24.0);
	lensBezierPath = [UIBezierPath bezierPathWithOvalInRect:lensBezierPathRect];
	[[UIColor colorWithRed:0.146 green:0.202 blue:0.195 alpha:1.000] setFill];
	[lensBezierPath fill];
	
	lensBezierPathRect = CGRectInset(lensBezierPathRect, 20.0, 20.0);
	lensBezierPath = [UIBezierPath bezierPathWithOvalInRect:lensBezierPathRect];
	[[UIColor colorWithRed:0.046 green:0.044 blue:0.057 alpha:1.000] setFill];
	[lensBezierPath fill];
	
	lensBezierPathRect = CGRectInset(lensBezierPathRect, 3.0, 3.0);
	lensBezierPath = [UIBezierPath bezierPathWithOvalInRect:lensBezierPathRect];
	[[UIColor colorWithRed:0.223 green:0.169 blue:0.250 alpha:1.000] setFill];
	[lensBezierPath fill];
	
	
	// reflection
	CGContextSaveGState(context);
	
	CGContextSetBlendMode(context, kCGBlendModeLighten);
	
	[[UIColor colorWithWhite:1.0 alpha:0.09] setFill];
	[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(190.0, 182.0, 12.0, 7.0)] fill];
	
	CGColorSpaceRef lensReflectionColorSpace = CGColorSpaceCreateDeviceRGB();
	
	const CGFloat kLensReflection1Colors[] = {
		0.286, 0.233, 0.768, 0.4,
		0.562, 0.336, 0.646, 0.3
	};
	
	CGGradientRef lensReflectionGradient = CGGradientCreateWithColorComponents(lensReflectionColorSpace, kLensReflection1Colors, NULL, 2);
	
	CGPoint lensReflectionGradientStartCenter = CGPointMake(165.0, 165.0);
	CGFloat lensReflectionGradientStartRadius = 35.0;
	
	CGPoint lensReflectionGradientEndCenter = CGPointMake(203.0, 193.0);
	CGFloat lensReflectionGradientEndRadius = 5.0;
	
	CGContextDrawRadialGradient(context,
								lensReflectionGradient,
								lensReflectionGradientStartCenter,
								lensReflectionGradientStartRadius,
								lensReflectionGradientEndCenter,
								lensReflectionGradientEndRadius,
								0);
	
	CGGradientRelease(lensReflectionGradient);
	
	
	const CGFloat kLensReflection2Colors[] = {
		0.281, 0.501, 0.530, 0.5,
		0.562, 0.336, 0.646, 0.2
	};
	
	lensReflectionGradient = CGGradientCreateWithColorComponents(lensReflectionColorSpace, kLensReflection2Colors, NULL, 2);
	
	lensReflectionGradientStartCenter = CGPointMake(260.0, 190.0);
	lensReflectionGradientStartRadius = 33.0;
	
	lensReflectionGradientEndCenter = CGPointMake(197.0, 204.0);
	lensReflectionGradientEndRadius = 3.0;
	
	CGContextDrawRadialGradient(context,
								lensReflectionGradient,
								lensReflectionGradientStartCenter,
								lensReflectionGradientStartRadius,
								lensReflectionGradientEndCenter,
								lensReflectionGradientEndRadius,
								0);
	
	CGGradientRelease(lensReflectionGradient);
	CGColorSpaceRelease(lensReflectionColorSpace);
	
	//      3/2 PI
	//       _v_
	//      /   \
	// PI->|     |<-0,2 PI
	//      \___/
	//        ^
	//      PI/2
	UIBezierPath *lensReflectionBezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(rintf(lensFittingBezierPathRect.origin.x + lensFittingBezierPathRect.size.width/2), rintf(lensFittingBezierPathRect.origin.y + lensFittingBezierPathRect.size.height/2))
																			radius:86.0
																		startAngle:M_PI*0.9
																		  endAngle:M_PI*1.7
																		 clockwise:YES];
	[lensReflectionBezierPath addArcWithCenter:CGPointMake(239.0, 157.0)
										radius:28.0
									startAngle:M_PI*1.8
									  endAngle:M_PI*0.35
									 clockwise:YES];
	[lensReflectionBezierPath addLineToPoint:CGPointMake(160.0, 240.0)];
	[lensReflectionBezierPath addArcWithCenter:CGPointMake(143.0, 221.0)
										radius:25.0
									startAngle:M_PI*0.3
									  endAngle:M_PI*0.9
									 clockwise:YES];
	[lensReflectionBezierPath closePath];
	
	[[UIColor colorWithWhite:1.0 alpha:0.08] setFill];
	[lensReflectionBezierPath fill];
	
	
	[lensReflectionBezierPath removeAllPoints];
	[lensReflectionBezierPath moveToPoint:CGPointMake(212.0, 165.0)];
	[lensReflectionBezierPath addLineToPoint:CGPointMake(228.0, 154.0)];
	[lensReflectionBezierPath addLineToPoint:CGPointMake(239.0, 172.0)];
	[lensReflectionBezierPath addLineToPoint:CGPointMake(230.0, 178.0)];
	[lensReflectionBezierPath closePath];
	
	[[UIColor colorWithWhite:1.0 alpha:0.2] setFill];
	[lensReflectionBezierPath fill];
	
	CGAffineTransform lensReflectionBezierPathTransform = CGAffineTransformMakeScale(0.65, 0.55);
	lensReflectionBezierPathTransform = CGAffineTransformTranslate(lensReflectionBezierPathTransform, 144.0, 164.0);
	[lensReflectionBezierPath applyTransform:lensReflectionBezierPathTransform];
	[lensReflectionBezierPath fill];
	
	CGContextRestoreGState(context);
	
	
	//
	// Rangefinder Fitting
	//
	CGContextSaveGState(context);
	
	CGRect rangefinderFittingBezierPathRect = CGRectMake(268.0, 31.0, 83.0, 83.0);
	UIBezierPath *rangefinderFittingBezierPath = [UIBezierPath bezierPathWithRoundedRect:rangefinderFittingBezierPathRect cornerRadius:17.0];
	[rangefinderFittingBezierPath addClip];
	
	CGContextSetBlendMode(context, kCGBlendModeSoftLight);
	
	CGColorSpaceRef rangefinderFittingColorSpace = CGColorSpaceCreateDeviceRGB();
	
	const CGFloat kRangefinderFittingColors[] = {
		0.106, 0.085, 0.061, 0.8,
		1.000, 0.840, 0.669, 0.8
	};
	
	CGGradientRef rangefinderFittingGradient = CGGradientCreateWithColorComponents(rangefinderFittingColorSpace, kRangefinderFittingColors, NULL, 2);
	CGPoint rangefinderFittingGradientStartPoint	= CGPointMake(290.0, 40.0);
	CGPoint rangefinderFittingGradientEndPoint		= CGPointMake(315.0, 120.0);
	CGContextDrawLinearGradient(context,
								rangefinderFittingGradient,
								rangefinderFittingGradientStartPoint,
								rangefinderFittingGradientEndPoint,
								kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	
	CGColorSpaceRelease(rangefinderFittingColorSpace);
	CGGradientRelease(rangefinderFittingGradient);
	
	CGContextRestoreGState(context);
	
	
	//
	// Rangefinder
	//
	CGRect rangefinderLensBezierPathRect = CGRectInset(rangefinderFittingBezierPathRect, 4.0, 4.0);
	UIBezierPath *rangefinderLensBezierPath = [UIBezierPath bezierPathWithRoundedRect:rangefinderLensBezierPathRect cornerRadius:14.0];
	[[UIColor colorWithWhite:0.1 alpha:1.0] setFill];
	[rangefinderLensBezierPath fill];
	
	rangefinderLensBezierPathRect = CGRectInset(rangefinderLensBezierPathRect, 11.0, 11.0);
	rangefinderLensBezierPath = [UIBezierPath bezierPathWithOvalInRect:rangefinderLensBezierPathRect];
	[[UIColor blackColor] setFill];
	[rangefinderLensBezierPath fill];
	
	rangefinderLensBezierPathRect = CGRectInset(rangefinderLensBezierPathRect, 3.0, 3.0);
	rangefinderLensBezierPath = [UIBezierPath bezierPathWithOvalInRect:rangefinderLensBezierPathRect];
	[[UIColor colorWithWhite:0.08 alpha:1.0] setFill];
	[rangefinderLensBezierPath fill];
	
	rangefinderLensBezierPathRect = CGRectInset(rangefinderLensBezierPathRect, 2.0, 2.0);
	rangefinderLensBezierPath = [UIBezierPath bezierPathWithOvalInRect:rangefinderLensBezierPathRect];
	[[UIColor blackColor] setFill];
	[rangefinderLensBezierPath fill];
	
	
	// reflection
	CGContextSaveGState(context);
	
	CGContextSetBlendMode(context, kCGBlendModeLighten);
	
	[[UIColor colorWithWhite:1.0 alpha:0.06] setFill];
	[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(306.0, 66.0, 6.0, 4.0)] fill];
	
	[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(146.0, 12.0, 200.0, 90.0)] addClip];
	
	CGRect rangefinderReflectionBezierPathRect = CGRectInset(rangefinderFittingBezierPathRect, 6.0, 6.0);
	UIBezierPath *rangefinderReflectionBezierPath = [UIBezierPath bezierPathWithRoundedRect:rangefinderReflectionBezierPathRect cornerRadius:16.0];
	[rangefinderReflectionBezierPath fill];
	
	
	[rangefinderReflectionBezierPath removeAllPoints];
	[rangefinderReflectionBezierPath moveToPoint:CGPointMake(318.0, 54.0)];
	[rangefinderReflectionBezierPath addLineToPoint:CGPointMake(327.0, 47.0)];
	[rangefinderReflectionBezierPath addLineToPoint:CGPointMake(333.0, 57.0)];
	[rangefinderReflectionBezierPath addLineToPoint:CGPointMake(326.0, 61.0)];
	[rangefinderReflectionBezierPath closePath];
	
	[[UIColor colorWithWhite:1.0 alpha:0.22] setFill];
	[rangefinderReflectionBezierPath fill];
	
	CGAffineTransform rangefinderReflectionBezierPathTransform = CGAffineTransformMakeScale(0.7, 0.5);
	rangefinderReflectionBezierPathTransform = CGAffineTransformTranslate(rangefinderReflectionBezierPathTransform, 149.0, 72.0);
	[rangefinderReflectionBezierPath applyTransform:rangefinderReflectionBezierPathTransform];
	[rangefinderReflectionBezierPath fill];
	
	CGContextRestoreGState(context);
	
	
	//
	// Camera Inner Shadow
	//
	CGContextSetBlendMode(context, kCGBlendModeHardLight);
	
	// top
	CGContextSaveGState(context);
	
	const CGFloat kCameraShadowInsetTop = 8.0;
	CGContextAddRect(context, UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(kCameraShadowInsetTop, cameraBezierPathCornerRadii.width, 0.0, cameraBezierPathCornerRadii.width)));
	CGContextClip(context);
	
	CGColorSpaceRef cameraShadowGradientColorSpace = CGColorSpaceCreateDeviceRGB();
	
	const CGFloat kCameraShadowGradientColors[] = {
		0.129, 0.099, 0.074, 0.7,
		0.477, 0.383, 0.293, 0.0
	};
	
	const CGFloat kCameraShadowGradientLocations[] = {
		0.1,
		1.0
	};
	
	size_t cameraShadowGradientNumberOfLocations = sizeof(kCameraShadowGradientLocations) / sizeof(kCameraShadowGradientLocations[0]);
	
	CGGradientRef cameraShadowGradient = CGGradientCreateWithColorComponents(cameraShadowGradientColorSpace,
																			 kCameraShadowGradientColors,
																			 kCameraShadowGradientLocations,
																			 cameraShadowGradientNumberOfLocations);
	const CGFloat kCameraShadowSize = 25.0;
	CGPoint linearCameraShadowGradientStartPoint	= CGPointMake(rect.origin.x, rect.origin.y + kCameraShadowInsetTop);
	CGPoint linearCameraShadowGradientEndPoint		= CGPointMake(rect.origin.x, rect.origin.y + kCameraShadowInsetTop + kCameraShadowSize);
	CGContextDrawLinearGradient(context, cameraShadowGradient, linearCameraShadowGradientStartPoint, linearCameraShadowGradientEndPoint, 0);
	
	CGContextRestoreGState(context);
	
	// bottom
	CGContextSaveGState(context);
	
	CGContextAddRect(context, UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0.0, cameraBezierPathCornerRadii.width, 0.0, cameraBezierPathCornerRadii.width)));
	CGContextClip(context);
	
	linearCameraShadowGradientStartPoint	= CGPointMake(rect.origin.x, CGRectGetMaxY(rect));
	linearCameraShadowGradientEndPoint		= CGPointMake(rect.origin.x, CGRectGetMaxY(rect) - kCameraShadowSize);
	CGContextDrawLinearGradient(context, cameraShadowGradient, linearCameraShadowGradientStartPoint, linearCameraShadowGradientEndPoint, 0);
	
	CGContextRestoreGState(context);
	
	// left
	CGContextSaveGState(context);
	
	CGContextAddRect(context, UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(kCameraShadowInsetTop + cameraBezierPathCornerRadii.height, 0.0, cameraBezierPathCornerRadii.height, 0.0)));
	CGContextClip(context);
	
	linearCameraShadowGradientStartPoint	= rect.origin;
	linearCameraShadowGradientEndPoint		= CGPointMake(rect.origin.x + kCameraShadowSize, rect.origin.y);
	CGContextDrawLinearGradient(context, cameraShadowGradient, linearCameraShadowGradientStartPoint, linearCameraShadowGradientEndPoint, 0);
	
	CGContextRestoreGState(context);
	
	// right
	CGContextSaveGState(context);
	
	CGContextAddRect(context, UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(kCameraShadowInsetTop + cameraBezierPathCornerRadii.height, 0.0, cameraBezierPathCornerRadii.height, 0.0)));
	CGContextClip(context);
	
	linearCameraShadowGradientStartPoint	= CGPointMake(CGRectGetMaxX(rect), rect.origin.y);
	linearCameraShadowGradientEndPoint		= CGPointMake(CGRectGetMaxX(rect) - kCameraShadowSize, rect.origin.y);
	CGContextDrawLinearGradient(context, cameraShadowGradient, linearCameraShadowGradientStartPoint, linearCameraShadowGradientEndPoint, 0);
	
	CGContextRestoreGState(context);
	
	// top left corner
	CGContextSaveGState(context);
	
	CGContextAddRect(context, CGRectMake(rect.origin.x, rect.origin.y + kCameraShadowInsetTop, cameraBezierPathCornerRadii.width, cameraBezierPathCornerRadii.height));
	CGContextClip(context);
	
	CGPoint radialCameraShadowGradientCenter = CGPointMake(rect.origin.x + cameraBezierPathCornerRadii.width, rect.origin.y + kCameraShadowInsetTop + cameraBezierPathCornerRadii.height);
	CGContextDrawRadialGradient(context,
								cameraShadowGradient,
								radialCameraShadowGradientCenter,
								cameraBezierPathCornerRadii.width,
								radialCameraShadowGradientCenter,
								kCameraShadowSize,
								0);
	
	CGContextRestoreGState(context);
	
	// top right corner
	CGContextSaveGState(context);
	
	CGContextAddRect(context, CGRectMake(CGRectGetMaxX(rect) - cameraBezierPathCornerRadii.width, rect.origin.y + kCameraShadowInsetTop, cameraBezierPathCornerRadii.width, cameraBezierPathCornerRadii.height));
	CGContextClip(context);
	
	radialCameraShadowGradientCenter = CGPointMake(CGRectGetMaxX(rect) - cameraBezierPathCornerRadii.width, rect.origin.y + kCameraShadowInsetTop + cameraBezierPathCornerRadii.height);
	CGContextDrawRadialGradient(context,
								cameraShadowGradient,
								radialCameraShadowGradientCenter,
								cameraBezierPathCornerRadii.width,
								radialCameraShadowGradientCenter,
								kCameraShadowSize,
								0);
	
	CGContextRestoreGState(context);
	
	// bottom left corner
	CGContextSaveGState(context);
	
	CGContextAddRect(context, CGRectMake(rect.origin.x, CGRectGetMaxY(rect) - cameraBezierPathCornerRadii.height, cameraBezierPathCornerRadii.width, cameraBezierPathCornerRadii.height));
	CGContextClip(context);
	
	radialCameraShadowGradientCenter = CGPointMake(rect.origin.x + cameraBezierPathCornerRadii.width, CGRectGetMaxY(rect) - cameraBezierPathCornerRadii.height);
	CGContextDrawRadialGradient(context,
								cameraShadowGradient,
								radialCameraShadowGradientCenter,
								cameraBezierPathCornerRadii.width,
								radialCameraShadowGradientCenter,
								kCameraShadowSize,
								0);
	
	CGContextRestoreGState(context);
	
	// bottom right corner
	CGContextSaveGState(context);
	
	CGContextAddRect(context, CGRectMake(CGRectGetMaxX(rect) - cameraBezierPathCornerRadii.width, CGRectGetMaxY(rect) - cameraBezierPathCornerRadii.height, cameraBezierPathCornerRadii.width, cameraBezierPathCornerRadii.height));
	CGContextClip(context);
	
	radialCameraShadowGradientCenter = CGPointMake(CGRectGetMaxX(rect) - cameraBezierPathCornerRadii.width, CGRectGetMaxY(rect) - cameraBezierPathCornerRadii.height);
	CGContextDrawRadialGradient(context,
								cameraShadowGradient,
								radialCameraShadowGradientCenter,
								cameraBezierPathCornerRadii.width,
								radialCameraShadowGradientCenter,
								kCameraShadowSize,
								0);
	
	CGContextRestoreGState(context);
	
	
	CGGradientRelease(cameraShadowGradient);
	CGColorSpaceRelease(cameraShadowGradientColorSpace);
	
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	
	
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
		CGContextRestoreGState(context);
	}
	
	
	// Conclusions:
	// - I reached the goal within the conditions and like the result, especially rendered on the device.
	// - In shipping apps always favor prerendered pixel graphics over a lot of drawing code where applicable (e.g. this).
	// - Code could be reduced by refactoring similar blocks in generic methods.
	// - I try to get rid of all magic numbers with something like: const CGFloat kLensWidth = 50.0; unless it's for a purely aesthetic purpose.
	// - At some points I tried to use another technique than already used (e.g. transform an existing shape).
	// - I like my quick implementation of multiplicative monochrome normal distributed saturated noise for this (formula from Wikipedia).
	// - I used higher level UIKit methods where possible.
	// - I favor rect.origin.x over CGRectGetMinX(rect), CGRectGetMaxX(rect) however is more convenient than (rect.origin.x + rect.size.width).
	// - Edges of curves are rendered pretty choppy, a trick I found to smooth those is clipping the graphics context along the edge.
	// - The custom "Developer Color Picker" for picking and generating UIColors is a winner.
	// - Calling this -drawRect: is probably pretty expensive and the performance (blending etc.) is not optimized at all.
	// - I quickly tried calling -drawRect: with 320x320 for iPhone and it of course gets messed up, scaling the current graphics context to fit the screen does the trick.
}


@end
