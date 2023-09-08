#!/bin/bash

# ------------------------ FIRST MENU --------------------------------

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
                echo "Which database would you like to connect to?:"
                read dbName
                connectToDB "$dbName"
            ;;

            'Drop DB')
                echo "These are the current databases. Which database would you like to drop?"
                listDB
                read dbName
                dropDB "$dbName"
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
    done
}

# ---------------------------------- CREATE DATABASE --------------------------------

function createDB() {
    echo "Enter the name of the database"
    read dbName
    if [ ! -d "./Databases/$dbName" ]; then
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
    if [ ! -d "./Databases/$1" ]; then
        echo "Database $1 does not exist. Do you want to create it? [Y/n]"
        read answer
        if [ "$answer" == "Y" ] || [ "$answer" == "y" ] || [ "$answer" == "yes" ] || [ "$answer" == "YES" ]; then
            createDB
        else 
            connectToDB
        fi
    else
        echo "Connecting to database $1"
        dbName="$1"
        tablesMenu
    fi
}

# ---------------------------------- DROP DATABASE --------------------------------

function dropDB() {
    if [ ! -d "./Databases/$1" ]; then
        echo "Database $1 does not exist"
    else
        echo "Dropping database $1"
        rm -rf "./Databases/$1"
        echo "Database $1 dropped"
        listDB
    fi
}

# ---------------------------------- SECOND MENU TABLES --------------------------------

function tablesMenu {
    echo "Choose an option:"
    select table in 'Create Table' 'Insert Into Table' 'List All Tables' 'Update Table' 'Select From Table' 'Delete From Table' 'Drop Table' 'Main Menu' 'Exit'
    do
        case $table in
            'Create Table')
                createTable
            ;;

            'Insert Into Table')
                insertIntoTable
            ;;

            'List All Tables')
                listAllTables
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
    done
}

# ---------------------------------- CREATE TABLE --------------------------------

function createTable() {
    echo "Enter the name of the table"
    read tableName

    if [ -f "$tableName" ]; then
        echo "Table $tableName already exists"
        connectToDB "$dbName"
    else
        touch "./Databases/$dbName/$tableName"
        echo "Table $tableName created"
    fi

    primary_key_set=false  # Flag to track if a primary key is set
    echo "Enter number of columns / fields to create"
    read numberOfCols

    if [[ $numberOfCols =~ ^[0-9]+$ ]]; then
        for ((i = 1; i <= numberOfCols; i++)); do
            echo "Enter the name of column $i"
            read colName

            # Ask the primary key question only for the first column
            if [ "$primary_key_set" = false ]; then
                echo "Is this column a primary key? [Y/n] ? "
                read pk
                if [[ $pk == "Y" || $pk == "y" || $pk == "yes" || $pk == "YES" ]]; then
                    isPrimaryKey="PK"
                    primary_key_set=true
                else
                    isPrimaryKey=""
                fi
            else
                isPrimaryKey=""
            fi
            # Apply the primary key status to the column
            echo -n "$colName $isPrimaryKey " >> "$tableName"

            while true; do
                echo "Choose the data type of column $colName from the following options:"
                echo "1. Integer"
                echo "2. Text"
                echo "3. Date"
                read dataType
                if [[ $dataType == "1" || $dataType == "Integer" ]]; then
                    echo -n " Integer, " >> "$tableName"
                    break
                elif [[ $dataType == "2" || $dataType == "Text" ]]; then
                    echo -n " Text, " >> "$tableName"
                    break
                elif [[ $dataType == "3" || $dataType == "Date" ]]; then
                    echo -n " Date, " >> "$tableName"
                    break
                else
                    echo "Invalid option"
                fi
            done
        done
      # Pass $colName to insertIntoTable
        insertIntoTable " $colName " " $tableName "
    else
        echo "Invalid input. Please enter a valid number of columns."
    fi
}
# -------------------- List All Tables --------------------

function listAllTables() {
    echo "Your current tables are:"
    ls "./Databases/$dbName/"
}

# -------------------- Insert Into Table --------------------
# # -------------------- Insert Into Table --------------------

# function insertIntoTable() {
#     echo "Enter the name of the table you want to insert data into: "
#     read tableName

#     if [ ! -f "./Databases/$dbName/$tableName" ]; then
#         echo "Table $tableName does not exist. Do you want to create it? [Y/n] "
#         read answer
#         if [ "$answer" == "Y" ] || [ "$answer" == "y" ] || [ "$answer" == "yes" ] || [ "$answer" == "YES" ]; then
#             createTable
#         else 
#             startMenu
#         fi
#     elif [ -f "./Databases/$dbName/$tableName" ]; then
#         echo "Enter data for the following columns (comma-separated):"
#         read inputData

