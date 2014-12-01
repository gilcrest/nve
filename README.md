Welcome to nve! (Name:Value Encryption)
========================
A PL/SQL framework to easily store and retrieve Name:Value pair Encrypted (NVE) data.  The goal of this project is to be able to easily persist sensitive information using the strongest encryption methods available.  This project uses Oracle's dbms_crypto package to do the actual encryption using the 256-bit AES algorithm with Cipher Block Chaining and PKCS#5 compliant padding.

In it's simplest form, you are able to encrypt data with only the following code:

### Simple encrypt call
```
begin
  nve.encrypt ('applicationPassword','superSecretPassword!');
end;
```

The data will be persisted in 3 tables: a lookup for the **Name**, a table to store 1/2 of the unique encryption key (aka the "salt") for each Name:Value pair and finally a table to store the encrypted **Value** data.

Retrieving the data is also very easy, take the following code as an example:

```
set serveroutput on 
declare
  v_password             varchar2(1000);
begin
  v_password := nve.decrypt ('applicationPassword');
  dbms_output.put_line('My Password is '||v_password);
end;
```
