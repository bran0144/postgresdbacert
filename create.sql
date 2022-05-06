-- Postgres
-- systems components are objects
-- Db is a top level object
CREATE DATABASE db_example;

-- db names must start with a letter or _, no numbers
-- tables are where data actually lives
-- varaibles number of rows
-- fixed number of columns (can be altered later)
-- TABLES
-- set of rows and columns

CREATE TABLE table_name (
    column1_name column1_datetype [col1_constraints],
    column2_name column2_datetype [col2_constraints]
);

CREATE TABLE school (
    id serial PRIMARY KEY,
    name TEXT NOT NULL,
    mascot_name TEXT
);

-- Exercises:

-- Define the business_type table below
CREATE TABLE business_type (
	id serial PRIMARY KEY,
  	description TEXT NOT NULL
);

-- Define the applicant table below
CREATE TABLE applicant (
	id serial PRIMARY KEY,
  	name TEXT NOT NULL,
  	zip_code CHAR(5) NOT NULL,
  	business_type_id INTEGER references business_type(id)
);

-- Schema - named container for tables
-- provides db users with separate environments
-- could provide each user with a replica of the production db
-- can be organized by business unit
-- public is the default schema
-- access the table within would be public.topic
CREATE SCHEMA division1;

CREATE TABLE division1.school (
    id serial PRIMARY KEY,
    name TEXT NOT NULL,
    mascot_name TEXT,
    num_scholarships INTEGER DEFAULT 0
);

-- Exercises:

