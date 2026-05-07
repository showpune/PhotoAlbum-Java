-- Migrated from Oracle to PostgreSQL according to SQL check item 1: Use lowercase for identifiers, uppercase for SQL keywords.
-- Migrated from Oracle to PostgreSQL according to SQL check item 9999: Migrate Oracle-specific verification queries to PostgreSQL.
-- Verification script to check if photoalbum user exists in PostgreSQL

-- Check if user exists
SELECT usename, usesuper, usecreatedb, usecreaterole
FROM pg_user
WHERE usename = 'photoalbum';

-- Show granted privileges on the database
SELECT grantee, privilege_type, table_catalog
FROM information_schema.role_table_grants
WHERE grantee = 'photoalbum'
LIMIT 10;
