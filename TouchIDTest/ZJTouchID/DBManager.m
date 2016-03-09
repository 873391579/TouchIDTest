//
//  DBManager.m
//  TouchIDTest
//
//  Created by Jion on 16/3/3.
//  Copyright © 2016年 Youjuke. All rights reserved.
//

#import "DBManager.h"
#import "FMDB.h"

@interface DBManager ()
@property(nonatomic,strong)FMDatabase *db;
@property(nonatomic,strong)FMDatabaseQueue *queue;
@end

@implementation DBManager
static DBManager *instance = nil;
+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         instance = [[DBManager alloc]init];
    });
    [instance shareFMDB];
    return instance;
}
//建表之前，先导入libsqlite3库
- (void)shareFMDB
{
    //1.获得数据库文件的路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [path stringByAppendingString:@"/cache.sqlite"];
   
    //2.获得数据库
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    //设置缓存可在有图片时使用
//    [db setShouldCacheStatements:YES];
    //3.打开数据库
    if ([db open]) {
        NSLog(@"打开数据库成功");
    }else{
        NSLog(@"打开数据库失败");
    }
    
    [db close];
    self.db = db;
}

//4.创表:字典中，key是列的名字，值是列的类型，如果有附加参数，直接写到值中
-(void)createtableForm:(NSString *)tableName keyAndAttribute:(NSDictionary *)dic
{
    if ([_db open]) {
        //4.创表
        NSString * sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(id integer PRIMARY KEY AUTOINCREMENT",tableName];
        
        for (NSString * columnName in dic) {
            if (![columnName isEqualToString:@"id"]) {
                sql = [sql stringByAppendingFormat:@", %@ %@", columnName, dic[columnName]];
            }
        }
        sql = [sql stringByAppendingString:@");"];
        BOOL result = [_db executeUpdate:sql];
        if (result) {
            NSLog(@"建表成功");
        }else{
            NSLog(@"建表失败");
        }
    }
    
    [_db close];
}


//插入数据
-(void)insertData:(NSDictionary *)dataDic ToTableForm:(NSString *)tableName
{
    [_db open];
    NSString * columnNames = [dataDic.allKeys componentsJoinedByString:@", "];
    
    NSMutableArray * xArray = [NSMutableArray array];
    
    for(int i = 0;i < dataDic.count;i++)
    {
        [xArray addObject:@"?"];
    }
    
    NSString * valueStr = [xArray componentsJoinedByString:@", "];
    NSString * sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES(%@);", tableName, columnNames, valueStr];
    BOOL ret = [_db executeUpdate:sql withArgumentsInArray:dataDic.allValues];
    if (ret == NO) {
        perror("插入失败");
    }else{
        NSLog(@"插入成功");
    }

    [_db close];
    
//    for (int i = 0; i<10; i++){
//        NSString *name = [NSString stringWithFormat:@"jack-%d", arc4random_uniform(100)];
        // executeUpdate : 不确定的参数用?来占位
//        [self.db executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?, ?);", name, @(arc4random_uniform(40))];
        //        [self.db executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?, ?);" withArgumentsInArray:@[name, @(arc4random_uniform(40))]];
         // executeUpdateWithFormat : 不确定的参数用%@、%d等来占位
         //        [self.db executeUpdateWithFormat:@"INSERT INTO t_student (name, age) VALUES (%@, %d);", name, arc4random_uniform(40)];
//    }
}

//删除数据
-(BOOL)deleteData:(NSDictionary*)whereDic fromTable:(NSString *)tableName
{
    [_db open];
    NSString * sql = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    for (int i = 0; i<whereDic.count; i++) {
        if (i==0) {
            sql = [sql stringByAppendingString:@" WHERE "];
        }else{
            sql = [sql stringByAppendingString:@" AND "];
        }
        sql = [sql stringByAppendingFormat:@"%@ = ?", whereDic.allKeys[i]];
    }
    sql = [sql stringByAppendingString:@";"];
   BOOL result = [_db executeUpdate:sql withArgumentsInArray:whereDic.allValues];
    [_db close];
    return result;
//    [self.db executeUpdate:@"DROP TABLE IF EXISTS t_student;"];
//    [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_student (id integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, age integer NOT NULL);"];
//    [self.db executeUpdate:@"DELETE FROM t_student;"];
}

//修改数据
-(BOOL)update:(NSDictionary *)dataDic where:(NSDictionary*)whereDic fromTable:(NSString *)tableName
{
    [_db open];
    //首先判断是否有参数带有的字段
    for (NSString *coulumn in dataDic.allKeys) {
        if (![_db columnExists:coulumn inTableWithName:tableName]) {
            NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ text",tableName,coulumn];
            [_db executeUpdate:sql];
            
        }
    }
    
    if (dataDic.count==0||whereDic.count==0) {
        return NO;
    }
    
    NSString *setString = @"";
    for (int i=0;i < dataDic.allKeys.count;i++) {
        if (i==dataDic.allKeys.count-1) {
            setString = [NSString stringWithFormat:@"%@%@ = '%@'",setString,dataDic.allKeys[i],dataDic.allValues[i]];
        }else{
            setString = [NSString stringWithFormat:@"%@%@ = '%@' ,",setString,dataDic.allKeys[i],dataDic.allValues[i]];
        }
        
    }
    NSString *whereString = @"";
    for (int i=0;i < whereDic.allKeys.count;i++) {
        if (i==whereDic.allKeys.count-1) {
            whereString = [NSString stringWithFormat:@"%@%@ = '%@'",whereString,whereDic.allKeys[i],whereDic.allValues[i]];
        }else{
            whereString = [NSString stringWithFormat:@"%@%@ = '%@' ,",whereString,whereDic.allKeys[i],whereDic.allValues[i]];
        }
        
    }
    
    NSString * sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@",tableName,setString,whereString];
    BOOL res = [_db executeUpdate:sql];
    if (!res) {
        NSLog(@"改变数据失败");
    }else{
        NSLog(@"改变数据成功");
    }
    [_db close];
    return res;
}

//按条件查询
- (NSArray*)queryDataFromTableForm:(NSString *)tableName keyAndValue:(NSDictionary*)keyValue
{
    [_db open];
    NSString *xTerm = @"";
    for (int i=0; i<keyValue.count; i++) {
        if (i == keyValue.count-1) {
            xTerm  = [NSString stringWithFormat:@"%@ %@ = ? ",xTerm, keyValue.allKeys[i]];
        }else{
           xTerm  = [NSString stringWithFormat:@"%@ %@ = ? AND",xTerm, keyValue.allKeys[i]];
        }
        

    }
    
    NSString * sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE%@",tableName,xTerm];
    FMResultSet *resultSet = [self.db executeQuery:sql withArgumentsInArray:keyValue.allValues];
    NSMutableArray * dataArray =[NSMutableArray array];
    while ([resultSet next]){
        NSDictionary *dic  = [resultSet resultDictionary];
        [dataArray addObject:dic];
    }
    [_db close];
    return dataArray;
}

//按字段查询
- (NSArray*)queryDataFromTableForm:(NSString *)tableName paramsKey:(NSString*)key
{
    [_db open];
     NSString * sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
    FMResultSet *resultSet = [self.db executeQuery:sql];
    NSMutableArray * dataArray = [NSMutableArray array];
    while ([resultSet next]){
        
        NSString *value = [resultSet stringForColumn:key];
        [dataArray addObject:value];
    }
    
    [_db close];
    return dataArray;
}
//表单查询
- (NSArray*)queryAllDataFromTableForm:(NSString *)tableName
{
    [_db open];
    NSString * sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
    // 1.执行查询语句
    FMResultSet *resultSet = [self.db executeQuery:sql];
    // 2.遍历结果
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    while ([resultSet next]){
        NSDictionary *dic  = [resultSet resultDictionary];
        [dataArray addObject:dic];
       
    }
    [_db close];

    return dataArray;

}

/**********************************/

/**************************  QUEUE  ****************************/

+ (instancetype)queueManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DBManager alloc]init];
    });
    [instance queueFMDB];
    return instance;
}

