//
//  ALEditVCardViewController.h
//  WeChat
//
//  Created by Arclin on 16/2/19.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALEditVCardViewController;
@protocol ALEditVCardViewControllerDelegate <NSObject>

- (void)editVCardViewController:(ALEditVCardViewController *)editVc didFinishedSave:(id)sender;

@end
@interface ALEditVCardViewController : UITableViewController

/**
 *  上一个控制器（个人信息控制器）传入的cell
 */
@property (nonatomic,strong) UITableViewCell *cell;

@property (nonatomic,weak) id<ALEditVCardViewControllerDelegate> delegate;

@end
