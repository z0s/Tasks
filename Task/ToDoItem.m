//
//  ToDoItem.m
//  finalProject
//
//  Created by IT on 2/26/16.
//  Copyright © 2016 self. All rights reserved.
//

#import "ToDoItem.h"

@implementation ToDoItem

- (id)initWithText:(NSString*) text
{
    self = [super init];
    if (self) {
        self.text = text;
    }
    return self;
}

+ (id)toDoItemWithText:(NSString *)text
{
    return [[ToDoItem alloc] initWithText:text];
}

@end
