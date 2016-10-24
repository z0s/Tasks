//
//  PinchToAddNewBehavior.m
//  finalProject
//
//  Created by IT on 2/26/16.
//  Copyright © 2016 self. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "PinchToAddNewBehavior.h"
#import "TableViewCell.h"
#import "TableView.h"

// represents the upper and lower points of a pinch
struct TouchPoints {
    CGPoint upper;
    CGPoint lower;
};

typedef struct TouchPoints TouchPoints;

@implementation PinchToAddNewBehavior
{
    // the table which this class extends and adds behaviour to
    TableView* _tableView;
    
    // a cell which is rendered as a placeholder to indicate where a new item is added
    TableViewCell* _placeholderCell;
    
    // inidcates that the pinch is in progress
    BOOL _pinchInProgress;
    
    // the indices of the upper and lower cells that are being pinched
    int _pointOneCellindex;
    int _pointTwoCellindex;
    
    // the location of the touch points when the pinch initiated
    TouchPoints _initialTouchPoints;
    
    // inidcates that the pinch was big enough to cause a new item to be added
    BOOL _pinchExceededRequiredDistance;
}

- (id)initWithTableView:(TableView*)tableView
{
    self = [super init];
    if (self) {
        _placeholderCell = [[TableViewCell alloc] init];
        _placeholderCell.backgroundColor = [UIColor redColor];
        
        _tableView = tableView;
        
        // add a pinch recognizer
        UIGestureRecognizer* recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [_tableView addGestureRecognizer:recognizer];
    }
    return self;
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self pinchStarted:recognizer];
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged
        && _pinchInProgress
        && recognizer.numberOfTouches == 2)
    {
        [self pinchChanged:recognizer];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self pinchEnded:recognizer];
    }
}

- (void) pinchStarted:(UIPinchGestureRecognizer *)recognizer
{
    // find the touch-points
    _initialTouchPoints = [self getNormalisedTouchPoints:recognizer];
    
    // locate the cells that these points touch
    _pointOneCellindex = -100;
    _pointTwoCellindex = -100;
    NSArray* visibleCells = _tableView.visibleCells;
    for(int i=0; i<visibleCells.count; i++)
    {
        UIView* cell = (UIView*)visibleCells[i];
        if ([self viewContainsPoint:cell withPoint:_initialTouchPoints.upper])
        {
            _pointOneCellindex = i;
        }
        if ([self viewContainsPoint:cell withPoint:_initialTouchPoints.lower])
        {
            _pointTwoCellindex = i;
        }
    }
    
    // check whether they are neighbours
    if (abs(_pointOneCellindex - _pointTwoCellindex) == 1)
    {
        // if so - initiate the pinch
        _pinchInProgress = YES;
        _pinchExceededRequiredDistance = NO;
        
        // show our place-holder cell
        TableViewCell* precedingCell = (TableViewCell*)(_tableView.visibleCells)[_pointOneCellindex];
        _placeholderCell.frame = CGRectOffset(precedingCell.frame, 0.0f, ROW_HEIGHT / 2.0f);
        [_tableView.scrollView insertSubview:_placeholderCell atIndex:0];
    }
}

-(void) pinchChanged:(UIPinchGestureRecognizer *)recognizer
{
    // find the touch-points
    TouchPoints currentTouchPoints = [self getNormalisedTouchPoints:recognizer];
    
    // determine by how much each touch point has changed, and take the minimum delta
    float upperDelta = currentTouchPoints.upper.y - _initialTouchPoints.upper.y;
    float lowerDelta = _initialTouchPoints.lower.y - currentTouchPoints.lower.y;
    float delta = -MIN(0, MIN(upperDelta, lowerDelta));
    float gapSize = delta * 2;
    
    // offset the cells, negative for th cells above, positive for those below
    NSArray* visibleCells = _tableView.visibleCells;
    for(int i=0; i<visibleCells.count; i++)
    {
        UIView* cell = (UIView*)visibleCells[i];
        if (i <= _pointOneCellindex)
        {
            cell.transform = CGAffineTransformMakeTranslation(0,  -delta);
        }
        if (i >= _pointTwoCellindex)
        {
            cell.transform = CGAffineTransformMakeTranslation(0, delta);
        }
    }
    
    // scale the placeholder cell
    float cappedGapSize = MIN(gapSize, ROW_HEIGHT);
    _placeholderCell.transform = CGAffineTransformMakeScale(1.0f, cappedGapSize / ROW_HEIGHT );
    
    _placeholderCell.label.text = gapSize > ROW_HEIGHT ?
    @"Release to Add Item" : @"Pull to Add Item";
    
    _placeholderCell.alpha = MIN(1.0f, gapSize / ROW_HEIGHT);
    
    // determine whether they have pinched far enough
    _pinchExceededRequiredDistance = gapSize > ROW_HEIGHT;
}

-(void) pinchEnded:(UIPinchGestureRecognizer *)recognizer
{
    _pinchInProgress = false;
    
    // remove the placeholder cell
    _placeholderCell.transform = CGAffineTransformIdentity;
    [_placeholderCell removeFromSuperview];
    
    if (_pinchExceededRequiredDistance)
    {
        // add a new item
        int indexOffset = floor(_tableView.scrollView.contentOffset.y / ROW_HEIGHT);
        [_tableView.datasource itemAddedAtIndex:_pointTwoCellindex + indexOffset];
    }
    else
    {
        //otherwise animate back to position
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             NSArray* visibleCells = _tableView.visibleCells;
                             for(TableViewCell* cell in visibleCells)
                             {
                                 cell.transform = CGAffineTransformIdentity;
                             }
                         }
                         completion:^(BOOL finished){
                             [_tableView reloadData];
                         }];
        
        
        ;
    }
    
}

// returns the two touch points, ordering them to ensure that upper and lower
// are correctly identified.
- (TouchPoints) getNormalisedTouchPoints: (UIGestureRecognizer*) recognizer
{
    CGPoint pointOne = [recognizer locationOfTouch:0 inView:_tableView];
    CGPoint pointTwo = [recognizer locationOfTouch:1 inView:_tableView];
    
    // offset based on scroll
    pointOne.y += _tableView.scrollView.contentOffset.y;
    pointTwo.y += _tableView.scrollView.contentOffset.y;
    
    // ensure pointOne is the top-most
    if (pointOne.y > pointTwo.y)
    {
        CGPoint temp = pointOne;
        pointOne = pointTwo;
        pointTwo = temp;
    }
    
    TouchPoints points = {pointOne, pointTwo};
    return points;
}

- (BOOL) viewContainsPoint:(UIView*)view withPoint:(CGPoint)point
{
    CGRect frame = view.frame;
    return (frame.origin.y < point.y) && (frame.origin.y +frame.size.height) > point.y;
}

@end
