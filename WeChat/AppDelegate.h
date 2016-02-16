//
//  AppDelegate.h
//  WeChat
//
//  Created by Arclin on 16/2/13.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    XMPPResultTypeLoginSuccess, // 登录成功
    XMPPResultTypeLoginFailure  // 登录失败
}XMPPResultType;

/**
 *  与服务器交互的结果
 */
typedef void (^XMPPResultBlock)(XMPPResultType);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 *  XMPP用户登录
 */
- (void)xmppLogin:(XMPPResultBlock)resultBlock;
@end

