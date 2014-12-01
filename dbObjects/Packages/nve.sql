create or replace PACKAGE nve
as 

  --  Ver#    ---Date---   --- Done-By ---  ----- What-Was-Done ----- ---- --- -- - -  -   -    -     -
  --  1.00    26 Nov 2014  Dan Gillis       New object
  --
  --  Purpose:
  --  1.  Package for Name Value pair encryption (nve) of individual data items using name:value db framework
  --

  procedure encrypt (p_name                           IN varchar2,
                     p_value                          IN varchar2,
                     p_grouping_name                  IN varchar2 default null,
                     p_usage_desc                     IN varchar2 default null);

  function  decrypt (p_name                           IN varchar2)
    return varchar2;

END nve;
/
create or replace PACKAGE BODY nve AS

  --  Ver#    ---Date---   --- Done-By ---  ----- What-Was-Done ----- ---- --- -- - -  -   -    -     -
  --  1.00    26 Nov 2014  Dan Gillis       New object
  --
  --  Purpose:
  --  1.  Package for Name Value pair encryption (nve) of individual data items using name:value db framework
  --

  /* Global Variables */
  -- ---------------------------------------------------------------------------------------------
  -- You need to change the gv_salt_string global variable below, but it must be exactly 16 bytes
  --  in length.  The concatenation of this 16 byte string (converted to raw) and the 16 bytes that
  --  are persisted in the database in steps below are what makeup the full unique 32 byte salt key
  -- ---------------------------------------------------------------------------------------------
  gv_salt_string                   varchar2(16) := '012X45548TK42717';
  -- ---------------------------------------------------------------------------------------------
  -- Destination Character Set
  -- ---------------------------------------------------------------------------------------------
  gv_character_set                 varchar2(10) := 'AL32UTF8'; 
  -- ---------------------------------------------------------------------------------------------
  -- use utl_i18n string_to_raw function to convert gv_salt_string global variable to RAW datatype
  --  using AL32UTF8 character set
  -- ---------------------------------------------------------------------------------------------
  gv_key                           RAW(16) := utl_i18n.string_to_raw( data => gv_salt_string, dst_charset => gv_character_set );
  -- ---------------------------------------------------------------------------------------------
  -- 256-bit AES algorithm with Cipher Block Chaining and PKCS#5 compliant padding
  -- ---------------------------------------------------------------------------------------------
  gv_encryption_type               pls_integer := (dbms_crypto.encrypt_aes256 + dbms_crypto.chain_cbc + dbms_crypto.pad_pkcs5);

  procedure ins_nve_data_item_lkup (p_data_item_id                IN number,
                                    p_data_item_name              IN varchar2,
                                    p_data_item_group_name        IN varchar2,
                                    p_usage_desc                  IN varchar2) AS
  begin
    insert into nve_data_item_lkup (data_item_id, data_item_name, usage_desc, data_item_group_name, deactv_date,
                                    create_user_id, create_date, update_user_id, update_date)
     values (p_data_item_id, p_data_item_name, p_usage_desc, p_data_item_group_name, null, USER, sysdate, USER, sysdate);
  end ins_nve_data_item_lkup;

  procedure ins_nve_key (p_data_item_id                IN number,
                         p_item_value                  IN RAW) AS
  begin
    insert into nve_key (data_item_id, item_value, create_user_id, create_date, update_user_id, update_date)
     values (p_data_item_id, p_item_value, USER, sysdate, USER, sysdate);
  end ins_nve_key;
  
  procedure ins_nve_data (p_data_item_id                IN number,
                          p_item_value                  IN RAW) AS
  begin
    insert into nve_data (data_item_id, item_value, create_user_id, create_date, update_user_id, update_date)
     values (p_data_item_id, p_item_value, USER, sysdate, USER, sysdate);
  end ins_nve_data;

  function get_encrypted_data (p_data_to_encrypt                IN varchar2,
                               p_full_key                       IN RAW) 
    return RAW AS
    
    /* Variables */
    v_data_to_encrypt                RAW (2000) := utl_i18n.string_to_raw( data => p_data_to_encrypt, dst_charset => gv_character_set );
    v_encrypted_raw                  RAW (2000);
    
    /* Exceptions */
    e_key_length                     exception;

  begin
    if (utl_raw.length(p_full_key) != 32) then
      raise e_key_length;
    end if;
    v_encrypted_raw := dbms_crypto.encrypt (src => v_data_to_encrypt,
                                            typ => gv_encryption_type,
                                            key => p_full_key);

    return v_encrypted_raw;
    
  exception
    when e_key_length then
      raise_application_error(-20708,'Key length must be exactly 32 bytes in length for AES 256-bit encryption');

  end get_encrypted_data;

  procedure store_encrypted_data (p_data_item_name              IN varchar2,
                                  p_data_item_group_name        IN varchar2,
                                  p_usage_desc                  IN varchar2,
                                  p_data_to_encrypt             IN varchar2) AS
    /* Local Variables */
    v_data_item_id                   nve_data_item_lkup.data_item_id%type;
    -- ------------------------------------------------------------------------------------------
    -- AES 256-bit encryption requires a 256 bit (32 byte) key, we get 16 bytes from the salt in
    --  the package body global variable and 16 bytes from the randombytes method
    -- ------------------------------------------------------------------------------------------
    v_random_key_bytes_length        NUMBER := 256/16;       -- key length 256 bits (16 bytes)
    v_key_bytes_raw                  RAW (16);               -- stores 256-bit encryption key
    v_full_key                       RAW (32);
    v_encrypted_data                 RAW (2000);

  begin
    -- -------------------------------------------------------------------------------------------
    -- Get Next Data Item ID from sequence
    -- -------------------------------------------------------------------------------------------
    v_data_item_id := nve_data_item_seq.nextval;

    -- -------------------------------------------------------------------------------------------
    -- Get randombytes for key table
    -- -------------------------------------------------------------------------------------------
    v_key_bytes_raw := DBMS_CRYPTO.RANDOMBYTES (number_bytes => v_random_key_bytes_length);

    -- -------------------------------------------------------------------------------------------
    -- Create nve Data Item Lookup record
    -- -------------------------------------------------------------------------------------------
    ins_nve_data_item_lkup (p_data_item_id => v_data_item_id,
                            p_data_item_name => p_data_item_name,
                            p_data_item_group_name => p_data_item_group_name,
                            p_usage_desc => p_usage_desc);

    -- -------------------------------------------------------------------------------------------
    -- Create nve Key record
    -- -------------------------------------------------------------------------------------------
    ins_nve_key (p_data_item_id => v_data_item_id,
                 p_item_value => v_key_bytes_raw);


    -- ----------------------------------------------------------------------------------------------
    -- Concatenate salt from randombytes with salt in package global variable to create the full salt
    --  assuming you wrap the package, this should secure your salt and allow for a unique salt
    --  per data item...
    -- ----------------------------------------------------------------------------------------------
    v_full_key := utl_raw.concat(r1 => v_key_bytes_raw,
                                 r2 => gv_key);

    -- ----------------------------------------------------------------------------------------------
    -- Call to get_encrypted_data function to encrypt data using the full salt
    -- ----------------------------------------------------------------------------------------------
    v_encrypted_data := get_encrypted_data (p_data_to_encrypt => p_data_to_encrypt,
                                            p_full_key => v_full_key);

    -- ----------------------------------------------------------------------------------------------
    -- Create nve Data record
    -- ----------------------------------------------------------------------------------------------
    ins_nve_data (p_data_item_id => v_data_item_id,
                  p_item_value => v_encrypted_data);

  end store_encrypted_data;

  function get_data_item_id (p_data_item_name               IN varchar2)
    return number AS
    
    /* Variables */
    v_data_item_id                   number;
  begin
    select data_item_id
      into v_data_item_id
      from nve_data_item_lkup
     where data_item_name = p_data_item_name;
     
    return v_data_item_id;

  exception
    when no_data_found then
      raise_application_error ('-20709','There is no matching nve data item record for the Data Item Name you have entered');

  end get_data_item_id;

  function get_nve_key (p_data_item_id                    IN number)
    return RAW as
    
    /* Variables */
    v_nve_key                        RAW(16);

  begin
    select item_value
      into v_nve_key
      from nve_key
     where data_item_id = p_data_item_id;
     
    return v_nve_key;

  end get_nve_key;

  function get_nve_data (p_data_item_id                    IN number)
    return RAW as
    
    /* Variables */
    v_nve_data                        RAW(2000);

  begin
    select item_value
      into v_nve_data
      from nve_data
     where data_item_id = p_data_item_id;
     
    return v_nve_data;

  end get_nve_data;

  procedure encrypt (p_name                           IN varchar2,
                     p_value                          IN varchar2,
                     p_grouping_name                  IN varchar2,
                     p_usage_desc                     IN varchar2) AS
  BEGIN
    store_encrypted_data(p_data_item_name => p_name,
                         p_data_item_group_name => p_grouping_name,
                         p_usage_desc => p_usage_desc,
                         p_data_to_encrypt => p_value);
  END encrypt;

  function decrypt (p_name                           IN varchar2)
    return varchar2 AS
  
    /* Variables */
    v_decrypted_raw                  RAW(32);
    v_decrypted_string               varchar2(32);
    v_data_item_id                   number;
    v_nve_key                        RAW(16);
    v_full_key                       RAW(32);
    v_encrypted_data                 RAW(2000);

  BEGIN
    -- -------------------------------------------------------------------------------------------
    -- Get Data Item ID from NVE Data Item Lookup Table
    -- -------------------------------------------------------------------------------------------
    v_data_item_id := get_data_item_id (p_data_item_name => p_name);
    
    -- -------------------------------------------------------------------------------------------
    -- Get 
    -- -------------------------------------------------------------------------------------------
    v_nve_key := get_nve_key (p_data_item_id => v_data_item_id);
    
    v_full_key := utl_raw.concat (r1 => v_nve_key,
                                  r2 => gv_key);

    v_encrypted_data := get_nve_data (p_data_item_id => v_data_item_id);

    v_decrypted_raw := dbms_crypto.decrypt (src => v_encrypted_data,
                                            typ => gv_encryption_type,
                                            key => v_full_key );

    v_decrypted_string := utl_i18n.raw_to_char (data => v_decrypted_raw,
                                                src_charset => gv_character_set);

    RETURN v_decrypted_string;

  END decrypt;

END nve;
/
