CREATE TABLE NVE_DATA 
 (	DATA_ITEM_ID                     NUMBER                             NOT NULL ENABLE, 
    ITEM_VALUE                       RAW(2000), 
    CREATE_USER_ID                   VARCHAR2(30 BYTE)  DEFAULT USER    NOT NULL ENABLE, 
    CREATE_DATE                      DATE DEFAULT       SYSDATE         NOT NULL ENABLE, 
    UPDATE_USER_ID                   VARCHAR2(30 BYTE)  DEFAULT USER    NOT NULL ENABLE, 
    UPDATE_DATE                      DATE               DEFAULT SYSDATE NOT NULL ENABLE, 
    DEACTV_DATE                      DATE, 
 CONSTRAINT PK_NVE_DATA PRIMARY KEY (DATA_ITEM_ID));
/
alter table NVE_DATA add constraint NVE_DATA_FK1 foreign key (DATA_ITEM_ID) references NVE_DATA_ITEM_LKUP (DATA_ITEM_ID);
/