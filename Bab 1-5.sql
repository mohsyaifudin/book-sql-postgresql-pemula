-- BAB 1
CREATE DATABASE belajar_sql;

\c belajar_sql

-- BAN 2

SELECT column1, column2, ... FROM table_name;

SELECT name, age FROM students;

SELECT * FROM students;

INSERT INTO table_name (column1, column2, ...) VALUES (value1, value2, ...);

INSERT INTO students (name, age) VALUES ('John Doe', 21);

UPDATE table_name SET column1 = value1, column2 = value2, ... WHERE condition;

UPDATE students SET age = 22 WHERE name = 'John Doe';

DELETE FROM table_name WHERE condition;

DELETE FROM students WHERE name = 'John Doe';

CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  age INTEGER,
  enrollment_date DATE
);

CREATE TABLE table_name (
  column1 datatype,
  column2 datatype,
  ...
);

CREATE TABLE courses (
  id SERIAL PRIMARY KEY,
  course_name VARCHAR(100),
  credits INTEGER
);

INSERT INTO courses (course_name, credits) VALUES ('Mathematics', 3);

SELECT * FROM courses;

SELECT * FROM courses WHERE credits = 3;

SELECT * FROM courses ORDER BY course_name ASC;

SELECT * FROM courses LIMIT 5;

-- BAB 3

-- INNER JOIN
SELECT employees.name, departments.department_name
FROM employees
INNER JOIN departments
ON employees.department_id = departments.id;

-- LEFT JOIN
SELECT employees.name, departments.department_name
FROM employees
LEFT JOIN departments
ON employees.department_id = departments.id;

SELECT department_id, COUNT(*) AS num_employees
FROM employees
GROUP BY department_id;

SELECT department_id, COUNT(*) AS num_employees
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 5;

SELECT name, (SELECT AVG(salary) FROM employees) AS avg_salary
FROM employees;

SELECT name
FROM employees
WHERE department_id = (SELECT id FROM departments WHERE department_name = 'Sales');


SELECT department_id, AVG(salary)
FROM (SELECT department_id, salary FROM employees WHERE salary > 3000) AS high_salary
GROUP BY department_id;


SELECT * FROM employees WHERE name LIKE 'John%';

SELECT * FROM employees WHERE department_id IN (1, 2, 3);

SELECT * FROM employees WHERE salary BETWEEN 3000 AND 5000;


-- BAB 4
SELECT COUNT(*) FROM employees;

SELECT COUNT(*) FROM employees WHERE salary > 3000;

SELECT SUM(salary) FROM employees;

SELECT SUM(salary) FROM employees WHERE department_id = 1;

SELECT AVG(salary) FROM employees;

SELECT AVG(salary) FROM employees WHERE department_id = 2;

SELECT MIN(salary) FROM employees;

SELECT MAX(salary) FROM employees;

SELECT department_id, COUNT(*) AS num_employees
FROM employees
GROUP BY department_id;

SELECT department_id, AVG(salary) AS avg_salary, MAX(salary) AS max_salary
FROM employees
GROUP BY department_id;

SELECT department_id, COUNT(*) AS num_employees
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 5;

SELECT department_id, SUM(salary) AS total_salary
FROM employees
GROUP BY department_id;

SELECT salary, COUNT(*) AS num_employees
FROM employees
GROUP BY salary;

SELECT department_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id
ORDER BY avg_salary DESC
LIMIT 1;

-- BAB 4

CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    department_name VARCHAR(100)
);

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    salary DECIMAL(10, 2),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

SELECT employees.name, departments.department_name
FROM employees
INNER JOIN departments
ON employees.department_id = departments.id;

CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    project_name VARCHAR(100)
);

CREATE TABLE employees_projects (
    employee_id INT,
    project_id INT,
    PRIMARY KEY (employee_id, project_id),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (project_id) REFERENCES projects(id)
);

SELECT employees.name, projects.project_name
FROM employees
INNER JOIN employees_projects ON employees.id = employees_projects.employee_id
INNER JOIN projects ON employees_projects.project_id = projects.id;

CREATE TABLE departments (
    id SERIAL PRIMARY KEY, -- PRIMARY KEY
    department_name VARCHAR(100)
);

CREATE TABLE employees (
    id SERIAL PRIMARY KEY, -- PRIMARY KEY
    name VARCHAR(100),
    salary DECIMAL(10, 2),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(id) -- FOREIGN KEY
);

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE,  -- UNIQUE constraint
    salary DECIMAL(10, 2)
);

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,  -- NOT NULL constraint
    salary DECIMAL(10, 2) NOT NULL
);

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    salary DECIMAL(10, 2) CHECK (salary > 0)  -- CHECK constraint
);

-- BAB 5
ALTER TABLE employees
ADD COLUMN email VARCHAR(100);

ALTER TABLE employees
DROP COLUMN email;

ALTER TABLE employees
ALTER COLUMN salary TYPE DECIMAL(10, 2);

CREATE INDEX idx_email
ON employees (email);

SELECT * FROM employees WHERE email = 'john.doe@example.com';

CREATE VIEW high_salary_employees AS
SELECT id, name, salary
FROM employees
WHERE salary > 3000;

SELECT * FROM high_salary_employees;

CREATE OR REPLACE FUNCTION update_last_modified()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_modified = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_last_modified
BEFORE UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION update_last_modified();


CREATE OR REPLACE FUNCTION calculate_annual_salary(employee_id INT)
RETURNS DECIMAL AS $$
DECLARE
    monthly_salary DECIMAL;
BEGIN
    SELECT salary INTO monthly_salary
    FROM employees
    WHERE id = employee_id;

    RETURN monthly_salary * 12;
END;
$$ LANGUAGE plpgsql;


SELECT calculate_annual_salary(1);









