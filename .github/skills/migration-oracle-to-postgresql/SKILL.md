---
name: migration-oracle-to-postgresql
description: Migrate from Oracle DB to PostgreSQL
---

# oracle-to-postgresql

## Overview

Your task is to migrate from Oracle DB to PostgreSQL.
Below are the specific instructions for different migration tasks, please follow the instructions to complete the migration. 

## Knowledge Base Content

* KB ID: microsoft://database-tasks/oracle-to-postgresql/java.formula
* Title: Migrate Java code from Oracle to PostgreSQL
* Description: Update Java files for Oracle to PostgreSQL migration
* Content: 
### Search code
Search files from workspace using below patterns:
- Glob pattern to find files: `**/*.java`
- Regex pattern to find code lines: `/VARCHAR2|CLOB|BLOB|SYSDATE|ROWNUM|ROWID|NOCOPY|TABLE|PROCEDURE|CONNECT BY\s+|START WITH|BULK COLLECT|FORALL|PL\/SQL|NOCACHE|DUAL|PRAGMA|JOIN\s+|CREATE\s+|ALTER\s+|SELECT\s+|INSERT\s+|UPDATE\s+|java\.sql\.Array|@Table|@Column|@NamedNativeQuery|@SequenceGenerator|@GeneratedValue|Oracle/i`
> you could use tools to search code whatever if possible.
### Instruction


Your task is to migrate Java code from Oracle database usage to PostgreSQL compatibility.

Follow these steps:
1. Locate the `coding_notes.md` file:
  - If `coding_notes.md` is already provided in the prompt or context, use it and skip to step 2.
  - Otherwise, search for `coding_notes.md` in the migration project workspace using the pattern `.github/postgres-migrations/*/results/application_guidance/coding_notes.md`.
  - If multiple files are found, compare their modification timestamps and use the most recently modified file.
  - If no `coding_notes.md` file is found, proceed to step 3 using only the formula checklist.
2. If `coding_notes.md` is found, read its entire content before listing files that need to be migrated.
  - The file contains project-specific migration guidance and rules that must be read before listing files that need to be migrated.
  - The file may exceed 1,000 lines; ensure you read it completely from start to end.
3. Review the formula checklist items below. **Priority rule**: If any checklist item conflicts with guidance in `coding_notes.md`, follow the `coding_notes.md` instructions instead.
4. Apply each relevant modification to the file.
5. For each change, add a comment to the migrated code that includes the checklist item information. Example:
  ```java
  // Migrated from Oracle to PostgreSQL according to java check item 1: Convert all table and column names from uppercase to lowercase in JPA annotations.
  // Migrated from Oracle to PostgreSQL according to coding notes check item: All object names are lowercased in PostgreSQL (unless quoted explicitly).
  ```

## Formula checklist

Java check item 0: Don't modify the content if it's obviously not related to Oracle based on file names or paths. However, always review imports and annotations (e.g., @SequenceGenerator) to identify Oracle-specific code that may require migration.

Java check item 1: Convert all table and column names from uppercase to lowercase in JPA annotations.
  ```java
  // Before migration (Oracle)
  @Entity
  @Table(name = "ITEMS")
  public class Item {
      @Id
      @Column(name = "ITEM_ID")
      private Long id;
  }

  // After migration (PostgreSQL)
  @Entity
  @Table(name = "items")
  public class Item {
      @Id
      @Column(name = "item_id")
      private Long id;
  }
  ```

Java check item 2: Convert sequence generator names to lowercase in JPA annotations.
  ```java
  // Before migration (Oracle)
  @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "ITEM_SEQ")
  @SequenceGenerator(name = "ITEM_SEQ", sequenceName = "ITEMS_SEQ", allocationSize = 1)

  // After migration (PostgreSQL)
  @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "item_seq")
  @SequenceGenerator(name = "item_seq", sequenceName = "items_seq", allocationSize = 1)
  ```

Java check item 3: Replace Oracle-specific SQL functions with PostgreSQL equivalents. Like RANK() to ROW_NUMBER()
  ```java
  // Before migration (Oracle)
  @NamedNativeQuery(
      name = "Item.findTopItems",
      query = """
          SELECT i.* FROM (
              SELECT i.*,
                     RANK() OVER (PARTITION BY i.CATEGORY_ID ORDER BY i.PRICE DESC) as price_rank
              FROM ITEMS i
          ) i
          WHERE i.price_rank <= :topN
          ORDER BY i.CATEGORY_ID, i.price_rank
      """
  )

  // After migration (PostgreSQL)
  @NamedNativeQuery(
      name = "Item.findTopItems",
      query = """
          SELECT i.* FROM (
              SELECT i.*,
                     ROW_NUMBER() OVER (PARTITION BY i.category_id ORDER BY i.price DESC) as price_rank
              FROM items i
          ) i
          WHERE i.price_rank <= :topN
          ORDER BY i.category_id, i.price_rank
      """
  )
  ```

Java check item 4: Replace TO_CHAR date functions with EXTRACT in SQL statements.
  ```java
  // Before migration (Oracle)
  @NamedNativeQuery(
      name = "Item.findItemsCreatedInQuarter",
      query = """
          SELECT * FROM ITEMS
          WHERE TO_CHAR(CREATE_DATE, 'Q') = :quarter
          AND TO_CHAR(CREATE_DATE, 'YYYY') = :year
          ORDER BY CREATE_DATE
      """
  )

  // After migration (PostgreSQL)
  @NamedNativeQuery(
      name = "Item.findItemsCreatedInQuarter",
      query = """
          SELECT * FROM items
          WHERE EXTRACT(QUARTER FROM create_date) = CAST(:quarter AS INTEGER)
          AND EXTRACT(YEAR FROM create_date)::text = :year
          ORDER BY create_date
      """
  )
  ```

Java check item 5: Replace TRUNC(date) with DATE_TRUNC('day', date) in SQL.
  ```java
  // Before migration (Oracle)
  "SELECT * FROM EMPLOYEES WHERE TRUNC(HIRE_DATE) BETWEEN TO_DATE(:startDate, 'YYYY-MM-DD') AND TO_DATE(:endDate, 'YYYY-MM-DD')"

  // After migration (PostgreSQL)
  // IMPORTANT: Don't delete other methods like "TO_DATE"
   "SELECT * FROM employees WHERE DATE_TRUNC('day', hire_date) BETWEEN TO_DATE(:startDate, 'YYYY-MM-DD') AND TO_DATE(:endDate, 'YYYY-MM-DD')"
  ```

Java check item 6: In SQL string literals, use lowercase for identifiers (like table and column names) and data type (like varchar), use uppercase for SQL keywords (like SELECT, FROM, WHERE).
  ```java
  // Before migration (Oracle)
  String sql = """
          INSERT INTO EMPLOYEES (
              EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL,
              PHONE_NUMBER, HIRE_DATE, JOB_ID, SALARY,
              COMMISSION_PCT, MANAGER_ID, DEPARTMENT_ID
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      """;

  // After migration (PostgreSQL)
  String sql = """
          INSERT INTO employees (
              employee_id, first_name, last_name, email,
              phone_number, hire_date, job_id, salary,
              commission_pct, manager_id, department_id
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      """;
  ```

Java check item 7: Replace PL/SQL BULK COLLECT and FORALL with standard JDBC batch operations.
  ```java
  // Before migration (Oracle)
  String plsql = """
          DECLARE
              TYPE emp_id_array IS TABLE OF EMPLOYEES.EMPLOYEE_ID%TYPE;
              TYPE salary_array IS TABLE OF EMPLOYEES.SALARY%TYPE;
              l_emp_ids emp_id_array;
              l_salaries salary_array;
              l_increase_pct NUMBER := ?;
          BEGIN
              -- Bulk collect employee IDs and salaries
              SELECT EMPLOYEE_ID, SALARY BULK COLLECT INTO l_emp_ids, l_salaries
              FROM EMPLOYEES
              WHERE EMPLOYEE_ID IN (?, ?, ?);
              -- Use FORALL to update all records in a single operation
              FORALL i IN 1..l_emp_ids.COUNT
                  UPDATE EMPLOYEES
                  SET SALARY = l_salaries(i) * (1 + l_increase_pct)
                  WHERE EMPLOYEE_ID = l_emp_ids(i);
              COMMIT;
          END;
          """;
  jdbcTemplate.update(plsql, params);

  // After migration (PostgreSQL)
  String sql = "UPDATE employees SET salary = salary * (1 + ?) WHERE employee_id = ?";
  List<Object[]> batchArgs = new ArrayList<>();
  for (Long employeeId : employeeIds) {
      batchArgs.add(new Object[] { increasePercent, employeeId });
  }
  jdbcTemplate.batchUpdate(sql, batchArgs);
  ```

Java check item 8: Replace hierarchical CONNECT BY queries with recursive CTEs.
  Example 1:
  ```java
  // Before migration (Oracle)
  String sql = """
          SELECT
              LEVEL as hierarchy_level,
              LPAD(' ', (LEVEL-1)*2, ' ') || e.FIRST_NAME || ' ' || e.LAST_NAME as employee_name,
              e.EMPLOYEE_ID,
              e.JOB_ID,
              e.SALARY,
              e.DEPARTMENT_ID
          FROM
              EMPLOYEES e
          START WITH
              e.EMPLOYEE_ID = ?
          CONNECT BY
              e.MANAGER_ID = PRIOR e.EMPLOYEE_ID
          ORDER SIBLINGS BY
              e.FIRST_NAME, e.LAST_NAME
      """;

  // After migration (PostgreSQL)
  String sql = """
          WITH RECURSIVE emp_hierarchy AS (
              -- Base case: start with the specific employee
              SELECT
                  e.employee_id,
                  e.first_name,
                  e.last_name,
                  e.job_id,
                  e.salary,
                  e.department_id,
                  e.manager_id,
                  1 as hierarchy_level
              FROM employees e
              WHERE e.employee_id = ?

              UNION ALL

              -- Recursive case: find the subordinates of the current employee
              SELECT
                  m.employee_id,
                  m.first_name,
                  m.last_name,
                  m.job_id,
                  m.salary,
                  m.department_id,
                  m.manager_id,
                  eh.hierarchy_level + 1
              FROM employees m
              JOIN emp_hierarchy eh ON m.manager_id = eh.employee_id
          )
          SELECT
              hierarchy_level,
              LPAD(' ', (hierarchy_level-1)*2, ' ') || first_name || ' ' || last_name as employee_name,
              employee_id,
              job_id,
              salary,
              department_id
          FROM emp_hierarchy
          ORDER BY hierarchy_level, first_name, last_name
          """;
  ```

  Example 2:
  ```java
  // Before migration (Oracle)
  String sql = """
              SELECT
                  e.EMPLOYEE_ID,
                  e.FIRST_NAME || ' ' || e.LAST_NAME as employee_name,
                  SYS_CONNECT_BY_PATH(e.FIRST_NAME || ' ' || e.LAST_NAME, ' -> ') as hierarchy_path,
                  CONNECT_BY_ROOT (e.FIRST_NAME || ' ' || e.LAST_NAME) as top_manager,
                  LEVEL as hierarchy_level,
                  CONNECT_BY_ISLEAF as is_leaf
              FROM
                  EMPLOYEES e
              START WITH
                  e.EMPLOYEE_ID = ?
              CONNECT BY
                  e.EMPLOYEE_ID = PRIOR e.MANAGER_ID
              ORDER BY hierarchy_level
          """;

  // After migration (PostgreSQL)
  // Important: "RECURSIVE" in the SQL is necessary.
  String sql = """
          WITH RECURSIVE emp_hierarchy(employee_id, first_name, last_name, manager_id, level_num) AS (
              SELECT employee_id, first_name, last_name, manager_id, 1
              FROM employees
              WHERE employee_id = ?
              UNION ALL
              SELECT e.employee_id, e.first_name, e.last_name, e.manager_id, eh.level_num + 1
              FROM employees e JOIN emp_hierarchy eh ON e.employee_id = eh.manager_id
          )
          SELECT
              employee_id,
              first_name,
              last_name,
              manager_id,
              level_num
          FROM emp_hierarchy
          ORDER BY level_num
      """;
  ```

