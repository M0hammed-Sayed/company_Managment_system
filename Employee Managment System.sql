SET SERVEROUTPUT ON;
-- =============================================================================
-- CREATE TABLES
-- =============================================================================

CREATE TABLE EMPLOYEES (
    employee_id   NUMBER        PRIMARY KEY,
    manager_id    NUMBER,
    first_name    VARCHAR2(50)  NOT NULL,
    last_name     VARCHAR2(50)  NOT NULL,
    role          VARCHAR2(100) NOT NULL,
    department    VARCHAR2(100) NOT NULL,
    salary        NUMBER(10,2)  NOT NULL,
    hire_date     DATE          NOT NULL,
    CONSTRAINT fk_emp_manager FOREIGN KEY (manager_id)
        REFERENCES EMPLOYEES(employee_id)
);

CREATE TABLE PRODUCTS (
    product_id    NUMBER        PRIMARY KEY,
    category_id   NUMBER        NOT NULL,
    name          VARCHAR2(100) NOT NULL,
    base_price    NUMBER(10,2)  NOT NULL,
    is_active     NUMBER(1)     DEFAULT 1 NOT NULL,
    CONSTRAINT chk_product_active CHECK (is_active IN (0,1))
);

CREATE TABLE PRODUCT_MANAGERS (
    pm_id           NUMBER    PRIMARY KEY,
    product_id      NUMBER    NOT NULL,
    employee_id     NUMBER    NOT NULL,
    assigned_from   DATE      NOT NULL,
    assigned_until  DATE,
    is_active       NUMBER(1) DEFAULT 1 NOT NULL,
    CONSTRAINT fk_pm_product  FOREIGN KEY (product_id)  REFERENCES PRODUCTS(product_id),
    CONSTRAINT fk_pm_employee FOREIGN KEY (employee_id) REFERENCES EMPLOYEES(employee_id),
    CONSTRAINT chk_pm_active  CHECK (is_active IN (0,1))
);

CREATE TABLE ORDERS (
    order_id      NUMBER        PRIMARY KEY,
    customer_id   NUMBER        NOT NULL,
    status        VARCHAR2(20)  NOT NULL,
    total_amount  NUMBER(10,2)  DEFAULT 0 NOT NULL,
    placed_at     TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT chk_order_status CHECK (status IN ('pending','confirmed','shipped','delivered','cancelled'))
);

CREATE TABLE ORDER_HANDLERS (
    handler_id    NUMBER        PRIMARY KEY,
    order_id      NUMBER        NOT NULL,
    employee_id   NUMBER        NOT NULL,
    action        VARCHAR2(50)  NOT NULL,
    handled_at    TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    notes         VARCHAR2(500),
    CONSTRAINT fk_oh_order    FOREIGN KEY (order_id)    REFERENCES ORDERS(order_id),
    CONSTRAINT fk_oh_employee FOREIGN KEY (employee_id) REFERENCES EMPLOYEES(employee_id)
);

CREATE TABLE SUPPLIERS (
    supplier_id   NUMBER        PRIMARY KEY,
    company_name  VARCHAR2(100) NOT NULL,
    country       VARCHAR2(100) NOT NULL
);

CREATE TABLE SUPPLIER_CONTACTS (
    sc_id              NUMBER        PRIMARY KEY,
    supplier_id        NUMBER        NOT NULL,
    employee_id        NUMBER        NOT NULL,
    relationship_type  VARCHAR2(100) NOT NULL,
    since              DATE          NOT NULL,
    is_primary         NUMBER(1)     DEFAULT 0 NOT NULL,
    CONSTRAINT fk_sc_supplier FOREIGN KEY (supplier_id) REFERENCES SUPPLIERS(supplier_id),
    CONSTRAINT fk_sc_employee FOREIGN KEY (employee_id) REFERENCES EMPLOYEES(employee_id),
    CONSTRAINT chk_sc_primary CHECK (is_primary IN (0,1))
);

CREATE TABLE LOGS (
    log_id      NUMBER         PRIMARY KEY,
    log_time    TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
    log_level   VARCHAR2(10)   NOT NULL,
    source      VARCHAR2(100)  NOT NULL,
    message     VARCHAR2(4000) NOT NULL,
    CONSTRAINT chk_log_level CHECK (log_level IN ('INFO','WARN','ERROR','DEBUG'))
);

