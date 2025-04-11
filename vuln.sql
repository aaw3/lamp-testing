-- Database setup for a vulnerable user authentication system
CREATE DATABASE IF NOT EXISTS vulnerable_app;
USE vulnerable_app;

-- Create users table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    is_admin TINYINT(1) DEFAULT 0
);

-- Insert sample data
INSERT INTO users (username, password, email, is_admin) VALUES
('admin', 'supersecret123', 'admin@example.com', 1),
('john_doe', 'password123', 'john@example.com', 0),
('jane_smith', 'letmein', 'jane@example.com', 0);

-- Vulnerable stored procedure for user login
DELIMITER //
CREATE PROCEDURE vulnerable_login(IN p_username VARCHAR(50), IN p_password VARCHAR(50))
BEGIN
    SET @sql = CONCAT('SELECT * FROM users WHERE username = ''', p_username, ''' AND password = ''', p_password, '''');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

-- Another vulnerable query example (direct concatenation)
CREATE PROCEDURE search_users(IN search_term VARCHAR(100))
BEGIN
    SET @query = CONCAT('SELECT * FROM users WHERE username LIKE ''%', search_term, '%'' OR email LIKE ''%', search_term, '%''');
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

-- Vulnerable function to change email
DELIMITER //
CREATE FUNCTION change_email(p_user_id INT, p_new_email VARCHAR(100)) RETURNS VARCHAR(100)
BEGIN
    SET @sql = CONCAT('UPDATE users SET email = ''', p_new_email, ''' WHERE id = ', p_user_id);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    RETURN 'Email updated';
END //
DELIMITER ;

-- Example of how these vulnerabilities could be exploited:
-- For the login procedure:
-- CALL vulnerable_login('admin', 'wrongpass' OR '1'='1'); -- Would bypass authentication
--
-- For the search_users procedure:
-- CALL search_users(''' OR 1=1; --'); -- Would return all users
--
-- For the change_email function:
-- SELECT change_email(1, 'hacker@evil.com'' WHERE username=''admin''; --'); -- Would change admin's email