Java check item 9: Replace MODEL clause with CTEs and UNION ALL queries.
  ```java
  // Before migration (Oracle)
  String sql = """
          SELECT
              DEPARTMENT_ID,
              EMPLOYEE_ID,
              LAST_NAME,
              YEAR,
              PROJECTED_SALARY
          FROM (
               SELECT
                  DEPARTMENT_ID,
                  EMPLOYEE_ID,
                  LAST_NAME,
                  SALARY
              FROM EMPLOYEES
              WHERE DEPARTMENT_ID IS NOT NULL
          )
          MODEL
              PARTITION BY (DEPARTMENT_ID)
              DIMENSION BY (EMPLOYEE_ID, 0 AS YEAR)
              MEASURES (LAST_NAME, SALARY AS PROJECTED_SALARY)
              RULES (
                  PROJECTED_SALARY[FOR EMPLOYEE_ID IN (SELECT EMPLOYEE_ID FROM EMPLOYEES WHERE DEPARTMENT_ID IS NOT NULL), 1] =
                      PROJECTED_SALARY[CV(), 0] * 1.05,
                  PROJECTED_SALARY[FOR EMPLOYEE_ID IN (SELECT EMPLOYEE_ID FROM EMPLOYEES WHERE DEPARTMENT_ID IS NOT NULL), 2] =
                      PROJECTED_SALARY[CV(), 1] * 1.05,
                  PROJECTED_SALARY[FOR EMPLOYEE_ID IN (SELECT EMPLOYEE_ID FROM EMPLOYEES WHERE DEPARTMENT_ID IS NOT NULL), 3] =
                      PROJECTED_SALARY[CV(), 2] * 1.05
              )
          ORDER BY DEPARTMENT_ID, EMPLOYEE_ID, YEAR
      """;

  // After migration (PostgreSQL)
  String sql = """
          WITH base_data AS (
               SELECT
                  department_id,
                  employee_id,
                  last_name,
                  salary
              FROM employees
              WHERE department_id IS NOT NULL
          )
          SELECT
              department_id,
              employee_id,
              last_name,
              0 AS year,
              salary AS projected_salary
          FROM base_data

          UNION ALL

          SELECT
              department_id,
              employee_id,
              last_name,
              1 AS year,
              salary * 1.05 AS projected_salary
          FROM base_data

          UNION ALL

          SELECT
              department_id,
              employee_id,
              last_name,
              2 AS year,
              salary * 1.05 * 1.05 AS projected_salary
          FROM base_data

          UNION ALL

          SELECT
              department_id,
              employee_id,
              last_name,
              3 AS year,
              salary * 1.05 * 1.05 * 1.05 AS projected_salary
          FROM base_data

          ORDER BY department_id, employee_id, year
      """;
  ```

Java check item 10: Replace PIVOT clause with CASE-based conditional aggregations.
  ```java
  // Before migration (Oracle)
  String sql = """
          SELECT * FROM (
              SELECT DEPARTMENT_ID, JOB_ID
              FROM EMPLOYEES
              WHERE DEPARTMENT_ID IS NOT NULL
          )
          PIVOT (
              COUNT(*)
              FOR JOB_ID IN (
                  'IT_PROG' AS IT_PROGRAMMERS,
                  'SA_REP' AS SALES_REPS,
                  'FI_ACCOUNT' AS ACCOUNTANTS,
                  'SA_MAN' AS SALES_MANAGERS
              )
          )
          ORDER BY DEPARTMENT_ID
      """;

  // After migration (PostgreSQL)
  String sql = """
          SELECT
              department_id,
              COUNT(CASE WHEN job_id = 'IT_PROG' THEN 1 END) AS it_programmers,
              COUNT(CASE WHEN job_id = 'SA_REP' THEN 1 END) AS sales_reps,
              COUNT(CASE WHEN job_id = 'FI_ACCOUNT' THEN 1 END) AS accountants,
              COUNT(CASE WHEN job_id = 'SA_MAN' THEN 1 END) AS sales_managers
          FROM
              employees
          WHERE
              department_id IS NOT NULL
          GROUP BY
              department_id
          ORDER BY
              department_id
      """;
  ```

Java check item 11: Replace PIVOT clause with CASE expressions for category counts.
  ```java
  // Before migration (Oracle)
  String sql = """
      SELECT * FROM (
          SELECT DEPARTMENT_ID, CATEGORY_ID
          FROM ITEMS
          WHERE DEPARTMENT_ID IS NOT NULL
      )
      PIVOT (
          COUNT(*)
          FOR CATEGORY_ID IN (
              'TYPE_1' AS TYPE1_COUNT,
              'TYPE_2' AS TYPE2_COUNT,
              'TYPE_3' AS TYPE3_COUNT,
              'TYPE_4' AS TYPE4_COUNT
          )
      )
      ORDER BY DEPARTMENT_ID
  """;

  // After migration (PostgreSQL)
  String sql = """
      SELECT
          department_id,
          COUNT(CASE WHEN category_id = 'TYPE_1' THEN 1 END) AS type1_count,
          COUNT(CASE WHEN category_id = 'TYPE_2' THEN 1 END) AS type2_count,
          COUNT(CASE WHEN category_id = 'TYPE_3' THEN 1 END) AS type3_count,
          COUNT(CASE WHEN category_id = 'TYPE_4' THEN 1 END) AS type4_count
      FROM
          items
      WHERE
          department_id IS NOT NULL
      GROUP BY
          department_id
      ORDER BY
          department_id
  """;
  ```

Java check item 12: Remove schema and package references from SimpleJdbcCall procedures.
  ```java
  // Before migration (Oracle)
  SimpleJdbcCall jdbcCall = new SimpleJdbcCall(dataSource)
          .withSchemaName("TEST")
          .withCatalogName("HR")      // Package name
          .withProcedureName("GET_EMPLOYEE_INFO")
          .declareParameters(
                  new org.springframework.jdbc.core.SqlParameter("p_employee_id", Types.NUMERIC),
                  new org.springframework.jdbc.core.SqlOutParameter("p_result", Types.REF_CURSOR)
          );

  // After migration (PostgreSQL)
  SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
          .withProcedureName("get_employee_info")
          .declareParameters(
                  new org.springframework.jdbc.core.SqlParameter("p_employee_id", Types.NUMERIC),
                  new org.springframework.jdbc.core.SqlOutParameter("p_result", Types.REF_CURSOR)
          );
  ```

Java check item 13: Replace OracleContainer with PostgreSQLContainer in test classes.
  ```java
  // Before migration (Oracle)
  import org.testcontainers.containers.OracleContainer;

  @Testcontainers
  public abstract class AbstractTestBase {
      private static final String ORACLE_IMAGE = "gvenzl/oracle-xe:latest";

      @Container
      protected static final OracleContainer oracleContainer = new OracleContainer(ORACLE_IMAGE)
              .withUsername("test")
              .withPassword("test");

      @DynamicPropertySource
      static void registerOracleProperties(DynamicPropertyRegistry registry) {
          registry.add("spring.datasource.url", oracleContainer::getJdbcUrl);
          registry.add("spring.datasource.username", oracleContainer::getUsername);
          registry.add("spring.datasource.password", oracleContainer::getPassword);
          registry.add("spring.datasource.driver-class-name", () -> "oracle.jdbc.OracleDriver");
      }
  }

  // After migration (PostgreSQL)
  import org.testcontainers.containers.PostgreSQLContainer;

  @Testcontainers
  public abstract class AbstractTestBase {
      private static final String POSTGRES_IMAGE = "postgres:latest";

      @Container
      protected static final PostgreSQLContainer<?> postgresContainer =
          new PostgreSQLContainer<>(POSTGRES_IMAGE)
              .withUsername("test")
              .withPassword("test")
              .withDatabaseName("testdb");

      @DynamicPropertySource
      static void registerPostgresProperties(DynamicPropertyRegistry registry) {
          registry.add("spring.datasource.url", postgresContainer::getJdbcUrl);
          registry.add("spring.datasource.username", postgresContainer::getUsername);
          registry.add("spring.datasource.password", postgresContainer::getPassword);
          registry.add("spring.datasource.driver-class-name", () -> "org.postgresql.Driver");
      }
  }
  ```

