Welcome to nve! (Name:Value Encryption)
========================
A PL/SQL framework to easily store and retrieve Name:Value pair Encrypted (NVE) data.  The goal of this project is to be able to easily persist sensitive information using the strongest encryption methods available.  This project uses Oracle's dbms_crypto package to do the actual encryption using the 256-bit AES algorithm with Cipher Block Chaining and PKCS#5 compliant padding.

In it's simplest form, you are able to encrypt data with only the following code:

### Simple encryption procedure call
```
begin
  nve.encrypt ('applicationPassword','superSecretPassword!');
end;
```

The data will be persisted in 3 tables: a lookup for the **Name**, a table to store 1/2 of the unique encryption key (aka the "salt") for each Name:Value pair and finally a table to store the encrypted **Value** data.

Retrieving the data is also very easy, take the following code as an example:

### Simple decryption function call
```sql
set serveroutput on 
declare
  v_password             varchar2(1000);
begin
  v_password := nve.decrypt ('applicationPassword');
  dbms_output.put_line('My Password is '||v_password);
end;
```
You may also add some metadata information to help identify the record on the lookup table (optional), with the following code example:

### Extended Encryption procedure call with metadata 
```sql
begin
  nve.encrypt (p_name => 'appPassword',
               p_value => 'superSecretPassword!',
               p_grouping_name => 'TEST GROUP',
               p_usage_desc => 'This is the password for some external app that I need to call via pl/sql, but do not want to the password to be shown in cleartext as part of the query string that I am forming in the code'
               );
end;
```
Database Objects
---------------------
The following database objects must be installed as part of this package:

**Package(s)**

| Name | Description          |
| ------------- | ----------- |
|NVE|Package that does all the actual encryption and storing/pulling of data.|

**Table(s)**

| Name | Description          |
| ------------- | ----------- |
|NVE_DATA_ITEM_LKUP|Stores the **Name**  as well as any optional metadata that you decide to give as input.  A sequence driven primary key is given to each record which is referenced by foreign keys in the other two tables.|
|NVE_DATA|Stores encrypted **Value** data|
|NVE_KEY|Stores 16 bytes of the 32 byte key used to encrypt the **Value** data|

**Index(es)**

| Name | Description          |
| ------------- | ----------- |
|UI1_NVE_DATA_ITEM_LKUP|Index on **Name** data on NVE_DATA_ITEM_LKUP table|
|PK_NVE_DATA|Primary Key for NVE_DATA table|
|PK_NVE_DATA_ITEM_LKUP|Primary Key for NVE_DATA_ITEM_LKUP table|
|PK_NVE_KEY|Primary Key for NVE_KEY table|

**Sequence(s)**

| Name | Description          |
| ------------- | ----------- |
|NVE_DATA_ITEM_SEQ|Used to produce primary key for NVE_DATA_ITEM_LKUP table|


