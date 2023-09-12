#!/bin/bash

# ------------------------ FIRST MENU --------------------------------

function startMenu {
    if [ -e "Databases" ]
    then
        cd ./Databases
        echo "Welcome To Databases"
    else 
        mkdir Databases
        if [ -d "Databases" ]
        then
            cd ./Databases
            echo "Welcome To Databases"
        else
            echo "There's a Problem"
            exit
        fi
    fi  
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
                connectToDB 
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
    if [ ! -d $dbName ]; then
        mkdir -p $dbName
        echo "Database $dbName created"
    else
        echo "Database $dbName already exists"
    fi
}

# ---------------------------------- LIST DATABASES --------------------------------

function listDB() {
    ls -F | grep '/' | sed 's|/||'
}

# ---------------------------------- CONNECT TO DATABASE --------------------------------

function connectToDB() {
    echo "Which database would you like to connect to?:"
    read dbName
    if ! [[ -d $dbName ]]; then
        echo $"Database $dbName does not exist. Do you want to create it? [Y/n]"
        read answer
        if [ "$answer" == "Y" ] || [ "$answer" == "y" ] || [ "$answer" == "yes" ] || [ "$answer" == "YES" ]; then
            createDB
        else 
            connectToDB
        fi
    else
        cd $dbName
        echo "Connecting to database $dbName"
        tablesMenu
    fi
}

# ---------------------------------- DROP DATABASE --------------------------------

function dropDB() {
    if [ ! -d $1 ]; then
        echo "Database $1 does not exist"
    else
        echo "Dropping database $1"
        rm -rf $1
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
    echo "Enter the name of the table you want to create : "
    read tableName

    if [[ -f $tableName ]]
    then
        echo "Table $tableName already exists"
        # connectToDB "$dbName"
    elif [[ $tableName =~ ^[a-zA-Z][a-zA-Z_0-9]*$ ]]
    then
    # touch $tableName
        touch $tableName
        echo "Table $tableName created"
        echo "Enter number of columns (fields) to create"
        read numberOfCols

        if [[ $numberOfCols =~ ^[0-9]+$ ]] 
        then
            primary_key_set="true"  # Flag to track if a primary key is set

            for ((i = 1; i <= numberOfCols; i++))
            do
                echo "Enter the name of column $i"
                read colName
                if [[ $colName =~ ^[a-zA-Z][a-zA-Z_0-9]*$ ]]
                then
                    # Ask the primary key question only for the first column
                    while [ "$primary_key_set" == "true" ]
                    do
                        echo "Is this column a primary key? [Y/n] ? "
                        read pk
                        if [[ $pk == "Y" || $pk == "y" || $pk == "yes" || $pk == "YES" ]]; then
                            primary_key_set="false"
                                # Apply the primary key status to the column
                            echo -n "(PK)" >> "$tableName"   
                        else
                            break
                        fi
                    done 
                    
                    # choosing data type for each column 
                    while true
                    do 
                        echo "Choose data type from (int , string)"
                        read datatype
                        case $datatype in
                            int)
                            echo -n $colName"($datatype);" >> $tableName;;
                            string)
                            echo -n $colName"($datatype);" >> $tableName;;
                            *)
                            echo "Data type incorrect!"
                            continue;
                        esac
                        break 
                    done
                else
                    i=$(($i-1))
                    echo "Invalid Name"
                fi
            done
                echo $'\n' >> $tableName #end of table header
                echo "Your table $tableName created"
                tablesMenu
            else
                echo "$fields is not a valid input (numbers only)"
                sleep 2
                createTable
        fi	
    else
        echo "Invalid Name"
    fi
    
}
# -------------------- List All Tables --------------------

function listAllTables() {
    echo "Your current tables are:"
    ls -F | grep -v '/'
}