Java check item 14: Update SQL script parsers to support dollar-quoted strings and PL/pgSQL syntax.
  ```java
  // Before migration (Oracle - parsing PL/SQL blocks)
  public String[] splitScriptIntoStatements(String script) {
      List<String> statements = new ArrayList<>();
      StringBuilder currentStatement = new StringBuilder();
      boolean inPlSqlBlock = false;

      for (String line : script.split("\n")) {
          if (line.trim().isEmpty() || line.trim().startsWith("--")) {
              continue;
          }

          // Check for standalone slash indicating end of PL/SQL block
          if (line.trim().equals("/")) {
              if (inPlSqlBlock) {
                  statements.add(currentStatement.toString().trim());
                  currentStatement = new StringBuilder();
                  inPlSqlBlock = false;
              }
              continue;
          }

          // Check for potential start of PL/SQL block
          if (!inPlSqlBlock &&
              (line.toUpperCase().contains("CREATE OR REPLACE PROCEDURE") ||
               line.toUpperCase().contains("CREATE OR REPLACE PACKAGE"))) {
              inPlSqlBlock = true;
          }

          currentStatement.append(line).append("\n");

          if (!inPlSqlBlock && line.trim().endsWith(";")) {
              statements.add(currentStatement.toString().trim());
              currentStatement = new StringBuilder();
          }
      }

      return statements.toArray(new String[0]);
  }

  // After migration (PostgreSQL - supporting dollar-quoted strings)
  public String[] splitScriptIntoStatements(String script) {
      List<String> statements = new ArrayList<>();
      StringBuilder currentStatement = new StringBuilder();
      boolean inPlSqlBlock = false;
      boolean inDollarQuotedString = false;
      boolean collectingProcedureOrFunction = false;

      for (String line : script.split("\n")) {
          if (line.trim().isEmpty() || line.trim().startsWith("--")) {
              continue;
          }## Migrate Java code from Oracle to PostgreSQL

Update Java files for Oracle to PostgreSQL migration

### Search code
Search files from workspace using below patterns:
- Glob pattern to find files: `**/*.java`
- Regex pattern to find code lines: `(?i)VARCHAR2|CLOB|BLOB|SYSDATE|ROWNUM|ROWID|NOCOPY|TABLE|PROCEDURE|CONNECT BY\s+|START WITH|BULK COLLECT|FORALL|PL/SQL|NOCACHE|DUAL|PRAGMA|JOIN\s+|CREATE\s+|ALTER\s+|SELECT\s+|INSERT\s+|UPDATE\s+|java\.sql\.Array|@Table|@Column|@NamedNativeQuery|@SequenceGenerator|@GeneratedValue|Oracle`

### Instruction


Your task is to migrate Java code from Oracle database usage to PostgreSQL compatibility.

Follow these steps:
1. Locate the `coding_notes.md` file:
  - If `coding_notes.md` is already provided in the prompt or context, use it and skip to step 2.
  - Otherwise, search for `coding_notes.md` in the migration project workspace using the pattern `.github/postgres-migrations/*/results/application_guidance/coding_notes.md`.
  - If multiple files are found, compare their modification timestamps and use the most recently modified file.
  - If no `coding_notes.md` file is found, proceed to step 3 using only the formula checklist.
2. If `coding_notes.md` is found, read its entire content before listing files that need to be migrated.
  - The file contains project-specific migration guidance and rules that must be read before listing files that need to be migrated.
  - The file may exceed 1,000 lines; ensure you read it completely from start to end.
3. Review the formula checklist items below. **Priority rule**: If any checklist item conflicts with guidance in `coding_notes.md`, follow the `coding_notes.md` instructions instead.
4. Apply each relevant modification to the file.
5. For each change, add a comment to the migrated code that includes the checklist item information. Example:
  ```java
  // Migrated from Oracle to PostgreSQL according to java check item 1: Convert all table and column names from uppercase to lowercase in JPA annotations.
  // Migrated from Oracle to PostgreSQL according to coding notes check item: All object names are lowercased in PostgreSQL (unless quoted explicitly).
  ```

## Formula checklist

Java check item 0: Don't modify the content if it's obviously not related to Oracle based on file names or paths. However, always review imports and annotations (e.g., @SequenceGenerator) to identify Oracle-specific code that may require migration.

Java check item 1: Convert all table and column names from uppercase to lowercase in JPA annotations.
  ```java
  // Before migration (Oracle)
  @Entity
  @Table(name = "ITEMS")
  public class Item {
      @Id
      @Column(name = "ITEM_ID")
      private Long id;
  }

  // After migration (PostgreSQL)
  @Entity
  @Table(name = "items")
  public class Item {
      @Id
      @Column(name = "item_id")
      private Long id;
  }
  ```

Java check item 2: Convert sequence generator names to lowercase in JPA annotations.
  ```java
  // Before migration (Oracle)
  @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "ITEM_SEQ")
  @SequenceGenerator(name = "ITEM_SEQ", sequenceName = "ITEMS_SEQ", allocationSize = 1)

  // After migration (PostgreSQL)
  @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "item_seq")
  @SequenceGenerator(name = "item_seq", sequenceName = "items_seq", allocationSize = 1)
  ```

Java check item 3: Replace Oracle-specific SQL functions with PostgreSQL equivalents. Like RANK() to ROW_NUMBER()
  ```java
  // Before migration (Oracle)
  @NamedNativeQuery(
      name = "Item.findTopItems",
      query = """
          SELECT i.* FROM (
              SELECT i.*,
                     RANK() OVER (PARTITION BY i.CATEGORY_ID ORDER BY i.PRICE DESC) as price_rank
              FROM ITEMS i
          ) i
          WHERE i.price_rank <= :topN
          ORDER BY i.CATEGORY_ID, i.price_rank
      """
  )

  // After migration (PostgreSQL)
  @NamedNativeQuery(
      name = "Item.findTopItems",
      query = """
          SELECT i.* FROM (
              SELECT i.*,
                     ROW_NUMBER() OVER (PARTITION BY i.category_id ORDER BY i.price DESC) as price_rank
              FROM items i
          ) i
          WHERE i.price_rank <= :topN
          ORDER BY i.category_id, i.price_rank
      """
  )
  ```

Java check item 4: Replace TO_CHAR date functions with EXTRACT in SQL statements.
  ```java
  // Before migration (Oracle)
  @NamedNativeQuery(
      name = "Item.findItemsCreatedInQuarter",
      query = """
          SELECT * FROM ITEMS
          WHERE TO_CHAR(CREATE_DATE, 'Q') = :quarter
          AND TO_CHAR(CREATE_DATE, 'YYYY') = :year
          ORDER BY CREATE_DATE
      """
  )

  // After migration (PostgreSQL)
  @NamedNativeQuery(
      name = "Item.findItemsCreatedInQuarter",
      query = """
          SELECT * FROM items
          WHERE EXTRACT(QUARTER FROM create_date) = CAST(:quarter AS INTEGER)
          AND EXTRACT(YEAR FROM create_date)::text = :year
          ORDER BY create_date
      """
  )
  ```

Java check item 5: Replace TRUNC(date) with DATE_TRUNC('day', date) in SQL.
  ```java
  // Before migration (Oracle)
  "SELECT * FROM EMPLOYEES WHERE TRUNC(HIRE_DATE) BETWEEN TO_DATE(:startDate, 'YYYY-MM-DD') AND TO_DATE(:endDate, 'YYYY-MM-DD')"

  // After migration (PostgreSQL)
  // IMPORTANT: Don't delete other methods like "TO_DATE"
   "SELECT * FROM employees WHERE DATE_TRUNC('day', hire_date) BETWEEN TO_DATE(:startDate, 'YYYY-MM-DD') AND TO_DATE(:endDate, 'YYYY-MM-DD')"
  ```

Java check item 6: In SQL string literals, use lowercase for identifiers (like table and column names) and data type (like varchar), use uppercase for SQL keywords (like SELECT, FROM, WHERE).
  ```java
  // Before migration (Oracle)
  String sql = """
          INSERT INTO EMPLOYEES (
              EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL,
              PHONE_NUMBER, HIRE_DATE, JOB_ID, SALARY,
              COMMISSION_PCT, MANAGER_ID, DEPARTMENT_ID
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      """;

  // After migration (PostgreSQL)
  String sql = """
          INSERT INTO employees (
              employee_id, first_name, last_name, email,
              phone_number, hire_date, job_id, salary,
              commission_pct, manager_id, department_id
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      """;
  ```

Java check item 7: Replace PL/SQL BULK COLLECT and FORALL with standard JDBC batch operations.
  ```java
  // Before migration (Oracle)
  String plsql = """
          DECLARE
              TYPE emp_id_array IS TABLE OF EMPLOYEES.EMPLOYEE_ID%TYPE;
              TYPE salary_array IS TABLE OF EMPLOYEES.SALARY%TYPE;
              l_emp_ids emp_id_array;
              l_salaries salary_array;
              l_increase_pct NUMBER := ?;
          BEGIN
              -- Bulk collect employee IDs and salaries
              SELECT EMPLOYEE_ID, SALARY BULK COLLECT INTO l_emp_ids, l_salaries
              FROM EMPLOYEES
              WHERE EMPLOYEE_ID IN (?, ?, ?);
              -- Use FORALL to update all records in a single operation
              FORALL i IN 1..l_emp_ids.COUNT
                  UPDATE EMPLOYEES
                  SET SALARY = l_salaries(i) * (1 + l_increase_pct)
                  WHERE EMPLOYEE_ID = l_emp_ids(i);
              COMMIT;
          END;
          """;
  jdbcTemplate.update(plsql, params);

  // After migration (PostgreSQL)
  String sql = "UPDATE employees SET salary = salary * (1 + ?) WHERE employee_id = ?";
  List<Object[]> batchArgs = new ArrayList<>();
  for (Long employeeId : employeeIds) {
      batchArgs.add(new Object[] { increasePercent, employeeId });
  }
  jdbcTemplate.batchUpdate(sql, batchArgs);
  ```

Java check item 8: Replace hierarchical CONNECT BY queries with recursive CTEs.
  Example 1:
  ```java
  // Before migration (Oracle)
  String sql = """
          SELECT
              LEVEL as hierarchy_level,
              LPAD(' ', (LEVEL-1)*2, ' ') || e.FIRST_NAME || ' ' || e.LAST_NAME as employee_name,
              e.EMPLOYEE_ID,
              e.JOB_ID,
              e.SALARY,
              e.DEPARTMENT_ID
          FROM
              EMPLOYEES e
          START WITH
              e.EMPLOYEE_ID = ?
          CONNECT BY
              e.MANAGER_ID = PRIOR e.EMPLOYEE_ID
          ORDER SIBLINGS BY
              e.FIRST_NAME, e.LAST_NAME
      """;

  // After migration (PostgreSQL)
  String sql = """
          WITH RECURSIVE emp_hierarchy AS (
              -- Base case: start with the specific employee
              SELECT
                  e.employee_id,
                  e.first_name,
                  e.last_name,
                  e.job_id,
                  e.salary,
                  e.department_id,
                  e.manager_id,
                  1 as hierarchy_level
              FROM employees e
              WHERE e.employee_id = ?

              UNION ALL

              -- Recursive case: find the subordinates of the current employee
              SELECT
                  m.employee_id,
                  m.first_name,
                  m.last_name,
                  m.job_id,
                  m.salary,
                  m.department_id,
                  m.manager_id,
                  eh.hierarchy_level + 1
              FROM employees m
              JOIN emp_hierarchy eh ON m.manager_id = eh.employee_id
          )
          SELECT
              hierarchy_level,
              LPAD(' ', (hierarchy_level-1)*2, ' ') || first_name || ' ' || last_name as employee_name,
              employee_id,
              job_id,
              salary,
              department_id
          FROM emp_hierarchy
          ORDER BY hierarchy_level, first_name, last_name
          """;
  ```

  Example 2:
  ```java
  // Before migration (Oracle)
  String sql = """
              SELECT
                  e.EMPLOYEE_ID,
                  e.FIRST_NAME || ' ' || e.LAST_NAME as employee_name,
                  SYS_CONNECT_BY_PATH(e.FIRST_NAME || ' ' || e.LAST_NAME, ' -> ') as hierarchy_path,
                  CONNECT_BY_ROOT (e.FIRST_NAME || ' ' || e.LAST_NAME) as top_manager,
                  LEVEL as hierarchy_level,
                  CONNECT_BY_ISLEAF as is_leaf
              FROM
                  EMPLOYEES e
              START WITH
                  e.EMPLOYEE_ID = ?
              CONNECT BY
                  e.EMPLOYEE_ID = PRIOR e.MANAGER_ID
              ORDER BY hierarchy_level
          """;

  // After migration (PostgreSQL)
  // Important: "RECURSIVE" in the SQL is necessary.
  String sql = """
          WITH RECURSIVE emp_hierarchy(employee_id, first_name, last_name, manager_id, level_num) AS (
              SELECT employee_id, first_name, last_name, manager_id, 1
              FROM employees
              WHERE employee_id = ?
              UNION ALL
              SELECT e.employee_id, e.first_name, e.last_name, e.manager_id, eh.level_num + 1
              FROM employees e JOIN emp_hierarchy eh ON e.employee_id = eh.manager_id
          )
          SELECT
              employee_id,
              first_name,
              last_name,
              manager_id,
              level_num
          FROM emp_hierarchy
          ORDER BY level_num
      """;
  ```

Java check item 9: Replace MODEL clause with CTEs and UNION ALL queries.
  ```java
  // Before migration (Oracle)
  String sql = """
          SELECT
              DEPARTMENT_ID,
              EMPLOYEE_ID,
              LAST_NAME,
              YEAR,
              PROJECTED_SALARY
          FROM (
               SELECT
                  DEPARTMENT_ID,
                  EMPLOYEE_ID,
                  LAST_NAME,
                  SALARY
              FROM EMPLOYEES
              WHERE DEPARTMENT_ID IS NOT NULL
          )
          MODEL
              PARTITION BY (DEPARTMENT_ID)
              DIMENSION BY (EMPLOYEE_ID, 0 AS YEAR)
              MEASURES (LAST_NAME, SALARY AS PROJECTED_SALARY)
              RULES (
                  PROJECTED_SALARY[FOR EMPLOYEE_ID IN (SELECT EMPLOYEE_ID FROM EMPLOYEES WHERE DEPARTMENT_ID IS NOT NULL), 1] =
                      PROJECTED_SALARY[CV(), 0] * 1.05,
                  PROJECTED_SALARY[FOR EMPLOYEE_ID IN (SELECT EMPLOYEE_ID FROM EMPLOYEES WHERE DEPARTMENT_ID IS NOT NULL), 2] =
                      PROJECTED_SALARY[CV(), 1] * 1.05,
                  PROJECTED_SALARY[FOR EMPLOYEE_ID IN (SELECT EMPLOYEE_ID FROM EMPLOYEES WHERE DEPARTMENT_ID IS NOT NULL), 3] =
                      PROJECTED_SALARY[CV(), 2] * 1.05
              )
          ORDER BY DEPARTMENT_ID, EMPLOYEE_ID, YEAR
      """;

  // After migration (PostgreSQL)
  String sql = """
          WITH base_data AS (
               SELECT
                  department_id,
                  employee_id,
                  last_name,
                  salary
              FROM employees
              WHERE department_id IS NOT NULL
          )
          SELECT
              department_id,
              employee_id,
              last_name,
              0 AS year,
              salary AS projected_salary
          FROM base_data

          UNION ALL

          SELECT
              department_id,
              employee_id,
              last_name,
              1 AS year,
              salary * 1.05 AS projected_salary
          FROM base_data

          UNION ALL

          SELECT
              department_id,
              employee_id,
              last_name,
              2 AS year,
              salary * 1.05 * 1.05 AS projected_salary
          FROM base_data

          UNION ALL

          SELECT
              department_id,
              employee_id,
              last_name,
              3 AS year,
              salary * 1.05 * 1.05 * 1.05 AS projected_salary
          FROM base_data

          ORDER BY department_id, employee_id, year
      """;
  ```

Java check item 10: Replace PIVOT clause with CASE-based conditional aggregations.
  ```java
  // Before migration (Oracle)
  String sql = """
          SELECT * FROM (
              SELECT DEPARTMENT_ID, JOB_ID
              FROM EMPLOYEES
              WHERE DEPARTMENT_ID IS NOT NULL
          )
          PIVOT (
              COUNT(*)
              FOR JOB_ID IN (
                  'IT_PROG' AS IT_PROGRAMMERS,
                  'SA_REP' AS SALES_REPS,
                  'FI_ACCOUNT' AS ACCOUNTANTS,
                  'SA_MAN' AS SALES_MANAGERS
              )
          )
          ORDER BY DEPARTMENT_ID
      """;

  // After migration (PostgreSQL)
  String sql = """
          SELECT
              department_id,
              COUNT(CASE WHEN job_id = 'IT_PROG' THEN 1 END) AS it_programmers,
              COUNT(CASE WHEN job_id = 'SA_REP' THEN 1 END) AS sales_reps,
              COUNT(CASE WHEN job_id = 'FI_ACCOUNT' THEN 1 END) AS accountants,
              COUNT(CASE WHEN job_id = 'SA_MAN' THEN 1 END) AS sales_managers
          FROM
              employees
          WHERE
              department_id IS NOT NULL
          GROUP BY
              department_id
          ORDER BY
              department_id
      """;
  ```

Java check item 11: Replace PIVOT clause with CASE expressions for category counts.
  ```java
  // Before migration (Oracle)
  String sql = """
      SELECT * FROM (
          SELECT DEPARTMENT_ID, CATEGORY_ID
          FROM ITEMS
          WHERE DEPARTMENT_ID IS NOT NULL
      )
      PIVOT (
          COUNT(*)
          FOR CATEGORY_ID IN (
              'TYPE_1' AS TYPE1_COUNT,
              'TYPE_2' AS TYPE2_COUNT,
              'TYPE_3' AS TYPE3_COUNT,
              'TYPE_4' AS TYPE4_COUNT
          )
      )
      ORDER BY DEPARTMENT_ID
  """;

  // After migration (PostgreSQL)
  String sql = """
      SELECT
          department_id,
          COUNT(CASE WHEN category_id = 'TYPE_1' THEN 1 END) AS type1_count,
          COUNT(CASE WHEN category_id = 'TYPE_2' THEN 1 END) AS type2_count,
          COUNT(CASE WHEN category_id = 'TYPE_3' THEN 1 END) AS type3_count,
          COUNT(CASE WHEN category_id = 'TYPE_4' THEN 1 END) AS type4_count
      FROM
          items
      WHERE
          department_id IS NOT NULL
      GROUP BY
          department_id
      ORDER BY
          department_id
  """;
  ```

Java check item 12: Remove schema and package references from SimpleJdbcCall procedures.
  ```java
  // Before migration (Oracle)
  SimpleJdbcCall jdbcCall = new SimpleJdbcCall(dataSource)
          .withSchemaName("TEST")
          .withCatalogName("HR")      // Package name
          .withProcedureName("GET_EMPLOYEE_INFO")
          .declareParameters(
                  new org.springframework.jdbc.core.SqlParameter("p_employee_id", Types.NUMERIC),
                  new org.springframework.jdbc.core.SqlOutParameter("p_result", Types.REF_CURSOR)
          );

  // After migration (PostgreSQL)
  SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
          .withProcedureName("get_employee_info")
          .declareParameters(
                  new org.springframework.jdbc.core.SqlParameter("p_employee_id", Types.NUMERIC),
                  new org.springframework.jdbc.core.SqlOutParameter("p_result", Types.REF_CURSOR)
          );
  ```

Java check item 13: Replace OracleContainer with PostgreSQLContainer in test classes.
  ```java
  // Before migration (Oracle)
  import org.testcontainers.containers.OracleContainer;

  @Testcontainers
  public abstract class AbstractTestBase {
      private static final String ORACLE_IMAGE = "gvenzl/oracle-xe:latest";

      @Container
      protected static final OracleContainer oracleContainer = new OracleContainer(ORACLE_IMAGE)
              .withUsername("test")
              .withPassword("test");

      @DynamicPropertySource
      static void registerOracleProperties(DynamicPropertyRegistry registry) {
          registry.add("spring.datasource.url", oracleContainer::getJdbcUrl);
          registry.add("spring.datasource.username", oracleContainer::getUsername);
          registry.add("spring.datasource.password", oracleContainer::getPassword);
          registry.add("spring.datasource.driver-class-name", () -> "oracle.jdbc.OracleDriver");
      }
  }

  // After migration (PostgreSQL)
  import org.testcontainers.containers.PostgreSQLContainer;

  @Testcontainers
  public abstract class AbstractTestBase {
      private static final String POSTGRES_IMAGE = "postgres:latest";

      @Container
      protected static final PostgreSQLContainer<?> postgresContainer =
          new PostgreSQLContainer<>(POSTGRES_IMAGE)
              .withUsername("test")
              .withPassword("test")
              .withDatabaseName("testdb");

      @DynamicPropertySource
      static void registerPostgresProperties(DynamicPropertyRegistry registry) {
          registry.add("spring.datasource.url", postgresContainer::getJdbcUrl);
          registry.add("spring.datasource.username", postgresContainer::getUsername);
          registry.add("spring.datasource.password", postgresContainer::getPassword);
          registry.add("spring.datasource.driver-class-name", () -> "org.postgresql.Driver");
      }
  }
  ```

Java check item 14: Update SQL script parsers to support dollar-quoted strings and PL/pgSQL syntax.
  ```java
  // Before migration (Oracle - parsing PL/SQL blocks)
  public String[] splitScriptIntoStatements(String script) {
      List<String> statements = new ArrayList<>();
      StringBuilder currentStatement = new StringBuilder();
      boolean inPlSqlBlock = false;

      for (String line : script.split("\n")) {
          if (line.trim().isEmpty() || line.trim().startsWith("--")) {
              continue;
          }

          // Check for standalone slash indicating end of PL/SQL block
          if (line.trim().equals("/")) {
              if (inPlSqlBlock) {
                  statements.add(currentStatement.toString().trim());
                  currentStatement = new StringBuilder();
                  inPlSqlBlock = false;
              }
              continue;
          }

          // Check for potential start of PL/SQL block
          if (!inPlSqlBlock &&
              (line.toUpperCase().contains("CREATE OR REPLACE PROCEDURE") ||
               line.toUpperCase().contains("CREATE OR REPLACE PACKAGE"))) {
              inPlSqlBlock = true;
          }

          currentStatement.append(line).append("\n");

          if (!inPlSqlBlock && line.trim().endsWith(";")) {
              statements.add(currentStatement.toString().trim());
              currentStatement = new StringBuilder();
          }
      }

      return statements.toArray(new String[0]);
  }

  // After migration (PostgreSQL - supporting dollar-quoted strings)
  public String[] splitScriptIntoStatements(String script) {
      List<String> statements = new ArrayList<>();
      StringBuilder currentStatement = new StringBuilder();
      boolean inPlSqlBlock = false;
      boolean inDollarQuotedString = false;
      boolean collectingProcedureOrFunction = false;

      for (String line : script.split("\n")) {
          if (line.trim().isEmpty() || line.trim().startsWith("--")) {
              continue;
          }

          // Check for PostgreSQL style functions with $$ delimiter
          if (!inPlSqlBlock && !collectingProcedureOrFunction &&
              (line.toUpperCase().contains("CREATE OR REPLACE PROCEDURE") ||
               line.toUpperCase().contains("CREATE OR REPLACE FUNCTION"))) {
              collectingProcedureOrFunction = true;
          }

          // Check for dollar quoted string - PostgreSQL syntax
          if (line.contains("$$")) {
              if (collectingProcedureOrFunction && !inPlSqlBlock) {
                  inPlSqlBlock = true;
              }
              inDollarQuotedString = !inDollarQuotedString;
          }

          // Special handling for the end of PostgreSQL function/procedure
          if (collectingProcedureOrFunction &&
              line.toUpperCase().contains("LANGUAGE PLPGSQL") &&
              !inDollarQuotedString) {
              inPlSqlBlock = false;
              collectingProcedureOrFunction = false;
          }

          currentStatement.append(line).append("\n");

          if (!inPlSqlBlock && !collectingProcedureOrFunction &&
              line.trim().endsWith(";")) {
              statements.add(currentStatement.toString().trim());
              currentStatement = new StringBuilder();
          }
      }

      return statements.toArray(new String[0]);
  }
  ```

Java check item 15: Replace multi-statement PL/SQL blocks with individual SQL statements.
  ```java
  // Before migration (Oracle)
  String plsqlBlock = """
          BEGIN
            UPDATE EMPLOYEES
            SET SALARY = SALARY + ?
            WHERE EMPLOYEE_ID = ?;

            INSERT INTO SALARY_HISTORY (
              EMPLOYEE_ID,
              CHANGE_DATE,
              SALARY_CHANGE,
              CHANGE_REASON
            ) VALUES (
              ?,
              SYSDATE,
              ?,
              'Annual increase'
            );

            COMMIT;
          EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK;
              RAISE;
          END;
          """;

  jdbcTemplate.update(plsqlBlock,
          salaryIncrease,
          employeeId,
          employeeId,
          salaryIncrease);

  // After migration (PostgreSQL)
  // Execute statements individually
  jdbcTemplate.update(
          "UPDATE employees SET salary = salary + ? WHERE employee_id = ?",
          salaryIncrease, employeeId
  );

  jdbcTemplate.update(
          "INSERT INTO salary_history (employee_id, change_date, salary_change, change_reason) " +
          "VALUES (?, CURRENT_DATE, ?, 'Annual increase')",
          employeeId, salaryIncrease
  );
  ```

Java check item 16: Replace SimpleJdbcCall with CALL syntax for PostgreSQL procedures. Add type cast in parameter if necessary.
  Before migration (Oracle)
  ```sql
  CREATE TABLE EMPLOYEES (
      EMPLOYEE_ID     NUMBER(6) PRIMARY KEY, -- Caution about the type here
      SALARY          NUMBER(8,2)
  );
  CREATE OR REPLACE PROCEDURE update_employee_salary( -- This is the definition of the stored procedure
      p_employee_id IN EMPLOYEES.EMPLOYEE_ID%TYPE, -- Caution about the type here
      p_percent IN NUMBER
  ) IS
  BEGIN
      UPDATE EMPLOYEES
      SET SALARY = SALARY * (1 + p_percent/100)
      WHERE EMPLOYEE_ID = p_employee_id;
      COMMIT;
  EXCEPTION
      WHEN OTHERS THEN
          ROLLBACK;
          RAISE;
  END update_employee_salary;
  /
  ```
  ```java
  // Using SimpleJdbcCall to call Oracle stored procedure
  SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
          .withProcedureName("update_employee_salary");

  Map<String, Object> inParams = new HashMap<>();
  inParams.put("p_employee_id", employeeId);
  inParams.put("p_percent", percentIncrease);

  jdbcCall.execute(inParams);
  ```

  After migration (PostgreSQL)
  ```sql
  CREATE TABLE employees (
      employee_id     integer PRIMARY KEY, -- Caution about the type here
      salary          numeric(8,2)
  );
  CREATE OR REPLACE PROCEDURE update_employee_salary( -- This is the definition of the stored procedure
      p_employee_id integer, -- Caution about the type here
      p_percent numeric
  ) AS $$
  BEGIN
      UPDATE employees
      SET salary = salary * (1 + p_percent/100)
      WHERE employee_id = p_employee_id;
  END;
  $$ LANGUAGE plpgsql;
  ```
  ```java
  // In PostgreSQL, procedures are called with CALL syntax
  String sql = "CALL update_employee_salary(CAST(? AS INTEGER), CAST(? AS NUMERIC))"; // Caution about the type cast here, it depends on the definition of the stored procedure
  jdbcTemplate.update(sql, employeeId, percentIncrease);
  ```

Java check item 17: Replace ROWNUM pagination with LIMIT/OFFSET in native SQL queries.
  ```java
  // Before migration (Oracle)
  @Query(value = "SELECT * FROM (SELECT a.*, ROWNUM rn FROM " +
          "(SELECT * FROM ITEMS ORDER BY PRICE DESC) a " +
          "WHERE ROWNUM <= :maxResults) WHERE rn >= :startIndex", nativeQuery = true)
  List<Item> findItemsWithPagination(@Param("startIndex") int startIndex,
                                    @Param("maxResults") int maxResults);

  // After migration (PostgreSQL)
  @Query(value = "SELECT * FROM items ORDER BY price DESC " +
          "LIMIT :maxResults OFFSET :startIndex - 1", nativeQuery = true)
  List<Item> findItemsWithPagination(@Param("startIndex") int startIndex,
                                    @Param("maxResults") int maxResults);
  ```

Java check item 18: Replace SYS_CONNECT_BY_PATH with string concatenation in recursive CTEs.
  ```java
  // Before migration (Oracle)
  String sql = """
      SELECT
          i.ITEM_ID,
          i.NAME as item_name,
          SYS_CONNECT_BY_PATH(i.NAME, ' -> ') as hierarchy_path,
          CONNECT_BY_ROOT (i.NAME) as top_item,
          LEVEL as hierarchy_level,
          CONNECT_BY_ISLEAF as is_leaf
      FROM
          ITEMS i
      START WITH
          i.ITEM_ID = ?
      CONNECT BY
          i.ITEM_ID = PRIOR i.PARENT_ID
      ORDER BY hierarchy_level
  """;
  // After migration (PostgreSQL)
  String sql = """
      WITH RECURSIVE item_hierarchy AS (
          -- Base case
          SELECT
              i.item_id,
              i.name as item_name,
              i.name as hierarchy_path,
              1 as hierarchy_level
          FROM
              items i
          WHERE
              i.item_id = ?

          UNION ALL

          -- Recursive case
          SELECT
              i.item_id,
              i.name,
              ih.hierarchy_path || ' -> ' || i.name,
              ih.hierarchy_level + 1
          FROM
              items i
          JOIN
              item_hierarchy ih ON i.parent_id = ih.item_id
      )
      SELECT
          item_id,
          item_name,
          hierarchy_path,
          hierarchy_level,
          (NOT EXISTS (
              SELECT 1 FROM items
              WHERE parent_id = item_hierarchy.item_id
          )) as is_leaf
      FROM
          item_hierarchy
      ORDER BY
          hierarchy_level
  """;
  ```

Java check item 19: Replace MEDIAN with PERCENTILE_CONT(0.5) WITHIN GROUP in SQL queries.
  ```java
  // Before migration (Oracle)
  String sql = """
      SELECT
          DEPARTMENT_ID,
          AVG(SALARY) AS AVG_SALARY,
          MIN(SALARY) AS MIN_SALARY,
          MAX(SALARY) AS MAX_SALARY,
          COUNT(*) AS EMP_COUNT,
          MEDIAN(SALARY) AS MEDIAN_SALARY
      FROM ITEMS
      GROUP BY DEPARTMENT_ID
      ORDER BY DEPARTMENT_ID
  """;

  // After migration (PostgreSQL)
  String sql = """
      SELECT
          department_id,
          AVG(value) AS avg_value,
          MIN(value) AS min_value,
          MAX(value) AS max_value,
          COUNT(*) AS item_count,
          PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY value) AS median_value
      FROM items
      GROUP BY department_id
      ORDER BY department_id
  """;
  ```

Java check item 20: Use executeFunction() for stored function calls in SimpleJdbcCall.
  ```java
  // Before migration (Oracle)
  public BigDecimal calculateItemValue(Long itemId, BigDecimal percentage) {
      SimpleJdbcCall jdbcCall = new SimpleJdbcCall(dataSource)
              .withSchemaName("TEST")
              .withCatalogName("ITEMS_PKG")
              .withFunctionName("CALCULATE_VALUE")
              .declareParameters(
                      new SqlParameter("p_item_id", Types.NUMERIC),
                      new SqlParameter("p_percent", Types.NUMERIC),
                      new SqlOutParameter("return", Types.NUMERIC)
              );

      SqlParameterSource params = new MapSqlParameterSource()
              .addValue("p_item_id", itemId)
              .addValue("p_percent", percentage);

      Map<String, Object> result = jdbcCall.execute(params);
      return (BigDecimal) result.get("return");
  }

  // After migration (PostgreSQL)
  public BigDecimal calculateItemValue(Long itemId, BigDecimal percentage) {
      SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
              .withFunctionName("calculate_value")
              .declareParameters(
                      new SqlParameter("p_item_id", Types.NUMERIC),
                      new SqlParameter("p_percent", Types.NUMERIC)
              );

      SqlParameterSource params = new MapSqlParameterSource()
              .addValue("p_item_id", itemId)
              .addValue("p_percent", percentage);

      return jdbcCall.executeFunction(BigDecimal.class, params);
  }
  ```

Java check item 21: Remove "FROM dual" in function call SQL statements.
  ```java
  // Before migration (Oracle)
  BigDecimal result = jdbcTemplate.queryForObject(
      "SELECT calculate_compensation(?, ?) FROM dual",
      BigDecimal.class,
      salary,
      commissionPct
  );

  // After migration (PostgreSQL)
  BigDecimal result = jdbcTemplate.queryForObject(
      "SELECT calculate_compensation(?, ?)",
      BigDecimal.class,
      salary,
      commissionPct
  );
  ```

Java check item 22: Add explicit type casting (::) for column and function parameters in SQL according to function definition. Because PostgreSQL is more strict about parameter types in stored procedure calls.
  Example one: In function parameter.
      Before migration (Oracle)
      ```sql
      FUNCTION CALCULATE_BONUS(
          p_employee_id IN NUMBER,
          p_percent IN NUMBER
      ) RETURN NUMBER IS
          v_salary EMPLOYEES.SALARY%TYPE;
          v_bonus NUMBER;
      BEGIN
          SELECT SALARY INTO v_salary FROM EMPLOYEES WHERE EMPLOYEE_ID = p_employee_id;
          v_bonus := v_salary * (p_percent / 100);
          RETURN v_bonus;
      END CALCULATE_BONUS;
      ```
      ```java
      BigDecimal bonus = jdbcTemplate.queryForObject(
          "SELECT calculate_bonus(?, ?)",
          BigDecimal.class,
          itemId,
          percent
      );

      After migration (PostgreSQL)
      ```sql
      CREATE OR REPLACE FUNCTION calculate_bonus(
          p_employee_id INTEGER,
          p_percent INTEGER
      ) RETURNS NUMERIC AS $$
      DECLARE
          v_salary employees.salary%TYPE;
          v_bonus NUMERIC;
      BEGIN
          SELECT salary INTO v_salary FROM employees WHERE employee_id = p_employee_id;
          -- Use numeric division to avoid integer division truncation
          v_bonus := v_salary * (p_percent::numeric / 100);
          RETURN v_bonus;
      END;
      $$ LANGUAGE plpgsql;
      ```
      ```java
      BigDecimal bonus = jdbcTemplate.queryForObject(
          "SELECT calculate_bonus(?::INTEGER, ?::INTEGER)", // Add casting  according to the function definition.
          BigDecimal.class,
          itemId,
          percent.intValue()
      );
      ```
  Example 2: In Column.
      ```java
      String sql = "SELECT last_name::varchar as emp_path FROM employees"
      ```

