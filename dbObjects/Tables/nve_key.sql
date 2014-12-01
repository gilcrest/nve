CREATE TABLE NVE_KEY 
 (	DATA_ITEM_ID                     NUMBER                             NOT NULL ENABLE, 
    ITEM_VALUE                       RAW(16), 
    CREATE_USER_ID                   VARCHAR2(30 BYTE)  DEFAULT USER    NOT NULL ENABLE, 
    CREATE_DATE                      DATE               DEFAULT SYSDATE NOT NULL ENABLE, 
    UPDATE_USER_ID                   VARCHAR2(30 BYTE)  DEFAULT USER    NOT NULL ENABLE, 
    UPDATE_DATE                      DATE               DEFAULT SYSDATE NOT NULL ENABLE, 
    DEACTV_DATE                      DATE, 
 CONSTRAINT PK_NVE_KEY PRIMARY KEY (DATA_ITEM_ID));
/
alter table NVE_KEY add constraint NVE_KEY_FK1 foreign key (DATA_ITEM_ID) references NVE_DATA_ITEM_LKUP (DATA_ITEM_ID);
/
