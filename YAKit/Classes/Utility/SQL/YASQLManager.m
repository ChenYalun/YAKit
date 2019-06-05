//
//  YASQLManager.m
//  Aaron
//
//  Created by Chen,Yalun on 2019/6/1.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import "YASQLManager.h"
#import "sqlite3.h"
#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject

static sqlite3 *ppdb = nil;
@implementation YASQLManager
+ (BOOL)executeSQL:(NSString *)sql uid:(NSString *)uid {
    if (![self openDB:uid]) return NO;
    // 执行语句
    BOOL result = sqlite3_exec(ppdb, sql.UTF8String, nil, nil, nil) == SQLITE_OK;
    [self closeDB];
    return result;
}

+ (BOOL)executeSQLList:(NSArray <NSString *> *)sqlList uid:(NSString *)uid {
    // 执行语句
    [self beginTransactionWithUID:uid];
    for (NSString *sql in sqlList) {
        BOOL result = [self executeSQL:sql uid:uid];
        if (!result) {
            [self rollBackTransactionWithUID:uid];
            return NO;
        }
    }
    [self commitTransactionWithUID:uid];
    return YES;
}

+ (NSMutableArray <NSMutableDictionary *> *)querySQL:(NSString *)sql
                                                uid:(NSString *)uid {
    [self openDB:uid];
    sqlite3_stmt *ppStmt = nil;
    if (sqlite3_prepare_v2(ppdb, sql.UTF8String, -1, &ppStmt, nil) != SQLITE_OK) {
        return nil;
    }
    
    NSMutableArray *rowDictArray = [NSMutableArray array];
    while (sqlite3_step(ppStmt) == SQLITE_ROW) {
        NSMutableDictionary *rowDict = [NSMutableDictionary dictionary];
        [rowDictArray addObject:rowDict];
        // 列个数
        int columnCount = sqlite3_column_count(ppStmt);
        // 遍历
        for (int i = 0; i < columnCount; i++) {
            const char *cName = sqlite3_column_name(ppStmt, i);
            NSString *columnName = [NSString stringWithUTF8String:cName];
            // 类型
            int type = sqlite3_column_type(ppStmt, i);
            id value = nil;
            switch (type) {
                case SQLITE_INTEGER:
                    value = @(sqlite3_column_int(ppStmt, i));
                    break;
                case SQLITE_FLOAT:
                    value = @(sqlite3_column_double(ppStmt, i));
                    break;
                case SQLITE_BLOB:
                    value = CFBridgingRelease(sqlite3_column_blob(ppStmt, i));
                    break;
                case SQLITE_TEXT:
                    value = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(ppStmt, i)];
                    break;
                case SQLITE_NULL:
                    value = @"";
                    break;
                default:break;
            }
            [rowDict setValue:value forKey:columnName];
        }
    }
    sqlite3_finalize(ppStmt);
    [self closeDB];
    return rowDictArray;
}

+ (BOOL)openDB:(NSString *)uid {
    NSString *db = uid.length > 0 ? uid : @"common";
    db = [NSString stringWithFormat:@"%@.sqlite", db];
    NSString *dbPath = [kCachePath stringByAppendingPathComponent:db];
    // 创建或者打开数据库
    ppdb = nil;
    if (sqlite3_open(dbPath.UTF8String, &ppdb) != SQLITE_OK) return NO;
    return YES;
}

+ (void)closeDB {
    sqlite3_close(ppdb);
}

+ (void)beginTransactionWithUID:(NSString *)uid {
    [self executeSQL:@"begin transaction" uid:uid];
}

+ (void)commitTransactionWithUID:(NSString *)uid {
    [self executeSQL:@"commit transaction" uid:uid];
}

+ (void)rollBackTransactionWithUID:(NSString *)uid {
    [self executeSQL:@"rollback transaction" uid:uid];
}
@end



#import <objc/runtime.h>
@interface YAModelManager()
@end
@implementation YAModelManager
+ (NSString *)tableNameForClass:(Class)cls {
    return NSStringFromClass(cls);
}

