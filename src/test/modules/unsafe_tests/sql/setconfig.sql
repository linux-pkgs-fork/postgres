-- This is borderline unsafe in that an additional login-capable user exists
-- during the test run.  Under installcheck, a too-permissive pg_hba.conf
-- might allow unwanted logins as regress_authenticated_user_ssa.

ALTER USER regress_authenticated_user_ssa superuser;
CREATE ROLE regress_session_user;
CREATE ROLE regress_current_user;
GRANT regress_current_user TO regress_authenticated_user_sr;
GRANT regress_session_user TO regress_authenticated_user_ssa;
ALTER ROLE regress_authenticated_user_ssa
	SET session_authorization = regress_session_user;
ALTER ROLE regress_authenticated_user_sr SET ROLE = regress_current_user;

\c - regress_authenticated_user_sr
SELECT current_user, session_user;

-- The longstanding historical behavior is that session_authorization in
-- setconfig has no effect.  Hence, session_user remains
-- regress_authenticated_user_ssa.  See comment in InitializeSessionUserId().
\c - regress_authenticated_user_ssa
SELECT current_user, session_user;
RESET SESSION AUTHORIZATION;
DROP USER regress_session_user;
DROP USER regress_current_user;