//
//  UIScrollView+EmptyMessage.m
//  Qfq
//
//  Created by Gforce on 14-9-20.
//  Copyright (c) 2014年 qfq. All rights reserved.
//

#import "UIScrollView+EmptyMessage.h"
@implementation UIScrollView (EmptyMessage)
@dynamic emptyMessage;
@dynamic imgUrl;

NSMutableArray*  arrayViews;
NSMutableDictionary*  dickBlocks;
-(void)setEmptyMessage:(NSString*) Identity emptyMessage:(NSAttributedString*) message YScale:(CGFloat)yScale height:(CGFloat)height{
    if (!arrayViews) {
        arrayViews = [NSMutableArray new];
    }
    for (UIView* view in arrayViews) {
        if ([view.accessibilityIdentifier isEqualToString:Identity]) {
            return;
        }
    }
    UIView*   emptyMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    emptyMessageView.accessibilityIdentifier = Identity;
    UILabel* lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height * yScale, self.frame.size.width, height)];
    lblMessage.backgroundColor = [UIColor clearColor];
    lblMessage.attributedText = message;
    lblMessage.tag = yScale * 100;
    lblMessage.textAlignment = NSTextAlignmentCenter;
    [emptyMessageView addSubview:lblMessage];
    [arrayViews addObject:emptyMessageView];
}

-(void)setEmptyMessage:(NSString*) Identity emptyMessage:(NSAttributedString*) message YScale:(CGFloat)yScale height:(CGFloat)height block:(clickBlock)blk{
    if (!arrayViews) {
        arrayViews = [NSMutableArray new];
    }
    if (!dickBlocks) {
        dickBlocks = [NSMutableDictionary new];
    }

    for (UIView* view in arrayViews) {
        if ([view.accessibilityIdentifier isEqualToString:Identity]) {
            return;
        }
    }
    UIView*   emptyMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    emptyMessageView.accessibilityIdentifier = Identity;
    UILabel* lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height * yScale, self.frame.size.width, height)];
    lblMessage.backgroundColor = [UIColor clearColor];
    lblMessage.attributedText = message;
    lblMessage.tag = yScale * 100;
    lblMessage.accessibilityIdentifier = Identity;
    lblMessage.textAlignment = NSTextAlignmentCenter;
    [emptyMessageView addSubview:lblMessage];
    if (blk != nil) {
        dickBlocks[Identity] = blk;
        lblMessage.userInteractionEnabled = YES;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageClick:)];
        [lblMessage addGestureRecognizer:tap];
    }
    [arrayViews addObject:emptyMessageView];
}

-(void)messageClick:(UITapGestureRecognizer*)gusture{
        UIView* lbl = [gusture view];
        if (dickBlocks[lbl.accessibilityIdentifier]) {
            clickBlock blk = dickBlocks[lbl.accessibilityIdentifier];
            blk(gusture.view);
        }
}

-(void)setEmptyImage:(NSString*) Identity imgUrl:(NSString*) imgUrl YScale:(CGFloat)yScale height:(CGFloat)height{
    
    if (!arrayViews) {
        arrayViews = [NSMutableArray new];
    }
    for (UIView* view in arrayViews) {
        if ([view.accessibilityIdentifier isEqualToString:Identity]) {
            return;
        }
    }
    UIView*   emptyMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    emptyMessageView.accessibilityIdentifier = Identity;
    //emptyMessageView.backgroundColor = BACKGROUNDCOLOR_240;
    UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height * yScale, self.frame.size.width, height)];
    img.contentMode = UIViewContentModeScaleAspectFit;
    img.tag = yScale * 100;
    img.image = [UIImage imageNamed:imgUrl];
    [emptyMessageView addSubview:img];

    [self addSubview:emptyMessageView];
}


-(void)setEmptyInfo:(NSString *)Identity emptyMessage:(NSAttributedString *)emptyMessage imgUrl:(NSString *)imgUrl imageYScale:(CGFloat)imageYScale ImageHeight:(CGFloat)ImageHeight messageDistanseFromImage:(CGFloat)distanse messageHeight:(CGFloat)messageHeight{
    if (!arrayViews) {
        arrayViews = [NSMutableArray new];
    }
    UIView*   emptyMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    emptyMessageView.accessibilityIdentifier = Identity;
    //emptyMessageView.backgroundColor = BACKGROUNDCOLOR_240;
    UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height * imageYScale, self.frame.size.width, ImageHeight)];
    img.contentMode = UIViewContentModeScaleAspectFit;
    img.image = [UIImage imageNamed:imgUrl];
    img.tag = imageYScale * 100;
    [emptyMessageView addSubview:img];
    
    UILabel* lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(img.frame) + distanse, self.frame.size.width, messageHeight)];
    lblMessage.backgroundColor = [UIColor clearColor];
    lblMessage.attributedText = emptyMessage;
    lblMessage.tag = distanse * 100;
    lblMessage.textAlignment = NSTextAlignmentCenter;
    [emptyMessageView addSubview:lblMessage];
    
    [arrayViews addObject:emptyMessageView];
    //   [self addSubview:emptyMessageView];
    //这里不添加
}