- (void)queueFMDB
{
    //1.获得数据库文件的路径
    NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName=[doc stringByAppendingPathComponent:@"/cache.sqlite"];
    //2.获得数据库队列
    FMDatabaseQueue *queue=[FMDatabaseQueue databaseQueueWithPath:fileName];
     //3.打开数据库
    [queue inDatabase:^(FMDatabase *db){
        [db open];
        [db close];
    }];
    self.queue=queue;
                     
}
//4.创表
-(void)queueCreateTableForm:(NSString *)tableName keyAndAttribute:(NSDictionary *)dic{
    [self.queue inDatabase:^(FMDatabase *db) {
        [db open];
        //字典中，key是列的名字，值是列的类型，如果有附加参数，直接写到值中
        /*
         id递增
         BOOL result=[db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_person (id integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, age integer NOT NULL);"];
         */
        NSString * sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(id integer PRIMARY KEY",tableName];
        
        for (NSString * columnName in dic) {
            if (![columnName isEqualToString:@"id"]) {
                sql = [sql stringByAppendingFormat:@", %@ %@", columnName, dic[columnName]];
            }
        }
        sql = [sql stringByAppendingString:@");"];
        BOOL ret = [db executeUpdate:sql];
        if (ret) {
            NSLog(@"建表成功");
            
        }else{
           NSLog(@"建表失败");
        }
        
        [db close];
    }];
    
}

//添加字段
- (void)addColumnForTable:(NSString*)tableName coulumn:(NSString*)coulumnName
{
    [self.queue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db columnExists:coulumnName inTableWithName:tableName]) {
            NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ text NOT NULL",tableName,coulumnName];
          BOOL ret =  [db executeUpdate:sql];
            if (ret) {
                NSLog(@"添加字段成功");
            }else{
                NSLog(@"添加字段失败");
            }
        }
        
        [db close];
    }];
}

