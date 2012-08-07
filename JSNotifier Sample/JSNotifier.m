/*
Copyright 2012 Jonah Siegle

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "JSNotifier.h"
#define _displaytime 4.f

const CGFloat kHeight = 40;

@implementation JSNotifier
@synthesize accessoryView, title = _title;
@synthesize didShowBlock, didHideBlock;

CGFloat JSStatusHeight()
{
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        return statusBarFrame.size.width;
    }
        
    return statusBarFrame.size.height;
}

CGRect JSScreenBounds()
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        CGFloat width = bounds.size.width;
        bounds.size.width = bounds.size.height;
        bounds.size.height = width;
    }
    
    return bounds;
}

- (id)initWithTitle:(NSString *)title
{
    self = [self initWithTitle:title position:JSNotifierPositionBottom];
    
    return self;
}

- (id)initWithTitle:(NSString *)title position:(JSNotifierPosition)position {
    
    CGRect screenBounds = JSScreenBounds();
    CGFloat top = 0;
    CGFloat width = screenBounds.size.width;
    
    switch (position) {
        case JSNotifierPositionBottom:
            top = screenBounds.size.height;
            break;
            
        default:
            top = JSStatusHeight() - kHeight;
            break;
    }
    
    if (self = [super initWithFrame:CGRectMake(0, top, width, kHeight)]){
    
        _position = position;
        
        self.backgroundColor = [UIColor clearColor];
        
        _txtLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 12, self.frame.size.width - 0, 20)];
        [_txtLabel setFont:[UIFont fontWithName: @"Helvetica" size: 16]];
        [_txtLabel setBackgroundColor:[UIColor clearColor]];
        
        [_txtLabel setTextColor:[UIColor whiteColor]];
        
        _txtLabel.layer.shadowOffset =CGSizeMake(0, -0.5);
        _txtLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _txtLabel.layer.shadowOpacity = 1.0;
        _txtLabel.layer.shadowRadius = 1;

        _txtLabel.layer.masksToBounds = NO;
        
        [self addSubview:_txtLabel];
        
        self.title= title;

        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        if (_position == JSNotifierPositionBottom)
        {
            self.autoresizingMask |= UIViewAutoresizingFlexibleTopMargin;
        }
        self.contentMode = UIViewContentModeRedraw;
        
        [[[UIApplication sharedApplication].keyWindow.subviews objectAtIndex:0] addSubview:self];
    }
    
    return self;
}

- (void)setAccessoryView:(UIView *)__accessoryView{
        
    [[self viewWithTag:1]removeFromSuperview];
    
    __accessoryView.tag = 1;
    [__accessoryView setFrame:CGRectMake(12, ((self.frame.size.height -__accessoryView.frame.size.height)/2)+1, __accessoryView.frame.size.width, __accessoryView.frame.size.height)];
    
    [self addSubview:__accessoryView];
    
    if (__accessoryView)
        [_txtLabel setFrame:CGRectMake(38, 12, self.frame.size.width - 38, 20)];
    else
        [_txtLabel setFrame:CGRectMake(8, 12, self.frame.size.width - 8, 20)];
}

- (void)setTitle:(NSString *)title{
    
    [_txtLabel setText:title];
}

-(UILineBreakMode)lineBreakMode
{
    return _txtLabel.lineBreakMode;
}

-(void)setLineBreakMode:(UILineBreakMode)lineBreakMode
{
    _txtLabel.lineBreakMode = lineBreakMode;
}

- (void)show{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(notifierDidShow)];
    
    CGFloat offset = 0;
    switch (_position)
    {
        case JSNotifierPositionBottom:
            offset = -kHeight;
            break;
        default:
            offset = kHeight;
            break;
    }
    
    CGRect move = self.frame;
    move.origin.y += offset;
    self.frame = move;
    
    [UIView commitAnimations];
      
}

- (void)showFor:(float)time{
    
    [self show];
    [self hideIn:time];
}

-(void)notifierDidShow
{
    if (didShowBlock)
    {
        didShowBlock();
    }
}

- (void)hideIn:(float)seconds{
    
    __block JSNotifier *blockSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        
        [blockSelf hide];
        
    });

}

- (void)hide{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationDelegate: self]; //or some other object that has necessary method
    [UIView setAnimationDidStopSelector: @selector(notifierDidHide)];
    
    CGFloat offset = 0;
    switch (_position)
    {
        case JSNotifierPositionBottom:
            offset = kHeight;
            break;
            
        default:
            offset = -kHeight;
            break;
    }
    
    CGRect move = self.frame;
    move.origin.y += offset;
    self.frame = move;
        
    [UIView commitAnimations];
}

-(void)notifierDidHide
{
    if (didHideBlock)
    {
        didHideBlock();
    }
    [self removeFromSuperview];
}


- (void)setAccessoryView:(UIView *)view animated:(BOOL)animated{

    if (!animated){
    [[self viewWithTag:1]removeFromSuperview];
    view.tag = 1;
    }
    
    [view setFrame:CGRectMake(12, ((self.frame.size.height -view.frame.size.height)/2)+1, view.frame.size.width, view.frame.size.height)];
    [self addSubview:view];
    
    if (animated) {
        view.alpha = 0.0;
        
        if ([self viewWithTag:1])
            view.tag = 0;
        else
            view.tag = 2;
    [UIView animateWithDuration:0.5
                     animations:^{
                         if ([self viewWithTag:1])
                            [self viewWithTag:1].alpha = 0.0;
                         else
                             view.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         
                         [[self viewWithTag:1]removeFromSuperview];
                         
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              view.alpha = 1.0;
                                              
                                          }
                                          completion:^(BOOL finished){
                                              
                                              view.tag = 1;
                                          }];
                         
                     }];
    }
    
    if (view)
        [_txtLabel setFrame:CGRectMake(38, 12, self.frame.size.width - 38, 20)];
    else
        [_txtLabel setFrame:CGRectMake(8, 12, self.frame.size.width - 8, 20)];



}

- (void)setTitle:(id)title animated:(BOOL)animated{
    
    float duration = 0.0;
    
    if (animated)
        duration = 0.5;
    
    [UIView animateWithDuration:duration
                     animations:^{
                      
                         _txtLabel.alpha = 0.0f;
                             
                     }
                     completion:^(BOOL finished){
                         
                         _txtLabel.text = title;
                         
                         [UIView animateWithDuration:duration
                                          animations:^{
                                              _txtLabel.alpha = 1.0f;

                                              
                                          }
                                          completion:^(BOOL finished){
                                              
                                          }];
                         
                     }];

}

- (void)drawRect:(CGRect)rect{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    //Background color
    CGRect rectangle = CGRectMake(0,4,rect.size.width,36);
    CGContextAddRect(context, rectangle);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f].CGColor);
    CGContextFillRect(context, rectangle);
    
    //First whiteColor
    CGContextSetLineWidth(context, 1.0);
    CGFloat componentsWhiteLine[] = {1.0, 1.0, 1.0, 0.35};
    CGColorRef Whitecolor = CGColorCreate(colorspace, componentsWhiteLine);
    CGContextSetStrokeColorWithColor(context, Whitecolor);
    
    CGContextMoveToPoint(context, 0, 4.5);
    CGContextAddLineToPoint(context, rect.size.width, 4.5);
    
    CGContextStrokePath(context);
    CGColorRelease(Whitecolor);
    
    //First whiteColor
    CGContextSetLineWidth(context, 1.0);
    CGFloat componentsBlackLine[] = {0.0, 0.0, 0.0, 1.0};
    CGColorRef Blackcolor = CGColorCreate(colorspace, componentsBlackLine);
    CGContextSetStrokeColorWithColor(context, Blackcolor);
    
    CGContextMoveToPoint(context, 0, 3.5);
    CGContextAddLineToPoint(context, rect.size.width, 3.5);
    
    CGContextStrokePath(context);
    CGColorRelease(Blackcolor);
    
    //Draw Shadow
    
    CGRect imageBounds = CGRectMake(0.0f, 0.0f, rect.size.width, 3.f);
	CGRect bounds = CGRectMake(0, 0, rect.size.width, 3);
	CGFloat alignStroke;
	CGFloat resolution;
	CGMutablePathRef path;
	CGRect drawRect;
	CGGradientRef gradient;
	NSMutableArray *colors;
	UIColor *color;
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGPoint point;
	CGPoint point2;
	CGAffineTransform transform;
	CGMutablePathRef tempPath;
	CGRect pathBounds;
	CGFloat locations[2];
	resolution = 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// Layer 1
	
	alignStroke = 0.0f;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(0.0f, 0.0f, rect.size.width, 3.0f);
	drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	CGPathAddRect(path, NULL, drawRect);
	colors = [NSMutableArray arrayWithCapacity:2];
	color = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
	[colors addObject:(id)[color CGColor]];
	locations[0] = 0.0f;
	color = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.18f];
	[colors addObject:(id)[color CGColor]];
	locations[1] = 1.0f;
	gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, locations);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	transform = CGAffineTransformMakeRotation(-1.571f);
	tempPath = CGPathCreateMutable();
	CGPathAddPath(tempPath, &transform, path);
	pathBounds = CGPathGetPathBoundingBox(tempPath);
	point = pathBounds.origin;
	point2 = CGPointMake(CGRectGetMaxX(pathBounds), CGRectGetMinY(pathBounds));
	transform = CGAffineTransformInvert(transform);
	point = CGPointApplyAffineTransform(point, transform);
	point2 = CGPointApplyAffineTransform(point2, transform);
	CGPathRelease(tempPath);
	CGContextDrawLinearGradient(context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
	CGContextRestoreGState(context);
	CGGradientRelease(gradient);
	CGPathRelease(path);
	
	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);

    CGColorSpaceRelease(colorspace);
}
    
@end
