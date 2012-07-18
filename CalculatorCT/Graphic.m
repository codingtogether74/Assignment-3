//
//  Graphic.m
//  Graph
//
//  Created by Olga Avanesova on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Graphic.h"
#import "AxesDrawer.h"
@implementation Graphic

@synthesize dataSource=_dataSource;
@synthesize origin=_origin;
@synthesize scale=_scale;

#define DEFAULT_SCALE 20.0;
#define DEFAULT_ORIGIN_X 0.0
#define DEFAULT_ORIGIN_Y 0.0


-(CGPoint)origin
{
/*    if (_origin.x==0 && _origin.y==0) {
        return [self retrieveFromUserDefaultsOrigin];
    }else {
        return _origin;
   }
*/      
     return _origin;
}

-(void)setOrigin:(CGPoint)origin
{
    if (origin.x!=_origin.x || origin.y != _origin.y) {
        _origin=origin;
        [self setNeedsDisplay];
//        [self saveToUserDefaultsOrgin:origin];
    }    
}

-(CGFloat)scale
{
    if(!_scale) return  DEFAULT_SCALE         //[self retrieveFromUserDefaultsScale];
    else return _scale;
}

-(void)setScale:(CGFloat)scale
{
    if (scale!=_scale) {
       _scale=scale;
       [self setNeedsDisplay];
//        [self saveToUserDefaultsScale:scale];
    }    
}

-(void)setup
{
    self.contentMode=UIViewContentModeRedraw;
}
 -(void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)pinch:(UIPinchGestureRecognizer *)gesture
{
if (gesture.state==UIGestureRecognizerStateChanged ||
    gesture.state==UIGestureRecognizerStateEnded)
    self.scale*=gesture.scale;
    gesture.scale=1.0;
    
}

-(void)pan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state==UIGestureRecognizerStateChanged ||
        gesture.state==UIGestureRecognizerStateEnded){
        CGPoint translation=[gesture translationInView:self];
        self.origin=CGPointMake(self.origin.x+translation.x, self.origin.y+translation.y);
        [gesture setTranslation:CGPointZero inView:self];
    } 
}

-(void)tripleTap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state==UIGestureRecognizerStateEnded){
        CGPoint tapPoint=[gesture locationInView:self];
        self.origin=CGPointMake(tapPoint.x-self.bounds.size.width/2.0, tapPoint.y-self.bounds.size.height/2.0);
    } 
}

const CGFloat darkRedColorValues[] = {1.0, 0.2, 0.2, 1.0};

#define DOT_RADIUS 0.5


// For every pixel on the screen, figure out it's "value", evaluate it, and then
// convert that value back to the coordinate system
//
// The arithmetic here is counter-intuitive since the X coordinates increase from
// left to right, while the Y coordinates decrease from top to bottom.
// 
// We loop over the X values of the currentPoint (x,y struct) and store the 
// pixel value we get back in the Y value of currentPoint.

- (void) plotGraphInContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
 //---------draw line graph---------- 
    CGContextSetLineWidth(context, 1.0);
    [[UIColor redColor] setStroke];
    [[UIColor blueColor] setFill];
    
    CGContextBeginPath(context);
    CGPoint beforePoint;
    BOOL beforePointIsEmpty =1;
    
    BOOL isProgramValid=[self.dataSource validProgram];
    
    if (isProgramValid){
        for (int i=0-self.origin.x; i<self.bounds.size.width-self.origin.x; i++) {
            CGPoint point;
            point.x=i+self.origin.x;
            double xValueAtPoint=i/self.scale-self.bounds.size.width/(2*self.scale);
            
            double yValueAtPoint=[self.dataSource yForGraphic:self withXValue:xValueAtPoint];
            
            point.y=-self.scale* yValueAtPoint+self.bounds.size.height/2.0+self.origin.y;
            if ([self.dataSource drawLinesForGraphView:self]) {
                CGContextMoveToPoint(context, beforePoint.x, beforePoint.y);
                if (!beforePointIsEmpty) CGContextAddLineToPoint(context, point.x, point.y);
            }   
            else {            
                
                [self drawCircleAtPoint:point withRadius:DOT_RADIUS inContext:context];
            }
            beforePointIsEmpty=0;
            beforePoint=point;
            CGContextStrokePath(context);
            
        }
    }    
    UIGraphicsPopContext();
}

- (void)drawCircleAtPoint:(CGPoint)p withRadius:(CGFloat)radius inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    CGContextAddArc(context, p.x, p.y, radius, 0, 2*M_PI, YES); // 360 degree (0 to 2pi) arc
    CGContextStrokePath(context);
    UIGraphicsPopContext();
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context=UIGraphicsGetCurrentContext();
     
    //---------draw axes----
    CGPoint axesOrigin;
    axesOrigin.x=self.origin.x+self.bounds.size.width/2.0;
    axesOrigin.y=self.origin.y+self.bounds.size.height/2.0;
    CGRect bounds=self.bounds;

    CGContextSetLineWidth(context, 2.0);
    [[UIColor blueColor] setStroke];
    
    [AxesDrawer drawAxesInRect:bounds originAtPoint:axesOrigin scale:self.scale];
   [self plotGraphInContext:context];
    
 }

-(void)saveToUserDefaultsOrgin:(CGPoint)origin
{
    NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setFloat:origin.x forKey:@"Default Origin X"];
        [standardUserDefaults setFloat:origin.y forKey:@"Default Origin Y"];
        [standardUserDefaults synchronize];
    }
}

-(CGPoint)retrieveFromUserDefaultsOrigin
{
    NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
    CGPoint origin=CGPointMake(DEFAULT_ORIGIN_X, DEFAULT_ORIGIN_Y);
    if (standardUserDefaults) {
        origin.x=[standardUserDefaults floatForKey:@"Default Origin X"];
        origin.y=[standardUserDefaults floatForKey:@"Default Origin Y"];
    }
    return origin;
}


-(void)saveToUserDefaultsScale:(CGFloat)scale
{
    NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setFloat:scale forKey:@"Default Scale"];
        [standardUserDefaults synchronize];
    }
}

-(float)retrieveFromUserDefaultsScale
{
    NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
    float scale=DEFAULT_SCALE;
    if (standardUserDefaults) {
        scale=[standardUserDefaults floatForKey:@"Default Scale"];
    }
    return scale;
}

@end
