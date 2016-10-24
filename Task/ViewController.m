//
//  ViewController.m
//  finalProject
//
//  Created by IT on 2/20/16.
//  Copyright © 2016 self. All rights reserved.
//

#import "ViewController.h"
#import "PinchToAddNewBehavior.h"
#import "PullToAddNewBehavior.h"
#import "TableViewCell.h"
#import "TableView.h"

@implementation ViewController

{
    // a array of to-do items
    NSMutableArray* _toDoItems;
    
    // the offset applied to cells when entering 'edit mode'
    float _editingOffset;
    
    PullToAddNewBehavior* _pullAddNewBehavior;
    PinchToAddNewBehavior* _pinchAddNewBehavior;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // create a dummy todo list
        _toDoItems = [[NSMutableArray alloc] init];
        [_toDoItems addObject:[ToDoItem toDoItemWithText:@"Finish CIS Homework"]];
        [_toDoItems addObject:[ToDoItem toDoItemWithText:@"Buy eggs from Costco"]];
        [_toDoItems addObject:[ToDoItem toDoItemWithText:@"Pack bags for vacation in Miami"]];
        [_toDoItems addObject:[ToDoItem toDoItemWithText:@"Learn Spanish to meet singles during Vacation"]];
        [_toDoItems addObject:[ToDoItem toDoItemWithText:@"Buy a new backpack"]];
        [_toDoItems addObject:[ToDoItem toDoItemWithText:@"Find lost sunglasses"]];
        [_toDoItems addObject:[ToDoItem toDoItemWithText:@"Write a new poem for girlfriend"]];
        [_toDoItems addObject:[ToDoItem toDoItemWithText:@"Begin to learn Swift"]];
        [_toDoItems addObject:[ToDoItem toDoItemWithText:@"Remember your wedding anniversary!"]];
        [_toDoItems addObject:[ToDoItem toDoItemWithText:@"Drink orange juice every morning"]];
        [_toDoItems addObject:[ToDoItem toDoItemWithText:@"Learn the theorems in Discrete Mathematics"]];
        [_toDoItems addObject:[ToDoItem toDoItemWithText:@"Drop off shirts to dry cleaners"]];
        [_toDoItems addObject:[ToDoItem toDoItemWithText:@"Pitch ideas to boss in regards to new directions"]];
        [_toDoItems addObject:[ToDoItem toDoItemWithText:@"Learn more about starting your own business"]];
        [_toDoItems addObject:[ToDoItem toDoItemWithText:@"Buy fresh fruit and vegetables from farmers' market"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // configure the table
    CGRect tableFrame = self.view.bounds;
    tableFrame.size.height -= 64;
//    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
//    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_tableView.view attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
//    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
//    [self.view addConstraints:@[heightConstraint, widthConstraint]];
    self.title = @"Tasks";
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addToDoItem:)];
   /// self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.items = [NSMutableArray array];

    TableView *tableView = [[TableView alloc] initWithFrame:tableFrame];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [self.tableView registerClassForCells:[TableViewCell class]];
    self.tableView.datasource = self;
    
    _pullAddNewBehavior = [[PullToAddNewBehavior alloc] initWithTableView:self.tableView];
    _pinchAddNewBehavior = [[PinchToAddNewBehavior alloc] initWithTableView:self.tableView];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor*)colorForIndex:(NSInteger) index
{
    NSUInteger itemCount = _toDoItems.count - 1;
    float val = ((float)index / (float)itemCount) * 0.6;
    return [UIColor colorWithRed: 1.0 green:val blue: 0.0 alpha:1.0];
}
//- (void)setEditing:(BOOL)editing animated:(BOOL)animated
//{
//    [super setEditing:editing animated:animated];
//    //[self.tableView setEditing:editing animated:YES];
//    if (editing) {
//        self.navigationItem.rightBarButtonItem.enabled = NO;
//    } else {
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//    }
//}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // If row is deleted, remove it from the list.
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self.items removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//}
- (void)addToDoItem:(id)sender
{
    ToDoItem *newToDoItem = [[ToDoItem alloc] init];
    [self.items addObject:newToDoItem];
    [self.tableView reloadData];
}

#pragma mark - TableViewCellDelegate methods

- (void)cellDidBeginEditing:(TableViewCell *)editingCell
{
    _editingOffset = _tableView.scrollView.contentOffset.y - editingCell.frame.origin.y;
    
    for(TableViewCell* cell in [_tableView visibleCells])
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             cell.transform = CGAffineTransformMakeTranslation(0,  _editingOffset);
                             if (cell != editingCell)
                             {
                                 cell.alpha = 0.3;
                             }
                         }];
    }
}

- (void)cellDidEndEditing:(TableViewCell *)editingCell
{
    for(TableViewCell* cell in [_tableView visibleCells])
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             cell.transform = CGAffineTransformIdentity;
                             if (cell != editingCell)
                             {
                                 cell.alpha = 1.0;
                             }
                         }];
    }
}


- (void) toDoItemDeleted:(ToDoItem*) todoItem
{
    float delay = 0.0;
    
    [_toDoItems removeObject:todoItem];
    
    NSArray* visibleCells = [_tableView visibleCells];
    
    UIView* lastView = [visibleCells lastObject];
    bool startAnimating = false;
    
    for(TableViewCell* cell in visibleCells)
    {
        if (startAnimating)
        {
            [UIView animateWithDuration:0.3
                                  delay:delay
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 cell.frame = CGRectOffset(cell.frame, 0.0f, -cell.frame.size.height);
                             }
                             completion:^(BOOL finished){
                                 if (cell == lastView)
                                 {
                                     [_tableView reloadData];
                                 }
                             }];
            delay+=0.03;
        }
        
        if (cell.todoItem == todoItem)
        {
            startAnimating = true;
            cell.hidden = YES;
        }
    }
}



#pragma mark - CustomTableViewDataSource methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView.editing) {
        UIViewController *vc = [[UIViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        //vc.view.backgroundColor = [UIColor blueColor];
        vc.title = @"Edit Tasks";
        vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModal:)];
        [self presentViewController:nav animated:YES completion:^{
        }];
        
    } else {
        UIViewController *vc = [[UIViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        //vc.view.backgroundColor = [UIColor blueColor];
        vc.title = @"Add Task";
        [self presentViewController:nav animated:YES completion:^{
        }];
    }
}

- (void)dismissModal:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)itemAdded
{
    [self itemAddedAtIndex:0];
}

- (void)itemAddedAtIndex:(NSInteger)index
{
    // create the new item
    ToDoItem* toDoItem = [[ToDoItem alloc] init];
    [_toDoItems insertObject:toDoItem atIndex:index];
    
    // refresh the table
    [_tableView reloadData];
    
    // enter edit mode
    TableViewCell* editCell;
    for(TableViewCell* cell in _tableView.visibleCells)
    {
        if (cell.todoItem == toDoItem)
        {
            editCell = cell;
            break;
        }
    }
    [editCell.label becomeFirstResponder];
}


- (NSInteger)numberOfRows
{
    return _toDoItems.count;
}



- (UIView *) cellForRow:(NSInteger) row;
{
    TableViewCell* cell = (TableViewCell*)[_tableView dequeueReusableCell];
    
    NSInteger index = row;
    ToDoItem *item = _toDoItems[index];
    cell.todoItem = item;
    cell.backgroundColor = [self colorForIndex:row];
    cell.delegate = self;
    
    return cell;
}

@end
