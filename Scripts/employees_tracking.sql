CREATE OR REPLACE FUNCTION attendance(file_path text) 
RETURNS SETOF employees AS
$$
DECLARE
  present text[] := ARRAY(
SELECT
	regexp_split_to_table(pg_read_file(file_path),
	',\s+')) AS name;

attendance_date DATE := NOW()::DATE;

employee_attendance RECORD;

BEGIN
  FOR employee_attendance IN
SELECT
	DISTINCT id,
	name,
	email
FROM
	employees
WHERE
	name LIKE ANY(present) LOOP
    INSERT
	INTO
	attendance (employee_id,
	name,
	email,
	date,
	attend_status)
VALUES (employee_attendance.id,
employee_attendance.name,
employee_attendance.email,
attendance_date,
'present')
    ON
CONFLICT (employee_id,
date) DO
UPDATE
SET
	attend_status = 'present';
END LOOP;

FOR employee_attendance IN
SELECT
	DISTINCT id,
	name,
	email
FROM
	employees
WHERE
	name NOT LIKE ANY(present) LOOP
    INSERT
	INTO
	attendance (employee_id,
	name,
	email,
	date,
	attend_status)
VALUES (employee_attendance.id,
employee_attendance.name,
employee_attendance.email,
attendance_date,
'absent')
    ON
CONFLICT (employee_id,
date) DO NOTHING;
END LOOP;

RETURN QUERY
SELECT
	*
FROM
	employees
WHERE
	name LIKE ANY(present);
END;

$$ LANGUAGE plpgsql;
--------
-- Example usage: replace 'C:/Users/ejike/Document/attendance_list.txt' with the actual file path
SELECT
	*
FROM
	attendance('C:/Users/ejike/Document/attendance_list.txt');
-- Retrieve employee attendance for the current date
SELECT
	name,
	attend_status,
	date
FROM
	attendance
WHERE
	date = current_date
ORDER BY
	attend_status DESC;
-- Parse the text file for names
SELECT
	regexp_split_to_table(pg_read_file('C:/Users/ejike/Document/attendance_list.txt'),
	',') AS name;
-- Identify employees who have been absent for more than 2 days
-- with dates listed in rows
SELECT
	name,
	string_agg(date::text,
	', ') AS absent_dates
FROM
	attendance
WHERE
	attend_status = 'absent'
GROUP BY
	name
HAVING
	COUNT(DISTINCT date) > 2
ORDER BY
	MIN(date) ASC;
-- with dates of absence as columns
SELECT
	name,
	MAX(CASE WHEN date = '2023-03-10' THEN attend_status ELSE NULL END) AS "2023-03-10",
	MAX(CASE WHEN date = '2023-03-14' THEN attend_status ELSE NULL END) AS "2023-03-14",
	MAX(CASE WHEN date = '2023-03-16' THEN attend_status ELSE NULL END) AS "2023-03-16"
FROM
	attendance
WHERE
	attend_status = 'absent'
GROUP BY
	name
HAVING
	COUNT(DISTINCT date) > 2
ORDER BY
	MIN(date) ASC;
