

#!/bin/bash

# //////////////////////////////////////////////////////////////////

# ------------------------ FIRST MENU --------------------------------

# //////////////////////////////////////////////////////////////////

# --------------------- starting menu -------------------- 
function startMenu {

    echo "Choose an option"

    select menu in 'Create DB' 'List all Databases' 'Connect to DB' 'Drop DB' 'Exit'
    

    do

    case $menu in
    'Create DB')
		createDB
    ;;

    'List all Databases')
        listDB
    ;;

    'Connect to DB')
        echo "These are the current databases"
        listDB
        echo "Which database would you like to connect to?:\n"
        read dbName
        connectToDB $dbName 
    
    ;;
    'Drop DB')
        echo "These are the current databases. Which database would you like to drop?"
        listDB
        read dbName
        dropDB $dbName
        echo "Now the current databases are $(listDB)"
    ;;
    'Exit')
        echo "Exiting. Bye!"
            exit
    ;;
    *)
        echo "Invalid option"
        startMenu
    ;;
    esac

done #tb3 el select .. in  "DO" 
}

# startMenu 

# ---------------------------------- CREATE DATABASE --------------------------------   


function createDB() {
    echo "Enter the name of the database"
    read dbName
    if [ ! -d ./Databases/$dbName ]; then
        mkdir -p "./Databases/$dbName"
        echo "Database $dbName created"
    else
        echo "Database $dbName already exists"
    fi
}

# ---------------------------------- LIST DATABASES --------------------------------    

function listDB() {
    ls "./Databases"
}

# ---------------------------------- CONNECT TO DATABASE --------------------------------    

function connectToDB() {
    # echo "Enter the name of the database"
    # read dbName
    if [ ! -d "./Databases/$dbName" ]; then
    echo "Database $dbName does not exist"
    else
    echo "Connecting to database $dbName"
    fi
}

# ---------------------------------- DROP DATABASE --------------------------------    

function dropDB() {
    # echo "Enter the name of the database"
    # read dbName
    if [ ! -d "./Databases/$dbName" ]; then
    echo "Database $dbName does not exist"
    else
    echo "Dropping database $dbName"
    fi
    rm -rf "./Databases/$dbName"
    echo "Database $dbName dropped"
    listDB
}

startMenu # We call The Funtion AT THE END 
# ---------------------------------- EXIT --------------------------------

# function exit() {
#     echo "Exiting. Bye!"
#     exit
# }

# --------------------------------    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ----------------------------------`---------------- --------------------------------


       

# //////////////////////////////////////////////////////////////////

# ------------------------ SECOND MENU TABLES --------------------------------

# //////////////////////////////////////////////////////////////////

function tablesMenu {


echo "Choose an option : "

select $table in 'Create Table' 'Insert Into Table' 'List all Tables' 'Update Table' 'Select From Table' 'Delete From Table' 'Drop Table' 'Main Menu' 'Exit'

case $table in
'Create Table')
    createTable
;;

'Insert Into Table')
    insertIntoTable
;;

'List all Tables')
    listTables
;;

'Update Table')
    updateTable
;;


'Select From Table')
    selectFromTable
;;

'Delete From Table')
    deleteFromTable
;;

'Drop Table')
    dropTable
;;

'Main Menu')
    # cd ../..
    startMenu
;;

'Exit')

    echo "Exiting. Bye!"
    exit
;;

*)
    echo "Invalid option"
    tablesMenu
;;
esac

}

# ////

function createTable() {
    echo "Enter the name of the table"
    read tableName

    if [ -f ${tableName} ]; then
    echo "Table $tableName already exists"
    # cd ../.. 
     connectToDB

    else

    touch ./Databases/$dbName/$tableName
    echo "Table $tableName created"
   
   fi 

   echo "Enter number of columns / fields to create"
   read numberOfCols
    number='^[0-9]+$'
    if [ numberOfCols =~ numberOfCols]
    then

   for i in ($numberOfCols)
   do

# name of column & PK
       echo "Enter the name of the column"
       read colName
       echo "Is this a PK? [Y/n] ? "
       read pk
       if [ $pk == "Y" || $pk == "y" || $pk == "yes" || $pk == "YES" ]; then
    #   ##### here ................... 
       echo -n $pk >> $tableName

        else
        break
        fi


# Data type of column
        echo "Choose the data type of the column from the following options :
        1. Integer
        2. Text
        3. Date"

        read colType
# ............................
        echo -n $colName"$colType;" >> $tableName



    # echo "Enter the default value of the column"
    # read colDefault
    # echo "Enter the constraint of the column"
    # read colConstraint

}



CREATE TABLE STUDENT {


ID INT PRIMARY KEY,
NAME VARCHAR(255),
AGE INT,

} 


# ////

# function insertIntoTable() {
#     echo "Enter the name of the table"
#     read tableName
#     if [ ! ./Databases/$dbName/$tableName ]; then