+ (NSDictionary *)classIvarNameTypeDict:(Class)cls {
    NSMutableDictionary *nameTypeDict = [NSMutableDictionary dictionary];
    unsigned int outCount = 0;
    Ivar *varList = class_copyIvarList(cls, &outCount);
    // 忽略的成员变量
    NSArray *ignoreKeys = nil;
    if ([cls respondsToSelector:@selector(ignoreKeys)]) {
        ignoreKeys = [cls ignoreKeys];
    }
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = varList[i];
        // name
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        if ([ivarName hasPrefix:@"_"]) {
            ivarName = [ivarName substringFromIndex:1];
        }
        // type
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        type = [type stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
        if (![ignoreKeys containsObject:ivarName]) {
             [nameTypeDict setObject:type forKey:ivarName];
        }
    }
    return nameTypeDict;
}

static inline NSDictionary *dictionaryForObjectiveCTypeToSQLiteType() {
    static NSDictionary *info = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        info = @{
                 @"d": @"real",    // double
                 @"f": @"real",    // float
                 
                 @"i": @"integer", // int
                 @"q": @"integer", // long
                 @"Q": @"integer", // long long
                 @"B": @"integer", // bool
                 
                 @"NSData": @"blob",
                 @"NSArray": @"text",
                 @"NSDictionary": @"text",
                 @"NSMutableArray": @"text",
                 @"NSMutableDictionary": @"text",
                 
                 @"NSString": @"text",
                 };
    });
    return info;
}

+ (NSDictionary *)ivarNameTypeDictionaryForClass:(Class)cls {
    NSMutableDictionary *dict = [[self classIvarNameTypeDict:cls] mutableCopy];
    NSDictionary *brige = dictionaryForObjectiveCTypeToSQLiteType();
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        dict[key] = brige[obj];
    }];
    return dict;
}

+ (NSString *)ivarNameTypeStringForClass:(Class)cls {
    NSDictionary *dict = [self ivarNameTypeDictionaryForClass:cls];
    NSMutableArray *pairArray = [NSMutableArray array];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [pairArray addObject:[NSString stringWithFormat:@"%@ %@", key, obj]];
    }];
    return [pairArray componentsJoinedByString:@","];
}

+ (BOOL)createTableForClass:(Class <YAModelManagerProtocol>)cls uid:(NSString *)uid {
    NSString *tableName = [self tableNameForClass:cls];
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        [[NSException exceptionWithName:@"未遵守协议" reason:@"没有实现primaryKey方法" userInfo:nil] raise];
        return NO;
    }
    NSString *primaryKey = [cls primaryKey];
    NSString *createTableSQL = [NSString stringWithFormat:@"create table if not exists %@(%@, primary key(%@))", tableName, [self ivarNameTypeStringForClass:cls], primaryKey];
    return [YASQLManager executeSQL:createTableSQL uid:uid];
}

+ (NSArray <NSString *> *)tableKeyListForClass:(Class) cls uid:(NSString *)uid {
    NSString *createTableSQL = nil;
    // 表格是否存在
    BOOL isTableExists = [self isTableExistsForClass:cls uid:uid createTableSQL:&createTableSQL];
    if (!isTableExists || createTableSQL.length <= 0) return nil;
    // 格式化
    // CREATE TABLE YAObject(ID text,num integer,firstName text,age integer,name text, primary key(ID))
    // ID text,num integer,firstName text,age integer,name text, primary key
    NSString *name = [createTableSQL componentsSeparatedByString:@"("][1];
    NSArray *keyTypes = [name componentsSeparatedByString:@","];
    NSMutableArray *keys = [NSMutableArray array];
    [keyTypes enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj containsString:@"primary"]) {
            NSString *key = [obj componentsSeparatedByString:@" "][0];
            [keys addObject:key];
        }
    }];
    [keys sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    return keys;
}

+ (NSArray <NSString *> *)ivarListForClass:(Class) cls uid:(NSString *)uid {
    NSArray *keys = [self ivarNameTypeDictionaryForClass:cls].allKeys;
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    return keys;
}