CREATE TABLE EMPLOYEE_LOGS (
    el_id        NUMBER        PRIMARY KEY,
    log_id       NUMBER        NOT NULL,
    employee_id  NUMBER        NOT NULL,
    context      VARCHAR2(500),
    created_at   TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT fk_el_log      FOREIGN KEY (log_id)      REFERENCES LOGS(log_id),
    CONSTRAINT fk_el_employee FOREIGN KEY (employee_id) REFERENCES EMPLOYEES(employee_id)
);


-- =============================================================================
-- SEQUENCES
-- =============================================================================

CREATE SEQUENCE Emp_Id_Seq               START WITH 8  INCREMENT BY 1;
CREATE SEQUENCE products_Id_Seq          START WITH 5  INCREMENT BY 1;
CREATE SEQUENCE product_managers_Id_Seq  START WITH 5  INCREMENT BY 1;
CREATE SEQUENCE orders_Id_Seq            START WITH 105 INCREMENT BY 1;
CREATE SEQUENCE Order_handlers_Id_Seq    START WITH 6  INCREMENT BY 1;
CREATE SEQUENCE suppliers_Id_Seq         START WITH 4  INCREMENT BY 1;
CREATE SEQUENCE supplier_contacts_Id_Seq START WITH 5  INCREMENT BY 1;
CREATE SEQUENCE LOG_Id_Seq               START WITH 5  INCREMENT BY 1;
CREATE SEQUENCE EMP_LOG_Id_Seq           START WITH 5  INCREMENT BY 1;


-- =============================================================================
-- SEED DATA
-- =============================================================================

-- EMPLOYEES
INSERT ALL
  INTO EMPLOYEES VALUES (1, NULL, 'Alice', 'Johnson',  'CEO',             'Executive', 130000, DATE '2014-03-01')
  INTO EMPLOYEES VALUES (2, 1,    'Bob',   'Smith',    'VP Sales',        'Sales',      95000, DATE '2016-06-15')
  INTO EMPLOYEES VALUES (3, 1,    'Carol', 'Davis',    'VP Technology',   'Tech',      100000, DATE '2015-11-20')
  INTO EMPLOYEES VALUES (4, 2,    'Dan',   'Lee',      'Sales Manager',   'Sales',      78000, DATE '2018-09-10')
  INTO EMPLOYEES VALUES (5, 3,    'Eve',   'Brown',    'Lead Developer',  'Tech',       88000, DATE '2019-04-22')
  INTO EMPLOYEES VALUES (6, 3,    'Frank', 'Wilson',   'DevOps Engineer', 'Tech',       82000, DATE '2020-01-08')
  INTO EMPLOYEES VALUES (7, 2,    'Grace', 'Taylor',   'Sales Rep',       'Sales',      60000, DATE '2021-07-19')
SELECT * FROM dual;

-- PRODUCTS
INSERT ALL
  INTO PRODUCTS VALUES (1, 10, 'Widget A',   29.99,  1)
  INTO PRODUCTS VALUES (2, 10, 'Widget B',   49.99,  1)
  INTO PRODUCTS VALUES (3, 20, 'Gadget X',   99.99,  0)
  INTO PRODUCTS VALUES (4, 20, 'Gadget Pro', 149.99, 1)
SELECT * FROM dual;

-- PRODUCT_MANAGERS
INSERT ALL
  INTO PRODUCT_MANAGERS VALUES (1, 1, 5, DATE '2022-01-01', NULL,              1)
  INTO PRODUCT_MANAGERS VALUES (2, 2, 5, DATE '2022-01-01', DATE '2023-06-30', 0)
  INTO PRODUCT_MANAGERS VALUES (3, 2, 6, DATE '2023-07-01', NULL,              1)
  INTO PRODUCT_MANAGERS VALUES (4, 4, 4, DATE '2023-01-01', NULL,              1)
SELECT * FROM dual;

