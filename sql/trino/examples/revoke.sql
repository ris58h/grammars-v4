REVOKE INSERT, DELETE ON t FROM u;
REVOKE UPDATE ON t FROM u;
REVOKE GRANT OPTION FOR SELECT ON t FROM ROLE PUBLIC;
REVOKE ALL PRIVILEGES ON TABLE t FROM USER u;
REVOKE DELETE ON TABLE "t" FROM "u";
REVOKE SELECT ON SCHEMA s FROM USER u;