# ------------------------- Insert into Table --------------------

		
function insertIntoTable() {

    echo " These are the current tables :  "
    listAllTables

    echo "Enter the name of the table you want to insert data into: " 
    read tableName

#    
# if [[ -f $tableName ]]
if [[ -f $tableName ]];

# cd ./Databases/$dbName/

		then
			x=`grep 'PK' $tableName | grep -o ";" | wc -l` # no of fields  .... grep 'PK' student | grep -o ";" | wc -l
															# o/p = 3
											#grep 'PK' student | grep -o ";"
											# o/p = ;
											#       ;
											#       ;
															

			# echo $x
			for ((i=1;i <= x;i++)) 
			do      
				colName=`grep PK $tableName| cut -f$i -d";"`              #grep PK student | cut -f1 -d";"      # bc -f$i = -f1 
														# = (PK)id(int)
											    #grep PK student | cut -f2 -d";"
														# = name(string)


				echo $'\n'
				echo $"Please enter data for field no.$i [$colName]"
				read data
				checkType $i $data

				if [[ $? != 0 ]]
				then
					(( i = $i - 1 ))
				else	
					echo -n $data";" >> $tableName 
				fi
			done	
			echo $'\n' >> $tableName  #end of record
			echo "insert done into"  $tableName 
		else
			echo "Table doesn't exist"
			echo "Do you want to create it? [y/n]"
			read answer
			case $answer in
				y) createTable
					;;
				n) insertIntoTable
					;;
				*) echo "Invalid choice. Going back to the main menu.." ;
					# sleep 2;
				cd ../..;
				startMenu
				;;
			esac
			
		fi



}


# ----------------------------------------------------------------
# function insertIntoTable() {
#     echo "These are the current tables: "
#     listAllTables

#     echo "Enter the name of the table you want to insert data into: "
#     read tableName

#     if [[ -f ./Databases/$dbName/$tableName ]]; then
#        x=`grep 'PK' ./Databases/$dbName/$tableName | grep -o ";" | wc -l`

#         for ((i = 1; i <= x; i++)); do
#             colName=$(grep 'PK' ./Databases/$dbName/$tableName | cut -f$i -d";")
#             echo $'\n'
#             echo "Please enter data for field no.$i [$colName]"
#             read data
#             checkType $i $data

#             if [[ $? != 0 ]]; then
#                 ((i = $i - 1))
#             else
#                 echo -n "$data;" >> ./Databases/$dbName/$tableName
#             fi
#         done
#         echo $'\n' >> ./Databases/$dbName/$tableName
#         echo "Insertion complete into $tableName"
#     else
#         echo "Table doesn't exist"
#         echo "Do you want to create it? [y/n]"
#         read answer
#         case $answer in
#             y) createTable
#                 ;;
#             n) insertIntoTable
#                 ;;
#             *) echo "Invalid choice. Going back to the main menu.." ;
#                 startMenu
#                 ;;
#         esac
#     fi
# }


#-------------------------------------DROP-DELETE-UPDATE----------------------

#-------------------------Drop Table------------------
function dropTable {
    # List available tables
    listAllTables

    # Prompt the user for the table name to delete
    echo "Please enter the table name you want to delete: "
    read tableName

    # if [[ -f $tableName ]]; then
    if [[ -f $tableName ]]; then

        # Ask for confirmation before deleting the table
        echo "Are you sure you want to delete this table? [y/n]"
        read confirm

        if [[ $confirm == "Y" || $confirm == "y" || $confirm == "yes" ]]; then
            # Delete the table file
            rm -rf $tableName
            echo "$tableName has been successfully deleted."
            # Continue with other menu operations
            tablesMenu
        else
            echo "Thank You."
            tablesMenu
        fi
        else
            echo "The table you entered does not exist."
        fi 
    
}