-- ORDERS
INSERT ALL
  INTO ORDERS VALUES (101, 500, 'delivered', 250.00,
        TO_TIMESTAMP('2024-01-10 09:00:00','YYYY-MM-DD HH24:MI:SS'))
  INTO ORDERS VALUES (102, 501, 'pending',    89.99,
        TO_TIMESTAMP('2024-03-11 14:00:00','YYYY-MM-DD HH24:MI:SS'))
  INTO ORDERS VALUES (103, 502, 'cancelled',   0.00,
        TO_TIMESTAMP('2024-03-12 10:30:00','YYYY-MM-DD HH24:MI:SS'))
  INTO ORDERS VALUES (104, 500, 'shipped',   310.50,
        TO_TIMESTAMP('2024-04-01 08:15:00','YYYY-MM-DD HH24:MI:SS'))
SELECT * FROM dual;

-- ORDER_HANDLERS
INSERT ALL
  INTO ORDER_HANDLERS VALUES (1, 101, 7, 'confirmed',
        TO_TIMESTAMP('2024-01-10 09:05:00','YYYY-MM-DD HH24:MI:SS'), NULL)
  INTO ORDER_HANDLERS VALUES (2, 101, 6, 'dispatched',
        TO_TIMESTAMP('2024-01-11 07:00:00','YYYY-MM-DD HH24:MI:SS'), 'Express shipping')
  INTO ORDER_HANDLERS VALUES (3, 102, 7, 'confirmed',
        TO_TIMESTAMP('2024-03-11 14:10:00','YYYY-MM-DD HH24:MI:SS'), NULL)
  INTO ORDER_HANDLERS VALUES (4, 103, 4, 'cancelled',
        TO_TIMESTAMP('2024-03-12 11:00:00','YYYY-MM-DD HH24:MI:SS'), 'Customer request')
  INTO ORDER_HANDLERS VALUES (5, 104, 7, 'confirmed',
        TO_TIMESTAMP('2024-04-01 08:20:00','YYYY-MM-DD HH24:MI:SS'), NULL)
SELECT * FROM dual;

-- SUPPLIERS
INSERT ALL
  INTO SUPPLIERS VALUES (1, 'TechSupply Co', 'Germany')
  INTO SUPPLIERS VALUES (2, 'WidgetWorld',   'China')
  INTO SUPPLIERS VALUES (3, 'ProParts Inc',  'USA')
SELECT * FROM dual;

-- SUPPLIER_CONTACTS
INSERT ALL
  INTO SUPPLIER_CONTACTS VALUES (1, 1, 3, 'Account Manager',  DATE '2020-01-01', 1)
  INTO SUPPLIER_CONTACTS VALUES (2, 1, 6, 'Technical Liaison', DATE '2021-06-01', 0)
  INTO SUPPLIER_CONTACTS VALUES (3, 2, 4, 'Account Manager',  DATE '2019-03-15', 1)
  INTO SUPPLIER_CONTACTS VALUES (4, 3, 5, 'Account Manager',  DATE '2022-09-01', 1)
SELECT * FROM dual;

-- LOGS
INSERT ALL
  INTO LOGS VALUES (1,
        TO_TIMESTAMP('2024-03-11 14:10:05','YYYY-MM-DD HH24:MI:SS'),
        'INFO',  'OrderService', 'Order 102 confirmed')
  INTO LOGS VALUES (2,
        TO_TIMESTAMP('2024-03-12 11:00:10','YYYY-MM-DD HH24:MI:SS'),
        'WARN',  'OrderService', 'Order 103 cancelled by customer')
  INTO LOGS VALUES (3,
        TO_TIMESTAMP('2024-04-01 08:20:01','YYYY-MM-DD HH24:MI:SS'),
        'INFO',  'OrderService', 'Order 104 confirmed')
  INTO LOGS VALUES (4,
        TO_TIMESTAMP('2024-04-01 08:21:00','YYYY-MM-DD HH24:MI:SS'),
        'ERROR', 'PaymentGW',   'Payment timeout for order 104')
SELECT * FROM dual;

