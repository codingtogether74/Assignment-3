//
//  GraphViewController.m
//  Graph
//
//  Created by Olga Avanesova on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "Graphic.h"
#import "CalculatorBrain.h"

@interface GraphViewController () <GraphViewDataSource>
@property (nonatomic, weak) IBOutlet Graphic *graphicView;
@end

@implementation GraphViewController

@synthesize program=_program;
@synthesize graphicView=_graphicView;

-(void)setProgram:(id)program
{
    _program=program;
	// We want to set the title of the controller if the program changes
	self.title = [NSString stringWithFormat:@"y = %@", 
                  [CalculatorBrain descriptionOfProgram:self.program]];
    [self.graphicView setNeedsDisplay];
}
-(void)setGraphicView:(Graphic *)graphicView
{
    _graphicView=graphicView;
    [self.graphicView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphicView action:@selector(pinch:)]];
    [self.graphicView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphicView action:@selector(pan:)]];
    UITapGestureRecognizer *tripleTap=[[UITapGestureRecognizer alloc] initWithTarget:self.graphicView action:@selector(tripleTap:)];
    tripleTap.numberOfTapsRequired=3;
    [self.graphicView addGestureRecognizer:tripleTap];
    self.graphicView.dataSource=self;
}
-(double)yForGraphic:(Graphic *)sender withXValue:(double)xValue
{
	// Find the corresponding Y value by passing the x value to the calculator Brain
	id yValue = [CalculatorBrain runProgram:self.program usingVariableValues:
                 [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:xValue] 
                                             forKey:@"x"]];
	
    if (![yValue isKindOfClass:[NSString class]]) return  [yValue doubleValue];
    else return 0.0;
//	return ((NSNumber *)yValue).floatValue;	
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
