//
//  PullToAddNewBehavior.h
//  finalProject
//
//  Created by IT on 2/26/16.
//  Copyright © 2016 self. All rights reserved.
//

#import "TableView.h"

@class TableView;

@interface PullToAddNewBehavior : NSObject<UIScrollViewDelegate>

// associates this behavior with the given table

- (id)initWithTableView:(TableView*)tableView;

@end


