SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- ====================================================================
-- He thong Quan ly Phong Gym / Fitness - Database Schema
-- De tai 23 - Trien khai va Quan tri He thong Phan mem
-- Sinh vien: Nguyen Duc Tuyen - MSSV: DTC245200566
-- ====================================================================

CREATE DATABASE IF NOT EXISTS gym_db 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE gym_db;

-- Xoa bang cu theo thu tu rang buoc khoa ngoai
DROP TABLE IF EXISTS schedules;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS trainers;
DROP TABLE IF EXISTS packages;

-- 1. Bang Goi tap (packages)
CREATE TABLE packages (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL DEFAULT 'Gym',
    duration_months INT UNSIGNED NOT NULL DEFAULT 1,
    price DECIMAL(12, 0) NOT NULL DEFAULT 0,
    description TEXT,
    features TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Bang Huan luyen vien (trainers)
CREATE TABLE trainers (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100),
    specialty VARCHAR(100) NOT NULL,
    experience_years INT UNSIGNED NOT NULL DEFAULT 1,
    bio TEXT,
    avatar_url VARCHAR(255),
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Bang Hoi vien (members)
CREATE TABLE members (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100),
    gender ENUM('male', 'female', 'other') NOT NULL DEFAULT 'other',
    date_of_birth DATE,
    package_id INT UNSIGNED NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('active', 'expired', 'pending') NOT NULL DEFAULT 'active',
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_members_package 
        FOREIGN KEY (package_id) REFERENCES packages(id) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_members_phone (phone),
    INDEX idx_members_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Bang Lich tap / Dat lich (schedules)
CREATE TABLE schedules (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    member_id INT UNSIGNED NOT NULL,
    trainer_id INT UNSIGNED NULL,
    session_date DATE NOT NULL,
    time_slot VARCHAR(50) NOT NULL,
    workout_type VARCHAR(100) NOT NULL DEFAULT 'Tap ca nhan',
    status ENUM('scheduled', 'completed', 'cancelled') NOT NULL DEFAULT 'scheduled',
    notes VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_schedules_member 
        FOREIGN KEY (member_id) REFERENCES members(id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_schedules_trainer 
        FOREIGN KEY (trainer_id) REFERENCES trainers(id) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_schedules_date (session_date),
    INDEX idx_schedules_member (member_id),
    INDEX idx_schedules_trainer (trainer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