-- EMPLOYEE_LOGS
INSERT ALL
  INTO EMPLOYEE_LOGS VALUES (1, 1, 7, 'Confirmed via dashboard',
        TO_TIMESTAMP('2024-03-11 14:10:05','YYYY-MM-DD HH24:MI:SS'))
  INTO EMPLOYEE_LOGS VALUES (2, 2, 4, 'Processed cancellation form',
        TO_TIMESTAMP('2024-03-12 11:00:10','YYYY-MM-DD HH24:MI:SS'))
  INTO EMPLOYEE_LOGS VALUES (3, 3, 7, 'Confirmed via dashboard',
        TO_TIMESTAMP('2024-04-01 08:20:01','YYYY-MM-DD HH24:MI:SS'))
  INTO EMPLOYEE_LOGS VALUES (4, 4, 6, 'Investigated payment issue',
        TO_TIMESTAMP('2024-04-01 09:00:00','YYYY-MM-DD HH24:MI:SS'))
SELECT * FROM dual;

COMMIT;


-- =============================================================================
-- REPORT PROCEDURES
-- =============================================================================

-- 1. Print the full employee hierarchy
CREATE OR REPLACE PROCEDURE report_employee_hierarchy AS
    CURSOR c IS
        SELECT
            e.employee_id,
            e.first_name || ' ' || e.last_name AS employee,
            e.role,
            e.department,
            e.salary,
            e.hire_date,
            m.first_name || ' ' || m.last_name AS reports_to
        FROM EMPLOYEES e
        LEFT JOIN EMPLOYEES m
            ON e.manager_id = m.employee_id
        ORDER BY e.department, e.hire_date;
    r c%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Employee Hierarchy ===');
    OPEN c;
    LOOP
        FETCH c INTO r;
        EXIT WHEN c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            'ID: '       || r.employee_id ||
            ' | Employee: ' || r.employee ||
            ' | Role: '     || r.role ||
            ' | Dept: '     || r.department ||
            ' | Salary: '   || r.salary ||
            ' | Manager: '  || NVL(r.reports_to, 'N/A')
        );
    END LOOP;
    CLOSE c;
END report_employee_hierarchy;  -- FIX: added procedure name to END
/

EXEC report_employee_hierarchy;


-- 2. Print active product managers
CREATE OR REPLACE PROCEDURE report_active_product_managers AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Active Product Managers ===');
    FOR r IN (
        SELECT
            p.name AS product,
            p.base_price,
            p.is_active AS product_active,
            e.first_name || ' ' || e.last_name AS manager,
            pm.assigned_from
        FROM PRODUCT_MANAGERS pm
        JOIN PRODUCTS p
            ON pm.product_id = p.product_id
        JOIN EMPLOYEES e
            ON pm.employee_id = e.employee_id
        WHERE pm.is_active = 1
        ORDER BY p.name
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Product: ' || RPAD(r.product, 15) ||
            ' | Price: '   || r.base_price ||
            ' | Active: '  || r.product_active ||
            ' | Manager: ' || RPAD(r.manager, 20) ||
            ' | Since: '   || TO_CHAR(r.assigned_from, 'YYYY-MM-DD')
        );
    END LOOP;
END report_active_product_managers;
/

EXEC report_active_product_managers;


-- 3. Print the full order audit trail
CREATE OR REPLACE PROCEDURE report_order_audit (
    p_order_id ORDERS.order_id%TYPE DEFAULT NULL
) AS
    CURSOR c IS
        SELECT
            o.order_id,
            o.status,
            o.total_amount,
            e.first_name || ' ' || e.last_name AS handled_by,
            oh.action,
            oh.handled_at,
            oh.notes
        FROM ORDERS o
        JOIN ORDER_HANDLERS oh ON o.order_id     = oh.order_id
        JOIN EMPLOYEES e       ON oh.employee_id  = e.employee_id
        WHERE (p_order_id IS NULL OR o.order_id = p_order_id);
    r c%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Order Audit Trail ===');
    OPEN c;
    LOOP
        FETCH c INTO r;
        EXIT WHEN c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            'Order#'       || r.order_id ||
            ' | Status: '  || RPAD(r.status, 12) ||
            ' | Amount: '  || r.total_amount ||
            ' | By: '      || RPAD(r.handled_by, 20) ||
            ' | Action: '  || RPAD(r.action, 15) ||
            ' | At: '      || TO_CHAR(r.handled_at, 'YYYY-MM-DD HH24:MI:SS') ||
            ' | Notes: '   || NVL(r.notes, '-')
        );
    END LOOP;
    CLOSE c;
END report_order_audit;
/

