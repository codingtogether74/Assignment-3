//
//  Graphic.h
//  Graph
//
//  Created by Olga Avanesova on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Graphic;
@protocol GraphViewDataSource 

-(id)yForGraphic:(Graphic *)sender withXValue:(double)x;
- (BOOL)drawLinesForGraphView:(Graphic *)sender;
- (BOOL)validProgram;
@end

@interface Graphic : UIView

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;
@property (nonatomic,weak) IBOutlet id <GraphViewDataSource> dataSource;

-(void)pinch:(UIPinchGestureRecognizer *)gesture;
-(void)pan:(UIPanGestureRecognizer *)gesture;
-(void)tripleTap:(UITapGestureRecognizer *)gesture;


@end
