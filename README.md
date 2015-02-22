Welcome to nve! (Name:Value Encryption)
========================
A utility to easily store and retrieve Name:Value pair Encrypted (NVE) data using Oracle PL/SQL.  The goal of this project is to be able to easily persist sensitive information using the strongest encryption methods available.  This project uses Oracle's dbms_crypto package to do the actual encryption using the 256-bit AES algorithm with Cipher Block Chaining and PKCS#5 compliant padding.

In it's simplest form, you are able to encrypt data with only the following code:

### Simple encryption procedure call
```
begin
  nve.encrypt ('anyStringName','anyStringValue');
end;
```

The data will be persisted in 3 tables: a lookup for the **Name**, a table to store 1/2 of the unique encryption key (aka the "salt") for each Name:Value pair and finally a table to store the encrypted **Value** data.

Retrieving the data is also very easy, take the following code as an example:

### Simple decryption function call
```sql
set serveroutput on 
declare
  v_decrypted_string             varchar2(1000);
begin
  v_decrypted_string := nve.decrypt ('anyStringName');
  dbms_output.put_line('My decrypted string value is '||v_decrypted_string);
end;
```
You may also add some metadata information to help identify the record on the lookup table (optional), with the following code example:

### Extended Encryption procedure call with metadata 
```sql
begin
  nve.encrypt (p_name => 'anyStringName',
               p_value => 'anyStringValue',
               p_grouping_name => 'TEST GROUP',
               p_usage_desc => 'This is where you would put a longer description of what is being encrypted, etc.'
               );
end;
```
### Encryption Key
The key used in the dbms_crypto.encrypt for AES256 must be exactly 32 bytes.  The key is broken into two 16 byte parts:
  * one 16 byte piece is written to the NVE_KEY table and the value is determined using `dbms_crypto.randombytes`.  This portion of the key is unique for every name:value pair record that is created
  * one 16 byte piece is taken from global variable `gv_salt_string` in the package body.  
> Every implementation of this package should change the value in the **gv_salt_string** global variable with your own unique 16 byte string.  You should also "wrap" this package after you have completed this change in order to obfuscate the key.

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


