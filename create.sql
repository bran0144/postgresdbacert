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