+ (BOOL)shouldUpdateTableKeyForClass:(Class)cls uid:(NSString *)uid {
    NSArray *tableKeys = [self tableKeyListForClass:cls uid:uid];
    NSArray *ivarList = [self ivarListForClass:cls uid:uid];
    return![tableKeys isEqualToArray:ivarList];
}

+ (BOOL)updateTableKeysForClass:(Class)cls uid:(NSString *)uid {
    if (![self shouldUpdateTableKeyForClass:cls uid:uid]) return NO;
    // 需要执行的SQL语句
    NSMutableArray *sqlList = [NSMutableArray array];
    // 1. 创建新的临时表格
    NSString *tableName = [self tableNameForClass:cls];
    NSString *tmpTableName = [NSString stringWithFormat:@"%@_tmp", tableName];
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        [[NSException exceptionWithName:@"未遵守协议" reason:@"没有实现primaryKey方法" userInfo:nil] raise];
        return NO;
    }
    NSString *primaryKey = [cls primaryKey];
    NSString *createTableSQL = [NSString stringWithFormat:@"create table if not exists %@(%@, primary key(%@))", tmpTableName, [self ivarNameTypeStringForClass:cls], primaryKey];
    [sqlList addObject:createTableSQL];
    
    // 2. 根据主键更新数据
    NSArray *oldNames = [self tableKeyListForClass:cls uid:uid];
    NSArray *newNames = [self ivarListForClass:cls uid:uid];
    // 新表设定的新key
    NSDictionary *customTableKey = nil;
    if ([cls respondsToSelector:@selector(customTableKeyForUpdate)]) {
        customTableKey = [cls customTableKeyForUpdate];
    }
    [newNames enumerateObjectsUsingBlock:^(NSString *newName, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *oldName = customTableKey[newName] ?: newName;
        if ([oldNames containsObject:oldName] && ![newName isEqualToString:primaryKey]) {
            NSString *updateSQL = [NSString stringWithFormat:@"update %@ set %@ = (select %@ from %@ where %@.%@ = %@.%@)", tmpTableName, newName, oldName, tableName, tmpTableName, primaryKey, tableName, primaryKey];
            [sqlList addObject:updateSQL];
        }
    }];
    
    // 3. 删除旧表
    NSString *deleteOldTable = [NSString stringWithFormat:@"drop table if exists %@", tableName];
    [sqlList addObject:deleteOldTable];
    
    // 4. 重命名新表
    NSString *renameNewTable = [NSString stringWithFormat:@"alter table %@ rename to %@", tmpTableName, tableName];
    [sqlList addObject:renameNewTable];
    
    // 5. 执行事务
    return [YASQLManager executeSQLList:sqlList uid:uid];
}

+ (BOOL)isTableExistsForClass:(Class)cls
                          uid:(NSString *)uid
               createTableSQL:(NSString **)createTableSQL{
    NSString *tableName = [self tableNameForClass:cls];
    NSString *sql = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'", tableName];
    NSMutableArray *result = [YASQLManager querySQL:sql uid:uid];
    if (result.count > 0 && createTableSQL) { // 一定注意判断createTableSQL是否存在
        *createTableSQL = result.firstObject[@"sql"];
    }
    return result.count;
}

