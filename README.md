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
```
set serveroutput on 
declare
  v_password             varchar2(1000);
begin
  v_password := nve.decrypt ('applicationPassword');
  dbms_output.put_line('My Password is '||v_password);
end;
```
You may also add some metadata information to the information you are encrypting if you so choose, with the following code example:

### Extended Encryption procedure call with metadata 
```
begin
  nve.encrypt (p_name => 'appPassword',
               p_value => 'superSecretPassword!',
               p_grouping_name => 'TEST GROUP',
               p_usage_desc => 'This is the password for some external app that I need to call via pl/sql, but do not want to the password to be shown in cleartext as part of the query string that I am forming in the code'
               );
end;
```
