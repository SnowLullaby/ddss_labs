SELECT spcname, pg_tablespace_location(oid)
FROM pg_tablespace
WHERE spcname IN ('uvx79','hqj18')
ORDER BY spcname;

SELECT COALESCE(t.spcname, 'pg_default') AS tablespace,
       n.nspname || '.' || c.relname AS object,
       CASE c.relkind
         WHEN 'r' THEN 'table'
         WHEN 'i' THEN 'index'
         WHEN 'S' THEN 'sequence'
         ELSE c.relkind::text
       END AS type
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_tablespace t ON t.oid = c.reltablespace
WHERE t.spcname IN ('uvx79','hqj18')
  AND c.relkind IN ('r','i','S')
ORDER BY 1,2,3;