# Employee Attendance Tracking Function
This function is used to track the attendance of employees in a workplace. The function is written in PL/pgSQL and creates a function named "attendance".

## Functionality
The function reads a text file containing the names of employees who are present at the workplace. It then checks each name in the text file against the names in the "employees" table in the database. If a name matches, the function inserts a record in the "attendance" table with the date and "present" as the attendance status. If a name doesn't match, the function inserts a record with the date and "absent" as the attendance status.

## Input
The function reads a text file containing the names of employees who are present. The path to this file is hardcoded in the function and can be changed as needed.

## Output
The function returns a list of employees whose attendance was marked as present in the "attendance" table.

### Limitations
The function assumes that the names in the text file and the "employees" table are exactly the same. Any mismatch in the names will result in incorrect attendance tracking.

## Usage
To use this function, call it by its name "attendance()" and it will return a list of employees whose attendance was marked as present.

## Example
`SELECT * FROM attendance();`