Java check item 23: Replace REF_CURSOR handling with direct queries or PostgreSQL's named cursors.
  ```java
  // Before migration (Oracle)
  // Use SimpleJdbcCall to call stored procedure with cursor
  SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
          .withCatalogName("HR") // Package name
          .withProcedureName("GET_ITEM_INFO")
          .declareParameters(
                  new SqlParameter("p_item_id", Types.NUMERIC),
                  new SqlOutParameter("p_result", Types.REF_CURSOR)
          );

  MapSqlParameterSource params = new MapSqlParameterSource()
          .addValue("p_item_id", itemId);
  Map<String, Object> result = jdbcCall.execute(params);

  @SuppressWarnings("unchecked")
  Map<String, Object> itemInfo = (Map<String, Object>) ((java.util.List<?>) result.get("p_result")).get(0);

  // After migration (PostgreSQL) - Option 1: Direct query approach
  Map<String, Object> itemInfo = jdbcTemplate.queryForMap(
      "SELECT i.*, c.category_name FROM items i " +
      "JOIN categories c ON i.category_id = c.category_id " +
      "WHERE i.item_id = ?",
      itemId
  );

  // After migration (PostgreSQL) - Option 2: If cursor is required
  // Create a named refcursor
  jdbcTemplate.execute("BEGIN; DECLARE c_item REFCURSOR;");

  // Call the stored procedure
  jdbcTemplate.update("CALL get_item_info(?, 'c_item')", itemId);

  // Fetch results from the cursor
  Map<String, Object> itemInfo = jdbcTemplate.queryForMap("FETCH ALL FROM c_item");

  jdbcTemplate.execute("COMMIT;");
  ```

