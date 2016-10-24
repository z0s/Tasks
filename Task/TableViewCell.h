//
//  TableViewCell.h
//  finalProject
//
//  Created by IT on 2/26/16.
//  Copyright © 2016 self. All rights reserved.
//

#import "ToDoItem.h"
#import "TableViewCellDelegate.h"
#import "StrikethroughLabel.h"

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell <UITextFieldDelegate>

// The item that this cell renders
@property (nonatomic) ToDoItem* todoItem;

// The object that acts as delegate for this cell.
@property (nonatomic, assign) id<TableViewCellDelegate> delegate;

// the label used to render the to-do text
@property (nonatomic, assign, readonly) StrikethroughLabel* label;


@end
