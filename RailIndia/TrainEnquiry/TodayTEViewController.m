//
//  TodayViewController.m
//  TrainEnquiry
//
//  Created by Praveen Jha on 20/06/14.
//  Copyright (c) 2014 GlobalLogic. All rights reserved.
//
//  MIT LICENSE
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TodayTEViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <IRCTC/IRCTC.h> // https://github.com/pkjmesra/IRCTCFramework

@interface TodayTEViewController () <NCWidgetProviding, UITableViewDelegate>
@property (nonatomic) EnquiryService *dataSource;
@property (nonatomic) UITableView *tableView;
@end

@implementation TodayTEViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    [super loadView];

    self.view.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self.dataSource loadPosts:2 completion:^(NSError *error) {
        if (!error) {
            [self updateTableView];
        } else {
            NSLog(@"Download error: %@", error);
        }
    }];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.

    // If an error is encoutered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    [self.dataSource loadPosts:2 completion:^(NSError *error) {
        NCUpdateResult result = NCUpdateResultNoData;
        if (!error) {
            result = NCUpdateResultNewData;

            [self updateTableView];
        } else {
            NSLog(@"Download error: %@", error);

            result = NCUpdateResultFailed;
        }

        completionHandler(result);
    }];
}

#pragma mark -
- (void)updateTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];

        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];

        [self.tableView endUpdates];

        CGFloat height = (self.tableView.contentSize.height) ? self.tableView.contentSize.height : [self.dataSource tableView:self.tableView numberOfRowsInSection:0] * EnquiryTableViewCellHeight;

        [self setPreferredContentSize:CGSizeMake(self.tableView.contentSize.width, height)];
    });


}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EnquiryResult *post = [self.dataSource postAtIndex:indexPath.row];

    [self.extensionContext openURL:[NSURL URLWithString:[NSString stringWithFormat:@"RailIndia://%@", @(post.postId)]]
                 completionHandler:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
}

#pragma mark -
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        _tableView.delegate = self;
        _tableView.dataSource = self.dataSource;

        _tableView.rowHeight = EnquiryTableViewCellHeight;
        _tableView.estimatedRowHeight = EnquiryTableViewCellHeight;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];

        [_tableView registerClass:[EnquiryTableViewCell class] forCellReuseIdentifier:EnquiryTableViewCellIdentifier];
    }

    return _tableView;
}

- (EnquiryService *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[EnquiryService alloc] initWithTodayCell];
    }

    return _dataSource;
}

@end