EXEC report_order_audit;
EXEC report_order_audit(p_order_id => 105);


-- 4. Print employee activity feed
CREATE OR REPLACE PROCEDURE report_employee_activity (
    p_log_level LOGS.log_level%TYPE DEFAULT NULL
) AS
    CURSOR c IS
        SELECT
            e.first_name || ' ' || e.last_name AS employee,
            l.log_level,
            l.source,
            l.message,
            el.context,
            el.created_at
        FROM EMPLOYEE_LOGS el
        JOIN LOGS      l ON el.log_id      = l.log_id
        JOIN EMPLOYEES e ON el.employee_id = e.employee_id
        WHERE (p_log_level IS NULL OR l.log_level = p_log_level);
    r c%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Employee Activity Feed ===');
    OPEN c;
    LOOP
        FETCH c INTO r;
        EXIT WHEN c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(r.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
            ' | [' || r.log_level || ']' ||
            ' | '  || RPAD(r.employee, 20) ||
            ' | Source: ' || RPAD(r.source, 15) ||
            ' | '  || r.message ||
            CASE WHEN r.context IS NOT NULL THEN ' (' || r.context || ')' ELSE '' END
        );
    END LOOP;
    CLOSE c;
END report_employee_activity;
/

EXEC report_employee_activity;
EXEC report_employee_activity(p_log_level => 'ERROR');


-- 5. Print supplier contacts
CREATE OR REPLACE PROCEDURE report_supplier_contacts (
    p_primary_only NUMBER DEFAULT NULL
) AS
    CURSOR c IS
        SELECT
            s.company_name,
            s.country,
            e.first_name || ' ' || e.last_name AS contact_person,
            sc.relationship_type,
            sc.since,
            sc.is_primary
        FROM SUPPLIER_CONTACTS sc
        JOIN SUPPLIERS s  ON sc.supplier_id  = s.supplier_id
        JOIN EMPLOYEES e  ON sc.employee_id  = e.employee_id
        WHERE (p_primary_only IS NULL OR sc.is_primary = p_primary_only);
    r c%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Supplier Contacts ===');
    OPEN c;
    LOOP
        FETCH c INTO r;
        EXIT WHEN c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.company_name, 20) ||
            ' | '          || RPAD(r.country, 10) ||
            ' | Contact: ' || RPAD(r.contact_person, 20) ||
            ' | Role: '    || RPAD(r.relationship_type, 20) ||
            ' | Since: '   || TO_CHAR(r.since, 'YYYY-MM-DD') ||
            ' | Primary: ' || r.is_primary
        );
    END LOOP;
    CLOSE c;
END report_supplier_contacts;
/

EXEC report_supplier_contacts;
EXEC report_supplier_contacts(p_primary_only => 1);


-- 6. Print department salary summary
CREATE OR REPLACE PROCEDURE report_dept_salary_summary AS
    CURSOR c IS
        SELECT
            department,
            COUNT(*)              AS headcount,
            MIN(salary)           AS min_salary,
            MAX(salary)           AS max_salary,
            ROUND(AVG(salary), 2) AS avg_salary,
            SUM(salary)           AS total_payroll
        FROM EMPLOYEES
        GROUP BY department;
    r c%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Department Salary Summary ===');
    OPEN c;
    LOOP
        FETCH c INTO r;
        EXIT WHEN c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.department, 12) ||
            ' | Headcount: ' || r.headcount ||
            ' | Min: '       || r.min_salary ||
            ' | Max: '       || r.max_salary ||
            ' | Avg: '       || r.avg_salary ||
            ' | Payroll: '   || r.total_payroll
        );
    END LOOP;
    CLOSE c;
END report_dept_salary_summary;
/

EXEC report_dept_salary_summary;


-- 7. Print orders grouped by status
CREATE OR REPLACE PROCEDURE report_orders_by_status AS
    CURSOR c IS
        SELECT
            status,
            COUNT(*)                    AS order_count,
            SUM(total_amount)           AS total_revenue,
            ROUND(AVG(total_amount), 2) AS avg_order_value
        FROM ORDERS
        GROUP BY status;
    r c%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Orders By Status ===');
    OPEN c;
    LOOP
        FETCH c INTO r;
        EXIT WHEN c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.status, 12) ||
            ' | Count: '   || r.order_count ||
            ' | Revenue: ' || r.total_revenue ||
            ' | Avg: '     || r.avg_order_value
        );
    END LOOP;
    CLOSE c;
