//
//  ComposeViewController.m
//  twitter
//
//  Created by Vince Magistrado on 10/4/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "ComposeViewController.h"
#import "UIImageView+AFNetworking.h"
#import "User.h"
#import "TwitterClient.h"

@interface ComposeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // update status bar appearance
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    // add Cancel button icon
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(onCancel)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    // add Tweet button
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweet)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    User *currentUser = [User currentUser];
    // rounded corners for profile images
    CALayer *layer = [self.profileImageView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:3.0];
    [self.profileImageView setImageWithURL:[NSURL URLWithString:[currentUser profileImageUrl]]];
    self.nameLabel.text = currentUser.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", currentUser.screenname];
    
    // set self as delegate for text view events
    self.tweetTextView.delegate = self;
    
    // set initial reply to string if a reply
    if (_replyToTweet) {
        // if replying to a retweet, mention original tweet author and retweeter
        if (_replyToTweet.retweetedTweet) {
            if ([_replyToTweet.user.screenname isEqualToString:[[User currentUser] screenname]]) {
                self.tweetTextView.text = [NSString stringWithFormat:@"@%@ ", _replyToTweet.retweetedTweet.user.screenname];
            } else {
                self.tweetTextView.text = [NSString stringWithFormat:@"@%@ @%@ ", _replyToTweet.retweetedTweet.user.screenname, _replyToTweet.user.screenname];
            }
        } else {
            self.tweetTextView.text = [NSString stringWithFormat:@"@%@ ", _replyToTweet.user.screenname];
        }
    }
    
    // set initial mention if writing to user
    if (_messageToUser) {
        self.tweetTextView.text = [NSString stringWithFormat:@"@%@ ", _messageToUser.screenname];
    }
    
    // initialize character count
    [self textViewDidChange:self.tweetTextView];
    
    // start with focus on the text view
    [self.tweetTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onCancel {
    // update status bar appearance
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onTweet {
    Tweet *tweet = [[Tweet alloc] initWithText:self.tweetTextView.text replyToTweet:self.replyToTweet];
    
    [[TwitterClient sharedInstance] sendTweetWithParams:nil tweet:tweet completion:^(NSString *tweetIdStr, NSError *error) {
        if (error) {
            NSLog([NSString stringWithFormat:@"Error sending tweet: %@", tweet]);
        } else {
            // set tweet id so it can be favorited
            NSLog([NSString stringWithFormat:@"Tweet successful, tweet id_str: %@", tweetIdStr]);
            tweet.idStr = tweetIdStr;
            if ([self.delegate respondsToSelector:@selector(didTweetSuccessfully)]) {
                [self.delegate didTweetSuccessfully];
            }
        }
    }];
    
    // update status bar appearance
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.delegate didTweet:tweet];
}

- (void) textViewDidChange:(UITextView *)textView {
    long charsLeft = 140 - textView.text.length;
    
    // if negative count, set to red
    UIColor *titleColor = nil;
    if (charsLeft < 0) {
        titleColor = [UIColor redColor];
    } else {
        titleColor = [UIColor lightGrayColor];
    }
    if (charsLeft < 0 || charsLeft == 140) {
        // disable tweet button
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        // enable tweet button
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:titleColor forKey:NSForegroundColorAttributeName]];
    
    UILabel *charsLeftTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    charsLeftTitle.textAlignment = NSTextAlignmentRight;
    charsLeftTitle.text = [NSString stringWithFormat:@"%ld", charsLeft];
    charsLeftTitle.textColor = titleColor;
    [charsLeftTitle setFont: [UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    self.navigationItem.titleView = charsLeftTitle;
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