-(void)setEmptyInfo:(NSString*) Identity emptyMessage:(NSAttributedString*)emptyMessage btn:(NSString*)btnContent  messageYScale:(CGFloat)messageYScale messageHeight:(CGFloat)messageHeight btnDistanseFromMsg:(CGFloat)distanse btnWidth:(CGFloat) btnWidth btnHeight:(CGFloat)btnHeight  clickBlock:(clickBlock)block;{
    if (!arrayViews) {
        arrayViews = [NSMutableArray new];
    }
    
    if (!dickBlocks) {
        dickBlocks = [NSMutableDictionary new];
    }
    UIView*   emptyMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    if(emptyMessageView.frame.size.width == 0){
        emptyMessageView.frame = [UIScreen mainScreen].bounds;
    }
    emptyMessageView.accessibilityIdentifier = Identity;

    CGFloat height = self.frame.size.height * messageYScale;
    if (height == 0) {
        height = [UIScreen mainScreen].bounds.size.height  * messageYScale ;
    }
    UILabel* lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, height,  [UIScreen mainScreen].bounds.size.width, messageHeight)];
    lblMessage.backgroundColor = [UIColor clearColor];
    lblMessage.attributedText = emptyMessage;
    lblMessage.tag = distanse * 100;
    lblMessage.textAlignment = NSTextAlignmentCenter;
    [emptyMessageView addSubview:lblMessage];
    
    CGFloat btnX = (self.frame.size.width - btnWidth) / 2;
    if(btnX < 0){
        btnX = ([UIScreen mainScreen].bounds.size.width - btnWidth) / 2;
    }
    
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, CGRectGetMaxY(lblMessage.frame) + distanse , btnWidth, btnHeight)];
    [btn setTitle:btnContent forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btn.accessibilityIdentifier = Identity;
    [btn addTarget:self action:@selector(emptyMsgClick:) forControlEvents:UIControlEventTouchUpInside];
    if (block != nil) {
        dickBlocks[Identity] = block;
    }
    [emptyMessageView addSubview:btn];
    
    [arrayViews addObject:emptyMessageView];

}

-(void)setEmptyView:(NSString *)Identity view:(UIView *)view YScale:(CGFloat)yScale{
    if (!arrayViews) {
        arrayViews = [NSMutableArray new];
    }
    view.tag = -1111;
    view.accessibilityIdentifier = Identity;
    CGFloat y = self.frame.size.height * yScale;
    if (y == 0) {
        y = [UIScreen mainScreen].bounds.size.height  * yScale ;
    }
    view.frame = CGRectMake(view.frame.origin.x, y, view.frame.size.width, view.frame.size.height);
    [arrayViews addObject:view];
}

-(void)showEmptyPageWithIdentity:(NSString *)identity{
    self.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    for (UIView* view in arrayViews) {
        if ([view.accessibilityIdentifier isEqualToString:identity]) {
            if (view.frame.size.width == 0){
                view.frame = self.bounds;
            }
            if (view.tag != -1111) {
                for (UIView* v in view.subviews) {
                    if (view.subviews.count == 1) {
                        v.frame = CGRectMake(0, v.tag / 100.0 * view.frame.size.height, view.frame.size.width, v.frame.size.height);
                    }
                    else{
                        UIView* img;
                        if([v isKindOfClass:[UIImageView class]]){
                            img = v;
                            v.frame = CGRectMake(0, v.tag / 100.0 * view.frame.size.height, view.frame.size.width, v.frame.size.height);
                        }
                        else  if([v isKindOfClass:[UILabel class]]){
                            if(v.frame.origin.y <= 0){
                                v.frame = CGRectMake(0, v.tag / 100.0 + CGRectGetMaxY(img.frame), view.frame.size.width, v.frame.size.height);
                            }
                            
                        }
                    }
                }
            }
            [self addSubview:view];
            break;
        }
    }
}


-(void)removeEmptyPageWithIdentity:(NSString*)identity
{
    self.backgroundColor = [UIColor whiteColor];
    for (UIView* view in self.subviews) {
        if ([view.accessibilityIdentifier isEqualToString:identity]) {
            [view removeFromSuperview];
            break;
        }
    }
}

-(void)emptyMsgClick:(UIButton*)sender{
    
    if (dickBlocks[sender.accessibilityIdentifier]) {
        clickBlock blk = dickBlocks[sender.accessibilityIdentifier];
        blk(sender);
    }
}

