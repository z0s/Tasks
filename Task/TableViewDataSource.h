//
//  TableViewDataSource.h
//  finalProject
//
//  Created by IT on 2/26/16.
//  Copyright © 2016 self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ToDoItem.h"

@protocol TableViewDataSource <NSObject>

// Indicates the number of rows in the table
- (NSInteger) numberOfRows;

// Obtains the cell for the given row
- (UIView *) cellForRow:(NSInteger) row;

// Informs the datasource that a new item has been added at the top of the table
- (void) itemAdded;

// Informs the datasource that a new item has been added at the given index
- (void) itemAddedAtIndex:(NSInteger)index;

@end

