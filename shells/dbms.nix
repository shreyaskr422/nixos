{ pkgs, ... }:

pkgs.mkShell {
  name = "dbms";

  packages = with pkgs; [
    postgresql
    pgcli
    dbeaver-bin
  ];

  shellHook = ''
    export DBMS_ROOT="$HOME/.local/share/dbms"
    export PGDATA="$DBMS_ROOT/postgres"
    export PGHOST="$DBMS_ROOT/socket"

    mkdir -p "$DBMS_ROOT"
    mkdir -p "$PGHOST"

    if [ ! -d "$PGDATA" ]; then
      echo "Initializing PostgreSQL at $PGDATA"
      initdb -D "$PGDATA" \
        --no-locale \
        --encoding=UTF8 \
        --auth-local=trust \
        --auth-host=trust >/dev/null

      sed -i "s|^#\?unix_socket_directories.*|unix_socket_directories = '$PGHOST'|" \
        "$PGDATA/postgresql.conf"
    fi

    echo "DBMS development environment"
    echo "PostgreSQL: $(psql --version)"
    echo "pgcli:      $(pgcli --version)"
    echo
    echo "PGDATA: $PGDATA"
    echo "PGHOST: $PGHOST"
    echo 'Start DB: pg_ctl -D "$PGDATA" -l "$DBMS_ROOT/postgres.log" start'
    echo 'Stop DB:  pg_ctl -D "$PGDATA" stop'
    echo 'Connect:  psql postgres'
  '';
}