#-------------------------Delete Rows------------------
function deleteFromTable {

    while [ true ]; do
		echo "Enter the table name you want to delete from: "
        read tableName
		if ! [[ -f $tableName ]]; then
			echo "This table doesn't Exsit! Please enter another name."
			deleteFromTable
		else
			while [ true ]; do
				echo "Do you want to delete all data in this table? [y/n]: " 
                read answer
				if ! [[ $answer == "y" || $answer == "n" || $answer == "Y" || $answer == "N" ]]; then
					echo "Invalid input!"
				elif [[ $answer == "y" || $answer == "Y" ]]; then
					sed -i '2,$d' $tableName			
					echo "Table is Deleted succesfully!!!"
					tablesMenu
				else
					echo "Enter PK value to Delete Row by it: " 
                    read PK
					checkPK=`cat $tableName | cut -f1 -d";" | grep $PK`
					if ! [[ $checkPK ]]
					then
						echo "Invalid PK! Try again!"
						deleteFromTable
					else
						echo "Are you sure you want to delete it? [y/n]: " 
                        read answer
						if ! [[ $answer == "y" || $answer == "Y" ]]; then
							echo "Thank You"
						else
							recordNum=`awk -F';' '{if($1=='${PK}'){print NR}}' ${tableName}`
							if [ $recordNum ]; then
								sed -i ''$recordNum'd' "$tableName"
								echo "Record deleted successfuly!!!"
								tablesMenu
							else
								echo "PK not Found! try again"
								deleteFromTable
							fi
						fi
					fi
					
				fi
			done
		fi
	done
#                 awk -v cindex="$columnIndex" -v value="$columnVal" -F";" '$cindex == value' $tableName
#                 echo "Would you like to delete this row \rows? (y/n)"
#                 read confirm

#                 if [[ $confirm == "Y" || $confirm == "y" || $confirm == "yes" ]]; then
#                     NR=$(awk -v cindex="$columnIndex" -v value="$columnVal" -F";" '$cindex == value{print NR}' $tableName 2>> /dev/null)
#                     sed -i'' $NR'd' $tableName 2>> /dev/null
#                     echo "Row Is Deleted Successfully!"
#                     tablesMenu
#                 else
#                     echo "Deletion canceled"
#                     tablesMenu
#                 fi
            
#             fi
        
#         fi
    
    
#     else
        
#         echo "Table doesn't exist"
#         tablesMenu
    
#     fi
# 
}
#--------------------Update Table --------------------
function updateTable {
    
    echo "Please enter the table you want to update"
    read tableName
    
    
    # if [[ -f $tableName ]]
    if [[ -f $tableName ]];

    then
        awk 'BEGIN{FS";"}{if (NR==1) {for (i=1; i<=NF ; i++) {printf "--|--" $i}{print "--|"}}}' $tableName
        NumberOfColumns=`awk -F';' '{if(NR==1) print NF}' $tableName`
        # echo $NumberOfColumns
		echo "Please specify column Number"
        read columnNum
        # echo $columnNum
		if [[ $columnNum == "" ]]
		then
			echo "Invalid input!"
			echo "Try again!"
			updateTable
		elif (( $columnNum > $NumberOfColumns-1 | $columnNum == 0 ))
		then
			echo "Invalid input!"
			updateTable
		else
			echo "Enter value you want to change: " 
            read oldValue
			value=`awk -v pat=$oldValue $'$0~pat{print $0\n}' $tableName | cut -f$columnNum -d";"`
			if [[ $value == "" ]]
			then
				echo "Not Found!"
				updateTable
				tablesMenu
			else
				echo "Enter your new value: " 
                read newValue
				checkType $columnNum $newValue
				if [[ $? == 0 ]]; then				# if exit status from last command == 0 kml el code 3ady
					sed -i "s/$oldValue/$newValue/g" $tableName	# Replace old value with new one
					echo "Done. Table updated successfully!!!"
					tablesMenu
				else
					echo "Not The same datatype .. !"
					echo "Try again!"
					updateTable
				fi				
			fi
		fi
    else 
        echo "Table does not exist"
        tablesMenu
    
    fi

}

#---------------------------Select From Table ------------------------

# function selectFromTable {

#     echo "These are the current tables: "
#     listAllTables
    
#     echo "Please enter the table name you want to select from: "

#     read tableName
#     # set -x
    
#     # if [[ -f "$tableName" ]]
#     if [[ -f "./Databases/$dbName/$tableName" ]]; 

#     then
# -

# echo $'\n'
# 			awk 'BEGIN{FS=";"}{if (NR==1) {for(i=1;i<=NF;i++){printf "--|--"$i}{print "--|"}}}' ./Databases/$dbName/$tableName 
# 			echo $'\nWould you like to print all records? [y/n]'
# 			read printall
# 			if [[ $printall == "Y" || $printall == "y" || $printall == "yes" ]]
# 			then
# 				echo $'\nWould you like to print a specific field? [y/n]'
# 				read cut1
# 				if [[ $cut1 == "Y" || $cut1 == "y" || $cut1 == "yes" ]]
# 				then
# 					echo $'\nPlease specify field number: '
# 					read fieldno
# 					echo $'<====================>'
# 					awk $'{print $0\n}' $tableName | cut -f$fieldno -d";"     #This command uses awk to print the entire content of the $table file (presumably the table data) and 
# 												#then uses cut to extract the values of the specified field number (fieldno) using 													the semicolon (;) as the delimiter. The result is displayed between <====================> markers.
# 					echo $'<====================>'
# 				else
# 					echo $'\n'
# 					echo $'<====================>'
# 					column -t -s ';' $tableName
# 					echo $'<====================>\n'
# 				fi
# 			else
# 				echo $'\nPlease enter a search value to select record(s): '
# 				read value
# 				echo $'\nWould you like to print a specific field? [y/n]'
# 				read cut
# 				if [[ $cut == "Y" || $cut == "y" || $cut == "yes" ]]
# 				then
# 					echo $'\nPlease specify field number: '
# 					read field
# 					echo $'<====================>\n'
# 					# find the pattern in records |> for that specific field
# 					awk -v pat=$value $'$0~pat{print $0\n}' $tableName | cut -f$field -d";"
					
