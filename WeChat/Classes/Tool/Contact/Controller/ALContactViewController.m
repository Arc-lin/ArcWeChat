//
//  ALContactViewController.m
//  WeChat
//
//  Created by Arclin on 16/2/21.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import "ALContactViewController.h"
#import "ALChatViewController.h"

@interface ALContactViewController ()<NSFetchedResultsControllerDelegate>{
    NSFetchedResultsController *_resultContr;
    NSManagedObjectContext *_rosterContext;
}

/**
 *  好友
 */
@property (nonatomic,strong) NSArray *users;

@end

@implementation ALContactViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    [self loadUsers2];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)loadUsers1
{
    // 显示好友数据(保存XMPPRoster.sqlite文件)
    // 1. 上下文 关联XMPPRoster.sqlite文件
    NSManagedObjectContext *rosterContext = [ALXMPPTool sharedALXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    // 2.Request 执行请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    // 设置排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    // 3.执行请求
    NSError *error = nil;
    NSArray *users = [rosterContext executeFetchRequest:request error:&error];
    self.users = users;
}

- (void)loadUsers2
{
    // 显示好友数据(保存XMPPRoster.sqlite文件)
    // 1. 上下文 关联XMPPRoster.sqlite文件
    // 主线程查询
    _rosterContext = [ALXMPPTool sharedALXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    // 2.Request 执行请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    // 设置排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    // 过滤
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"subscription != %@",@"none"];
    request.predicate = pre;
    
    // 在数据库中删除subscription为none的联系人
    [self deleteNoneContact];
    // 3.执行请求
    // 3.1 创建结果控制器
    // 数据库查询，如果数据很多，会放在子线程查询
    // 移动客户端的数据库里的数据不会很多，所以很多数据库的查询操作都在主线程
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _resultContr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_rosterContext sectionNameKeyPath:nil cacheName:nil];
        ALLog(@"%@",[NSThread currentThread]);
//    });
    
    _resultContr.delegate = self;
    NSError *err = nil;
    // 3.2 执行
    [_resultContr performFetch:&err];
   
}

- (void)deleteNoneContact
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];

    NSPredicate *pre = [NSPredicate predicateWithFormat:@"subscription = %@",@"none"];
    request.predicate = pre;

    NSArray *deleteObjs = [_rosterContext executeFetchRequest:request error:nil];
    
    for (XMPPUserCoreDataStorageObject *obj in deleteObjs) {
        [_rosterContext deleteObject:obj];
    }
    
    [_rosterContext save:nil];
}
#pragma mark - 结果控制器的代理
#pragma mark - 数据库内容改变
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // 刷新表格
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return self.users.count;
    return  _resultContr.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    // 获取对应的好友
//    XMPPUserCoreDataStorageObject *user = self.users[indexPath.row];
    XMPPUserCoreDataStorageObject *user = _resultContr.fetchedObjects[indexPath.row];
    
    // 标识用户是否在线
    // 0:在线 1:离开 2:离线
    cell.textLabel.text = user.displayName;
    if (user.photo) { // 默认的情况，不是程序一启动就有头像
        cell.imageView.image = user.photo;
    }else{ // 从服务器中获取头像
        NSData *imageData = [[ALXMPPTool sharedALXMPPTool].avatar photoDataForJID:user.jid];
        cell.imageView.image = [UIImage imageWithData:imageData];
    }
    // 1.通过KVO来监听用户状态的改变
//    [user addObserver:self forKeyPath:@"sectionNum" options:NSKeyValueObservingOptionNew context:nil];
    
    switch ([user.sectionNum integerValue]) {
        case 0:
            cell.detailTextLabel.text = @"在线";
            break;
        case 1:
            cell.detailTextLabel.text = @"离开";
            break;
        case 2:
            cell.detailTextLabel.text = @"离线";
            break;
        default:
            cell.detailTextLabel.text = @"无法识别状态";
            break;
    }
    
    return cell;
}

// 通过KVO来监听用户状态的改变
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    [self.tableView reloadData];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPJID *friendJid = [_resultContr.fetchedObjects[indexPath.row] jid];
    // 进入聊天控制器
    [self performSegueWithIdentifier:@"toChatVcSegue" sender:friendJid];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destVc = segue.destinationViewController;
    if ([destVc isKindOfClass:[ALChatViewController class]]) {
        ALChatViewController *chatVc = destVc;
        chatVc.friendJid = sender;
    }
}

#pragma mark - 结果控制器的代理
#pragma mark - 数据库内容改变
#pragma mark 实现此方法，就会出现delete按钮
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *user = _resultContr.fetchedObjects[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 删除好友
        [[ALXMPPTool sharedALXMPPTool].roster removeUser:user.jid];
    }
    
    // 刷新表格
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
