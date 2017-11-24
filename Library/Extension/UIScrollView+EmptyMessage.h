//
//  UIScrollView+EmptyMessage.h
//  Qfq
//
//  Created by Gforce on 14-9-20.
//  Copyright (c) 2014年 qfq. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^clickBlock)(UIView * sender);
@interface UIScrollView (EmptyMessage)

@property (nonatomic ,assign) NSString* emptyMessage;

@property (nonatomic,copy) NSString* imgUrl;


-(void)setEmptyMessage:(NSString*) Identity emptyMessage:(NSAttributedString*) message YScale:(CGFloat)yScale height:(CGFloat)height;

-(void)setEmptyMessage:(NSString*) Identity emptyMessage:(NSAttributedString*) message YScale:(CGFloat)yScale height:(CGFloat)height block:(clickBlock)blk;
-(void)setEmptyImage:(NSString*) Identity imgUrl:(NSString*) imgUrl YScale:(CGFloat)yScale height:(CGFloat)height;

-(void)removeEmptyPageWithIdentity:(NSString*)identity;
-(void)setEmptyInfo:(NSString*) Identity emptyMessage:(NSAttributedString*)emptyMessage imgUrl:(NSString*)imgUrl  imageYScale:(CGFloat)imageYScale ImageHeight:(CGFloat)ImageHeight messageDistanseFromImage:(CGFloat)distanse messageHeight:(CGFloat)messageHeight;
-(void)setEmptyInfo:(NSString*) Identity emptyMessage:(NSAttributedString*)emptyMessage btn:(NSString*)btnContent  messageYScale:(CGFloat)messageYScale messageHeight:(CGFloat)messageHeight btnDistanseFromMsg:(CGFloat)distanse btnWidth:(CGFloat) btnWidth btnHeight:(CGFloat)btnHeight  clickBlock:(clickBlock)block;
-(void)showEmptyPageWithIdentity:(NSString*)identity;

-(void)setEmptyView:(NSString*) Identity view:(UIView*) view YScale:(CGFloat)yScale;
@end

@interface UIView (EmptyMessage)
-(void)setEmptyInfoWithIdentity:(NSString *)Identity emptyMessage:(NSAttributedString *)emptyMessage imageName:(NSString *)name imageYScale:(CGFloat)imageYScale ImageHeight:(CGFloat)ImageHeight messageDistanseFromImage:(CGFloat)distanse messageHeight:(CGFloat)messageHeight;

-(void)setEmptyInfoWithIdentity:(NSString *)Identity emptyMessage:(NSAttributedString *)emptyMessage imageName:(NSString *)name coverInSuperViewY:(CGFloat)Y imageYScale:(CGFloat)imageYScale ImageHeight:(CGFloat)ImageHeight messageDistanseFromImage:(CGFloat)distanse messageHeight:(CGFloat)messageHeight;

-(void)showEmptyPageWithIdentity:(NSString*)identity;
-(void)removeEmptyPageWithIdentity:(NSString*)identity;
@end

@interface UITableView (EmptyMessage)
-(void)reloadWithToken:(NSString*)token;
@end