#         # Append the input data to the table
#         echo "$inputData" >> "./Databases/$dbName/$tableName"
#         echo "Data inserted into $tableName."
#     fi
# }
# ------------------------------
function insertIntoTable() {
    local colName="$i"  # Get the column names from the argument
    local tableName="$2"  # Get the table name from the argument

#  local y=$(awk 'BEGIN{FS=";"} {if (NR==1) {for(i=1;i<=NF;i++){printf "--|--"$i}}}' "$tableName")
#     echo "Enter data for the following columns $y comma-separated):"
    echo "Enter data for the following columns ($colName[$i]  ) with commas separating them : "
    read inputData

    IFS=',' read -ra values <<< "$inputData"

    if [ ${#values[@]} -eq ${#colName[@]} ]; then
        for ((i = 0; i < ${#values[@]}; i++)); do
            echo -n "${values[i]}," >> "./Databases/$dbName/$tableName"
        done
        echo "" >> "./Databases/$dbName/$tableName"
        echo "Data inserted into $tableName."
    else
        echo "Invalid input. Please provide data for all columns."
    fi
}


# ----------------------------------------------------------------


#-------------------------------------DROP-DELETE-UPDATE----------------------

#-------------------------Drop Table------------------
function dropTable {
    # List available tables
    listAllTables

    # Prompt the user for the table name to delete
    echo "Please enter the table name you want to delete: "
    read tableName

    if [[ -f $tableName ]]; then
        # Ask for confirmation before deleting the table
        echo "Are you sure you want to delete this table? [y/n]"
        read confirm

        if [[ $confirm == "Y" || $confirm == "y" || $confirm == "yes" ]]; then
            # Delete the table file
            rm $tableName
            echo "$tableName has been successfully deleted."
            # Continue with other menu operations
            tablesMenu
        else
            echo "Deletion of the table is canceled."

            tablesMenu
        fi
    
    
    else
        echo "The table you entered does not exist."

        tablesMenu
    
    fi
}

#-------------------------Delete Rows------------------
function deleteFromTable {
    
    echo "Would you please enter the table name you want to delete from: "
    read tableName

    if [[ -f $tableName ]]
    then
        # Display the table header
        echo "Here is a display of the columns in the table you chose: "

        awk 'BEGIN{FS";"}{if (NR==1){for(i=1 ; i<=NF ; i++){printf "--|--" $i}{print"--|"}}}' $tableName

        echo "Please enter column name:"
        read columnName

        # Getting field number
        columnIndex=$(awk 'BEGIN{FS";"}{if (NR==1){for(i=1 ; i<=NF ; i++){if($i=="'$columnName'"){print i}}}' $tableName)

        if [[ -z $columnIndex ]]
        then
            echo "Column not found"
            tablesMenu
        
        
        else
            echo "Please enter a value: "
            read columnVal

            # Display row to be deleted
            searchVal=$(awk -v cindex="$columnIndex" -v value="$columnVal" -F";" '$cindex == value' $tableName 2>> /dev/null)

            if [[ -z $searchVal ]]
            then
                echo "Row not found"
                tablesMenu
            else
                echo "Row to be deleted:"
                awk -v cindex="$columnIndex" -v value="$columnVal" -F";" '$cindex == value' $tableName
                echo "Would you like to delete this row \rows? (y/n)"
                read confirm

                if [[ $confirm == "Y" || $confirm == "y" || $confirm == "yes" ]]; then
                    NR=$(awk -v cindex="$columnIndex" -v value="$columnVal" -F";" '$cindex == value{print NR}' $tableName 2>> /dev/null)
                    sed -i'' $NR'd' $tableName 2>> /dev/null
                    echo "Row Is Deleted Successfully!"
                    tablesMenu
                else
                    echo "Deletion canceled"
                    tablesMenu
                fi
            
            fi
        
        fi
    
    
    else
        
        echo "Table doesn't exist"
        tablesMenu
    
    fi
}

#--------------------Update Table --------------------
function updateTable {
    
    echo "Please enter the table you want to update"
    read tableName
    
    
    if [[ -f $tableName ]]
    then
        awk 'BEGIN{FS";"}{if (NR==1) {for (i=1; i<NF ; i++) {printf "--|--" $i}{print "--|"}}}' $tableName
        echo "Please specify column name"
        read columnName
        columnIndex=$(awk 'BEGIN{FS=";"}{if(NR == 1){for(i=1; i<NF; i++){if($i=="'$columnName'") print i}}}' $tableName)
        
        
        if [[ -z $columnIndex ]]
        then 
            echo "Column does not exist"
            tablesMenu
        
        
        else
            echo "Please enter a value"
            
            read columnVal
            
            searchVal=$(awk 'BEGIN{FS=";"}{if($'$columnIndex'=="'$columnVal'") print $'$columnIndex'}' $tableName 2>> /dev/null )
            
            
            if [[ -z $searchVal ]]
            then 
                echo "Value does not exist"
                tablesMenu
            
            
            else 
                echo "Enter the value you want to update with"
                read updateVal
                NR=$(awk 'BEGIN{FS=";"}{if($'$columnIndex'=="'$columnVal'") print NR}' $tableName 2>> /dev/null)
                echo $NR
                oldValue=$(awk 'BEGIN{FS==";"}{if(NR=='$NR'){for(i=1; i<=NF; i++){if(i=='$columnIndex') print $i}}}' $tableName 2>> /dev/null)
                echo $oldValue
                sed -i ''$NR's/'$oldValue'/'$updateVal'/g' $tableName 2>> /dev/null
                echo "Row is Updated Successfully"
                tablesMenu
            
            fi
        
        fi
    
    
    else 
        echo "Table does not exist"
        tablesMenu
    
    fi

}

#---------------------------Select From Table ------------------------

function selectFromTable {
    
    echo "Please enter the table name you want to select from: "

    read tableName

    
    if [[ -f "$tableName" ]]
    then
        echo "These are the columns of the table you wanted to select from"
        awk 'BEGIN{FS=";"} {if (NR==1) {for(i=1;i<=NF;i++){printf "--|--"$i}}}' "$tableName"
        echo "Would you like to print all the records of the columns above? [y/n]"
        read displayall

        
        if [[ $displayall == "Y" || $displayall == "y" || $displayall == "yes" ]]; then
            echo -n "Would you like to print a specific column? [y/n]"
            read answer
            
            if [[ $answer == "Y" || $answer == "y" || $answer == "yes" ]]; then
                echo "Please enter the column you want to display"
                read columnnum
                output=$(awk -v col="$columnnum" '{print $col}' "$tableName" | column -t -s ';')
                echo "$output"
            
            
            else
                column -t -s ';' "$tableName"
            fi
        
        
        else 
            echo "Please enter a search value for the record you want to display"
            read searchVal
            echo "Would you like to print a specific column in the record? [y/n]"
            read columnOpt
            
            
            if [[ $columnOpt == "Y" || $columnOpt == "y" || $columnOpt == "yes" ]]; then 
                echo "Please enter the column number you want to display"
                read numColumn
                output=$(awk -v patternVal="$searchVal" -v col="$numColumn" '$0~patternVal{print $col}' "$tableName" | column -t -s ';')
                echo "$output"
            
            
            else
                output=$(awk -v patternVal="$searchVal" '$0~patternVal{print $0}' "$tableName" | column -t -s ';')
                echo "$output"
            
            fi
        
        
        fi
        echo "Would you like to make another query? [y/n]"
        read anotherQ
        
        
        if [[ $anotherQ == "Y" || $anotherQ == "y" || $anotherQ == "yes" ]]; then  
            selectFromTable
        
        
        elif [[ $anotherQ == "N" || $anotherQ == "n" || $anotherQ == "no" ]]; then
            cd ../..   # Navigate out of table file in the database folder and then out of the database folder in mydatabases folder
            connectToDB
        
        
        else
            echo "You entered an invalid choice"
            echo "Let's go back to the main menu!"
            cd ../..
            startMenu
        
        
        fi
    
    
    else
        echo "The table you entered does not exist"
        echo "Would you like to create the table you entered? [y/n]"
        read tableAns
        
        
        if [[ $tableAns == "Y" || $tableAns == "y" || $tableAns == "yes" ]]; then 
            createTable
        
        
        elif [[ $tableAns == "N" || $tableAns == "n" || $tableAns == "no" ]]; then
            selectFromTable # Loop back
        
        
        else
            echo "You entered an invalid option"
            echo "Let's go back to the main menu!"
            cd ../..
            startMenu
        
        fi
    
    fi
}
startMenu
