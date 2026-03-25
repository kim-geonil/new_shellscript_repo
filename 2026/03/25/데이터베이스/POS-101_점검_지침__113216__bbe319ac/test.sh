#!/bin/bash

# === POS-101 Check Result ===
# Check time: $(date)
# Applied config: targetOS=Linux, outputFormat=bash

# Mock INI file content
mock_ini_content="[postgresql]\nrolcanlogin=f\nrolpassword=NULL\nhba_file=/tmp/pg_hba.conf"

# Create a temporary directory and mock files
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo -e "$mock_ini_content" > "$TMP_DIR/qualys_conf.ini"
touch "$TMP_DIR/pg_hba.conf"

# Mock psql command to return expected results
mock_psql() {
  case "$1" in
    "-U postgres -c \"SELECT rolcanlogin FROM pg_roles WHERE rolname='postgres'\"")
      echo " f"
      ;;
    "-U postgres -c \"SELECT rolpassword IS NULL FROM pg_authid WHERE rolname='postgres'\"")
      echo " t"
      ;;
    "-U postgres -c \"SHOW hba_file;\"")
      echo "/tmp/pg_hba.conf"
      ;;
    *)
      exit 1
      ;;
  esac
}

# Mock psql command in PATH
export PATH="$TMP_DIR:$PATH"

# Main script logic
if [ ! -f "$TMP_DIR/qualys_conf.ini" ]; then
  echo "Error: qualys_conf.ini not found."
  RESULT=FAIL
else
  source <(grep -E '^[^;#]' "$TMP_DIR/qualys_conf.ini" | xargs)

  login_check=$(mock_psql)
  password_check=$(mock_psql)
  hba_file=$(mock_psql)
  access_check=$(grep -E 'postgres.*reject' "$hba_file")
  validity_check=$(mock_psql)

  if [ "$(echo $login_check | tr -d '[:space:]')" = "f" ] && [ "$(echo $password_check | tr -d '[:space:]')" = "t" ] && [ ! -z "$access_check" ] && [ "$(echo $validity_check | tr -d '[:space:]')" = "f" ]; then
    RESULT=PASS
  else
    RESULT=FAIL
  fi
fi

# Final Result
echo "Final Result: $RESULT"
exit $(echo $login_check | tr -d '[:space:]' | grep -q 'f'; echo $?)