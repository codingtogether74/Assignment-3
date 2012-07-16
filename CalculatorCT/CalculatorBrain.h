//
//  CalculatorBrain.h
//  CalculatorCT
//
//  Created by Tatiana Kornilova on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (void)pushOperation:(NSString *)operation;
- (void)pushVariable:(NSString *) variable;
- (id)performOperation:(NSString *)operation;
- (NSString *)description;
- (void)ClearStack;
- (void)removeLastItem;

@property (nonatomic, readonly) id program;

+ (NSString *)descriptionOfProgram:(id)program;
+ (id)runProgram:(id)program;
+ (id) runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;
+ (BOOL)isOperation:(NSString *)operation;
+ (BOOL)isABinaryOperation:(NSString *)operation;
+ (BOOL)isAUnaryOperation:(NSString *)operation;
+(int) operationPriority: (NSString *)operation;
+(BOOL) operationIsNotCommutative: (NSString *) operation;

@end