END report_orders_by_status;
/

EXEC report_orders_by_status;


-- =============================================================================
-- STORED PROCEDURES
-- =============================================================================

-- 1. Add new employee
CREATE OR REPLACE PROCEDURE add_employee (
    p_manager_id  EMPLOYEES.manager_id%TYPE,
    p_fname       EMPLOYEES.first_name%TYPE,
    p_lname       EMPLOYEES.last_name%TYPE,
    p_role        EMPLOYEES.role%TYPE,
    p_dept        EMPLOYEES.department%TYPE,
    p_salary      EMPLOYEES.salary%TYPE,
    p_hire_date   EMPLOYEES.hire_date%TYPE
) AS
BEGIN
    INSERT INTO EMPLOYEES (
        employee_id, manager_id, first_name, last_name,
        role, department, salary, hire_date
    ) VALUES (
        Emp_Id_Seq.NEXTVAL, p_manager_id, p_fname, p_lname,
        p_role, p_dept, p_salary, p_hire_date
    );
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Employee ' || p_fname || ' ' || p_lname || ' added successfully.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error adding employee: ' || SQLERRM);
        RAISE;
END add_employee;
/

-- EXECUTE add_employee
BEGIN
    add_employee(
        p_manager_id => 1,
        p_fname      => 'Mohamed',
        p_lname      => 'Sayed',
        p_role       => 'Software Engineer',
        p_dept       => 'IT',
        p_salary     => 10000,
        p_hire_date  => SYSDATE
    );
END;
/


-- 2. Add new product
CREATE OR REPLACE PROCEDURE add_product (
    p_category_id  PRODUCTS.category_id%TYPE,
    p_name         PRODUCTS.name%TYPE,
    p_base_price   PRODUCTS.base_price%TYPE,
    p_is_active    PRODUCTS.is_active%TYPE DEFAULT 1
) AS
BEGIN
    INSERT INTO PRODUCTS (product_id, category_id, name, base_price, is_active)
    VALUES (products_Id_Seq.NEXTVAL, p_category_id, p_name, p_base_price, p_is_active);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Product "' || p_name || '" added successfully.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error adding product: ' || SQLERRM);
        RAISE;
END add_product;
/

-- EXECUTE add_product  -- FIX: added missing / and removed quotes from numeric args
BEGIN
    add_product(
        p_category_id => 1,
        p_name        => 'Iphone',
        p_base_price  => 80000,
        p_is_active   => 1
    );
END;
/


-- 3. Place order
CREATE OR REPLACE PROCEDURE place_order (
    p_customer_id   ORDERS.customer_id%TYPE,
    p_total_amount  ORDERS.total_amount%TYPE,
    p_order_id      OUT ORDERS.order_id%TYPE
) AS
BEGIN
    p_order_id := orders_Id_Seq.NEXTVAL;
    INSERT INTO ORDERS (order_id, customer_id, status, total_amount, placed_at)
    VALUES (p_order_id, p_customer_id, 'pending', p_total_amount, SYSTIMESTAMP);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Order ' || p_order_id || ' placed for customer ' || p_customer_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error placing order: ' || SQLERRM);
        RAISE;
END place_order;
/

-- EXECUTE place_order
DECLARE
    v_order_id ORDERS.order_id%TYPE;
BEGIN
    place_order(
        p_customer_id  => 1,
        p_total_amount => 5000,
        p_order_id     => v_order_id
    );
    DBMS_OUTPUT.PUT_LINE('New Order ID = ' || v_order_id);
END;
/


-- 4. Update order status and log the handler action
CREATE OR REPLACE PROCEDURE update_order_status (
    p_order_id    ORDER_HANDLERS.order_id%TYPE,
    p_employee_id ORDER_HANDLERS.employee_id%TYPE,
    p_new_status  ORDERS.status%TYPE,
    p_action      ORDER_HANDLERS.action%TYPE,
    p_notes       ORDER_HANDLERS.notes%TYPE DEFAULT NULL
) AS
BEGIN
    UPDATE ORDERS
    SET    status = p_new_status
    WHERE  order_id = p_order_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Order ' || p_order_id || ' not found.');
    END IF;

    INSERT INTO ORDER_HANDLERS (handler_id, order_id, employee_id, action, handled_at, notes)
    VALUES (Order_handlers_Id_Seq.NEXTVAL, p_order_id, p_employee_id, p_action, SYSTIMESTAMP, p_notes);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Order ' || p_order_id || ' updated to "' || p_new_status || '".');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error updating order: ' || SQLERRM);
        RAISE;
