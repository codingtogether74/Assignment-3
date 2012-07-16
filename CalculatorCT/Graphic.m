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


-(void)setOrigin:(CGPoint)origin
{
    if (origin.x!=_origin.x || origin.y != _origin.y) {
        _origin=origin;
        [self setNeedsDisplay];
    }    
}

-(CGFloat)scale
{
    if (!_scale) {
        return DEFAULT_SCALE;
    }else {
        return _scale;
    }
}

-(void)setScale:(CGFloat)scale
{
    if (scale!=_scale) {
       _scale=scale;
       [self setNeedsDisplay];
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
    
//---------draw graph---------- 
    CGContextSetLineWidth(context, 1.0);
    [[UIColor redColor] setStroke];

    CGContextBeginPath(context);
    CGPoint beforePoint;
    BOOL beforePointIsEmpty =1;
    for (int i=0-self.origin.x; i<self.bounds.size.width-self.origin.x; i++) {
        CGPoint point;
        point.x=i+self.origin.x;
        double xValueAtPoint=i/self.scale-self.bounds.size.width/(2*self.scale);
        
        double yValueAtPoint=[self.dataSource yForGraphic:self withXValue:xValueAtPoint];
        
        point.y=-self.scale* yValueAtPoint+self.bounds.size.height/2.0+self.origin.y;
        CGContextMoveToPoint(context, beforePoint.x, beforePoint.y);
        
        if (!beforePointIsEmpty) CGContextAddLineToPoint(context, point.x, point.y);
        beforePointIsEmpty=0;
        beforePoint=point;
        CGContextStrokePath(context);
        
    }
}

@end
