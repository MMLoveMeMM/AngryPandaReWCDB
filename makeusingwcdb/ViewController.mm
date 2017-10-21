//
//  ViewController.m
//  makeusingwcdb
//
//  Created by liuzhibao on 8/1/17.
//  Copyright © 2017 HelloOS. All rights reserved.
//

#import "ViewController.h"
#import <WINQ.h>
#import <core_base.hpp>
#import <database.hpp>
#import <statement_create_table.hpp>
#import <statement.hpp>

using namespace WCDB;
@interface ViewController ()

@end

//WCDB::Database *_database;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton* createdb=[self.view viewWithTag:10];
    [createdb setTitle:@"create db" forState:UIControlStateNormal];
    [createdb addTarget:self action:@selector(createdatabase) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* createtab=[self.view viewWithTag:20];
    [createtab setTitle:@"create table" forState:UIControlStateNormal];
    [createtab addTarget:self action:@selector(createtable) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* insert=[self.view viewWithTag:30];
    [insert setTitle:@"insert" forState:UIControlStateNormal];
    [insert addTarget:self action:@selector(insertdb) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* dulquery=[self.view viewWithTag:210];
    [dulquery setTitle:@"dulquery" forState:UIControlStateNormal];
    [dulquery addTarget:self action:@selector(/*dulquerydb*//*deletefiledb*//*renametable*//*querypage*//*avatarquery*/addcolume) forControlEvents:UIControlEventTouchUpInside];
    
}
typedef std::shared_ptr<WCDB::Database> DatabasePtr;
DatabasePtr _database;
typedef std::shared_ptr<WCDB::CoreBase> DatacCore;
DatacCore core;
-(void)createdatabase
{
    NSLog(@"create database !");
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                                , NSUserDomainMask
                                                                , YES);
    NSString *databaseFilePath=[[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"wcdb0125.db"];
    NSLog(@"database direction : %@",databaseFilePath);
    //_database=DatabasePtr(new WCDB::Database(databaseFilePath.UTF8String));
    core=DatacCore(new WCDB::Database(databaseFilePath.UTF8String));
    _database=DatabasePtr((WCDB::Database*)core.get());
    _database->setCipherKey("dbpassword", strlen("dbpassword"));
    //_database->setConfig("message", <#const Config &config#>, Configs::Order:)
    
    if(_database->isOpened()){
        NSLog(@"new database is open");
    }
    
    if(_database->canOpen()){
        NSLog(@"new database can be opened !");
    }else{
        NSLog(@"new database can not be opened !");
    }
    
    [self createtable];
    [self insertdb];
    [self querydb];
    //[self selectdb];
    //[self deletedb];
    //[self updatedb];
    //[self selectdb];
    //[self addcolume];
    //[self getdbversion];
    [self flushdb];
}

//method one
-(void)flushdb
{

    Error err;
    StatementPragma statement;
    statement.pragma(Pragma::WalCheckpoint);
    _database->exec(statement, err);

}
//method two
-(void)flushdatabase
{
    WCDB::Error err;
    RecyclableHandle handle = _database->flowOut(err);//from protected to public by modifing source file
    if (!handle) {
        return ;
    }
    NSLog(@"flush data to database !");
    
}

//get table

//get table verson
-(void)getdbversion
{

    StatementPragma pragmastate;
    pragmastate.pragma(WCDB::Pragma::DataVersion);
    NSLog(@"pragma sql : %s",pragmastate.getDescription().c_str());
    
    WCDB::Error err;
    WCDB::RecyclableStatement statehandle=_database->prepare(pragmastate, err);
    
    statehandle->step();
    
    const char* version = statehandle->getColumnName(0);
    const int no=statehandle->getValue<WCDB::ColumnType::Integer32>(0);
    NSLog(@"version : %s value no : %d",version,no);
    
    
}

//modify table colume
-(void)addcolume
{

    NSString* tablename=@"mytable";
    
    StatementAlterTable alterstate;
    
    
    ColumnDef columnDef(WCDB::Column("address"),WCDB::ColumnType::Text);
    ColumnDef columnDefs(WCDB::Column("age"),WCDB::ColumnType::Integer32);
    
    alterstate.alter(tablename.UTF8String).addColumn(columnDef);
    alterstate.alter(tablename.UTF8String).addColumn(columnDefs);
    NSLog(@"alter colume : %s",alterstate.getDescription().c_str());
    
    WCDB::Error err;
    WCDB::RecyclableStatement statehandle=_database->prepare(alterstate, err);
    statehandle->step();
    
}

-(void)renametable
{
    NSString* tablename=@"mytable";
    NSString* newtable=@"newtable";
    
    StatementAlterTable alterstate;
    
    ColumnDef columnDef(WCDB::Column("address"),WCDB::ColumnType::Text);
    
    alterstate.alter(tablename.UTF8String).addColumn(WCDB::ColumnDef(WCDB::Column("NIUBI"),WCDB::ColumnType::Text));
    
    //alterstate.alter(tablename.UTF8String).rename(newtable.UTF8String);
    NSLog(@"alter colume : %s",alterstate.getDescription().c_str());
    
    //WCDB::Error err;
    //WCDB::RecyclableStatement statehandle=_database->prepare(alterstate, err);
    //statehandle->step();
    
}

// operation table list structure
-(void)createtable
{
    NSString* tablename=@"mytable";
    WCDB::ColumnDefList columnDefList;
    WCDB::TableConstraintList constraintList;

    WCDB::ColumnDef columndef(WCDB::Column("name"),WCDB::ColumnType::Text);
    
    columnDefList.push_back(columndef);
    
    WCDB::ColumnDef columndef1(WCDB::Column("age"),WCDB::ColumnType::Integer32);
    
    columnDefList.push_back(columndef1);
    
    WCDB::Error err;
    WCDB::StatementCreateTable state;
    state.create([tablename cStringUsingEncoding:NSUTF8StringEncoding], columnDefList, constraintList,true);
    _database->exec(state, err);
    
}

//recover database
-(void)repairdb
{
    NSString* backupdbpath=@"";
    WCDB::Error err;
    bool result = _database->recoverFromPath([backupdbpath UTF8String], 0, "liu123456", strlen("liu123456"), "dbpassword", strlen("dbpassword"), err);
    
}
//backup database
-(void)backupdb
{
    char* backuppwd="liu123456";
    WCDB::Error err;
    bool result = _database->backup(backuppwd, strlen(backuppwd), err);
}

-(void)deletedb
{
    NSString* tablename=@"mytable";

    WCDB::StatementDelete deletestate;
    //deletestate.deleteFrom(tablename.UTF8String).where(WCDB::Expr(WCDB::Column("name"))=="shenzhen");//
    deletestate.deleteFrom(tablename.UTF8String).where(WCDB::Expr(WCDB::Column("age"))==200);
    
    NSLog(@"delete sql : %s",deletestate.getDescription().c_str());
    //effect
    WCDB::Error err;
    WCDB::RecyclableStatement statementHandle = _database->prepare(deletestate, err);
    statementHandle->step();
    
    NSLog(@"################# after delete a list ! #################");
    [self selectdb];
    
    
}

-(void)deletefiledb
{

    //select msgId from t_msg_list where _from=567 AND sid=100789
    //delete * from t_file_info where msgId in (select msgId from t_msg_list where _from=567 AND sid=100789)
    
    WCDB::ColumnResult columns(WCDB::Column("msgId"));
    std::list<const WCDB::ColumnResult> columnResultList;
    columnResultList.push_back(WCDB::ColumnResult(WCDB::Column("msgId")));
    WCDB::StatementSelect substateselect;
    substateselect.select(columnResultList).from("t_msg_list").where(WCDB::Expr(WCDB::Column("_from"))=="567"&&WCDB::Expr(WCDB::Column("sid"))=="100789"&&WCDB::Expr(WCDB::Column("cmd"))=="1006");
    
    std::list<const WCDB::StatementSelect> statelist;
    statelist.push_back(substateselect);
    
    WCDB::StatementDelete deletestate;
    deletestate.deleteFrom("t_file_info").where(WCDB::Expr(WCDB::Column("msgid")).in(statelist));
    
    NSLog(@"delfile : %s",deletestate.getDescription().c_str());
    
}

-(void)dulquerydb
{

    {
        //SELECT * FROM  t_msg_list where ts in (select ts from t_msg_list ORDER BY ts DESC) GROUP BY sid
        WCDB::ColumnResult columnts(Column::Any);// *
        
        std::list<const WCDB::ColumnResult> columnResultList;
        columnResultList.push_back(columnts);
        
        WCDB::Subquery query("t_msg_list");
        std::list<const WCDB::Subquery> subqueryList;
        subqueryList.push_back(query);
        
        WCDB::Order order(WCDB::Expr("ts"),OrderTerm::DESC);
        std::list<const WCDB::Order> orderlist;
        orderlist.push_back(order);
        
        WCDB::StatementSelect selectstate;
        //SELECT * FROM  t_msg_list where ts in (select ts from t_msg_list ORDER BY ts DESC) GROUP BY sid
        //selectstate.select(columnResultList).from(subqueryList).where(WCDB::Expr(WCDB::Column("ts"))=="LIKE %10%");
        //selectstate.select(columnResultList).from(subqueryList).where(WCDB::Expr(WCDB::Column("ts in (select ts from t_msg_list ORDER BY ts DESC) GROUP BY sid")));
        
        /*******************************************/
        //select ts from t_msg_list ORDER BY ts DESC
        WCDB::ColumnResult columns(WCDB::Expr(WCDB::Column("ts")).WCDB::Expr::max(false));
        std::list<const WCDB::ColumnResult> columnList;
        columnList.push_back(columns);
        WCDB::Subquery subquery("t_msg_list");
        std::list<const WCDB::Subquery> subqueryList1;
        subqueryList1.push_back(subquery);
        
        WCDB::Order order1(WCDB::Expr(WCDB::Column("ts")),OrderTerm::DESC);
        std::list<const WCDB::Order> orderlist1;
        orderlist1.push_back(order1);
        
        WCDB::Expr exp(WCDB::Column("sid"));
        std::list<const WCDB::Expr> grouplist;
        grouplist.push_back(exp);
        WCDB::StatementSelect selectstates;
        selectstates.select(columnList).from(subqueryList1).groupBy(grouplist).orderBy(orderlist1);
        
        std::list<const WCDB::StatementSelect> statelist;
        statelist.push_back(selectstates);
        
        selectstate.select(columnResultList).from(subqueryList).where(WCDB::Expr(WCDB::Column("ts")).in(statelist)).groupBy(grouplist);
        
        NSLog(@"dul query : %s\n",selectstate.getDescription().c_str());
        
    }
    
}

-(void)querypage
{

    //SELECT * FROM t_msg_list WHERE (sid='101017') ORDER BY ts DESC,_id DESC LIMIT 10 OFFSET 10
    NSString* tablename=@"t_msg_list";
    //select * from t_msg_list where ts < 1503456153000000 order by ts DESC limit 10 offset 0
    WCDB::ColumnResult columns(WCDB::Column::Any);
    
    std::list<const WCDB::ColumnResult> columnResultList;
    columnResultList.push_back(columns);
    
    WCDB::Subquery query(tablename.UTF8String);
    std::list<const Subquery> subqueryList;
    subqueryList.push_back(query);
    
    int stamp=1503456153;
    int pagesize=10;
    int sid=10086;
    
    WCDB::Order order(WCDB::Expr("ts"),OrderTerm::DESC);
    std::list<const WCDB::Order> orderlist;
    orderlist.push_back(order);
    
    WCDB::StatementSelect selectstate;
    selectstate.select(columnResultList).from(subqueryList).where(WCDB::Expr(WCDB::Column("ts"))<stamp&WCDB::Expr(WCDB::Column("sid"))=sid).orderBy(orderlist).limit(WCDB::Expr(pagesize)).offset(WCDB::Expr(0));
    
    NSLog(@"query sql : %s",selectstate.getDescription().c_str());
    
}


-(void)avatarquery
{

    NSString* tablename=@"t_basic_info";
    
    WCDB::ColumnResult columnret("avatar");
    std::list<const WCDB::ColumnResult> columnResultList;
    columnResultList.push_back(columnret);
    
    WCDB::Subquery query(tablename.UTF8String);
    std::list<const Subquery> subqueryList;
    subqueryList.push_back(query);
    
    WCDB::StatementSelect selectstate;
    
    std::list<const WCDB::Expr> exptrlist;
    std::string uidlist("60042302,60031502");
    exptrlist.push_back(WCDB::Expr(uidlist));
    selectstate.select(columnResultList).from(subqueryList).where(WCDB::Expr(WCDB::Column("uid")).in(exptrlist));
    
    NSLog(@"query sql : %s",selectstate.getDescription().c_str());
    
}


-(void)querydb
{
    NSString* tablename=@"mytable";
    
    WCDB::ColumnResult columnresult("name");
    
    std::list<const WCDB::ColumnResult> columnResultList;
    columnResultList.push_back(columnresult);
    
    WCDB::Subquery query(tablename.UTF8String);
    std::list<const Subquery> subqueryList;
    subqueryList.push_back(query);
    
    WCDB::StatementSelect selectstate;
    selectstate.select(columnResultList).from(subqueryList);
    
    NSLog(@"query sql : %s",selectstate.getDescription().c_str());
    
    {
        //add where
        WCDB::ColumnResult columnresult("age");
        
        std::list<const WCDB::ColumnResult> columnResultList;
        columnResultList.push_back(columnresult);
        
        WCDB::Subquery query(tablename.UTF8String);
        std::list<const Subquery> subqueryList;
        subqueryList.push_back(query);
        
        WCDB::StatementSelect selectstate;
        selectstate.select(columnResultList).from(subqueryList)
        .where(WCDB::Expr(WCDB::Column("age"))==103);
        
        NSLog(@"query where sql : %s",selectstate.getDescription().c_str());
    
    }
    
    {
        //add where like
        WCDB::ColumnResult columnresult("age");
        
        std::list<const WCDB::ColumnResult> columnResultList;
        columnResultList.push_back(columnresult);
        
        WCDB::Subquery query(tablename.UTF8String);
        std::list<const Subquery> subqueryList;
        subqueryList.push_back(query);
        
        WCDB::StatementSelect selectstate;
        selectstate.select(columnResultList).from(subqueryList)
        .where(WCDB::Expr(WCDB::Column("age"))=="LIKE %10%");
        
        NSLog(@"query where sql : %s",selectstate.getDescription().c_str());
        
    }
    
    {
        //add where like limit
        WCDB::ColumnResult columnresult("age");
        
        std::list<const WCDB::ColumnResult> columnResultList;
        columnResultList.push_back(columnresult);
        
        WCDB::Subquery query(tablename.UTF8String);
        std::list<const Subquery> subqueryList;
        subqueryList.push_back(query);
        
        WCDB::StatementSelect selectstate;
        selectstate.select(columnResultList).from(subqueryList)
        .where(WCDB::Expr(WCDB::Column("age"))=="LIKE %10%")
        .limit(WCDB::Expr(1),WCDB::Expr(2))
        .offset(WCDB::Expr(5));
        
        NSLog(@"query where sql : %s",selectstate.getDescription().c_str());
        
    }
    
    {
        //add orderby
        WCDB::ColumnResult columnresult("age");
        
        std::list<const WCDB::ColumnResult> columnResultList;
        columnResultList.push_back(columnresult);
        
        WCDB::Subquery query(tablename.UTF8String);
        std::list<const Subquery> subqueryList;
        subqueryList.push_back(query);
        
        WCDB::Order order(WCDB::Expr("age"),OrderTerm::DESC);
        std::list<const WCDB::Order> orderlist;
        orderlist.push_back(order);
        
        WCDB::StatementSelect selectstate;
        selectstate.select(columnResultList).from(subqueryList)
        .orderBy(orderlist);
        
        NSLog(@"query order sql : %s",selectstate.getDescription().c_str());
        
    }
    
    {
        //add groupby
        WCDB::ColumnResult columnresult("name");
        WCDB::ColumnResult columnresult1("age");
        
        std::list<const WCDB::ColumnResult> columnResultList;
        columnResultList.push_back(columnresult);
        columnResultList.push_back(columnresult1);
        
        WCDB::Subquery query(tablename.UTF8String);
        std::list<const Subquery> subqueryList;
        subqueryList.push_back(query);
        
        WCDB::Expr exp("name");
        std::list<const WCDB::Expr> grouplist;
        grouplist.push_back(exp);
        
        WCDB::Order order(WCDB::Expr("name"),OrderTerm::DESC);
        std::list<const WCDB::Order> orderlist;
        orderlist.push_back(order);
        
        WCDB::StatementSelect selectstate;
        selectstate.select(columnResultList).from(subqueryList)
        .groupBy(grouplist)
        .orderBy(orderlist);
        
        NSLog(@"query groupby sql : %s",selectstate.getDescription().c_str());
        
    }
    
    
    
    {
        //add join
        NSString* newtable=@"youtable";
        WCDB::ColumnResult columnresult("name");
        WCDB::ColumnResult columnresult1("age");
        
        std::list<const WCDB::ColumnResult> columnResultList;
        columnResultList.push_back(columnresult);
        columnResultList.push_back(columnresult1);
        
        WCDB::Subquery query(tablename.UTF8String);
        std::list<const Subquery> subqueryList;
        subqueryList.push_back(query);
        
        const WCDB::Subquery joinquery(newtable.UTF8String);
        std::string table=[newtable UTF8String];
        WCDB::JoinClause joinclause(table);
        joinclause.join(joinquery,WCDB::JoinClause::Type::Left,false);
        
        WCDB::StatementSelect selectstate;
        selectstate.select(columnResultList).from(joinclause);
        
        NSLog(@"query joinclause sql : %s",selectstate.getDescription().c_str());
    }
    
    
    
}


-(void)selectdb
{

    NSString* tablename=@"mytable";
    WCDB::ColumnResultList columnResultList;
    WCDB::ColumnResult colresult(Column::Any);
    columnResultList.push_back(colresult);
    
    WCDB::StatementSelect selectstate;
    selectstate.select(columnResultList).from(tablename.UTF8String);
    
    WCDB::Error err;
    WCDB::RecyclableStatement statementHandle = _database->prepare(selectstate, err);
    //get value from selectstate
    
    int step=0;
    while(statementHandle && statementHandle->step()){
    
        //ready to get value
        const char* colname=statementHandle->getColumnName(0);
        const char* colvalue=statementHandle->getValue<ColumnType::Text>(0);
        //NSString* coln=[NSString stringWithUTF8String:colname];
        NSLog(@"0 colume name : %s colume value : %s",colname,colvalue);
        
        colname=statementHandle->getColumnName(1);
        colvalue=statementHandle->getValue<ColumnType::Text>(1);
        //NSString* coln=[NSString stringWithUTF8String:colname];
        NSLog(@"1 colume name : %s colume value : %s",colname,colvalue);

    }
    
}

-(void)updatedb
{

    NSString* tablename=@"mytable";
    
    WCDB::StatementUpdate updatestate;

    UpdateValue updatevalue({"age",655});
    UpdateValueList updatelist;
    updatelist.push_back(updatevalue);
    
    const std::pair<const WCDB::Column,const WCDB::Expr> p1({WCDB::Column("age"),WCDB::Expr(458)});
    std::list<const std::pair<const WCDB::Column, const WCDB::Expr>> valuelist;
    valuelist.push_back(p1);
    
    updatestate.update(tablename.UTF8String)
    .set(valuelist)
    .where(WCDB::Expr(WCDB::Column("age"))==202);
    
    WCDB::Error err;
    WCDB::RecyclableStatement statehandle=_database->prepare(updatestate, err);
    statehandle->step();
    
    NSLog(@"update sql : %s",updatestate.getDescription().c_str());
    
}

-(void)insertdb
{

    NSString* tablename=@"mytable";
    
    WCDB::StatementTransaction transaction;
    transaction.begin();
    
    
    for(int i=0;i<5;i++)
    {
        WCDB::ColumnList collist;
        collist.push_back("name");
        collist.push_back("age");
        
        WCDB::ExprList explist;
        explist.push_back("shenzhen");
        NSString* age=[NSString stringWithFormat:@"%d",200+i];
        explist.push_back([age UTF8String]);
        
        WCDB::StatementInsert insertstate;
        insertstate.insert(tablename.UTF8String, collist).values(explist);
        NSLog(@"sql : %s",insertstate.getDescription().c_str());
        
        WCDB::Error err;
        WCDB::RecyclableStatement statementHandle = _database->prepare(insertstate, err);
        statementHandle->step();
        
        if(!statementHandle->isOK()){
            transaction.rollback();//rollback when come across error
            err=statementHandle->getError();
            return ;
        }else{
            
        }
    }
    
    
    transaction.commit();

//    statementHandle->resetBinding();
//    if (!statementHandle->isOK()) {
//        err = statementHandle->getError();
//        return ;
//    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