END update_order_status;
/

-- EXECUTE update_order_status  -- FIX: removed empty DECLARE
BEGIN
    update_order_status(
        p_order_id    => 105,
        p_employee_id => 8,
        p_new_status  => 'shipped',
        p_action      => 'STATUS UPDATE',
        p_notes       => 'Order shipped successfully'
    );
END;
/


-- 5. Add supplier
CREATE OR REPLACE PROCEDURE add_supplier (
    p_company_name  SUPPLIERS.company_name%TYPE,
    p_country       SUPPLIERS.country%TYPE
) AS
BEGIN
    INSERT INTO SUPPLIERS (supplier_id, company_name, country)
    VALUES (suppliers_Id_Seq.NEXTVAL, p_company_name, p_country);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Supplier "' || p_company_name || '" added.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error adding supplier: ' || SQLERRM);
        RAISE;
END add_supplier;
/

-- EXECUTE add_supplier  -- FIX: lowercase p_ prefix to match parameter names
BEGIN
    add_supplier(
        p_company_name => 'ProParts Inc',
        p_country      => 'USA'
    );
END;
/


-- 6. Assign product manager
CREATE OR REPLACE PROCEDURE assign_product_manager (
    p_product_id   PRODUCT_MANAGERS.product_id%TYPE,
    p_employee_id  PRODUCT_MANAGERS.employee_id%TYPE,
    p_from_date    PRODUCT_MANAGERS.assigned_from%TYPE DEFAULT SYSDATE
) AS
BEGIN
    -- Deactivate any current active manager for this product
    UPDATE PRODUCT_MANAGERS
    SET    is_active      = 0,
           assigned_until = p_from_date - 1
    WHERE  product_id = p_product_id
      AND  is_active  = 1;

    -- Insert new assignment
    INSERT INTO PRODUCT_MANAGERS (pm_id, product_id, employee_id, assigned_from, assigned_until, is_active)
    VALUES (product_managers_Id_Seq.NEXTVAL, p_product_id, p_employee_id, p_from_date, NULL, 1);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Employee ' || p_employee_id || ' assigned to product ' || p_product_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error assigning manager: ' || SQLERRM);
        RAISE;
END assign_product_manager;
/

-- EXECUTE assign_product_manager
BEGIN
    assign_product_manager(
        p_product_id  => 1,
        p_employee_id => 8,
        p_from_date   => SYSDATE
    );
END;
/


-- 7. Write application log with optional employee link
CREATE OR REPLACE PROCEDURE write_log (
    p_level       LOGS.log_level%TYPE,
    p_source      LOGS.source%TYPE,
    p_message     LOGS.message%TYPE,
    p_employee_id EMPLOYEE_LOGS.employee_id%TYPE DEFAULT NULL,
    p_context     EMPLOYEE_LOGS.context%TYPE     DEFAULT NULL
) AS
    v_log_id LOGS.log_id%TYPE;
BEGIN
    v_log_id := LOG_Id_Seq.NEXTVAL;

    INSERT INTO LOGS (log_id, log_time, log_level, source, message)
    VALUES (v_log_id, SYSTIMESTAMP, p_level, p_source, p_message);

    IF p_employee_id IS NOT NULL THEN
        INSERT INTO EMPLOYEE_LOGS (el_id, log_id, employee_id, context, created_at)
        VALUES (EMP_LOG_Id_Seq.NEXTVAL, v_log_id, p_employee_id, p_context, SYSTIMESTAMP);
    END IF;

    COMMIT;
END write_log;
/

-- EXECUTE write_log
BEGIN
    write_log(
        p_level   => 'INFO',
        p_source  => 'ORDER_SYSTEM',
        p_message => 'Order processed successfully'
    );
END;
/