-- Create a table named 'bank' in the 'loan_504' schema
CREATE TABLE loan_504.bank (
    id serial PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Create a table named 'bank' in the 'loan_7a' schema
CREATE TABLE loan_7a.bank (
    id serial PRIMARY KEY,
    name VARCHAR (100) NOT NULL,
  	express_provider BOOLEAN
);

-- Create a table named 'borrower' in the 'loan_504' schema
CREATE TABLE loan_504.borrower (
    id serial PRIMARY KEY,
    full_name VARCHAR (100) NOT NULL
);

-- Create a table named 'borrower' in the 'loan_7a' schema
CREATE TABLE loan_7a.borrower (
    id serial PRIMARY KEY,
    full_name VARCHAR (100) NOT NULL,
  	individual BOOLEAN
);

-- Data types
-- Text, Numeric, temporal, Boolean, Geometric, Binary, Monetary

-- Exercises:
-- Create the project table
CREATE TABLE project (
	-- Unique identifier for projects
	id SERIAL PRIMARY KEY,
    -- Whether or not project is franchise opportunity
	is_franchise BOOLEAN DEFAULT FALSE,
	-- Franchise name if project is franchise opportunity
    franchise_name TEXT DEFAULT NULL,
    -- State where project will reside
    project_state TEXT,
    -- County in state where project will reside
    project_county TEXT,
    -- District number where project will reside
    congressional_district NUMERIC,
    -- Amount of jobs projected to be created
    jobs_supported NUMERIC
);

-- Defining text columns
-- Text in Postgres: TEXT, VARCHAR(N), CHAR(N)
-- Text - represents strings of variable length
    -- length can be unlimited (based on disc space)
    -- good for text of unknown length
-- VARCHAR(N) - strings can be variable and unlimited, but you can place some restrictions
    -- N is maximum length - can be shorter, but if you try to insert longer, you will get an error
-- CHAR(N) - do not vary in length
    -- if inserted shorter, strings are right padded with spaces

-- Exercises:
-- Create the appeal table
CREATE TABLE appeal (
    -- Specify the unique identifier column
	id SERIAL PRIMARY KEY,
    -- Define a column for holding the text of the appeals
    content TEXT NOT NULL
);

-- Numeric values
-- SMALLINT - -32768 to 32767
-- INTEGER - -2137483648 to 2147483647
-- BIGINT - -9223372036854775808 to 9223372036854775807
-- SERIAL - only positive autoincrementing integer 1 to 2147483647
-- BIGSERIAL - large autoincirementing integer 1 to 9223372036854775807
-- DECIMAL(8,2) - takes precision, scale
-- DECIMAL and NUMERIC types are interchangeable
    -- 131072 digits before decnimal, 16383 digits after decimal
-- REAL - 6 decimal digits precision
-- DOUBLE PRECISION - 15 digits precision

-- Exercises:

-- Create the client table
CREATE TABLE client (
	-- Unique identifier column
	id SERIAL PRIMARY KEY,
    -- Name of the company
    name VARCHAR(50),
	-- Specify a text data type for variable length urls
	site_url VARCHAR(50),
    -- Number of employees (max of 1500 for small business)
    num_employees SMALLINT,
    -- Number of customers
    num_customers INTEGER
);

-- Create the campaign table
CREATE TABLE campaign (
  -- Unique identifier column
  id SERIAL PRIMARY KEY,
  -- Campaign name column
  name VARCHAR(50),
  -- The campaign's budget
  budget NUMERIC(7, 2),
  -- The duration of campaign in days
  num_days SMALLINT DEFAULT 30,
  -- The number of new applications desired
  goal_amount INTEGER DEFAULT 100,
  -- The number of received applications
  num_applications INTEGER DEFAULT 0
);

-- BOOLEAN and TEMPORAL
    -- BOOLEAN - true, false, null state 
        -- default is false, but can be specified
    -- TIMESTAMP - date and time
    -- DATE - only date, no time
    -- TIME - only time, no date

-- Exercises:

CREATE TABLE appeal (
	id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
  	-- Add received_on column
    received_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  	
  	-- Add approved_on_appeal column
  	approved_on_appeal BOOLEAN DEFAULT NULL,
  	
  	-- Add reviewed column
    reviewed DATE
);

-- Create the loan table
CREATE TABLE loan (
    borrower_id INTEGER REFERENCES borrower(id),
    bank_id INTEGER REFERENCES bank(id),
  	-- 'approval_date': the loan approval date
    approval_date DATE NOT NULL DEFAULT CURRENT_DATE,
    -- 'gross_approval': amounts up to $5,000,000.00
  	gross_approval DECIMAL(9, 2) NOT NULL,
  	-- 'term_in_months': total # of months for repayment
    term_in_months SMALLINT NOT NULL,
    -- 'revolver_status': TRUE for revolving line of credit
  	revolver_status BOOLEAN NOT NULL DEFAULT FALSE,
  	initial_interest_rate DECIMAL(4, 2) NOT NULL
);

-- Data Normalization
-- Redundant data can be problematic
-- concerned with data consistency, data organization

  -- Define zip_code column
  zip_code CHAR(5) PRIMARY KEY,
  -- Define city column
  city VARCHAR(50) NOT NULL,
  -- Define state column
  state CHAR(2) NOT NULL
);

CREATE TABLE borrower (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  approved BOOLEAN DEFAULT NULL,
  
  -- Remove zip_code column (defined below)
  -- zip_code CHAR(5) NOT NULL,
  
  -- Remove city column (defined below)
  -- city VARCHAR(50) NOT NULL,
  
  -- Remove state column (defined below)
  -- state CHAR(2) NOT NULL,
  
  -- Add column referencing place table
  place_id CHAR(5) REFERENCES place(zip_code)
);

-- Create the contact table
CREATE TABLE contact (
  	-- Define the id primary key column
	id SERIAL PRIMARY KEY,
  	-- Define the name column
  	name VARCHAR(50) NOT NULL,
    -- Define the email column
  	email VARCHAR(50) NOT NULL
);

-- Add contact_id to the client table
ALTER TABLE client ADD contact_id INTEGER NOT NULL;

-- Add a FOREIGN KEY constraint to the client table
ALTER TABLE client ADD CONSTRAINT fk_c_id FOREIGN KEY (contact_id) REFERENCES contact(id);

-- Exercises:
-- Create the test_grade table
CREATE TABLE test_grade (
    -- Include a column for the student id
	student_id INTEGER NOT NULL,
  
  	-- Include a column for the course name
    course_name VARCHAR(50) NOT NULL,
  
  	-- Add a column to capture a single test grade
    grade NUMERIC NOT NULL
);