# 				else
# 					echo echo $'<====================>\n'
# 					# find the pattern in records |> for all fields |> as a table display 
# 					awk -v pat=$value '$0~pat{print $0}' $tableName | column -t -s ';'
						
# 				fi
# 		fi
# 		echo $'\nWould you like to make another query? [y/n]'
# 		read answer
# 		if [[ $answer == "Y" || $answer == "y" || $answer == "yes" ]]
# 		then
			
# 			selectFromTable 
# 		elif [[ $answer == "N" || $answer == "n" || $answer == "no" ]]
# 		then	
			
# 			# cd ../..
# 			connectToDB
# 		else
# 			echo $'Invalid choice\n'
# 			echo "Redirecting to main menu.."
# 			# cd ../..
# 			# sleep 2
# 			startMenu
# 		fi
# 	else
# 		echo "Table doesn't exist"
# 		echo "Do you want to create it? [y/n]"
# 		read answer
# 		case $answer in
# 			y)
# 			createTable;;
# 			n)
# 			selectFromTable;;
# 			*)
# 			echo "Incorrect answer. Redirecting to main menu.." ;
# 			# sleep 2;
# 			# cd ../..;
# 			startMenu;;
# 		esac
# 	fi
# }

# --------------------------------


function selectFromTable {
    echo "These are the current tables: "
    listAllTables
    
    echo "Please enter the table name you want to select from: "
    read tableName
	if ! [[ -f $tableName ]]; then
		echo "Table doesn't exist"
	else
		echo $'\nWould you like to print all records? [y/n]'
        read printall
		 if [[ $printall == "Y" || $printall == "y" || $printall == "yes" ]]; then
			echo $'\nWould you like to print a specific field? [y/n]'
            read cut1
			if [[ $cut1 == "Y" || $cut1 == "y" || $cut1 == "yes" ]]; then
				 echo $'\nPlease specify field number: '
                read fieldno
				echo "-----------------------------"
				awk $'{print $0\n}' $tableName | cut -f$fieldno -d";" # Print all rows of column x
				echo "-----------------------------"
			else
				echo "-----------------------------"
				column -t -s ';' $tableName # Print Full Table
				echo "-----------------------------"
			fi
		else
			echo $'\nPlease enter a search value to select record(s): '
            read value
			echo $'\nWould you like to print a specific field? [y/n]'
            read cut
            if [[ $cut == "Y" || $cut == "y" || $cut == "yes" ]]; then
                echo $'\nPlease specify field number: '
                read field
				echo "-----------------------------"
				awk -v pat=$value $'$0~pat{print $0\n}' $tableName | cut -f$field -d";"
				echo "-----------------------------"
			else
				# find the pattern in records |> for all fields |> as a table display
				echo "-----------------------------"
				awk -v pat=$value '$0~pat{print $0}' $tableName | column -t -s ';'
				echo "-----------------------------"
			fi
		fi
		read -p $'Would you like to make another query? [y/n]: ' answer
		if [[ $answer == "y" || $answer == "Y" || $answer == "yes" ]]; then
			selectFromTable
		elif [[ $answer == "n" || $answer == "N" || $answer == "no" ]]; then
			tablesMenu
		else
			echo "Invalid input! Please wait a second .."
			sleep 1
			echo "Back to Table Menu"
			tablesMenu
		fi
	fi
}


# checktypeeee

function checkType {
	dataType=`grep PK $tableName | cut -f$1 -d";"`

	# colname(int) => get in the () only
	if [[ "$dataType" == *"int"* ]]
	then
		num='^[0-9]+$'
		if ! [[ $2 =~ $num ]]
		then
			echo "False input: Not a number!"
			return 1
		else
			checkPK $1 $2
		fi
	elif [[ "$dataType" == *"string"* ]]
	then
		str='^[a-zA-Z]+$'
		if ! [[ $2 =~ $str ]]
		then
			echo "False input: Not string!"
			return 1
		else
			checkPK $1 $2
		fi
	fi
}


# check el primary keyyyy
function checkPK {
header=`grep PK $tableName | cut -f$1 -d";"`
if [[ "$header" == *"PK"* ]]
then
	if [[ `cut -f$1 -d";" $tableName  | grep -w $2` ]]
	then
		echo $'\nPrimary Key already exists' 
		return 1
	fi
fi
}


startMenu