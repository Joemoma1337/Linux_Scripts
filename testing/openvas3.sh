echo "Run the following commands:"
echo "sudo -u postgres bash"
echo "cd"
echo "createuser -DRS gvm"
echo "createdb -O gvm gvmd"
echo 'psql gvmd -c "create role dba with superuser noinherit; grant dba to gvm;"'
echo "exit"