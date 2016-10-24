//
//  ViewController.h
//  finalProject
//
//  Created by IT on 2/20/16.
//  Copyright © 2016 self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewCellDelegate.h"
#import "TableView.h"

@interface ViewController : UIViewController <TableViewCellDelegate, TableViewDataSource>


@property (weak, nonatomic) TableView *tableView;
@property (nonatomic, strong) NSMutableArray *items;


@end

