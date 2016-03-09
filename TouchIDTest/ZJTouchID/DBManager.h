//
//  DBManager.h
//  TouchIDTest
//
//  Created by Jion on 16/3/3.
//  Copyright © 2016年 Youjuke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

+ (instancetype)manager;
-(void)createtableForm:(NSString *)tableName keyAndAttribute:(NSDictionary *)dic;
//插入数据
-(void)insertData:(NSDictionary *)dataDic ToTableForm:(NSString *)tableName;
//表单查询
- (NSArray*)queryAllDataFromTableForm:(NSString *)tableName;
//按字段查询
- (NSArray*)queryDataFromTableForm:(NSString *)tableName paramsKey:(NSString*)key;
//按条件查询
- (NSArray*)queryDataFromTableForm:(NSString *)tableName keyAndValue:(NSDictionary*)keyValue;
//修改数据
-(BOOL)update:(NSDictionary *)dataDic where:(NSDictionary*)whereDic fromTable:(NSString *)tableName;
//删除数据
-(BOOL)deleteData:(NSDictionary*)whereDic fromTable:(NSString *)tableName;

/***************QUEUE*************************/

+ (instancetype)queueManager;
/*
 参数：
   tableName 表的名字
   dic   字典中，key是列的名字，值是列的类型，如果有附加参数，直接写到值中
 */
-(void)queueCreateTableForm:(NSString *)tableName keyAndAttribute:(NSDictionary *)dic;
//插入数据: dataDic为插入数据库的字典 tableName为表单的名称
- (void)queueInsertData:(NSDictionary *)dataDic ToTableForm:(NSString *)tableName;

//条件查询
- (NSArray *)queueQueryDataFromTableForm:(NSString *)tableName keyAndValue:(NSDictionary*)keyValue;
//按字段查询
- (NSArray*)queueQueryFromTableForm:(NSString *)tableName paramsKey:(NSString*)key;
/*
 修改更新
 参数：
 dataDic 要修改的数据
 whereDic  查询条件
 tableName 要修改的表的名字
 */
-(void)queueUpdate:(NSDictionary *)dataDic where:(NSDictionary*)whereDic fromTable:(NSString *)tableName;

/*
 删除
 */
- (void)queueDeleteData:(NSDictionary *)dict fromTable:(NSString *)tableName;


@end