@end

@implementation UIView (EmptyMessage)

-(void)setEmptyInfoWithIdentity:(NSString *)Identity emptyMessage:(NSAttributedString *)emptyMessage imageName:(NSString *)name imageYScale:(CGFloat)imageYScale ImageHeight:(CGFloat)ImageHeight messageDistanseFromImage:(CGFloat)distanse messageHeight:(CGFloat)messageHeight {
    
    if (!arrayViews) {
        arrayViews = [NSMutableArray new];
    }
    UIView*   emptyMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    emptyMessageView.accessibilityIdentifier = Identity;
    //emptyMessageView.backgroundColor = BACKGROUNDCOLOR_240;
    UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height * imageYScale, self.frame.size.width, ImageHeight)];
    img.contentMode = UIViewContentModeScaleAspectFit;
    img.image = [UIImage imageNamed:name];
    [emptyMessageView addSubview:img];
    
    UILabel* lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(img.frame) + distanse, self.frame.size.width, messageHeight)];
    lblMessage.backgroundColor = [UIColor clearColor];
    lblMessage.attributedText = emptyMessage;
    lblMessage.textAlignment = NSTextAlignmentCenter;
    [emptyMessageView addSubview:lblMessage];
    
    [arrayViews addObject:emptyMessageView];
    //   [self addSubview:emptyMessageView];
    //这里不添加
    
}

-(void)setEmptyInfoWithIdentity:(NSString *)Identity emptyMessage:(NSAttributedString *)emptyMessage imageName:(NSString *)name coverInSuperViewY:(CGFloat)Y imageYScale:(CGFloat)imageYScale ImageHeight:(CGFloat)ImageHeight messageDistanseFromImage:(CGFloat)distanse messageHeight:(CGFloat)messageHeight{
    if (!arrayViews) {
        arrayViews = [NSMutableArray new];
    }
    UIView *emptyMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, Y, self.frame.size.width, self.frame.size.height)];
    emptyMessageView.accessibilityIdentifier = Identity;
    //emptyMessageView.backgroundColor = BACKGROUNDCOLOR_240;
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, imageYScale * (self.frame.size.height + Y) - Y , self.frame.size.width, ImageHeight)];
    img.contentMode = UIViewContentModeScaleAspectFit;
    img.image = [UIImage imageNamed:name];
    [emptyMessageView addSubview:img];
    
    UILabel *lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(img.frame) + distanse, self.frame.size.width, messageHeight)];
    lblMessage.backgroundColor = [UIColor clearColor];
    lblMessage.attributedText = emptyMessage;
    lblMessage.textAlignment = NSTextAlignmentCenter;
    [emptyMessageView addSubview:lblMessage];
    
    [arrayViews addObject:emptyMessageView];
}

-(void)showEmptyPageWithIdentity:(NSString *)identity{
    self.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    for (UIView* view in arrayViews) {
        if ([view.accessibilityIdentifier isEqualToString:identity]) {
            if (view.frame.size.width == 0){
                view.frame = self.bounds;
            }
            for (UIView* v in view.subviews) {
                if (view.subviews.count == 1) {
                    v.frame = CGRectMake(0, v.tag / 100.0 * view.frame.size.height, view.frame.size.width, v.frame.size.height);
                }
                else{
                    UIView* img;
                    if([v isKindOfClass:[UIImageView class]]){
                        img = v;
                        v.frame = CGRectMake(0, v.tag / 100.0 * view.frame.size.height, view.frame.size.width, v.frame.size.height);
                    }
                    else  if([v isKindOfClass:[UILabel class]]){
                        v.frame = CGRectMake(0, v.tag / 100.0 + CGRectGetMaxY(img.frame), view.frame.size.width, v.frame.size.height);
                    }
                }
            }
            [self addSubview:view];
            break;
        }
    }
}

-(void)removeEmptyPageWithIdentity:(NSString*)identity
{
    self.backgroundColor = [UIColor whiteColor];
    for (UIView* view in self.subviews) {
        if ([view.accessibilityIdentifier isEqualToString:identity]) {
            [view removeFromSuperview];
            break;
        }
    }
}

@end


@implementation UITableView(EmptyMessage)

-(void)reloadWithToken:(NSString *)token{
    NSInteger section = 1;
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:) ] ) {
        section = [self.dataSource numberOfSectionsInTableView:self];
    }
    NSInteger count = 0;
    for (NSInteger i = 0; i < section; i++) {
         count += [self.dataSource tableView:self numberOfRowsInSection:i];
    }
    
    [self reloadData];
    if (count <= 0){
        [self showEmptyPageWithIdentity:token];
    }
    else{
        [self removeEmptyPageWithIdentity:token];
    }
}

@end
