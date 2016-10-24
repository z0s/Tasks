//
//  ToDoItem.h
//  finalProject
//
//  Created by IT on 2/26/16.
//  Copyright © 2016 self. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToDoItem: NSObject


// A text description of this item.
@property (nonatomic, copy) NSString *text;

// A boolean value that determines the completed state of this item.
@property (nonatomic) BOOL completed;

// Returns an ToDoItem item initialised with the given text.
- (id)initWithText:(NSString*) text;


// Returns an ToDoItem item initialised with the given text.
+ (id)toDoItemWithText:(NSString*) text;

@end