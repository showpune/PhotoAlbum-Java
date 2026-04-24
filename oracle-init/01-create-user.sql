-- Migrated from Oracle to PostgreSQL according to SQL check item 1: Use lowercase for identifiers, uppercase for SQL keywords.
-- Migrated from Oracle to PostgreSQL according to SQL check item 9999: Migrate Oracle-specific user creation syntax to PostgreSQL.
-- This script creates the photoalbum user and grants necessary privileges in PostgreSQL

-- Create photoalbum role/user with login
CREATE USER photoalbum WITH PASSWORD 'photoalbum';

-- Grant connection privilege to the database
GRANT CONNECT ON DATABASE photoalbum TO photoalbum;

-- Grant schema usage and object privileges
GRANT USAGE ON SCHEMA public TO photoalbum;

-- Grant table and sequence privileges
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO photoalbum;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO photoalbum;

-- Ensure future tables/sequences are also accessible
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO photoalbum;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO photoalbum;