//插入数据: dataDic为插入数据库的字典 tableName为表单的名称
- (void)queueInsertData:(NSDictionary *)dataDic ToTableForm:(NSString *)tableName
{
    
    [self.queue inDatabase:^(FMDatabase *db){
        [db open];
        
        NSString * columnNames = [dataDic.allKeys componentsJoinedByString:@", "];
        
        NSMutableArray * xArray = [NSMutableArray array];
        
        for(int i = 0;i < dataDic.count;i++)
        {
            [xArray addObject:@"?"];
        }
        
        NSString * valueStr = [xArray componentsJoinedByString:@", "];
        NSString * sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES(%@);", tableName, columnNames, valueStr];
        BOOL ret = [db executeUpdate:sql withArgumentsInArray:[dataDic.allValues arrayByAddingObject:[NSDate date]]];
        
        if (ret == NO) {
            perror("插入失败");
        }else{
            NSLog(@"插入成功");
        }
        [db close];
    }];
}

//条件查询
- (NSArray *)queueQueryDataFromTableForm:(NSString *)tableName keyAndValue:(NSDictionary*)keyValue
{
    __block NSMutableArray * dataArray = nil;
    [self.queue inDatabase:^(FMDatabase *db){
        [db open];
        NSString *xTerm = @"";
        
        for (int i=0; i<keyValue.count; i++) {
            if (i == keyValue.count-1) {
                xTerm  = [NSString stringWithFormat:@"%@ %@ = ? ",xTerm, keyValue.allKeys[i]];
            }else{
                xTerm  = [NSString stringWithFormat:@"%@ %@ = ? AND",xTerm, keyValue.allKeys[i]];
            }
            
            
        }
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE%@",tableName,xTerm];
        FMResultSet *resultSet = [db executeQuery:sql withArgumentsInArray:keyValue.allValues];
        dataArray = [[NSMutableArray alloc]init];
        while ([resultSet next]){
            NSMutableDictionary *dic  = (NSMutableDictionary*)[resultSet resultDictionary];
            for (int i=0;i<dic.allKeys.count;i++) {
                id value = dic.allValues[i];
                if ([value isKindOfClass:[NSNull class]]) {
                    [dic removeObjectForKey:dic.allKeys[i]];
                }
            }
            [dataArray addObject:dic];
            
        }

        [db close];
    }];
    return dataArray;
}
//按字段查询
- (NSArray*)queueQueryFromTableForm:(NSString *)tableName paramsKey:(NSString*)key
{
    __block NSMutableArray * dataArray = nil;
    [self.queue inDatabase:^(FMDatabase *db){
       [db open];
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
        FMResultSet *resultSet = [db executeQuery:sql];
        dataArray = [NSMutableArray array];
        while ([resultSet next]){
            
            NSString *value = [resultSet stringForColumn:key];
            [dataArray addObject:value];
        }
        [db close];
    }];
    return dataArray;
    
}
//查询数据
- (NSArray *)queueQueryAllDataFromTableForm:(NSString *)tableName
{
    __block NSMutableArray * dataArray = nil;
   
    [self.queue inDatabase:^(FMDatabase *db){
        [db open];
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
        // 1.执行查询语句
        FMResultSet *resultSet = [db executeQuery:sql];
        
        dataArray = [[NSMutableArray alloc]init];
        // 2.遍历结果
        while ([resultSet next]){
            NSDictionary *dic  = [resultSet resultDictionary];
            [dataArray addObject:dic];
            
        }
        [db close];
            
        }];
    
    return dataArray;
       
}
-(void)queueUpdate:(NSDictionary *)dataDic where:(NSDictionary*)whereDic fromTable:(NSString *)tableName{
    [self.queue inDatabase:^(FMDatabase *db) {
        [db open];
        
        //首先判断是否有参数带有的字段
        for (NSString *coulumn in dataDic.allKeys) {
            if (![db columnExists:coulumn inTableWithName:tableName]) {
                NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ text",tableName,coulumn];
                [db executeUpdate:sql];
                
            }
        }
        
        if (dataDic.count==0||whereDic.count==0) {
            return ;
        }
        
        NSString *setString = @"";
        for (int i=0;i < dataDic.allKeys.count;i++) {
            if (i==dataDic.allKeys.count-1) {
                setString = [NSString stringWithFormat:@"%@%@ = '%@'",setString,dataDic.allKeys[i],dataDic.allValues[i]];
            }else{
                setString = [NSString stringWithFormat:@"%@%@ = '%@' ,",setString,dataDic.allKeys[i],dataDic.allValues[i]];
            }
            
        }
        NSString *whereString = @"";
        for (int i=0;i < whereDic.allKeys.count;i++) {
            if (i==whereDic.allKeys.count-1) {
                whereString = [NSString stringWithFormat:@"%@%@ = '%@'",whereString,whereDic.allKeys[i],whereDic.allValues[i]];
            }else{
                whereString = [NSString stringWithFormat:@"%@%@ = '%@' ,",whereString,whereDic.allKeys[i],whereDic.allValues[i]];
            }
            
        }
        
        NSString * sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@",tableName,setString,whereString];
        BOOL res = [db executeUpdate:sql];
        if (!res) {
            NSLog(@"改变数据失败");
        }else{
            NSLog(@"改变数据成功");
        }
        [db close];
       
    }];
    
}
- (void)queueDeleteData:(NSDictionary *)dict fromTable:(NSString *)tableName
{
    [self.queue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString * sql = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
        for (int i = 0; i<dict.count; i++) {
            if (i==0) {
                sql = [sql stringByAppendingString:@" WHERE "];
            }else{
              sql = [sql stringByAppendingString:@" AND "];
            }
            sql = [sql stringByAppendingFormat:@"%@ = ?", dict.allKeys[i]];
        }
        sql = [sql stringByAppendingString:@";"];
        BOOL ret = [db executeUpdate:sql withArgumentsInArray:dict.allValues];
        if (!ret) {
            perror("删除失败");
        }else{
            NSLog(@"删除成功");
        }
    }];
}

//事务插入：把多条语句放到同一个事务中，要么全部成功，要不全部失败（如果中途出现问题，那么会自动回滚）。事务的执行具有原子性。
- (void)eventInsert
{
    [self.queue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
         [db executeUpdate:@"INSERT INTO t_person (name, age) VALUES (?, ?);",@"wendingding", @22];
         [db executeUpdate:@"INSERT INTO t_person (name, age) VALUES (?, ?);",@"wendingding", @23];
        [db commit];
    }];
}
//事务处理的另一种方式:先开事务，再开始事务，之后执行block中的代码段，最后提交事务

- (void)eventOtherInsert{
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback){
        [db executeUpdate:@"INSERT INTO t_person (name, age) VALUES (?, ?);",@"wendingding", @22];
        [db executeUpdate:@"INSERT INTO t_person (name, age) VALUES (?, ?);",@"wendingding", @23];
        [db executeUpdate:@"INSERT INTO t_person (name, age) VALUES (?, ?);",@"wendingding", @24];
    }];
}

@end
