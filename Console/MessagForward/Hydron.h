//
//  Hydron.h
//  
//
//  Created by Stan Hu on 2018/11/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Hydron : NSObject
//这里可以做简单转发
@property (nonatomic,copy) NSString* name;

@end



//因为没有这个方法XCode就会报错，所以可以用categary来实现
@interface Hydron(helper)
-(NSString*)hydronId;
@end
NS_ASSUME_NONNULL_END
