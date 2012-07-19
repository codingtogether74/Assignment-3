//
//  CalculatorViewController.m
//  CalculatorCT
//
//  Created by Tatiana Kornilovaon 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reservedvvv.
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
- (void) updateInputDisplay: (NSString *)displayString;
@end

@implementation CalculatorViewController
@synthesize display = _display;
@synthesize inputDisplay = _inputDisplay;
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
    self.userIsInTheMiddleOfEnteringANumber=NO;
    self.userAlreadyEnteredADecimalPoint=NO; 
    
}
- (IBAction)operationPressed:(UIButton *)sender {
    
    NSString *operation=sender.currentTitle;
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    [self.brain pushOperation:operation];
    [self synchronizeView];      
}
- (IBAction)variablePressed:(UIButton *)sender {

    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
	[self.brain pushVariable:sender.currentTitle];
    self.display.text = sender.currentTitle;
    [self updateInputDisplay: [self.brain description]];
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
- (NSString *)lightTest {
    self.testVariablesValue = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"x",nil];
    id result1 =[[self.brain class] runProgram:self.brain.program usingVariableValues:self.testVariablesValue]; 
    self.testVariablesValue = [NSDictionary dictionaryWithObjectsAndKeys:@"-1", @"x",nil];
    id result2 =[[self.brain class] runProgram:self.brain.program usingVariableValues:self.testVariablesValue]; 
    self.testVariablesValue = [NSDictionary dictionaryWithObjectsAndKeys:@"100", @"x",nil];
    id result3 =[[self.brain class] runProgram:self.brain.program usingVariableValues:self.testVariablesValue];
                     
    if ([result1 isKindOfClass:[NSString class]]&& [result2 isKindOfClass:[NSString class]]&& [result3 isKindOfClass:[NSString class]]
        && [result1 isEqualToString:result2]&& [result1 isEqualToString:result2]) return result1;
     else return @"Variables in use";      
    
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


-(void)synchronizeView {   
    NSSet *variablesBeingUsed = [[self.brain class] variablesUsedInProgram:self.brain.program];
    if ([variablesBeingUsed count]>0) {
   // variables present
        self.display.text=[self lightTest]; 
    }else {
   //no variables     
        id result =[[self.brain class] runProgram:self.brain.program usingVariableValues:nil]; 
        if ([result isKindOfClass:[NSString class]])
            self.display.text = result;
        else 
            self.display.text = [NSString stringWithFormat:@"%g", [result doubleValue]];
    }
    

    [self updateInputDisplay: [self.brain description]];
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

-(GraphViewController *)splitViewGraphViewController
{
    id gvc=[self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[GraphViewController class]]) {
        gvc=nil;
    }
    return gvc;
}

//
// iPad:   Send program to graph pane
// iPhone: Bring up Graph by Segue
//

- (IBAction)graphPress:(id)sender {
    if ([self splitViewGraphViewController]) {
        [self splitViewGraphViewController].program=self.brain.program;
    }else {
        
        [self performSegueWithIdentifier:@"ShowGraph" sender:self];
    }    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowGraph"]) {
        [segue.destinationViewController setProgram:self.brain.program];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

// Need to disable swipes to reveal calculator for iOS 5.1, interferes with pan. MAKE SURE you check that
// the splitview controller supports the selector "respondsToSelecter" before you call it, or you will
// crash on iOS 5!
- (void)awakeFromNib {
    [super awakeFromNib];
    if (self.splitViewController) {
        if ([self.splitViewController respondsToSelector:@selector(presentsWithGesture)]) {
            self.splitViewController.presentsWithGesture = NO;
        }
    }
}

- (void)viewDidUnload {
    [self setInputDisplay:nil];
    [super viewDidUnload];
}
@end
