//
//  YASQLManager.h
//  Aaron
//
//  Created by Chen,Yalun on 2019/6/1.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YAModelManagerProtocol <NSObject>
@required
+ (NSString *)primaryKey;
@optional
+ (NSArray <NSString *> *)ignoreKeys;
// 新的字段映射到旧的字段(不能是主键)
+ (NSDictionary <NSString *, NSString *> *)customTableKeyForUpdate;
@end



@interface YAModelManager : NSObject
// 支持新增或者删减类的成员变量
+ (BOOL)updateTableKeysForClass:(Class)cls uid:(NSString *)uid;

+ (BOOL)updateModel:(id)model uid:(NSString *)uid;
+ (NSArray <id> *)queryAllModelsWithClass:(Class)cls uid:(NSString *)uid;
+ (BOOL)deleteModel:(id)model uid:(NSString *)uid;
+ (BOOL)deleteModelForClass:(Class)cls
                        uid:(NSString *)uid
                  condition:(NSString *)condition;
@end

@interface YASQLManager : NSObject
+ (BOOL)executeSQL:(NSString *)sql uid:(NSString *)uid;
+ (NSMutableArray <NSMutableDictionary *> *)querySQL:(NSString *)sql uid:(NSString *)uid;
@end