-- Exercises:

-- Create the course table
CREATE TABLE course (
    -- Add a column for the course table
	id SERIAL PRIMARY KEY,
  
  	-- Add a column for the course table
  	name VARCHAR(50) NOT NULL,
  
  	-- Add a column for the course table
  	max_students SMALLINT
);

CREATE TABLE ingredient (
  -- Add PRIMARY KEY for table
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL
);

CREATE TABLE meal (
    -- Make id a PRIMARY KEY
	id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,

	-- Remove the 2 columns (below) that do not satisfy 2NF
  	-- ingredients VARCHAR(150), -- comma separated list
    avg_student_rating NUMERIC,
    -- date_served DATE,
    total_calories SMALLINT NOT NULL
);

CREATE TABLE meal_date (
    -- Define a column referencing the meal table
  	meal_id INTEGER REFERENCES meal(id),
    date_served DATE NOT NULL
);

CREATE TABLE meal_ingredient (
  	meal_id INTEGER REFERENCES meal(id),
  
    -- Define a column referencing the ingredient table
    ingredient_id INTEGER REFERENCES ingredient(id)
);

-- Complete the definition of the table for zip codes
CREATE TABLE zip (
	code INTEGER PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL
);

-- Complete the definition of the "zip_code" column
CREATE TABLE school (
	id serial PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    street_address VARCHAR(100) NOT NULL,
    zip_code INTEGER REFERENCES zip(code)
);

-- Add new columns to the borrower table
ALTER TABLE borrower
ADD COLUMN first_name VARCHAR (50) NOT NULL,
ADD COLUMN last_name VARCHAR (50) NOT NULL;

-- Remove column from borrower table to satisfy 1NF
ALTER TABLE borrower
DROP COLUMN full_name;


-- Add columns to the borrower table
ALTER TABLE borrower
ADD COLUMN first_name VARCHAR (50) NOT NULL,
ADD COLUMN last_name VARCHAR (50) NOT NULL;

-- Remove column from borrower table to satisfy 1NF
ALTER TABLE borrower
DROP COLUMN full_name;

-- Add a new column named 'zip' to the 'bank' table 
ALTER TABLE bank
ADD COLUMN zip VARCHAR(10) NOT NULL;

-- Remove corresponding column from 'loan' to satisfy 2NF
ALTER TABLE loan
DROP COLUMN bank_zip;

-- Add columns to the borrower table
ALTER TABLE borrower
ADD COLUMN first_name VARCHAR (50) NOT NULL,
ADD COLUMN last_name VARCHAR (50) NOT NULL;

-- Remove column from borrower table to satisfy 1NF
ALTER TABLE borrower
DROP COLUMN full_name;

-- Add a new column called 'zip' to the 'bank' table
ALTER TABLE bank
ADD COLUMN zip VARCHAR(10) NOT NULL;

-- Remove a corresponding column from 'loan' to satisfy 2NF
ALTER TABLE loan
DROP COLUMN bank_zip;

-- Define 'program' table with max amount for each program
CREATE TABLE program (
  	id serial PRIMARY KEY,
  	description text NOT NULL,
  	max_amount DECIMAL(9,2) NOT NULL
);

-- Add columns to the borrower table
ALTER TABLE borrower
ADD COLUMN first_name VARCHAR (50) NOT NULL,
ADD COLUMN last_name VARCHAR (50) NOT NULL;

-- Remove column from borrower table to satisfy 1NF
ALTER TABLE borrower
DROP COLUMN full_name;

-- Add a new column called 'zip' to the 'bank' table 
ALTER TABLE bank
ADD COLUMN zip VARCHAR(10) NOT NULL;

-- Remove a corresponding column from 'loan' to satisfy 2NF
ALTER TABLE loan
DROP COLUMN bank_zip;

