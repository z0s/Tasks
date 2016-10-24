//
//  TableView.m
//  finalProject
//
//  Created by IT on 2/27/16.
//  Copyright © 2016 self. All rights reserved.
//

#import "TableView.h"
#import "TableViewCell.h"

const float ROW_HEIGHT = 50.0f;

@implementation TableView

{
    // the scroll view which hosts the cells
    UIScrollView* _scrollView;
    
    // the object which acts as a datasource
    id<TableViewDataSource> _datasource;
    
    // a set of cells which are re-useable
    NSMutableSet* _reuseCells;
    
    // the Class which indicates the cell type
    Class _cellClass;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectNull];
        [self addSubview:_scrollView];
        
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        _reuseCells = [[NSMutableSet alloc] init];
    }
    return self;
}

//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectNull];
//        [self addSubview:_scrollView];
//        
//        _scrollView.delegate = self;
//        _scrollView.backgroundColor = [UIColor clearColor];
//        self.backgroundColor = [UIColor clearColor];
//        
//        _reuseCells = [[NSMutableSet alloc] init];
//    }
//    return self;
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _scrollView.frame = self.frame;
    [self refreshView];
}

#pragma mark - cell lifecycle


// based on the current scroll location, recycles off-screen cells and
// creates new ones to fill the empty space.
-(void) refreshView
{
    if (CGRectIsNull(_scrollView.frame))
    {
        return;
    }
    
    _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, [_datasource numberOfRows] * ROW_HEIGHT);
    
    // remove cells that are no longer visible
    for(UIView* cell in [self cellSubviews])
    {
        // is the cell off the top of the scrollview?
        if (cell.frame.origin.y + cell.frame.size.height < _scrollView.contentOffset.y)
        {
            [self recycleCell:cell];
        }
        
        // is the cell off the bottom of the scrollview?
        if (cell.frame.origin.y > _scrollView.contentOffset.y + _scrollView.frame.size.height)
        {
            [self recycleCell:cell];
        }
    }
    
    // ensure we have a cell for each row
    int firstVisibleIndex = MAX(0, floor(_scrollView.contentOffset.y / ROW_HEIGHT));
    int lastVisibleIndex = MIN([_datasource numberOfRows],
                               firstVisibleIndex + 1 + ceil(_scrollView.frame.size.height / ROW_HEIGHT));
    
    for (int row = 	firstVisibleIndex; row < lastVisibleIndex; row++)
    {
        UIView* cell = [self cellForRow:row];
        if (!cell)
        {
            UIView* cell = [_datasource cellForRow:row];
            float topEdgeForRow = row * ROW_HEIGHT;
            cell.frame = CGRectMake(0, topEdgeForRow, _scrollView.frame.size.width, ROW_HEIGHT);
            [_scrollView insertSubview:cell atIndex:0];
        }
    }
}


// re-cycles a cell by adding it the set of re-use cells and removing it from the view
-(void) recycleCell:(UIView*)cell
{
    [_reuseCells addObject:cell];
    [cell removeFromSuperview];
}

// returns the cell for the given row, or nil if it doesn't exist
-(UIView*) cellForRow:(NSInteger)row
{
    float topEdgeForRow = row * ROW_HEIGHT;
    for(UIView* cell in [self cellSubviews])
    {
        if (cell.frame.origin.y == topEdgeForRow)
        {
            return cell;
        }
    }
    
    return nil;
}

// the scrollViewer subviews that are cells
-(NSArray*)cellSubviews
{
    NSMutableArray* cells = [[NSMutableArray alloc] init];
    for(UIView* subView in _scrollView.subviews)
    {
        if ([subView isKindOfClass:[TableViewCell class]])
        {
            [cells addObject:subView];
        }
    }
    return cells;
}

#pragma mark - UIScrollViewDelegate handlers

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self refreshView];
    
    // forward the delegate method
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]){
        [self.delegate scrollViewDidScroll:scrollView];
    }
    
}

#pragma mark - UIScrollViewDelegate forwarding

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([self.delegate respondsToSelector:aSelector]) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}


- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self.delegate respondsToSelector:aSelector]) {
        return self.delegate;
    }
    return [super forwardingTargetForSelector:aSelector];
}

#pragma mark - public API methods

-(void) registerClassForCells: (Class)cellClass
{
    _cellClass = cellClass;
}

-(NSArray*) visibleCells
{
    NSMutableArray* cells = [[NSMutableArray alloc] init];
    for(UIView* subView in [self cellSubviews])
    {
        [cells addObject:subView];
    }
    NSArray* sortedCells = [cells sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        UIView* view1 = (UIView*)obj1;
        UIView* view2 = (UIView*)obj2;
        
        float result = view2.frame.origin.y - view1.frame.origin.y;
        if (result > 0.0) {
            return NSOrderedAscending;
        } else if (result < 0.0){
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    return sortedCells;
}

-(UIView*)dequeueReusableCell
{
    // first obtain a cell from the re-use pool
    UIView* cell = [_reuseCells anyObject];
    if (cell) {
        [_reuseCells removeObject:cell];
    }
    
    // otherwise create a new cell
    if (!cell) {
        cell = [[_cellClass alloc] init];
    }
    return cell;
}


-(void)reloadData
{
    // remove all subviews
    [[self cellSubviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    
    [self refreshView];
    
}

#pragma mark - property getters / setters

- (UIScrollView *)scrollView
{
    return _scrollView;
}

-(id<TableViewDataSource>)datasource
{
    return _datasource;
}

-(void)setDatasource:(id<TableViewDataSource>)datasource
{
    _datasource = datasource;
    
    [self refreshView];
}

@end
