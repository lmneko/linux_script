### MySQL常用命令

| 命令                                                         | 功能                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| show databases;                                              | 查看所有的数据库；                                           |
| create database bbs;                                         | 创建名为bbs的数据库；                                        |
| use bbs;                                                     | 进入bbs数据库；                                              |
| show tables;                                                 | 查看数据库里有多少张表；                                     |
| create tables t0001 (id varchar(20), name varchar(20),age varchar(10),job varchar(20)); | 创建名为t0001的表，并创建四个字段，id,name,age,job varchar表示设置数据长度，用字符来定义长度单位，其中1个汉字=2字符=2Bytes； |
| insert into t0001 values("001","xiaowang","24","it");        | 向表中插入数据；                                             |
| select * fro t0001;                                          | 查看t0001表数据内容；                                        |
| select * form t0001 where id=1 and age='24';                 | id,age多条件查询                                             |
| alter table t0001 modify column name varchar(40);               | 修改name字段的长度；                                         |
| update t0001 set name='xiaoming' where id=1;			| 修改name字段内容 |
| flush privileges;               | 刷新权限；|
| delete from t0001;  | 清空表内容； |
| drop tables t0001; | 删除表；|
| drop database bbs; | 删除bbs数据库； |
| show variables like '%char%'; | 查看数据库字符集； |
| show engines; | 查看MySQL存储引擎； |
| show variables like '%storage_engine%'; | 查看MySQL默认的存储引擎； |


