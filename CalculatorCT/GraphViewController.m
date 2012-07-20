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
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UISwitch *LineModeSwitch;
@property (nonatomic, strong) IBOutlet UIPopoverController * myPopoverController;
@end

@implementation GraphViewController

@synthesize program=_program;
@synthesize graphicView=_graphicView;
@synthesize toolBar = _toolBar;
@synthesize LineModeSwitch = _LineModeSwitch;

- (IBAction)LineModePress:(UISwitch *)sender {
  [self.graphicView setNeedsDisplay];

}

- (BOOL) validProgram
{
    return (self.program != nil);
}

-(void)setProgram:(id)program
{
    _program=program;

	// We want to set the title of the controller if the program changes
    // If there is a comma, only show the text after the rightmost command
    NSArray *listPrograms = [[CalculatorBrain descriptionOfProgram:self.program] componentsSeparatedByString:@","];
    [self showProgramDescription:[NSString stringWithFormat:@"y = %@", [ listPrograms lastObject]]];

    [self.graphicView setNeedsDisplay];
}

- (void)showProgramDescription:(NSString *)programDesc
{
    BOOL changed;
    if (self.toolBar) {
        // iPad
        NSMutableArray * items = [[self.toolBar items] mutableCopy];
        for (int i = 0; i < items.count; i++) {
            UIBarButtonItem * b = [items objectAtIndex:i];
            if (b.style == UIBarButtonItemStylePlain) {
                [b setTitle:programDesc];
                changed = YES;
            }
        }
        if (changed) [self.toolBar setItems:items];
    }
    else {
        // iPhone
        self.title = programDesc;
//        self.title = [NSString stringWithFormat:@"y = %@",programDesc ];
    }
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
-(id)yForGraphic:(Graphic *)sender withXValue:(double)xValue
{
	// Find the corresponding Y value by passing the x value to the calculator Brain
	id yValue = [CalculatorBrain runProgram:self.program usingVariableValues:
                 [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:xValue] forKey:@"x"]];
	
    if ([yValue isKindOfClass:[NSNumber class]]){
        return([NSNumber numberWithFloat: [yValue floatValue]]);
    } else {
        return @"Error"; // When the caller receives a string, it will know there is an error in the value calculation
    }    
}

- (BOOL) drawLinesForGraphView:(Graphic *)sender
{
    return self.LineModeSwitch.on;
}

// Split View Delegate 
// all the rigamarole in here to present a popover (whew!)
//

@synthesize myPopoverController = _myPopoverController;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;

}

- (void) splitViewController:(UISplitViewController *)svc
      willHideViewController:(UIViewController *)aViewController
           withBarButtonItem:(UIBarButtonItem *)barButtonItem
        forPopoverController:(UIPopoverController *)pc
{
    // add button to toolbar
    barButtonItem.title = @"Calculator";
    // tell the detail view to put this button up
    NSMutableArray *items = [[self.toolBar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [self.toolBar setItems:items animated:YES];
    self.myPopoverController = pc;
} 

- (void)splitViewController:(UISplitViewController *)svc 
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // remove button from toolbar
    NSMutableArray *items = [[self.toolBar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [self.toolBar setItems:items animated:YES];
    self.myPopoverController = nil;
}
- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    if (self.splitViewController) {
        // iPad
        return UIInterfaceOrientationIsPortrait(orientation);
    } else {
        // iPhone
        return NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidUnload {
    [self setToolBar:nil];
    [self setLineModeSwitch:nil];
    [self setLineModeSwitch:nil];
    [super viewDidUnload];
}
@end
