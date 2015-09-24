//
//  DBManager.h
//  re:group'd
//
//  Created by Gal Blank on 12/19/14.
//  Copyright (c) 2014 Gal Blank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>




#define LOCAL_DB_FILE_NAME     @"amberalert"
#define LOCAL_DB_FILE_EXT      @"db"
#define DB_BUNDLE_VERSION_KEY  @"kDB_BUNDLE_VERSION_KEY"
#define DB_QUEUE_NAME          "com.galblank.app.dbqueue"


@interface DBManager : NSObject
{
    NSString *databaseFullPath;
    //sqlite3 *sqlite3Database;
    //int openDatabaseResult;
    
    //dispatch_semaphore_t semaphore;
}
-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename;
-(void)copyDatabaseIntoDocumentsDirectory;
-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable;
-(NSMutableArray *)loadDataFromDB:(NSString *)query;
-(void)executeQuery:(NSString *)query;
-(void)deleteAllDataFromDB;

+ (DBManager *)sharedInstance;

@property (nonatomic, strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;
@property (nonatomic, strong) NSMutableArray *arrResults;

@property (nonatomic, strong) dispatch_queue_t databaseQueue;

@end
