//
//  ALContactViewController.m
//  WeChat
//
//  Created by Arclin on 16/2/21.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import "ALContactViewController.h"

@interface ALContactViewController ()<NSFetchedResultsControllerDelegate>{
    NSFetchedResultsController *_resultContr;
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
    NSManagedObjectContext *rosterContext = [ALXMPPTool sharedALXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    // 2.Request 执行请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    // 设置排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    // 3.执行请求
    // 3.1 创建结果控制器
    // 数据库查询，如果数据很多，会放在子线程查询
    // 移动客户端的数据库里的数据不会很多，所以很多数据库的查询操作都在主线程
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _resultContr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:rosterContext sectionNameKeyPath:nil cacheName:nil];
        ALLog(@"%@",[NSThread currentThread]);
//    });
    
    _resultContr.delegate = self;
    NSError *err = nil;
    // 3.2 执行
    [_resultContr performFetch:&err];
   
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
