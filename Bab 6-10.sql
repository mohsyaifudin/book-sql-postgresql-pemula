-- BAB 6

CREATE OR REPLACE FUNCTION calculate_annual_salary(employee_id INT)
RETURNS DECIMAL AS $$
DECLARE
    monthly_salary DECIMAL;
BEGIN
    -- Mengambil gaji bulanan pegawai
    SELECT salary INTO monthly_salary
    FROM employees
    WHERE id = employee_id;
    
    -- Menghitung gaji tahunan
    RETURN monthly_salary * 12;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION determine_bonus(employee_id INT)
RETURNS DECIMAL AS $$
DECLARE
    salary DECIMAL;
    bonus DECIMAL;
BEGIN
    -- Mengambil gaji pegawai
    SELECT salary INTO salary
    FROM employees
    WHERE id = employee_id;
    
    -- Menentukan bonus berdasarkan gaji
    IF salary < 3000 THEN
        bonus := 0.05 * salary;  -- 5% bonus untuk gaji < 3000
    ELSE
        bonus := 0.10 * salary;  -- 10% bonus untuk gaji >= 3000
    END IF;
    
    -- Mengembalikan nilai bonus
    RETURN bonus;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_salaries(percentage DECIMAL)
RETURNS VOID AS $$
DECLARE
    emp RECORD;
BEGIN
    FOR emp IN SELECT id, salary FROM employees LOOP
        UPDATE employees
        SET salary = salary + (salary * percentage)
        WHERE id = emp.id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

BEGIN;  -- Memulai transaksi

UPDATE employees SET salary = salary + 500 WHERE id = 1;  -- Operasi pertama
UPDATE employees SET salary = salary + 300 WHERE id = 2;  -- Operasi kedua

COMMIT;  -- Menyelesaikan transaksi jika tidak ada kesalahan


BEGIN;  -- Memulai transaksi

UPDATE employees SET salary = salary + 500 WHERE id = 1;  -- Operasi pertama
UPDATE employees SET salary = salary + 300 WHERE id = 2;  -- Operasi kedua

-- Jika ada kesalahan
ROLLBACK;  -- Membatalkan transaksi

BEGIN;

SAVEPOINT sp1;  -- Menyimpan titik savepoint

UPDATE employees SET salary = salary + 500 WHERE id = 1;

-- Jika ada kesalahan setelah savepoint, lakukan rollback ke savepoint
ROLLBACK TO SAVEPOINT sp1;

COMMIT;

WITH department_avg_salary AS (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT e.name, e.salary, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.id
INNER JOIN department_avg_salary das ON e.department_id = das.department_id
WHERE e.salary > das.avg_salary;

WITH RECURSIVE employee_hierarchy AS (
    SELECT id, name, manager_id
    FROM employees
    WHERE manager_id IS NULL  -- Pegawai yang tidak memiliki manajer (top level)
    UNION ALL
    SELECT e.id, e.name, e.manager_id
    FROM employees e
    INNER JOIN employee_hierarchy eh ON e.manager_id = eh.id
)
SELECT * FROM employee_hierarchy;

-- BAB 7

EXPLAIN SELECT * FROM employees WHERE salary > 3000;

SELECT id, name, salary FROM employees WHERE salary > 3000;

SELECT * FROM employees WHERE department_id = 5;

VACUUM ANALYZE employees;

CREATE INDEX idx_employee_name ON employees(name);

CREATE INDEX idx_employee_name_hash ON employees USING hash(name);

CREATE INDEX idx_employee_location ON employees USING gist(location);

CREATE INDEX idx_employee_skills ON employees USING gin(skills);

DROP INDEX idx_employee_name;

EXPLAIN SELECT * FROM employees WHERE name = 'John Doe';


CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    product_id INT,
    amount DECIMAL,
    sale_date DATE
) PARTITION BY RANGE (sale_date);

CREATE TABLE sales_2023 PARTITION OF sales
    FOR VALUES FROM ('2023-01-01') TO ('2023-12-31');

CREATE TABLE sales_2024 PARTITION OF sales
    FOR VALUES FROM ('2024-01-01') TO ('2024-12-31');

-- BAB 8

CREATE ROLE admin_user WITH LOGIN PASSWORD 'password123';

GRANT SELECT, INSERT, UPDATE, DELETE ON employees TO admin_user;

GRANT USAGE ON SCHEMA public TO admin_user;

CREATE ROLE super_admin WITH LOGIN PASSWORD 'securepass' SUPERUSER;

\du

GRANT SELECT ON employees TO guest_user;

REVOKE SELECT ON employees FROM guest_user;

GRANT SELECT (salary) ON employees TO guest_user;

CREATE ROLE staff;
GRANT SELECT ON employees TO staff;

GRANT staff TO new_user;

-- BAB 9

CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    published_year INT,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);


CREATE TABLE members (
    member_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    join_date DATE
);


CREATE TABLE borrowings (
    borrowing_id SERIAL PRIMARY KEY,
    member_id INT,
    book_id INT,
    borrow_date DATE,
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL
);

SELECT books.title, borrowings.borrow_date, borrowings.return_date
FROM borrowings
JOIN books ON borrowings.book_id = books.book_id
WHERE borrowings.member_id = 1;

SELECT books.title, members.name
FROM borrowings
JOIN books ON borrowings.book_id = books.book_id
JOIN members ON borrowings.member_id = members.member_id
WHERE borrowings.return_date IS NULL;

SELECT categories.category_name, COUNT(borrowings.book_id) AS borrow_count
FROM borrowings
JOIN books ON borrowings.book_id = books.book_id
JOIN categories ON books.category_id = categories.category_id
GROUP BY categories.category_name;

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2),
    stock INT
);

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(20)
);

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    customer_id INT,
    transaction_date DATE,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE transaction_details (
    detail_id SERIAL PRIMARY KEY,
    transaction_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10, 2),
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

SELECT customers.name, transactions.transaction_date, transactions.total_amount
FROM transactions
JOIN customers ON transactions.customer_id = customers.customer_id
WHERE customers.customer_id = 1;


SELECT products.product_name, SUM(transaction_details.quantity) AS total_sold
FROM transaction_details
JOIN products ON transaction_details.product_id = products.product_id
GROUP BY products.product_name;


SELECT product_name, stock - COALESCE(SUM(transaction_details.quantity), 0) AS remaining_stock
FROM products
LEFT JOIN transaction_details ON products.product_id = transaction_details.product_id
GROUP BY products.product_name, products.stock;


-- BAB 10