Java check item 24: Replace MERGE statement with INSERT ON CONFLICT for upsert operations.
  ```java
  // Before migration (Oracle)
  String mergeSql =
          "MERGE INTO items i " +
          "USING (SELECT :itemId AS item_id, :itemName AS item_name, " +
          ":categoryId AS category_id FROM dual) src " +
          "ON (i.ITEM_ID = src.item_id) " +
          "WHEN MATCHED THEN " +
          "UPDATE SET i.ITEM_NAME = src.item_name, " +
          "i.CATEGORY_ID = src.category_id " +
          "WHEN NOT MATCHED THEN " +
          "INSERT (ITEM_ID, ITEM_NAME, CATEGORY_ID) " +
          "VALUES (src.item_id, src.item_name, src.category_id)";

  MapSqlParameterSource params = new MapSqlParameterSource()
          .addValue("itemId", itemId)
          .addValue("itemName", itemName)
          .addValue("categoryId", categoryId);

  int rowsAffected = jdbcTemplate.update(mergeSql, params);

  // After migration (PostgreSQL)
  String upsertSql =
          "INSERT INTO items (item_id, item_name, category_id) " +
          "VALUES (:itemId, :itemName, :categoryId) " +
          "ON CONFLICT (item_id) " +
          "DO UPDATE SET " +
          "item_name = :itemName, " +
          "category_id = :categoryId";

  MapSqlParameterSource params = new MapSqlParameterSource()
          .addValue("itemId", itemId)
          .addValue("itemName", itemName)
          .addValue("categoryId", categoryId);

  int rowsAffected = jdbcTemplate.update(upsertSql, params);
  ```

Java check item 25: Use JdbcTemplate.queryForObject to replace SimpleJdbcCall#executeFunction.
  ```java
  // Before migration (Oracle)
  SimpleJdbcCall calculateBonusCall = new SimpleJdbcCall(jdbcTemplate)
          .withCatalogName("HR") // Package name
          .withFunctionName("CALCULATE_BONUS")
          .declareParameters(
                  new SqlParameter("p_item_id", Types.NUMERIC),
                  new SqlParameter("p_percent", Types.NUMERIC)
          );

  SqlParameterSource inParams = new MapSqlParameterSource()
          .addValue("p_item_id", itemId)
          .addValue("p_percent", percent);

  BigDecimal bonus = calculateBonusCall.executeFunction(BigDecimal.class, inParams);

  // After migration (PostgreSQL)
  // In PostgreSQL, we can call functions directly with SELECT
  // Add casting if necessary according to the function definition.
  String sql = "SELECT calculate_bonus(?::INTEGER, ?::INTEGER)";
  BigDecimal bonus = jdbcTemplate.queryForObject(sql, BigDecimal.class,
          itemId, percent.intValue());
  ```

Java check item 26: Change H2 from Oracle mode to PostgreSQL mode.
  ```java
  // Before migration (Oracle)
  import org.h2.jdbcx.JdbcDataSource;

  public class OracleTestSetup {
      public static JdbcDataSource createOracleDataSource(String dbName) {
          JdbcDataSource h2DataSource = new JdbcDataSource();
          h2DataSource.setURL("jdbc:h2:mem:" + dbName + ";MODE=Oracle;DB_CLOSE_DELAY=-1");
          h2DataSource.setUser("sa");
          h2DataSource.setPassword("");
          return h2DataSource;
      }
  }

  // After migration (PostgreSQL)
  import org.h2.jdbcx.JdbcDataSource;

  public class PostgresTestSetup {
      public static JdbcDataSource createPostgresDataSource(String dbName) {
          JdbcDataSource h2DataSource = new JdbcDataSource();
          h2DataSource.setURL("jdbc:h2:mem:" + dbName + ";MODE=PostgreSQL;DB_CLOSE_DELAY=-1");
          h2DataSource.setUser("sa");
          h2DataSource.setPassword("");
          return h2DataSource;
      }
  }
  ```

Java check item 27: Change from OracleDataSource to PGSimpleDataSource.
  ```java
  // Before migration (Oracle)
  public static DataSource createOracleDataSource(String user, String password, String url) {
      OracleDataSource dataSource = null;
      try {
          dataSource = new OracleDataSource();
          dataSource.setUser(user);
          dataSource.setPassword(password);
          dataSource.setURL(url); // e.g., jdbc:oracle:thin:@localhost:1521:xe
          dataSource.setImplicitCachingEnabled(true);
          return dataSource;
      } catch (SQLException e) {
          e.printStackTrace();
      }
      return null;
  }

  // After migration (PostgreSQL)
  public static DataSource createPostgresDataSource(String user, String password, String url) {
      PGSimpleDataSource dataSource = new PGSimpleDataSource();
      try {
          dataSource.setUser(user);
          dataSource.setPassword(password);
          dataSource.setURL(url); // e.g., jdbc:postgresql://localhost:5432/mydb
          return dataSource;
      } catch (Exception e) {
          e.printStackTrace();
      }
      return null;
  }
  ```

Java check item 28: Enable passwordless connection. comment out all "username" and "password" related content which are ONLY corresponding to the PostgreSQL JDBC URL.
- Example: Java code difference fragment 1
  ```diff
  - @Value("${spring.shardingsphere.dataSource1.username}")
  - private String username;
  - @Value("${spring.shardingsphere.dataSource1.password}")
  - private String password;
  + // Comment out all content about "username" and "password" because now PostgreSQL will authenticate using managed identity.
  + // @Value("${spring.shardingsphere.dataSource1.username}")
  + // private String username;
  + // @Value("${spring.shardingsphere.dataSource1.password}")
  + // private String password;
  ```
- Example: Java code difference fragment 2
  ```diff
  - hikariDataSource.setUsername(dataSource1Config.getUsername());
  - hikariDataSource.setPassword(dataSource1Config.getPassword());
  + // Comment out all content about "username" and "password" because now PostgreSQL will authenticate using managed identity.
  + // hikariDataSource.setUsername(dataSource1Config.getUsername());
  + // hikariDataSource.setPassword(dataSource1Config.getPassword());
  ```

Java check item 9999: Migrate all other Oracle-specific content to PostgreSQL. For each line, carefully verify whether it uses Oracle-only features.



## Migrate ORM mapping files from Oracle to PostgreSQL

Update ORM mapping files for Oracle to PostgreSQL migration

### Search code
Search files from workspace using below patterns:
- Glob pattern to find files: `**/*.xml`
- Regex pattern to find code lines: `resultMap|select|insert|update|delete|<if>|<where>|<foreach>|<sql>|<script>|ROWNUM|DUAL|NVL|CONNECT BY|VARCHAR2|NUMBER|PL/SQL|column=\"[A-Za-z_]+\"|table=\"[A-Za-z_]+\"|FROM\s+[A-Za-z_]+|JOIN\s+[A-Za-z_]+`

### Instruction


Your task is to migrate ORM mapping XML files from Oracle database settings to PostgreSQL compatibility.

Follow these steps:
1. Locate the `coding_notes.md` file:
  - If `coding_notes.md` is already provided in the prompt or context, use it and skip to step 2.
  - Otherwise, search for `coding_notes.md` in the migration project workspace using the pattern `.github/postgres-migrations/*/results/application_guidance/coding_notes.md`.
  - If multiple files are found, compare their modification timestamps and use the most recently modified file.
  - If no `coding_notes.md` file is found, proceed to step 3 using only the formula checklist.
2. If `coding_notes.md` is found, read its entire content before listing files that need to be migrated.
  - The file contains project-specific migration guidance and rules that must be read before listing files that need to be migrated.
  - The file may exceed 1,000 lines; ensure you read it completely from start to end.
3. Review the formula checklist items below. **Priority rule**: If any checklist item conflicts with guidance in `coding_notes.md`, follow the `coding_notes.md` instructions instead.
4. Apply each relevant modification to the file.
5. For each change, add a comment to the migrated code that includes the checklist item information. Example:
  ```xml
  <!-- Migrated from Oracle to PostgreSQL according to ORM check item 1: Use lowercase for identifiers (like table and column names) and data type (like varchar), use uppercase for SQL keywords (like SELECT, FROM, WHERE). -->
  <!-- Migrated from Oracle to PostgreSQL according to coding notes check item: All object names are lowercased in PostgreSQL (unless quoted explicitly). -->
  ```

## Formula checklist

ORM check item 0: Don't modify the content if it's obviously not related to Oracle. For example: File named mysql-mapping.xml, file with path mysql/mapping.xml

