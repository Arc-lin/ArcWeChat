//
//  ALChatViewController.m
//  WeChat
//
//  Created by Arclin on 16/2/23.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import "ALChatViewController.h"

@interface ALChatViewController ()<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSFetchedResultsController *_resultContr;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
/**
 *  输入框容器距离底部的约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation ALChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 添加键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 加载数据库的聊天数据
    // 1.上下文
    NSManagedObjectContext *msgContext = [ALXMPPTool sharedALXMPPTool].msgArchivingStorage.mainThreadManagedObjectContext;
    // 2.查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];

    // 过滤(当前登录用户 和 好友的聊天消息)
    NSString *loginUserJid = [ALXMPPTool sharedALXMPPTool].xmppStream.myJID.bare;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ and bareJidStr = %@",loginUserJid,self.friendJid.bare];
    request.predicate = pre;
    
    // 设置时间排序
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[timeSort];
    
    // 3.执行请求
    _resultContr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:msgContext sectionNameKeyPath:nil cacheName:nil];
    _resultContr.delegate = self;
    NSError *err = nil;
    [_resultContr performFetch:&err];
    if (err) {
        ALLog(@"%@",err);
    }
    [self rollToBottom];
}

#pragma mark 数据库内容改变调用
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
    
    [self rollToBottom];
}
- (void)rollToBottom
{
    // 表格滚动到底部
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:_resultContr.fetchedObjects.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
#pragma mark -tableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resultContr.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"ChatCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ID];
    
    // 获取聊天信息
    XMPPMessageArchiving_Message_CoreDataObject *msgObj = _resultContr.fetchedObjects[indexPath.row];
    
    cell.textLabel.text = msgObj.body;
    
    NSData *imageData = [[ALXMPPTool sharedALXMPPTool].avatar photoDataForJID:self.friendJid];
    cell.imageView.image = [UIImage imageWithData:imageData];
   
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",msgObj.timestamp];
    
    return cell;
}

#pragma mark 键盘的通知
#pragma mark 键盘出现
- (void)kbWillShow:(NSNotification *)noti
{
    // 显示的时候改变bottomContraint
    
    // 获取键盘高度
    CGFloat kbHeight = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    self.bottomConstraint.constant = kbHeight;
        
}
#pragma mark 键盘消失
- (void)kbWillHide:(NSNotification *)noti
{
    self.bottomConstraint.constant = 0;
}


#pragma mark 发送聊天数据
- (IBAction)sendBtnClick:(id)sender {
    [self sendMsg];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendMsg];
    
    return YES;
}
- (void)sendMsg
{
    if (self.textField.text) {
        NSString *txt = self.textField.text;
        // 怎么发聊天数据
        XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
        [msg addBody:txt];
        [[ALXMPPTool sharedALXMPPTool].xmppStream sendElement:msg];
        
        // 清空输入框的文本
        self.textField.text = nil;
    }
}
#pragma mark 表格滚动，隐藏键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
