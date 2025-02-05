sc-deploy-db
===============

sc-deploy-db is a multi-platform command line tool for deploying scripts to Snowflake. 
For large data warehouses, it makes it easy when you have folders with a lot of source files
and you need a quick solution to deploy them to your Snowflake Warehouse.


Installation
------------

.. code:: bash

    $ pip install snowconvert-deploy-tool --upgrade
    
.. note:: If you run this command on MacOS change `pip` by `pip3`

You might need to install the python connecto for snowflake: pip install "snowflake-connector-python[pandas]"



Usage
-----

For information about the different parameters or options just run it using the  `-h` option:

.. code:: bash

    $ sc-deploy-db -h

.. code:: bash

    usage: sc-deploy-db [-h] [-A ACCOUNT] [-D DATABASE] [-WH WAREHOUSE] [-R ROLE] [-U USER] [-P PASSWORD] [-W WORKSPACE] -I INPATH
                    [--activeConn ACTIVECONN] [--authenticator AUTHENTICATOR] [-L LOGPATH] [--SplitBefore SPLITBEFORE] [--SplitAfter SPLITAFTER]
                    [--ObjectType [OBJECTTYPE]]
    SnowConvertStudio Deployment Script
    ===================================
    This script helps you to deploy a collection of .sql files to a Snowflake Account.
    The tool will look for settings like:
    - Snowflake Account
    - Snowflake Warehouse
    - Snowflake Role
    - Snowflake Database
    If the tool can find a config_snowsql.ini file in the current directory or in the workspace\config_snowsql.ini location
    it will read those parameters from there.
    optional arguments:
    -h, --help            show this help message and exit
    -A ACCOUNT, --Account ACCOUNT
                          Snowflake Account
    -D DATABASE, --Database DATABASE
                          Snowflake Database
    -S SCHEMA, --Schema SCHEMA
                          Snowflake Initial Schema                          
    -WH WAREHOUSE, --Warehouse WAREHOUSE
                          Snowflake Warehouse
    -R ROLE, --Role ROLE  Snowflake Role
    -U USER, --User USER  Snowflake User
    -P PASSWORD, --Password PASSWORD
                          Password
    -W WORKSPACE, --Workspace WORKSPACE
                          Path for workspace root. Defaults to current dir
    -I INPATH, --InPath INPATH
                          Path for SQL scripts
    --activeConn ACTIVECONN
                          When given, it will be used to select connection parameters forn config_snowsql.ini
    --authenticator AUTHENTICATOR
                          Use the authenticator with you want to use a different authentication mechanism
    -L LOGPATH, --LogPath LOGPATH
                          Path for process logs. Defaults to current dir
    --SplitBefore SPLITBEFORE
                          Regular expression that can be used to split code in fragments starting **BEFORE** the matching expression
    --SplitAfter SPLITAFTER
                          Regular expression that can be used to split code in fragments starting **AFTER** the matching expression
    --ObjectType [OBJECTTYPE]
                          Object Type to deploy table,view,procedure,function,macro

This tool assumes :

- that you have a collection of `.sql` files under a directory. It will then execute all those `.sql` files connecting to the specified database.
- that each file contains **only** one statement.

The tool can also read its values from environment variables. The following environment variables are recognized by this tool:

.. list-table:: Environmental Variables
   :widths: 25 50
   :header-rows: 1

   * - Variable Name
     - Description
   * - SNOW_USER
     - The username that will be used for the connection
   * - SNOW_PASSWORD
     - The password that will be used for the connection
   * - SNOW_ROLE
     - The snowflake role that will used for the connection
   * - SNOW_ACCOUNT
     - The snowflake accountname that will used for the connection
   * - SNOW_WAREHOUSE
     - The warehouse to use when running the sql
   * - SNOW_DATABASE
     - The database to use when running the sql


.. note::  If your files contains several statements you can use the SplitPattern argument, as explained below, so the tool will try to split the statements prior to execution.

Examples
--------

If you have a folder structure like:

::

    + code
       + procs
         proc1.sql
       + tables
         table1.sql
         + folder1
             table2.sql

You can deploy then by running:

:: 

    sc-deploy-db -A my_sf_account -WH my_wh -U user -P password -I code

If you want to use another authentication like Azure AD you can do:

::

    sc-deploy-db -A my_sf_account -WH my_wh -U user -I code --authenticator externalbrowser


A recommended approach is that you setup a bash shell script, for example `config.sh` with contents like:

::

    export SNOW_ACCOUNT="migration.us-east-1"
    export SNOW_WAREHOUSE="TIAA_WH"
    export SNOW_ROLE="TIAA_FULL_ROLE"
    export SNOW_DATABASE="TIAA"
    echo "Reading User and Password. When you type values wont be displayed"
    read -s -p "User: "     SNOW_USER
    echo ""
    read -s -p "Password: " SNOW_PASSWORD
    echo ""
    export SNOW_USER
    export SNOW_PASSWORD

You can then run the script like: `source config.sh`. After that you can just run `sc-deploy-db -I folder-to-deploy`


Files with multiple statements
------------------------------

If your files have multiple statements, it will cause some failures are the snowflake Python API does not allow multiple statements on a single call.
In order to handle that, you give a tool a this pattern is a regular expression that can be used to split the file contents before
sending them to the database. This pattern could be used to split before the pattern: `--SplitBefore` or to split after the pattern `--SplitAfter`.

Let's see some example. 

If you have a file with contents like:

::

    CREATE OR REPLACE SEQUENCE SEQ1
    START WITH 1
    INCREMENT BY 1;

    /* <sc-table> TABLE1 </sc-table> */
    CREATE TABLE TABLE1 (
        COL1 VARCHAR
    );

You can use an argument like `--SplitAfter ';'` that will create a fragment from the file anytime a `;` is found.

If you have a file with statements like:

::
    
    CREATE TABLE OR REPLACE TABLE1 (
        COL1 VARCHAR
    );

    /* <sc-table> TABLE2 </sc-table> */
    CREATE TABLE TABLE2 (
        COL1 VARCHAR
    );

You can use an argument like `--SplitBefore 'CREATE (OR REPLACE)?'`. That will create a fragment each time a `CREATE` or `CREATE OR REPLACE` fragment is found;

Reporting issues and feedback
-----------------------------

If you encounter any bugs with the tool please file an issue in the
`Issues`_ section of our GitHub repo.


License
-------

sc-deploy-db is licensed under the `MIT license`_.


.. _Issues: https://github.com/MobilizeNet/SnowConvert_Support_Library/issues
.. _MIT license: https://github.com/MobilizeNet/SnowConvert_Support_Library/tools/snowconvert-deploy/LICENSE.txt
