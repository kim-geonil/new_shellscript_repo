#!/bin/bash

# === POS-101 Check Result ===
# Check time: $(date)
# Applied config: targetOS=Linux, outputFormat=bash

# Load INI file
if [ ! -f "qualys_conf.ini" ]; then
  echo "Error: qualys_conf.ini not found."
  exit 1
fi

source <(grep -E '^[^;#]' qualys_conf.ini | xargs)

# Check PostgreSQL login permission
login_check=$(psql -U postgres -c "SELECT rolcanlogin FROM pg_roles WHERE rolname='postgres'" 2>/dev/null)
if [ "$login_check" != " f" ]; then
  echo "Check 1: Fail (PostgreSQL login permission is not disabled)"
else
  echo "Check 1: Pass"
fi

# Check PostgreSQL password setting
password_check=$(psql -U postgres -c "SELECT rolpassword IS NULL FROM pg_authid WHERE rolname='postgres'" 2>/dev/null)
if [ "$password_check" != " t" ]; then
  echo "Check 2: Fail (PostgreSQL password is not set)"
else
  echo "Check 2: Pass"
fi

# Check access control in pg_hba.conf
hba_file=$(psql -U postgres -c "SHOW hba_file;" 2>/dev/null)
if [ ! -f "$hba_file" ]; then
  echo "Error: pg_hba.conf not found."
  exit 1
fi

access_check=$(grep -E 'postgres.*reject' $hba_file 2>/dev/null)
if [ -z "$access_check" ]; then
  echo "Check 3: Fail (PostgreSQL access control is not properly configured)"
else
  echo "Check 3: Pass"
fi

# Check account validity period
validity_check=$(psql -U postgres -c "SELECT rolvaliduntil < now() FROM pg_authid WHERE rolname='postgres'" 2>/dev/null)
if [ "$validity_check" != " f" ]; then
  echo "Check 4: Fail (PostgreSQL account validity period is not set to past date)"
else
  echo "Check 4: Pass"
fi

# Final Result
if [ "$(echo $login_check | tr -d '[:space:]')" = "f" ] && [ "$(echo $password_check | tr -d '[:space:]')" = "t" ] && [ ! -z "$access_check" ] && [ "$(echo $validity_check | tr -d '[:space:]')" = "f" ]; then
  echo "Final Result: Pass"
else
  echo "Final Result: Fail"
fi
exit $(echo $login_check | tr -d '[:space:]' | grep -q 'f'; echo $?)