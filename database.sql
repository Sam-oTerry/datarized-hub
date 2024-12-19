-- Create the database
CREATE DATABASE datarized_hub;
USE datarized_hub;

-- Users table
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    gender ENUM('Male', 'Female', 'Other'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Programs table
CREATE TABLE programs (
    program_id INT PRIMARY KEY AUTO_INCREMENT,
    program_name VARCHAR(100) NOT NULL,
    description TEXT,
    duration VARCHAR(50),
    fee DECIMAL(10, 2),
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Enrollments table
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    program_id INT,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Approved', 'Rejected', 'Completed') DEFAULT 'Pending',
    education_level VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (program_id) REFERENCES programs(program_id)
);

-- Documents table
CREATE TABLE documents (
    document_id INT PRIMARY KEY AUTO_INCREMENT,
    enrollment_id INT,
    document_type VARCHAR(50),
    file_name VARCHAR(255),
    file_path VARCHAR(255),
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id)
);

-- Payments table
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    enrollment_id INT,
    amount DECIMAL(10, 2),
    payment_method ENUM('Credit Card', 'Bank Transfer'),
    payment_status ENUM('Pending', 'Completed', 'Failed') DEFAULT 'Pending',
    transaction_id VARCHAR(100),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id)
);

-- Contact Messages table
CREATE TABLE contact_messages (
    message_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100),
    subject VARCHAR(200),
    message TEXT,
    status ENUM('New', 'Read', 'Replied') DEFAULT 'New',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Admin Users table
CREATE TABLE admin_users (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('Admin', 'Staff') DEFAULT 'Staff',
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Program Categories table
CREATE TABLE program_categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add category_id to programs table
ALTER TABLE programs
ADD COLUMN category_id INT,
ADD FOREIGN KEY (category_id) REFERENCES program_categories(category_id);

-- Insert sample program categories
INSERT INTO program_categories (category_name, description) VALUES
('Data Analytics', 'Courses related to data analysis and visualization'),
('Machine Learning', 'AI and machine learning programs'),
('Cloud Computing', 'Cloud infrastructure and services courses'),
('Big Data', 'Big data processing and analytics programs');

-- Insert sample programs
INSERT INTO programs (program_name, description, duration, fee, category_id) VALUES
('Data Analytics Fundamentals', 'Introduction to data analysis using modern tools', '3 months', 999.99, 1),
('Machine Learning Basics', 'Learn the basics of ML and AI', '4 months', 1299.99, 2),
('AWS Cloud Practitioner', 'Get started with AWS cloud services', '2 months', 799.99, 3),
('Hadoop Essentials', 'Learn big data processing with Hadoop', '3 months', 999.99, 4);

-- Create indexes for better performance
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_enrollment_status ON enrollments(status);
CREATE INDEX idx_payment_status ON payments(payment_status);
CREATE INDEX idx_program_status ON programs(status);

-- Create view for active enrollments
CREATE VIEW active_enrollments AS
SELECT 
    e.enrollment_id,
    u.full_name,
    u.email,
    p.program_name,
    e.enrollment_date,
    e.status,
    pay.payment_status
FROM enrollments e
JOIN users u ON e.user_id = u.user_id
JOIN programs p ON e.program_id = p.program_id
LEFT JOIN payments pay ON e.enrollment_id = pay.enrollment_id
WHERE e.status != 'Completed'; 