ORM check item 1: Use lowercase for identifiers (like table and column names) and data type (like varchar), use uppercase for SQL keywords (like SELECT, FROM, WHERE).
  ```xml
  <!-- Before migration (Oracle) -->
  <resultMap id="EmployeeResultMap" type="com.example.model.Employee">
      <id property="id" column="EMPLOYEE_ID" />
      <result property="firstName" column="FIRST_NAME" />
      <result property="lastName" column="LAST_NAME" />
      <result property="email" column="EMAIL" />
  </resultMap>

  <!-- After migration (PostgreSQL) -->
  <resultMap id="EmployeeResultMap" type="com.example.model.Employee">
      <id property="id" column="employee_id" />
      <result property="firstName" column="first_name" />
      <result property="lastName" column="last_name" />
      <result property="email" column="email" />
  </resultMap>
  ```

ORM check item 2: Replace ROWNUM-based pagination with LIMIT/OFFSET in XML SQL queries.
  ```xml
  <!-- Before migration (Oracle) -->
  <select id="findEmployeesWithPagination" resultMap="EmployeeResultMap">
      SELECT * FROM (
          SELECT e.*, ROWNUM as rn
          FROM (
              SELECT * FROM EMPLOYEES
              ORDER BY HIRE_DATE DESC
          ) e
          WHERE ROWNUM &lt;= #{endRow}
      )
      WHERE rn > #{startRow}
  </select>

  <!-- After migration (PostgreSQL) -->
  <select id="findEmployeesWithPagination" resultMap="EmployeeResultMap">
      SELECT * FROM employees
      ORDER BY hire_date DESC
      LIMIT #{pageSize} OFFSET #{offset}
  </select>
  ```

ORM check item 3: Remove FROM DUAL in XML mapper queries.
  ```xml
  <!-- Before migration (Oracle) -->
  <select id="getCurrentDate" resultType="java.util.Date">
      SELECT SYSDATE FROM DUAL
  </select>

  <!-- After migration (PostgreSQL) -->
  <select id="getCurrentDate" resultType="java.util.Date">
      SELECT CURRENT_DATE
  </select>
  ```

ORM check item 4: Replace NVL function with COALESCE in XML SQL statements.
  ```xml
  <!-- Before migration (Oracle) -->
  <select id="getTotalCompensation" resultType="java.math.BigDecimal">
      SELECT SALARY + NVL(COMMISSION_PCT * SALARY, 0) AS total_comp
      FROM EMPLOYEES
      WHERE EMPLOYEE_ID = #{employeeId}
  </select>

  <!-- After migration (PostgreSQL) -->
  <select id="getTotalCompensation" resultType="java.math.BigDecimal">
      SELECT salary + COALESCE(commission_pct * salary, 0) AS total_comp
      FROM employees
      WHERE employee_id = #{employeeId}
  </select>
  ```

ORM check item 5: Replace CONNECT BY with WITH RECURSIVE CTEs in XML queries.
  ```xml
  <!-- Before migration (Oracle) -->
  <select id="getEmployeeHierarchy" resultMap="EmployeeResultMap">
      SELECT
          EMPLOYEE_ID, FIRST_NAME, LAST_NAME,
          LEVEL as hierarchy_level
      FROM EMPLOYEES
      START WITH EMPLOYEE_ID = #{rootEmployeeId}
      CONNECT BY PRIOR EMPLOYEE_ID = MANAGER_ID
      ORDER SIBLINGS BY LAST_NAME
  </select>

  <!-- After migration (PostgreSQL) -->
  <select id="getEmployeeHierarchy" resultMap="EmployeeResultMap">
      WITH RECURSIVE emp_hierarchy AS (
          SELECT
              employee_id, first_name, last_name,
              1 as hierarchy_level
          FROM employees
          WHERE employee_id = #{rootEmployeeId}

          UNION ALL

          SELECT
              e.employee_id, e.first_name, e.last_name,
              eh.hierarchy_level + 1
          FROM
              employees e
          JOIN
              emp_hierarchy eh ON e.manager_id = eh.employee_id
      )
      SELECT
          employee_id, first_name, last_name,
          hierarchy_level
      FROM emp_hierarchy
      ORDER BY hierarchy_level, last_name
  </select>
  ```

ORM check item 6: Replace TO_CHAR date functions with EXTRACT in XML mapper queries.
  ```xml
  <!-- Before migration (Oracle) -->
  <select id="findEmployeesHiredInQuarter" resultMap="EmployeeResultMap">
      SELECT * FROM EMPLOYEES
      WHERE TO_CHAR(HIRE_DATE, 'Q') = #{quarter}
      AND TO_CHAR(HIRE_DATE, 'YYYY') = #{year}
  </select>

  <!-- After migration (PostgreSQL) -->
  <select id="findEmployeesHiredInQuarter" resultMap="EmployeeResultMap">
      SELECT * FROM employees
      WHERE EXTRACT(QUARTER FROM hire_date) = CAST(#{quarter} AS INTEGER)
      AND EXTRACT(YEAR FROM hire_date)::text = #{year}
  </select>
  ```

ORM check item 7: Use PostgreSQL's auto-generated keys instead of sequence.nextval in XML inserts.
  ```xml
  <!-- Before migration (Oracle) -->
  <insert id="insertEmployee" parameterType="com.example.model.Employee">
      <selectKey keyProperty="id" resultType="java.lang.Long" order="BEFORE">
          SELECT EMPLOYEES_SEQ.NEXTVAL FROM DUAL
      </selectKey>
      INSERT INTO EMPLOYEES (
          EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL
      ) VALUES (
          #{id}, #{firstName}, #{lastName}, #{email}
      )
  </insert>

  <!-- After migration (PostgreSQL) -->
  <insert id="insertEmployee" parameterType="com.example.model.Employee" useGeneratedKeys="true" keyProperty="id">
      INSERT INTO employees (
          first_name, last_name, email
      ) VALUES (
          #{firstName}, #{lastName}, #{email}
      )
  </insert>
  ```

ORM check item 8: Replace {call} syntax with CALL statement for stored procedures.
  ```xml
  <!-- Before migration (Oracle) -->
  <update id="updateItemPrice">
      {call update_item_price(
        #{itemId, mode=IN, jdbcType=NUMERIC},
        #{percentIncrease, mode=IN, jdbcType=NUMERIC}
      )}
  </update>

  <!-- After migration (PostgreSQL) -->
  <update id="updateItemPrice">
      CALL update_item_price(
        #{itemId, mode=IN, jdbcType=NUMERIC},
        #{percentIncrease, mode=IN, jdbcType=NUMERIC}
      )
  </update>
  ```

ORM check item 9: In stored procedure calls, check the definition of the stored procedure, make sure that every parameter type is correct. Use "CAST" to convert type if necessary. Because PostgreSQL is more strict about parameter types in stored procedure calls.
  Before migration (Oracle)
  ```sql
  CREATE TABLE EMPLOYEES (
      EMPLOYEE_ID     NUMBER(6) PRIMARY KEY, -- Caution about the type here
      SALARY          NUMBER(8,2)
  );
  CREATE OR REPLACE PROCEDURE update_employee_salary( -- This is the definition of the stored procedure
      p_employee_id IN EMPLOYEES.EMPLOYEE_ID%TYPE, -- Caution about the type here
      p_percent IN NUMBER
  ) IS
  BEGIN
      UPDATE EMPLOYEES
      SET SALARY = SALARY * (1 + p_percent/100)
      WHERE EMPLOYEE_ID = p_employee_id;
      COMMIT;
  EXCEPTION
      WHEN OTHERS THEN
          ROLLBACK;
          RAISE;
  END update_employee_salary;
  /
  ```
  ```xml
  <update id="updateEmployeeSalary">
    {call update_employee_salary(
    #{employeeId, mode=IN, jdbcType=NUMERIC}, <!-- Caution about the type here -->
    #{percentIncrease, mode=IN, jdbcType=NUMERIC}
  )}
  </update>
  ```

  After migration (PostgreSQL)
  ```sql
  CREATE TABLE employees (
      employee_id     integer PRIMARY KEY, -- Caution about the type here
      salary          numeric(8,2)
  );
  CREATE OR REPLACE PROCEDURE update_employee_salary( -- This is the definition of the stored procedure
      p_employee_id integer, -- Caution about the type here
      p_percent numeric
  ) AS $$
  BEGIN
      UPDATE employees
      SET salary = salary * (1 + p_percent/100)
      WHERE employee_id = p_employee_id;
  END;
  $$ LANGUAGE plpgsql;
  ```
  ```xml
  <update id="updateEmployeeSalary">
    CALL update_employee_salary(
    CAST(#{employeeId, mode=IN, jdbcType=NUMERIC} AS integer), <!-- Caution about the type cast here, it depends on the definition of the stored procedure -->
    #{percentIncrease, mode=IN, jdbcType=NUMERIC}
    )
  </update>
  ```

ORM check item 9999: Migrate all other Oracle-specific content to PostgreSQL. For each line, carefully verify whether it uses Oracle-only features.



## Migrate Java build files from Oracle to PostgreSQL

Update Maven POM and Gradle build files for Oracle to PostgreSQL migration

### Search code
Search files from workspace using below patterns:
- Glob pattern to find files: `**/{pom.xml,build.gradle,build.gradle.kts}`
- Regex pattern to find code lines: `oracle|Oracle|ojdbc`

### Instruction


Your task is to migrate Maven POM or Gradle build files from Oracle database dependencies to PostgreSQL compatibility.

Follow these steps:
1. Locate the `coding_notes.md` file:
  - If `coding_notes.md` is already provided in the prompt or context, use it and skip to step 2.
  - Otherwise, search for `coding_notes.md` in the migration project workspace using the pattern `.github/postgres-migrations/*/results/application_guidance/coding_notes.md`.
  - If multiple files are found, compare their modification timestamps and use the most recently modified file.
  - If no `coding_notes.md` file is found, proceed to step 3 using only the formula checklist.
2. If `coding_notes.md` is found, read its entire content before listing files that need to be migrated.
  - The file contains project-specific migration guidance and rules that must be read before listing files that need to be migrated.
  - The file may exceed 1,000 lines; ensure you read it completely from start to end.
3. Review the formula checklist items below. **Priority rule**: If any checklist item conflicts with guidance in `coding_notes.md`, follow the `coding_notes.md` instructions instead.
4. Apply each relevant modification to the file.
5. For each change, add a comment to the migrated code that includes the checklist item information. Example:
  ```xml
  <!-- Migrated from Oracle to PostgreSQL according to Build file check item 1: Replace Oracle JDBC driver with PostgreSQL driver dependency. -->
  <!-- Migrated from Oracle to PostgreSQL according to coding notes check item: All object names are lowercased in PostgreSQL (unless quoted explicitly). -->
  ```

## Formula checklist

Build file check item 0: Don't modify the content if it's obviously not related to Oracle.

Build file check item 1: Replace Oracle JDBC driver (ojdbc) with PostgreSQL driver dependency.
  Example 1:
    Before migration (Oracle):
      - groupId: com.oracle.database.jdbc
        artifactId: ojdbc11
    After migration (PostgreSQL):
      - groupId: org.postgresql
        artifactId: postgresql
        version: 42.7.7
  Example 2:
    Before migration (Oracle):
      - groupId: com.oracle.database.r2dbc
        artifactId: oracle-r2dbc
    After migration (PostgreSQL):
      - groupId: io.r2dbc
        artifactId: r2dbc-postgresql
        version: 0.8.13.RELEASE

Build file check item 2: Replace flyway-database-oracle with flyway-database-postgresql.
  Example:
    Before migration (Oracle):
      - groupId: org.flywaydb
        artifactId: flyway-database-oracle
    After migration (PostgreSQL):
      - groupId: org.flywaydb
        artifactId: flyway-database-postgresql

Build file check item 3: Replace oracle-xe testcontainer with postgresql testcontainer.
  Example:
    Before migration (Oracle):
      - groupId: org.testcontainers
        artifactId: oracle-xe
    After migration (PostgreSQL):
      - groupId: org.testcontainers
        artifactId: postgresql

Build file check item 4: For newly added dependencies, avoid specifying explicit versions when a BOM (Bill of Materials) already manages a CVE-free version.
  - Omit version numbers only when both of the following 2 conditions are met:
    - The dependency version is managed by a parent POM or imported BOM
    - (Must be satisfied) The managed version is secure (no known CVEs)
  - Version can be managed by a parent POM. Example:
    - groupId: org.springframework.boot
      artifactId: spring-boot-starter-parent
  - Version can be managed by imported BOM. Example:
    - groupId: org.springframework.boot
      artifactId: spring-boot-dependencies
      scope: import
      type: pom
  - Omit version only when the managed version is CVE-free:
    - groupId: org.flywaydb
      artifactId: flyway-database-postgresql

Build file check item 5: Enable passwordless connection. To use the AzurePostgresqlAuthenticationPlugin in the PostgreSQL JDBC URL, it's necessary to add dependencies.
Example: pom file difference
  ```diff
  + <dependency>
  +     <groupId>com.azure</groupId>
  +     <artifactId>azure-identity-extensions</artifactId>
  +     <version>1.2.2</version>
  + </dependency>
  ```