#pragma mark - Public methods
// 没有则创建, 有则更新
+ (BOOL)updateModel:(id)model uid:(NSString *)uid {
    Class cls = [model class];
    if (![self isTableExistsForClass:cls uid:uid createTableSQL:nil]) {
        // 创建
        [self createTableForClass:cls uid:uid];
    }
    // 是否需要更新字段
    if ([self shouldUpdateTableKeyForClass:cls uid:uid]) {
        [self updateTableKeysForClass:cls uid:uid];
    }
    NSString *tableName = [self tableNameForClass:cls];
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        [[NSException exceptionWithName:@"未遵守协议" reason:@"没有实现primaryKey方法" userInfo:nil] raise];
        return NO;
    }
    NSString *primaryKey = [cls primaryKey];
    id primaryValue = [model valueForKeyPath:primaryKey];
    if (!primaryValue) {
        [[NSException exceptionWithName:@"参数有误" reason:@"模型的主键为空" userInfo:nil] raise];
    }
    NSString *querySQL = [NSString stringWithFormat:@"select * from %@ where %@ = '%@'", tableName, primaryKey, primaryValue];
    NSArray *result = [YASQLManager querySQL:querySQL uid:uid];
    
    NSArray *allKeys = [self classIvarNameTypeDict:cls].allKeys;
    NSMutableArray *values = [NSMutableArray array];
    NSMutableArray *keys = [NSMutableArray array];
    [allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = [model valueForKeyPath:key];
        if (value) { // 只取有值的key和value
            if ([value isKindOfClass:NSArray.class] || [value isKindOfClass:NSDictionary.class]) {
                NSData *data = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:nil];
                value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            [keys addObject:key];
            [values addObject:value];
        }
    }];
    
    // 拼接key和value
    NSMutableArray *keyValueArray = [NSMutableArray array];
    NSUInteger count = keys.count;
    for (NSUInteger i = 0; i < count; i++) {
        NSString *keyValue = [NSString stringWithFormat:@"%@='%@'",keys[i], values[i]];
        [keyValueArray addObject:keyValue];
    }
    NSString *sql = nil;
    if (result.count > 0) {
        // 更新
        sql = [NSString stringWithFormat:@"update %@ set %@ where %@ = '%@'", tableName, [keyValueArray componentsJoinedByString:@","], primaryKey, primaryValue];
    } else {
        // 插入
        sql = [NSString stringWithFormat:@"insert into %@(%@) values('%@')", tableName, [keys componentsJoinedByString:@","], [values componentsJoinedByString:@"','"]];
    }
    return [YASQLManager executeSQL:sql uid:uid];;
}

+ (NSArray <id> *)queryAllModelsWithClass:(Class)cls uid:(NSString *)uid {
    NSString *tableName = [self tableNameForClass:cls];
    NSString *sql = [NSString stringWithFormat:@"select * from %@", tableName];
    NSArray <NSDictionary *> *results = [YASQLManager querySQL:sql uid:uid];
    NSMutableArray *modes = [NSMutableArray array];
    NSDictionary *nameTypeInfo = [self ivarNameTypeDictionaryForClass:cls];
    [results enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
        id model = [cls new];
        // [model setValuesForKeysWithDictionary:dict];
        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            id value = obj;
            NSString *type = nameTypeInfo[key];
            if ([type isEqualToString:@"NSArray"] || [type isEqualToString:@"NSDictionary"]) {
                NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
                value = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            } else if ([type isEqualToString:@"NSMutableArray"] || [type isEqualToString:@"NSMutableDictionary"]) {
                NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
                value = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            }
            [model setValue:value forKeyPath:key];
        }];
        [modes addObject:model];
    }];
    return modes;
}

+ (BOOL)deleteModel:(id)model uid:(NSString *)uid {
    Class cls = [model class];
    NSString *tableName = [self tableNameForClass:cls];
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        [[NSException exceptionWithName:@"未遵守协议" reason:@"没有实现primaryKey方法" userInfo:nil] raise];
        return NO;
    }
    NSString *primaryKey = [cls primaryKey];
    id primaryValue = [model valueForKeyPath:primaryKey];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'", tableName, primaryKey, primaryValue];
    return [YASQLManager executeSQL:sql uid:uid];
}

+ (BOOL)deleteModelForClass:(Class)cls
                        uid:(NSString *)uid
                  condition:(NSString *)condition {
    NSString *tableName = [self tableNameForClass:cls];
    NSString *sql = [NSString stringWithFormat:@"delete from %@", tableName];
    if (condition.length > 0) {
        sql = [sql stringByAppendingFormat:@" where %@", condition];
    }
    return [YASQLManager executeSQL:sql uid:uid];
}
@end
