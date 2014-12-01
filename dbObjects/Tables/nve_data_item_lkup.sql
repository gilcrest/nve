CREATE TABLE NVE_DATA_ITEM_LKUP 
 (	DATA_ITEM_ID                     NUMBER                             NOT NULL ENABLE, 
    DATA_ITEM_NAME                   VARCHAR2(60 BYTE)                  NOT NULL ENABLE, 
    USAGE_DESC                       VARCHAR2(1000 CHAR), 
    DATA_ITEM_GROUP_NAME             VARCHAR2(60 BYTE), 
    DEACTV_DATE                      DATE, 
    CREATE_USER_ID                   VARCHAR2(30 BYTE)  DEFAULT USER    NOT NULL ENABLE, 
    CREATE_DATE                      DATE               DEFAULT SYSDATE NOT NULL ENABLE, 
    UPDATE_USER_ID                   VARCHAR2(30 BYTE)  DEFAULT USER    NOT NULL ENABLE, 
    UPDATE_DATE                      DATE               DEFAULT SYSDATE NOT NULL ENABLE, 
 CONSTRAINT PK_NVE_DATA_ITEM_LKUP PRIMARY KEY (DATA_ITEM_ID));
/