Build file check item 6: Verify newly added dependencies are CVE-free.
  - If you specify an explicit version that has known CVEs, update to a secure version without vulnerabilities.
  - If the version is managed by a BOM (Bill of Materials) that contains CVEs, override with a secure version.
  - Double-check for security issues before finalizing versions.

Build file check item 9999: Migrate all other Oracle-specific content to PostgreSQL. For each line, carefully verify whether it uses Oracle-only features.



## Migrate configuration properties from Oracle to PostgreSQL

Update configuration files for Oracle to PostgreSQL migration

### Search code
Search files from workspace using below patterns:
- Glob pattern to find files: `**/*.{yml,yaml,properties}`
- Regex pattern to find code lines: `oracle|Oracle|1521|ojdbc`

### Instruction


Your task is to migrate configuration properties from Oracle database settings to PostgreSQL compatibility.

Follow these steps:
1. Locate the `coding_notes.md` file:
  - If `coding_notes.md` is already provided in the prompt or context, use it and skip to step 2.
  - Otherwise, search for `coding_notes.md` in the migration project workspace using the pattern `.github/postgres-migrations/*/results/application_guidance/coding_notes.md`.
  - If multiple files are found, compare their modification timestamps and use the most recently modified file.
  - If no `coding_notes.md` file is found, proceed to step 3 using only the formula checklist.
2. If `coding_notes.md` is found, read its entire content before listing files that need to be migrated.
  - The file contains project-specific migration guidance and rules that must be read before listing files that need to be migrated.
  - The file may exceed 1,000 lines; ensure you read it completely from start to end.
3. Review the formula checklist items below. **Priority rule**: If any checklist item conflicts with guidance in `coding_notes.md`, follow the `coding_notes.md` instructions instead.
4. Apply each relevant modification to the file.
5. For each change, add a comment to the migrated code that includes the checklist item information. Example:
  ```properties
  # Migrated from Oracle to PostgreSQL according to property check item 1: Check item 1. Change JDBC URL from Oracle to PostgreSQL.
  #  Migrated from Oracle to PostgreSQL according to coding notes check item: All object names are lowercased in PostgreSQL (unless quoted explicitly).
  ```

## Formula checklist

Property check item 0: Don't modify the content if it's obviously not related to Oracle. For example: these properties are oracle specific:
   - oracle.jdbc
   - ojdbc
   - hibernate.dialect=org.hibernate.dialect.OracleDialect
   - database.port=1521
   - spring.datasource.url=jdbc:oracle
   - spring.datasource.driver-class-name=oracle.jdbc.OracleDriver
   - SELECT 1 FROM DUAL

Property check item 1: Change JDBC URL from Oracle to PostgreSQL.
  - Standard JDBC URL
  ```properties
    # Before migration (Oracle)
    spring.datasource.url=jdbc:oracle:thin:@localhost:1521:ORCL
    # After migration (PostgreSQL)
    spring.datasource.url=jdbc:postgresql://localhost:5432/postgres
    ```

  - H2 Database in Compatibility Mode
    ```properties
    # Before migration (H2 in Oracle Compatibility Mode)
    spring.datasource.url=jdbc:h2:~/test_oracle;MODE=Oracle
    # After migration (H2 in PostgreSQL Compatibility Mode)
    spring.datasource.url=jdbc:h2:~/test_postgres;MODE=PostgreSQL
    ```

Property check item 2: Replace Oracle JDBC driver class with PostgreSQL driver class.
  ```properties
  # Before migration (Oracle)
  spring.datasource.driver-class-name=oracle.jdbc.OracleDriver

  # After migration (PostgreSQL)
  spring.datasource.driver-class-name=org.postgresql.Driver
  ```

Property check item 3: Change Hibernate dialect from Oracle to PostgreSQL.
  ```properties
  # Before migration (Oracle)
  spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.OracleDialect

  # After migration (PostgreSQL)
  spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
  ```

Property check item 4: If port property is Oracle specific, then replace with PostgreSQL equivalents.
  ```properties
  # Before migration (Oracle)
  database.port=1521

  # After migration (PostgreSQL)
  database.port=5432
  ```

Property check item 5: Change username and password to environment variable placeholder.
  ```properties
  # Before migration (Oracle)
  spring.datasource.username=original-username
  spring.datasource.password=original-password

  # After migration (PostgreSQL)
  spring.datasource.username=${POSTGRES_USERNAME}
  spring.datasource.password=${POSTGRES_PASSWORD}
  ```

Property check item 6: If schema property is Oracle specific, then replace with PostgreSQL equivalents.
  ```properties
  # Before migration (Oracle)
  spring.jpa.properties.hibernate.default_schema=HR

  # After migration (PostgreSQL)
  spring.jpa.properties.hibernate.default_schema=public
  ```

Property check item 7: If other Oracle-specific properties exists, then replace with PostgreSQL equivalents.
  ```properties
  # Before migration (Oracle)
  spring.datasource.validationQuery=SELECT 1 FROM DUAL

  # After migration (PostgreSQL)
  spring.datasource.validationQuery=SELECT 1
  ```

Property check item 8: Enable passwordless connection. Update the PostgreSQL JDBC URL to support auth by manage identity.
Follow these steps:
1. Add these parameters to the PostgreSQL JDBC URL:
  - user=${MANAGED_IDENTITY_NAME}
  - sslmode=require
  - authenticationPluginClassName=com.azure.identity.extensions.jdbc.postgresql.AzurePostgresqlAuthenticationPlugin
  - azure.managedIdentityEnabled=true
  - azure.clientId=${MANAGED_IDENTITY_CLIENT_ID}
2. Use environment variable for database host/port/database name if the original value is not Azure PostgreSQL.
3. Add comments about environment variables in the PostgreSQL JDBC URL.
4. Comment out all "username" and "password" related content which are ONLY corresponding to the PostgreSQL JDBC URL.
5. Example: Property file difference fragment
    ```diff
    - url:  jdbc:postgresql://localhost:5432/testdb
    - username: testuser
    - password: testpass
    + # Remember to set the value for the environment variables in the url value below
    + # For Azure sovereign cloud, add these parameters in the url:
    + #  azure.scopes
    + #     - azure_china: https://ossrdbms-aad.database.chinacloudapi.cn/.default
    + #     - azure_germany: https://ossrdbms-aad.database.cloudapi.de/.default
    + #     - azure_us_government: https://ossrdbms-aad.database.usgovcloudapi.net/.default
    + #     - azure: https://ossrdbms-aad.database.windows.net/.default
    + #  azure.authorityHost
    + #     - azure_china: https://login.partner.microsoftonline.cn
    + #     - azure_germany: https://login.microsoftonline.de
    + #     - azure_us_government: https://login.microsoftonline.us
    + #     - azure: https://login.microsoftonline.com
    + url: jdbc:postgresql://${PGHOST}:${PGPORT}/${PGDATABASE}?user=${MANAGED_IDENTITY_NAME}&sslmode=require&authenticationPluginClassName=com.azure.identity.extensions.jdbc.postgresql.AzurePostgresqlAuthenticationPlugin&azure.managedIdentityEnabled=true&azure.clientId=${MANAGED_IDENTITY_CLIENT_ID}
    + # Comment out all content about "username" and "password" because now PostgreSQL will authenticate using managed identity.
    + # username: testuser
    + # password: testpass
    ```

Property check item 9: Add example PostgreSQL JDBC URL to show how to auth by service principal.
1. These parameters are required:
  - user=${SERVICE_PRINCIPAL_NAME}
  - sslmode=require
  - authenticationPluginClassName=com.azure.identity.extensions.jdbc.postgresql.AzurePostgresqlAuthenticationPlugin
  - azure.clientId=${SERVICE_PRINCIPAL_CLIENT_ID}
  - azure.clientSecret=${SERVICE_PRINCIPAL_CLIENT_SECRET}
  - azure.tenantId=${SERVICE_PRINCIPAL_TENANT_ID}
2. Example: Property file difference fragment
    ```diff
    + # Example url of auth by Service Principal instead of Managed Identity
    + # url: jdbc:postgresql://${PGHOST}:${PGPORT}/${PGDATABASE}?user=${SERVICE_PRINCIPAL_NAME}&sslmode=require&authenticationPluginClassName=com.azure.identity.extensions.jdbc.postgresql.AzurePostgresqlAuthenticationPlugin&azure.clientId=${SERVICE_PRINCIPAL_CLIENT_ID}&azure.clientSecret=${SERVICE_PRINCIPAL_CLIENT_SECRET}&azure.tenantId=${SERVICE_PRINCIPAL_TENANT_ID}
    ```

Property check item 9999: Migrate all other Oracle-specific content to PostgreSQL. For each line, carefully verify whether it uses Oracle-only features.



## Migrate SQL scripts from Oracle to PostgreSQL

Update SQL files for Oracle to PostgreSQL migration

### Search code
Search files from workspace using below patterns:
- Glob pattern to find files: `**/*.sql`
- Regex pattern to find code lines: `(?i)VARCHAR2|CLOB|BLOB|SYSDATE|ROWNUM|ROWID|NOCOPY|TABLE|PROCEDURE|CONNECT BY\s+|START WITH|BULK COLLECT|FORALL|PL/SQL|NOCACHE|DUAL|PRAGMA|JOIN\s+|CREATE\s+|ALTER\s+|SELECT\s+|INSERT\s+|UPDATE\s+`

### Instruction


Your task is to migrate SQL scripts from Oracle syntax to PostgreSQL compatibility.

Follow these steps:
1. Locate the `coding_notes.md` file:
  - If `coding_notes.md` is already provided in the prompt or context, use it and skip to step 2.
  - Otherwise, search for `coding_notes.md` in the migration project workspace using the pattern `.github/postgres-migrations/*/results/application_guidance/coding_notes.md`.
  - If multiple files are found, compare their modification timestamps and use the most recently modified file.
  - If no `coding_notes.md` file is found, proceed to step 3 using only the formula checklist.
2. If `coding_notes.md` is found, read its entire content before listing files that need to be migrated.
  - The file contains project-specific migration guidance and rules that must be read before listing files that need to be migrated.
  - The file may exceed 1,000 lines; ensure you read it completely from start to end.
3. Review the formula checklist items below. **Priority rule**: If any checklist item conflicts with guidance in `coding_notes.md`, follow the `coding_notes.md` instructions instead.
4. Apply each relevant modification to the file.
5. For each change, add a comment to the migrated code that includes the checklist item information. Example:
  ```sql
  -- Migrated from Oracle to PostgreSQL according to SQL check item 1: Use lowercase for identifiers (like table and column names) and data type (like varchar), use uppercase for SQL keywords (like SELECT, FROM, WHERE).
  -- Migrated from Oracle to PostgreSQL according to coding notes check item: All object names are lowercased in PostgreSQL (unless quoted explicitly).
  ```

## Formula checklist

SQL check item 0: Don't modify the content if it's obviously not related to Oracle. For example: File named mysql-schema.sql, file with path mysql/schema.sql. However, also scan the file content for Oracle-specific keywords (e.g., VARCHAR2, NUMBER, etc.) to ensure it does not contain Oracle-related syntax before excluding it.

SQL check item 1: Use lowercase for identifiers (like table and column names) and data type (like varchar), use uppercase for SQL keywords (like SELECT, FROM, WHERE).
  ```sql
  -- Before migration (Oracle)
  CREATE TABLE EMPLOYEES (
      EMPLOYEE_ID NUMBER(6) PRIMARY KEY,
      FIRST_NAME VARCHAR2(20),
      LAST_NAME VARCHAR2(25) NOT NULL,
      EMAIL VARCHAR2(25) UNIQUE,
      SALARY NUMBER(8,2)
  );
  ALTER TABLE QRTZ_SIMPROP_TRIGGERS
      ADD CONSTRAINT FK_QRTZ_SIMPROP_TRIGGERS_QRTZ_TRIGGERS FOREIGN KEY (
          SCHED_NAME,
          TRIGGER_NAME,
          TRIGGER_GROUP
      ) REFERENCES QRTZ_TRIGGERS (
          SCHED_NAME,
          TRIGGER_NAME,
          TRIGGER_GROUP
      ) ON DELETE CASCADE;


  -- After migration (PostgreSQL)
  CREATE TABLE employees (
      employee_id INTEGER PRIMARY KEY,
      first_name varchar(20),
      last_name varchar(25) NOT NULL,
      email varchar(25) UNIQUE,
      salary numeric(8,2)
  );
  ALTER TABLE qrtz_simprop_triggers
      ADD CONSTRAINT fk_qrtz_simprop_triggers_qrtz_triggers FOREIGN KEY (
          sched_name,
          trigger_name,
          trigger_group
      ) REFERENCES qrtz_triggers (
          sched_name,
          trigger_name,
          trigger_group
      ) ON DELETE CASCADE;
  ```

SQL check item 2: Replace Oracle-specific data types with PostgreSQL equivalents (NUMBER→INTEGER, VARCHAR2→VARCHAR, etc).
  ```sql
  -- Before migration (Oracle)
  CREATE TABLE PRODUCTS (
      PRODUCT_ID NUMBER PRIMARY KEY,
      NAME VARCHAR2(100),
      DESCRIPTION CLOB,
      IMAGE BLOB,
      CREATED_DATE DATE,
      MODIFIED_TIMESTAMP TIMESTAMP
  );

  -- After migration (PostgreSQL)
  CREATE TABLE products (
      product_id SERIAL PRIMARY KEY,
      name varchar(100),
      description text,
      image bytea,
      created_date date,
      modified_timestamp timestamp
  );
  ```

