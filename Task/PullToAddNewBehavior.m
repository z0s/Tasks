//
//  PullToAddNewBehavior.m
//  finalProject
//
//  Created by IT on 2/26/16.
//  Copyright © 2016 self. All rights reserved.
//

#import "PullToAddNewBehavior.h"
#import "TableViewCell.h"
#import "TableView.h"

@implementation PullToAddNewBehavior
{
    // the table which this class extends and adds behaviour to
    __weak TableView* _tableView;
    
    // indicates the state of this behaviour
    BOOL _pullDownInProgress;
    
    // a cell which is rendered as a placeholder to indicate where a new item is added
    TableViewCell* _placeholderCell;
}

- (id)initWithTableView:(TableView*)tableView
{
    self = [super init];
    if (self) {
        _placeholderCell = [[TableViewCell alloc] init];
        _placeholderCell.backgroundColor = [UIColor redColor];
        
        _tableView = tableView;
        tableView.delegate = self;
    }
    return self;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // this behaviour starts when a user pulls down while at the top of the table
    _pullDownInProgress = scrollView.contentOffset.y <= 0.0f;
    
    if (_pullDownInProgress)
    {
        // add our placeholder
        [_tableView insertSubview:_placeholderCell atIndex:0];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_pullDownInProgress && _tableView.scrollView.contentOffset.y <= 0.0f)
    {
        // maintain the location of the placeholder
        _placeholderCell.frame = CGRectMake(0, - _tableView.scrollView.contentOffset.y - ROW_HEIGHT,
                                            _tableView.frame.size.width, ROW_HEIGHT);
        _placeholderCell.label.text = -_tableView.scrollView.contentOffset.y > ROW_HEIGHT ?
        @"Release to Add Item" : @"Pull to Add Item";
        
        _placeholderCell.alpha = MIN(1.0f, - _tableView.scrollView.contentOffset.y / ROW_HEIGHT);
    }
    else
    {
        _pullDownInProgress = false;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // check whether the user pulled down far enough
    if (_pullDownInProgress && - _tableView.scrollView.contentOffset.y > ROW_HEIGHT)
    {
        [_tableView.datasource itemAdded];
    }
    
    _pullDownInProgress = false;
    [_placeholderCell removeFromSuperview];
}

@end