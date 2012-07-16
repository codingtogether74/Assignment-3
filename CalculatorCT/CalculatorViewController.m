//
//  CalculatorViewController.m
//  CalculatorCT
//
//  Created by Tatiana Kornilovaon 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"
#define MAX_INPUT_DISPLAY_LENGTH (30)

@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL userAlreadyEnteredADecimalPoint;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic,strong)  NSDictionary *testVariablesValue;

- (NSString *)variablesDescription;
- (id)calculateProgram;
- (void) updateInputDisplay: (NSString *)displayString;
@end

@implementation CalculatorViewController
@synthesize display = _display;
@synthesize inputDisplay = _inputDisplay;
@synthesize variablesDisplay = _variablesDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber=_userIsInTheMiddleOfEnteringANumber;
@synthesize userAlreadyEnteredADecimalPoint=_userAlreadyEnteredADecimalPoint;
@synthesize testVariablesValue=_testVariablesValue;

@synthesize brain=_brain;
- (CalculatorBrain *)brain
{
    if (!_brain) _brain=[[CalculatorBrain alloc] init];
    return _brain;
}
//----------------------------------------------------------------------------
- (IBAction)digitPress:(UIButton *)sender {
    
    NSString *digit = [sender currentTitle];
    if ([digit isEqualToString:@"0"] && [self.display.text isEqualToString:@"0"])return;//ignore leading zeros
    if (self.userIsInTheMiddleOfEnteringANumber){
        self.display.text = [self.display.text stringByAppendingString:digit];
//--------remove leading zeroes ----------------
        self.display.text=self.display.text;
        if ([self.display.text hasPrefix:@"0"] &&
           ![[self.display.text substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"." ] ) 
        {
            self.display.text=[self.display.text  substringWithRange:NSMakeRange(1,[self.display.text length]-1)]; 
        }
       
    } else {
            self.display.text=digit;
            self.userIsInTheMiddleOfEnteringANumber= YES;
    }
}
//----------------------------------------------------------------------------
- (IBAction)enterPressed 
{
    [self.brain pushOperand:[self.display.text doubleValue]];    
    [self updateInputDisplay: [self.brain description]];
    self.variablesDisplay.text = [self variablesDescription];
    self.userIsInTheMiddleOfEnteringANumber=NO;
    self.userAlreadyEnteredADecimalPoint=NO; 
    
}
- (IBAction)operationPressed:(UIButton *)sender {
    
    NSString *operation=sender.currentTitle;
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    [self.brain pushOperation:operation];
    [self synchronizeView];      
/*    id result=[self.brain performOperation:operation];
    if ([result isKindOfClass:[NSString class]]) 
        self.display.text = result;
    else 
        self.display.text = [NSString stringWithFormat:@"%g", [result doubleValue]];
    [self updateInputDisplay: [self.brain description]];
    self.variablesDisplay.text = [self variablesDescription];
*/
}
- (IBAction)variablePressed:(UIButton *)sender {

    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
	[self.brain pushVariable:sender.currentTitle];
    self.display.text = sender.currentTitle;
    [self updateInputDisplay: [self.brain description]];
    self.variablesDisplay.text = [self variablesDescription];
    self.userIsInTheMiddleOfEnteringANumber=NO;
    self.userAlreadyEnteredADecimalPoint=NO; 
}

- (IBAction)decimalPointPressed {

    if (!self.userAlreadyEnteredADecimalPoint) {
        if (self.userIsInTheMiddleOfEnteringANumber) {
            self.display.text = [self.display.text stringByAppendingString:@"."];

        } else {
            // in case the decimal point is first 
            self.display.text = @"0.";
            self.userIsInTheMiddleOfEnteringANumber = YES;
        }
        self.userAlreadyEnteredADecimalPoint = YES;
    }
}

- (IBAction)CleanAll {

    self.display.text = @"0";
    self.inputDisplay.text = @"";
    [self.brain ClearStack];
    self.testVariablesValue = nil;
    self.variablesDisplay.text = [self variablesDescription];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userAlreadyEnteredADecimalPoint = NO;
}

- (IBAction)undoPress:(id)sender {

    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self delDigit];
    } else {
        [self.brain removeLastItem];
        [self synchronizeView];      
    }
}
- (IBAction)setTestVariables:(UIButton *)sender {
 
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
        self.testVariablesValue = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"x",nil];
    [self synchronizeView];      
}

- (IBAction)graphPress:(id)sender {
    [self performSegueWithIdentifier:@"ShowGraph" sender:self];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowGraph"]) {
        [segue.destinationViewController setProgram:self.brain.program];
    }
}


- (IBAction)delDigit {

    //----------------------------- It is working only in entering a number-------
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([self.display.text length]>0) {
            self.display.text = [self.display.text substringToIndex:[self.display.text length] - 1];
    
    //------------------------------ check "." after deleted ---------------------
            NSRange range= [self.display.text rangeOfString:@"."];
            if (range.location == NSNotFound) self.userAlreadyEnteredADecimalPoint = NO;
   
    //------------------------------ if all numbers have been deleted, stay display with 0
            if ([self.display.text length]==0) {
                self.display.text = @"0";
                self.userAlreadyEnteredADecimalPoint = NO;
                self.userIsInTheMiddleOfEnteringANumber=NO;
            }
   
        }
    }
}

- (NSString *)variablesDescription {

    NSString *descriptionOfVariablesUsed = @"";
    
    NSSet *variablesBeingUsed = [[self.brain class] variablesUsedInProgram:self.brain.program];
    
    for (NSString *variable in variablesBeingUsed) {
        if ([self.testVariablesValue objectForKey:variable]) {
            descriptionOfVariablesUsed = [descriptionOfVariablesUsed stringByAppendingString:[NSString stringWithFormat:@"%@= %@  ", variable, [self.testVariablesValue objectForKey:variable]]];
        } else 
            descriptionOfVariablesUsed = [descriptionOfVariablesUsed stringByAppendingString:[NSString stringWithFormat:@"%@= 0  ", variable]];
    }
    return descriptionOfVariablesUsed;
}

- (id)calculateProgram {
    
    if (!self.testVariablesValue) {
        return [[self.brain class] runProgram:self.brain.program];
    } else {
        return [[self.brain class] runProgram:self.brain.program usingVariableValues:self.testVariablesValue];
    }
    
}

-(void)synchronizeView {   

    id result =[self calculateProgram]; 
    if ([result isKindOfClass:[NSString class]])
        self.display.text = result;
    else 
        self.display.text = [NSString stringWithFormat:@"%g", [result doubleValue]];

    [self updateInputDisplay: [self.brain description]];
    self.variablesDisplay.text = [self variablesDescription];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userAlreadyEnteredADecimalPoint = NO;
}

- (void) updateInputDisplay: (NSString *)displayString {

    NSString *userDisplayText = displayString;
    NSUInteger userActionDisplayLength = [userDisplayText length];
    
    if (userActionDisplayLength >= MAX_INPUT_DISPLAY_LENGTH){
        userDisplayText = [userDisplayText substringWithRange:NSMakeRange(userActionDisplayLength - MAX_INPUT_DISPLAY_LENGTH, MAX_INPUT_DISPLAY_LENGTH)];
    }
    self.inputDisplay.text = userDisplayText;
}
- (void)viewDidUnload {
    [self setInputDisplay:nil];
    [self setVariablesDisplay:nil];
    [super viewDidUnload];
}
@end