SQL check item 3: Remove FROM DUAL in SELECT statements that only return values.
  ```sql
  -- Before migration (Oracle)
  SELECT SYSDATE FROM DUAL;

  -- After migration (PostgreSQL)
  SELECT CURRENT_DATE;
  ```

SQL check item 4: Convert Oracle's TO_DATE format to PostgreSQL ISO date literals.
  ```sql
  -- Before migration (Oracle)
  INSERT INTO EMPLOYEES (HIRE_DATE)
  VALUES (TO_DATE('17-JUN-2003', 'DD-MON-YYYY'));

  -- After migration (PostgreSQL)
  INSERT INTO employees (hire_date)
  VALUES ('2003-06-17');
  ```

SQL check item 5: Replace Oracle MERGE with PostgreSQL alternatives
  ```sql
  -- Case 1: For upsert operations (INSERT + UPDATE)
  -- Before migration (Oracle)
  MERGE INTO DEPARTMENTS d
  USING (SELECT 70 AS dept_id, 'Public Relations' AS dept_name FROM dual) src
  ON (d.DEPARTMENT_ID = src.dept_id)
  WHEN MATCHED THEN
      UPDATE SET d.DEPARTMENT_NAME = src.dept_name
  WHEN NOT MATCHED THEN
      INSERT (DEPARTMENT_ID, DEPARTMENT_NAME)
      VALUES (src.dept_id, src.dept_name);

  -- After migration (PostgreSQL)
  INSERT INTO departments (department_id, department_name)
  VALUES (70, 'Public Relations')
  ON CONFLICT (department_id)
  DO UPDATE SET
      department_name = EXCLUDED.department_name;

  -- Case 2: For update-only operations with joined data
  -- Before migration (Oracle)
  merge into DIALOG d
  using ID_MAPPINGER@VEILARBAKTIVITET idm on (d.ARENA_ID = idm.EKSTERN_REFERANSE_ID)
  when matched then
  update set d.AKTIVITET_ID = idm.AKTIVITET_ID;

  -- After migration (PostgreSQL)
  UPDATE dialog d
  SET aktivitet_id = idm.aktivitet_id
  FROM id_mappinger idm
  WHERE d.arena_id = idm.ekstern_referanse_id;
  ```

SQL check item 6: Replace CONNECT BY hierarchical queries with recursive CTEs.
  ```sql
  -- Before migration (Oracle)
  SELECT
      employee_id,
      last_name,
      LEVEL as hierarchy_level
  FROM EMPLOYEES
  START WITH manager_id IS NULL
  CONNECT BY PRIOR employee_id = manager_id;

  -- After migration (PostgreSQL)
  WITH RECURSIVE emp_hierarchy AS (
      -- Base case
      SELECT
          employee_id,
          last_name,
          1 as hierarchy_level
      FROM employees
      WHERE manager_id IS NULL

      UNION ALL

      -- Recursive case
      SELECT
          e.employee_id,
          e.last_name,
          eh.hierarchy_level + 1
      FROM
          employees e
      JOIN
          emp_hierarchy eh ON e.manager_id = eh.employee_id
  )
  SELECT
      employee_id,
      last_name,
      hierarchy_level
  FROM emp_hierarchy;
  ```

SQL check item 7: Replace ROWNUM-based pagination with LIMIT/OFFSET.
  ```sql
  -- Before migration (Oracle)
  SELECT * FROM EMPLOYEES
  WHERE ROWNUM <= 10
  ORDER BY SALARY DESC;

  -- After migration (PostgreSQL)
  SELECT * FROM employees
  ORDER BY salary DESC
  LIMIT 10;
  ```

SQL check item 8: Convert Oracle sequences to PostgreSQL sequences and update usage syntax.
  ```sql
  -- Before migration (Oracle)
  CREATE SEQUENCE EMPLOYEES_SEQ
  START WITH 1000
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

  -- Oracle sequence usage
  INSERT INTO EMPLOYEES (EMPLOYEE_ID, FIRST_NAME, LAST_NAME)
  VALUES (EMPLOYEES_SEQ.NEXTVAL, 'John', 'Doe');

  -- After migration (PostgreSQL)
  CREATE SEQUENCE employees_seq
  START WITH 1000
  INCREMENT BY 1;

  -- PostgreSQL sequence usage
  INSERT INTO employees (employee_id, first_name, last_name)
  VALUES (nextval('employees_seq'), 'John', 'Doe');
  ```

SQL check item 9: Replace DATABASE LINK with postgres_fdw Foreign Data Wrapper.
  ```sql
  -- Before migration (Oracle)
  CREATE DATABASE LINK remote_db
    CONNECT TO remote_user IDENTIFIED BY remote_password
    USING 'remote_tns_entry';

  SELECT * FROM items@remote_db;

  -- After migration (PostgreSQL)
  CREATE EXTENSION postgres_fdw;

  CREATE SERVER remote_server
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host 'remote_host', dbname 'remote_db', port '5432');

  CREATE USER MAPPING FOR local_user
  SERVER remote_server
  OPTIONS (user 'remote_user', password 'remote_password');

  CREATE FOREIGN TABLE remote_items (
      item_id integer,
      item_name varchar(100)
  )
  SERVER remote_server
  OPTIONS (schema_name 'public', table_name 'items');

  SELECT * FROM remote_items;
  ```

SQL check item 10: Replace GENERATED ALWAYS AS IDENTITY with SERIAL for auto-incrementing keys.
  ```sql
  -- Before migration (Oracle)
  CREATE TABLE log_entries (
      LOG_ID NUMBER GENERATED ALWAYS AS IDENTITY,
      LOG_MESSAGE VARCHAR2(200),
      LOG_TIMESTAMP TIMESTAMP DEFAULT SYSTIMESTAMP,
      PARENT_LOG_ID NUMBER
  );

  -- After migration (PostgreSQL)
  CREATE TABLE log_entries (
      log_id serial PRIMARY KEY,
      log_message varchar(200),
      log_timestamp timestamp DEFAULT CURRENT_TIMESTAMP,
      parent_log_id integer
  );
  ```

SQL check item 11: Convert Oracle NOCACHE to PostgreSQL (omit or use CACHE 1)
  ```sql
  -- Case 1: Using default behavior (omitting CACHE directive)
  -- Before migration (Oracle)
  CREATE SEQUENCE items_seq
      START WITH 1000
      INCREMENT BY 1
      NOCACHE
      NOCYCLE;

  -- After migration (PostgreSQL)
  CREATE SEQUENCE items_seq
      START WITH 1000
      INCREMENT BY 1
      NO CYCLE;

  -- Case 2: Explicitly setting CACHE 1
  -- Before migration (Oracle)
  CREATE SEQUENCE order_seq
      START WITH 5000
      INCREMENT BY 1
      NOCACHE
      NOCYCLE;

  -- After migration (PostgreSQL)
  CREATE SEQUENCE order_seq
      START WITH 5000
      INCREMENT BY 1
      CACHE 1
      NO CYCLE;
  ```

SQL check item 12: Convert procedure syntax from PL/SQL to PL/pgSQL with dollar-quoted bodies.
  ```sql
  -- Before migration (Oracle)
  CREATE OR REPLACE PROCEDURE update_item_value(
      p_item_id IN ITEMS.ITEM_ID%TYPE,
      p_percent IN NUMBER
  ) IS
  BEGIN
      UPDATE ITEMS
      SET VALUE = VALUE * (1 + p_percent/100)
      WHERE ITEM_ID = p_item_id;
      COMMIT;
  EXCEPTION
      WHEN OTHERS THEN
          ROLLBACK;
          RAISE;
  END update_item_value;
  /

  -- After migration (PostgreSQL)
  CREATE OR REPLACE PROCEDURE update_item_value(
      p_item_id bigint,
      p_percent numeric
  ) AS $$
  BEGIN
      UPDATE items
      SET value = value * (1 + p_percent/100)
      WHERE item_id = p_item_id;
  EXCEPTION
      WHEN OTHERS THEN
          RAISE;
  END;
  $$ LANGUAGE plpgsql;
  ```

SQL check item 13: Convert function syntax from PL/SQL to PL/pgSQL with dollar quotes and explicit RETURNS.
  ```sql
  -- Before migration (Oracle)
  CREATE OR REPLACE FUNCTION calculate_total(
      p_value IN ITEMS.VALUE%TYPE,
      p_tax_pct IN NUMBER
  ) RETURN NUMBER IS
      v_total NUMBER;
  BEGIN
      v_total := p_value * (1 + p_tax_pct/100);
      RETURN v_total;
  END calculate_total;
  /

  -- After migration (PostgreSQL)
  CREATE OR REPLACE FUNCTION calculate_total(
      p_value numeric,
      p_tax_pct numeric
  ) RETURNS numeric AS $$
  DECLARE
      v_total numeric;
  BEGIN
      v_total := p_value * (1 + p_tax_pct/100);
      RETURN v_total;
  END;
  $$ LANGUAGE plpgsql;
  ```

SQL check item 14: Split packages into separate standalone functions and procedures.
  ```sql
  -- Before migration (Oracle)
  CREATE OR REPLACE PACKAGE item_manager AS
      PROCEDURE get_item_info(
          p_item_id IN NUMBER,
          p_result OUT SYS_REFCURSOR
      );

      FUNCTION calculate_discount(
          p_item_id IN NUMBER,
          p_percent IN NUMBER
      ) RETURN NUMBER;
  END item_manager;
  /

  -- After migration (PostgreSQL)
  -- Create separate procedure
  CREATE OR REPLACE PROCEDURE get_item_info(
      p_item_id integer,
      INOUT p_result refcursor
  ) AS $$
  BEGIN
      p_result := 'item_cursor';
      OPEN p_result FOR
      SELECT i.*, c.category_name
      FROM items i
      JOIN categories c ON i.category_id = c.category_id
      WHERE i.item_id = p_item_id;
  END;
  $$ LANGUAGE plpgsql;

  -- Create separate function
  CREATE OR REPLACE FUNCTION calculate_discount(
      p_item_id integer,
      p_percent integer
  ) RETURNS numeric AS $$
  DECLARE
      v_price items.price%TYPE;
      v_discount numeric;
  BEGIN
      SELECT price INTO v_price FROM items WHERE item_id = p_item_id;
      v_discount := v_price * (p_percent::numeric / 100);
      RETURN v_discount;
  END;
  $$ LANGUAGE plpgsql;
  ```

SQL check item 15: Convert package body functions to standalone PL/pgSQL functions.
  ```sql
  -- Before migration (Oracle)
  CREATE OR REPLACE PACKAGE HR AS
      FUNCTION CALCULATE_BONUS(
          p_employee_id IN NUMBER,
          p_percent IN NUMBER
      ) RETURN NUMBER;
  END HR;
  /

  CREATE OR REPLACE PACKAGE BODY HR AS
      FUNCTION CALCULATE_BONUS(
          p_employee_id IN NUMBER,
          p_percent IN NUMBER
      ) RETURN NUMBER
      IS
          v_salary NUMBER;
          v_bonus NUMBER;
      BEGIN
          SELECT SALARY INTO v_salary
          FROM EMPLOYEES
          WHERE EMPLOYEE_ID = p_employee_id;

          v_bonus := v_salary * (p_percent/100);
          RETURN v_bonus;
      END CALCULATE_BONUS;
  END HR;
  /

  -- After migration (PostgreSQL)
  CREATE OR REPLACE FUNCTION calculate_bonus(
      p_employee_id integer,
      p_percent integer
  ) RETURNS numeric AS $$
  DECLARE
      v_salary numeric;
      v_bonus numeric;
  BEGIN
      SELECT salary INTO v_salary
      FROM employees
      WHERE employee_id = p_employee_id;

      v_bonus := v_salary * (p_percent::numeric / 100);
      RETURN v_bonus;
  END;
  $$ LANGUAGE plpgsql;
  ```

SQL check item 16: Remove Oracle-specific features that have no direct PostgreSQL equivalent, including storage clauses, tablespace specifications, and other Oracle-specific optimizations that have no easy PostgreSQL counterpart.
  ```sql
  -- Before migration (Oracle)
  ALTER TABLE users
      ADD CONSTRAINT users_pk PRIMARY KEY (user_id)
          USING INDEX PCTFREE 10 INITRANS 2 TABLESPACE users LOGGING
              STORAGE (
                  INITIAL 65536
                  NEXT 1048576
                  PCTINCREASE 0
                  MINEXTENTS 1
                  MAXEXTENTS 2147483645
                  FREELISTS 1
                  FREELIST GROUPS 1
                  BUFFER_POOL DEFAULT
              );

  -- After migration (PostgreSQL)
  ALTER TABLE users
      ADD CONSTRAINT users_pk PRIMARY KEY (user_id);
  ```

SQL check item 9999: Migrate all other Oracle-specific content to PostgreSQL. For each line, carefully verify whether it uses Oracle-only features.