-- Define 'program' table with max amount for each program
CREATE TABLE program (
  	id serial PRIMARY KEY,
  	description text NOT NULL,
  	max_amount DECIMAL(9,2) NOT NULL
);

-- Alter the 'loan' table to satisfy 3NF
ALTER TABLE loan
ADD COLUMN program_id INTEGER REFERENCES program (id), 
DROP COLUMN max_amount,
DROP COLUMN program;

-- Access Control

-- Create sgold with a temporary password
CREATE USER sgold WITH PASSWORD 'changeme';

-- Update the password for sgold
ALTER USER sgold WITH PASSWORD 'kxqr478-?egH%&FQ';

-- Access privileges

GRANT p ON obj TO grantee;

GRANT INSERT ON account TO fin;
-- Some privileges cannot be granted, and only given to superuser

-- Provide sgold with the required table privileges
ALTER TABLE loan OWNER TO sgold;

-- hierarchical control with schemas
CREATE SCHEMA me;
CREATE TABLE me.account (...);
CREATE USER better_half WITH PASSWORD 'changeme';
GRANT USAGE ON SCHEMA public TO better_half;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO better_half;

CREATE GROUP family;
GRANT USAGE ON SCHEMA public to family;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO family;
ALTER GROUP family ADD USER fin;

-- Exercises:
-- Create a user account for Ronald Jones
CREATE USER rjones WITH PASSWORD 'changeme';

-- Create a user account for Kim Lopez
CREATE USER klopez WITH PASSWORD 'changeme';

-- Create a user account for Jessica Chen
CREATE USER jchen WITH PASSWORD 'changeme';

-- Create the dev_team group
CREATE GROUP dev_team;

-- Grant privileges to dev_team group on loan table
GRANT INSERT, UPDATE, DELETE, SELECT ON loan TO dev_team;

-- Add the new user accounts to the dev_team group
ALTER GROUP dev_team ADD USER rjones, klopez, jchen;

-- Create the development schema
CREATE SCHEMA development;

-- Grant usage privilege on new schema to dev_team
GRANT USAGE ON SCHEMA development TO dev_team;

-- Create a loan table in the development schema
CREATE TABLE development.loan (
	borrower_id INTEGER,
	bank_id INTEGER,
	approval_date DATE,
	program text NOT NULL,
	max_amount DECIMAL(9,2) NOT NULL,
	gross_approval DECIMAL(9, 2) NOT NULL,
	term_in_months SMALLINT NOT NULL,
	revolver_status BOOLEAN NOT NULL,
	bank_zip VARCHAR(10) NOT NULL,
	initial_interest_rate DECIMAL(4, 2) NOT NULL
);

-- Grant privileges on development schema
GRANT INSERT, UPDATE, DELETE, SELECT ON ALL TABLES IN SCHEMA development TO dev_team;

-- rolling back privleges
REVOKE ALL PRIVILEGES ON finances.* FROM cousin;
GRANT SELECT ON finances.* FROM cousin;

-- Exercises:
-- Remove the specified privileges for Kim
REVOKE INSERT, UPDATE, DELETE ON development.loan FROM klopez;

-- Create the project_management group
CREATE GROUP project_management;

-- Grant project_management SELECT privilege
GRANT SELECT ON loan TO project_management;

-- Add Kim's user to project_management group
ALTER GROUP project_management ADD USER klopez;

-- Remove Kim's user from dev_team group
REVOKE dev_team FROM klopez;

-- Create the new analysis schema
CREATE SCHEMA analysis;

-- Create a table unapproved loan under the analysis schema
CREATE TABLE analysis.unapproved_loan (
    id serial PRIMARY KEY,
    loan_id INTEGER REFERENCES loan(id),
    description TEXT NOT NULL
);

-- Create 'data_scientist' user with password 'changeme'
CREATE USER data_scientist WITH password 'changeme';

-- Give 'data_scientist' ability to use 'analysis' schema
GRANT USAGE ON SCHEMA analysis TO data_scientist;

-- Grant read-only access to table for 'data_scientist' user
GRANT SELECT ON analysis.unapproved_loan TO data_scientist;

