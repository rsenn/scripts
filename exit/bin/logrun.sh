. @HOME@/etc/conf
. @HOME@/etc/functions
LOGNAME=$LOG/$(basename `dirname $PWD`)
mkdir -p $LOGNAME
test -L ./main || ln -s $LOGNAME ./main
chowner $logUSER $LOGNAME
chowner $logUSER ./main
exec setuidgid $logUSER multilog t s1000000 ./main
