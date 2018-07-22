#检查IP服务
check_ipaddr()
{
    echo $1|grep "^[0-9]\{1,3\}\.\([0-9]\{1,3\}\.\)\{2\}[0-9]\{1,3\}$" > /dev/null;
    if [ $? -ne 0 ]
    then
        return 1
    fi
    ipaddr=$1
    a=`echo $ipaddr|awk -F . '{print $1}'`
    b=`echo $ipaddr|awk -F . '{print $2}'`
    c=`echo $ipaddr|awk -F . '{print $3}'`
    d=`echo $ipaddr|awk -F . '{print $4}'`
    for num in $a $b $c $d
    do
        if [ $num -gt 255 ] || [ $num -lt 0 ]
        then
            return 1
        fi
   done
   return 0
}
#安装系统必须组件服务
install_needs(){
echo 'deb http://mirrors.163.com/debian/ jessie main non-free contrib
deb http://mirrors.163.com/debian/ jessie-updates main non-free contrib
deb http://mirrors.163.com/debian/ jessie-backports main non-free contrib
deb-src http://mirrors.163.com/debian/ jessie main non-free contrib
deb-src http://mirrors.163.com/debian/ jessie-updates main non-free contrib
deb-src http://mirrors.163.com/debian/ jessie-backports main non-free contrib
deb http://mirrors.163.com/debian-security/ jessie/updates main non-free contrib
deb-src http://mirrors.163.com/debian-security/ jessie/updates main non-free contrib' > /etc/apt/sources.list
apt-get -y update
if [ $? != 0 ]; then
  echo "apt-get -y update" >> log
fi

apt-get -y upgrade
if [ $? != 0 ]; then
  echo "apt-get -y upgrade" >> log
fi

apt-get install -y gcc
if [ $? != 0 ]; then
  echo "apt-get install -y gcc" >> log
fi
apt-get install -y g++
if [ $? != 0 ]; then
  echo "apt-get install -y g++" >> log
fi
apt-get install -y make
if [ $? != 0 ]; then
  echo "apt-get install -y make" >> log
fi
apt-get install -y wget
if [ $? != 0 ]; then
  echo "apt-get install -y wget" >> log
fi
apt-get install -y unzip ntpdate
if [ $? != 0 ]; then
  echo "apt-get install -y unzip ntpdate" >> log
fi
apt-get install -y git
if [ $? != 0 ]; then
  echo "apt-get install -y git" >> log
fi
}

#安装LNMP服务
install_lnmp(){
#安装NGINX服务
apt-get install -y nginx
if [ $? != 0 ]; then
  echo "apt-get install -y nginx" >> log
fi
#安装mysql服务
apt-get install -y mysql-server mysql-client
if [ $? != 0 ]; then
  echo "apt-get install -y mysql-server mysql-client" >> log
fi
#安装PHP服务
apt-get install -y php5-fpm
if [ $? != 0 ]; then
  echo "apt-get install -y php5-fpm" >> log
fi
#安装PHP扩展服务
apt-get install -y php5-gd php5-mysql php5-curl php5-imagick php5-mcrypt php5-odbc
if [ $? != 0 ]; then
  echo "apt-get install -y php5-gd php5-mysql php5-curl php5-imagick php5-mcrypt php5-odbc" >> log
fi

#配置NGINX服务
echo 'user www-data;
worker_processes 4;
pid /run/nginx.pid;
events {
    worker_connections 768;
    # multi_accept on;
}
http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_names_hash_bucket_size 128;
        client_header_buffer_size 32k;
        large_client_header_buffers 4 32k;
        client_max_body_size 500m;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
    ssl_prefer_server_ciphers on;
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
        gzip on;
        gzip_min_length  1k;
        gzip_buffers     4 16k;
        gzip_http_version 1.1;
        gzip_comp_level 2;
        gzip_types     text/plain application/javascript application/x-javascript text/javascript text/css application/xml application/xml+rss;
        gzip_vary on;
        gzip_proxied   expired no-cache no-store private auth;
        gzip_disable   "MSIE [1-6]\.";
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}'>/etc/nginx/nginx.conf
if [ $? != 0 ]; then
  echo "Please check conf:/etc/nginx/nginx.conf" >> log
fi
echo 'server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /home/wwwroot/default;
    index index.html index.htm index.nginx-debian.html index.php;

    server_name _;
    fastcgi_connect_timeout 300;
    fastcgi_send_timeout 300;
    fastcgi_read_timeout 300;
    fastcgi_buffer_size 64k;
    fastcgi_buffers 4 64k;
    fastcgi_busy_buffers_size 128k;
    fastcgi_temp_file_write_size 256k;
    location / {
        try_files $uri $uri/ =404;
    }
    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|js|css)$ {
        add_header Cache-Control no-store;
    }
    location ~ \.php$ {
        add_header Cache-Control no-store;
        root /home/wwwroot/default;
        fastcgi_index index.php;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}'>/etc/nginx/sites-enabled/default
if [ $? != 0 ]; then
  echo "Please check conf:/etc/nginx/sites-enabled/default" >> log
fi

#配置PHP服务
echo '[PHP]
engine = On
short_open_tag = Off
asp_tags = Off
precision = 14
output_buffering = 4096
zlib.output_compression = Off
implicit_flush = Off
unserialize_callback_func =
serialize_precision = 17
disable_functions = pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,
disable_classes =
ignore_user_abort = On
zend.enable_gc = On
expose_php = Off
max_execution_time = 30
max_input_time = 600
memory_limit = 512M
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors = Off
display_startup_errors = Off
log_errors = On
log_errors_max_len = 1024
ignore_repeated_errors = Off
ignore_repeated_source = Off
report_memleaks = On
track_errors = Off
html_errors = On
variables_order = "GPCS"
request_order = "GP"
register_argc_argv = Off
auto_globals_jit = On
post_max_size = 8M
auto_prepend_file =
auto_append_file =
default_mimetype = "text/html"
default_charset = "UTF-8"
doc_root =
user_dir =
enable_dl = Off
file_uploads = On
upload_max_filesize = 100M
max_file_uploads = 20
allow_url_fopen = On
allow_url_include = Off
default_socket_timeout = 60
[CLI Server]
cli_server.color = On
[Date]
date.timezone = Asia/Hong_Kong
[filter]
[iconv]
[intl]
[sqlite3]
[Pcre]
[Pdo]
[Pdo_mysql]
pdo_mysql.cache_size = 2000
pdo_mysql.default_socket=
[Phar]
[mail function]
SMTP = localhost
smtp_port = 25
mail.add_x_header = On
[SQL]
sql.safe_mode = Off
[ODBC]
odbc.allow_persistent = On
odbc.check_persistent = On
odbc.max_persistent = -1
odbc.max_links = -1
odbc.defaultlrl = 4096
odbc.defaultbinmode = 1
[Interbase]
ibase.allow_persistent = 1
ibase.max_persistent = -1
ibase.max_links = -1
ibase.timestampformat = "%Y-%m-%d %H:%M:%S"
ibase.dateformat = "%Y-%m-%d"
ibase.timeformat = "%H:%M:%S"
[MySQL]
mysql.allow_local_infile = On
mysql.allow_persistent = On
mysql.cache_size = 2000
mysql.max_persistent = -1
mysql.max_links = -1
mysql.default_port =
mysql.default_socket =
mysql.default_host =
mysql.default_user =
mysql.default_password =
mysql.connect_timeout = 60
mysql.trace_mode = Off
[MySQLi]
mysqli.max_persistent = -1
mysqli.allow_persistent = On
mysqli.max_links = -1
mysqli.cache_size = 2000
mysqli.default_port = 3306
mysqli.default_socket =
mysqli.default_host =
mysqli.default_user =
mysqli.default_pw =
mysqli.reconnect = Off
[mysqlnd]
mysqlnd.collect_statistics = On
mysqlnd.collect_memory_statistics = Off
[OCI8]
[PostgreSQL]
pgsql.allow_persistent = On
pgsql.auto_reset_persistent = Off
pgsql.max_persistent = -1
pgsql.max_links = -1
pgsql.ignore_notice = 0
pgsql.log_notice = 0
[Sybase-CT]
sybct.allow_persistent = On
sybct.max_persistent = -1
sybct.max_links = -1
sybct.min_server_severity = 10
sybct.min_client_severity = 10
[bcmath]
bcmath.scale = 0
[browscap]
[Session]
session.save_handler = files
session.use_strict_mode = 0
session.use_cookies = 1
session.use_only_cookies = 1
session.name = PHPSESSID
session.auto_start = 0
session.cookie_lifetime = 0
session.cookie_path = /
session.cookie_domain =
session.cookie_httponly =
session.serialize_handler = php
session.gc_probability = 0
session.gc_divisor = 1000
session.gc_maxlifetime = 1440
session.referer_check =
session.cache_limiter = nocache
session.cache_expire = 180
session.use_trans_sid = 0
session.hash_function = 0
session.hash_bits_per_character = 5
url_rewriter.tags = "a=href,area=href,frame=src,input=src,form=fakeentry"
[MSSQL]
mssql.allow_persistent = On
mssql.max_persistent = -1
mssql.max_links = -1
mssql.min_error_severity = 10
mssql.min_message_severity = 10
mssql.compatibility_mode = Off
mssql.secure_connection = Off
[Assertion]
[COM]
[mbstring]
[gd]
[exif]
[Tidy]
tidy.clean_output = Off
[soap]
soap.wsdl_cache_enabled=1
soap.wsdl_cache_dir="/tmp"
soap.wsdl_cache_ttl=86400
soap.wsdl_cache_limit = 5
[sysvshm]
[ldap]
ldap.max_links = -1
[mcrypt]
[dba]
[opcache]
[curl]
[openssl]'>/etc/php5/fpm/php.ini
echo '[www]
user = www-data
group = www-data
listen = /var/run/php5-fpm.sock
listen.owner = www-data
listen.group = www-data
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
chdir = /
php_admin_value[memory_limit] = 128M
php_admin_value[upload_max_filesize] = 128M
php_admin_value[ignore_user_abort] = On
php_admin_value[post_max_size] = 100M
php_admin_value[disable_functions] = pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,
php_admin_value[opcache.enable] = 0
php_admin_value[opcache.validate_timestamps] = 1
php_admin_value[opcache.revalidate_freq] = 0
php_admin_value[session.auto_start] = On
php_admin_value[session.save_path] = /home/wwwroot/default/application/cache
php_admin_value[session.use_cookies] = 1
php_admin_value[session.cookie_lifetime] = 999999999
php_admin_value[session.gc_maxlifetime] = 999999999'>/etc/php5/fpm/pool.d/www.conf
if [ $? != 0 ]; then
  echo "Please check conf:/etc/php5/fpm/pool.d/www.conf and /etc/php5/fpm/php.ini" >> log
fi

#配置mysql服务
echo '[client]
port= 3306
socket= /var/run/mysqld/mysqld.sock
default-character-set=utf8
[mysqld_safe]
socket= /var/run/mysqld/mysqld.sock
nice= 0
[mysqld]
user= mysql
pid-file= /var/run/mysqld/mysqld.pid
socket= /var/run/mysqld/mysqld.sock
port= 3306
basedir= /usr
datadir= /var/lib/mysql
tmpdir= /tmp
lc-messages-dir= /usr/share/mysql
skip-external-locking
bind-address= 0.0.0.0
key_buffer= 16M
max_allowed_packet= 16M
thread_stack= 192K
thread_cache_size = 8
myisam-recover = BACKUP
query_cache_limit= 1M
query_cache_size = 16M
log_error = /var/log/mysql/error.log
expire_logs_days= 10
max_binlog_size = 100M
default-time_zone = "+8:00"
character-set-server=utf8
[mysqldump]
quick
quote-names
max_allowed_packet= 16M
[mysql]
default-character-set=utf8
[isamchk]
key_buffer= 16M
!includedir /etc/mysql/conf.d/
' > /etc/mysql/my.cnf
if [ $? != 0 ]; then
  echo "Please check conf:/etc/mysql/my.cnf" >> log
fi
#重启LNMP服务
/etc/init.d/nginx start
if [ $? != 0 ]; then
  echo "/etc/init.d/nginx start" >> log
fi
/etc/init.d/nginx restart
if [ $? != 0 ]; then
  echo "/etc/init.d/nginx restart" >> log
fi
/etc/init.d/php5-fpm start
if [ $? != 0 ]; then
  echo "/etc/init.d/php5-fpm start" >> log
fi
/etc/init.d/php5-fpm restart
if [ $? != 0 ]; then
  echo "/etc/init.d/php5-fpm restart" >> log
fi
/etc/init.d/mysql start
if [ $? != 0 ]; then
  echo "/etc/init.d/mysql start" >> log
fi
/etc/init.d/mysql restart
if [ $? != 0 ]; then
  echo "/etc/init.d/mysql restart" >> log
fi

}

#安装python扩展服务
install_python(){
if [ ! -f "get-pip.py" ];then
wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py
if [ $? != 0 ]; then
  echo "wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py" >> log
fi
else
python get-pip.py
if [ $? != 0 ]; then
  echo "python get-pip.py" >> log
fi
fi

pip install bs4 && pip install BeautifulSoup && pip install lxml && pip install request && pip install requests && pip install paho-mqtt && pip install DBUtils && pip install logging && pip install feedparser
if [ $? != 0 ]; then
  echo "pip install bs4 && pip install BeautifulSoup && pip install lxml && pip install request && pip install requests && pip install paho-mqtt && pip install DBUtils && pip install logging && pip install feedparser" >> log
fi
apt-get install -y python-mysqldb
if [ $? != 0 ]; then
  echo "apt-get install -y python-mysqldb" >> log
fi

}

#安装视频处理服务
install_ffmpeg(){
echo 'deb http://ftp.uk.debian.org/debian jessie-backports main'>>/etc/apt/sources.list
apt-get install -y ffmpeg
if [ $? != 0 ]; then
  echo "apt-get install -y ffmpeg" >> log
fi
}

#安装EMQTTD服务
install_mqtt(){
wget http://emqtt.com/static/brokers/emqttd-debian8-v2.3-rc.2_amd64.deb && dpkg -i emqttd-debian8-v2.3-rc.2_amd64.deb
if [ $? != 0 ]; then
  echo "wget http://emqtt.com/static/brokers/emqttd-debian8-v2.3-rc.2_amd64.deb && dpkg -i emqttd-debian8-v2.3-rc.2_amd64.deb" >> log
fi
service emqttd start
if [ $? != 0 ]; then
  echo "service emqttd start" >> log
fi
}

#主程序开始
#
#read -p "Please input ip address:" ipaddr
#check_ipaddr ${ipaddr}
#
#if test $? -eq 0
#then
#	ip=${ipaddr}
#else
#	exit
#fi
##获取网关地址服务
#gateway=$(echo ${ip} | sed 's:[^.]*$:1:')
#cat > /etc/network/interfaces << EOF
#source /etc/network/interfaces.d/*
#auto lo
#iface lo inet loopback
#allow-hotplug eth0
#iface eth0 inet static
#address ${ip}
#netmask 255.255.255.0
#gateway ${gateway}
#EOF
#cat > /etc/resolv.conf << EOF
#domain localdomain
#search localdomain
#nameserver ${gateway}
#EOF
#
#/etc/init.d/networking restart
#if [ $? != 0 ]; then
#  echo "/etc/init.d/networking restart" >> log
#fi
echo "+------------------------------------------------------------------------+"
echo "|  Management Center Server Installer                                    |"
echo "+------------------------------------------------------------------------+"
echo "|  A tool to auto-install MC Server Script and nessary extension on Linux|"
echo "+------------------------------------------------------------------------+"
echo "|  Write By James Chen and GaoXin Da@Systec team                         |"
echo "+------------------------------------------------------------------------+"
install_needs
install_lnmp
install_python
install_ffmpeg
install_mqtt
read -p "Please input version:" version
mkdir myrepo
cd myrepo
git init
git config core.sparseCheckout true
git remote add -f ${version} http://192.168.1.254:3000/Management/Management_V2.0.git
echo "Server版管理中心服务端/*" > .git/info/sparse-checkout
git checkout ${version}
if [ -d "/home/wwwroot/default/" ];then
mv Server版管理中心服务端/* /home/wwwroot/default/
chmod 777 /home/ -R
#tar xvf management.tar -C /home/wwwroot/default
else
mkdir /home/wwwroot && mkdir /home/wwwroot/default && chmod 777 /home/ -R
mv Server版管理中心服务端/* /home/wwwroot/default/
#tar xvf management.tar -C /home/wwwroot/default
fi
echo 'export TZ="Asia/Shanghai"' >> /etc/profile
source /etc/profile
echo '1 */8 * * *   root    python /home/wwwroot/default/lib/python/crawlTraffic.py
* * * * * root      php /home/wwwroot/default/cron/crawlMap.php
* * * * * root      python /home/wwwroot/default/lib/python/crawlNews.py
* * * * * root      python /home/wwwroot/default/lib/python/crawlWeather.py
@reboot   root      supervisorctl reload
' >> /etc/crontab

apt-get install -y supervisor
echo '[program:app]
command=/usr/bin/python2.7 /home/wwwroot/default/lib/python/messageHandle.py
autostart=true
autorestart=true
directory=/home/wwwroot/default/lib/python
user=root'>/etc/supervisor/conf.d/app.conf
supervisorctl reload && supervisorctl start app
mysql -uroot -proot <  /home/wwwroot/default/management.sql
echo '#!/bin/sh -e
/usr/bin/supervisord
exit' > /etc/rc.local
cd /usr/lib/systemd/ && mkdir system
echo '#supervisord.service
[Unit]
Description=Supervisor daemon
[Service]
Type=forking
ExecStart=/usr/bin/supervisorctl reload
KillMode=process
Restart=on-failure
RestartSec=42s
[Install]
WantedBy=multi-user.target'>/usr/lib/systemd/system/supervisord.service
systemctl enable supervisord
ntpdate ntp.sjtu.edu.cn
ipaddr=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
output_constant="<?php
defined('SHOW_DEBUG_BACKTRACE') OR define('SHOW_DEBUG_BACKTRACE', TRUE);
defined('FILE_READ_MODE')  OR define('FILE_READ_MODE', 0644);
defined('FILE_WRITE_MODE') OR define('FILE_WRITE_MODE', 0666);
defined('DIR_READ_MODE')   OR define('DIR_READ_MODE', 0755);
defined('DIR_WRITE_MODE')  OR define('DIR_WRITE_MODE', 0755);
defined('FOPEN_READ')                           OR define('FOPEN_READ', 'rb');
defined('FOPEN_READ_WRITE')                     OR define('FOPEN_READ_WRITE', 'r+b');
defined('FOPEN_WRITE_CREATE_DESTRUCTIVE')       OR define('FOPEN_WRITE_CREATE_DESTRUCTIVE', 'wb');
defined('FOPEN_READ_WRITE_CREATE_DESTRUCTIVE')  OR define('FOPEN_READ_WRITE_CREATE_DESTRUCTIVE', 'w+b');
defined('FOPEN_WRITE_CREATE')                   OR define('FOPEN_WRITE_CREATE', 'ab');
defined('FOPEN_READ_WRITE_CREATE')              OR define('FOPEN_READ_WRITE_CREATE', 'a+b');
defined('FOPEN_WRITE_CREATE_STRICT')            OR define('FOPEN_WRITE_CREATE_STRICT', 'xb');
defined('FOPEN_READ_WRITE_CREATE_STRICT')       OR define('FOPEN_READ_WRITE_CREATE_STRICT', 'x+b');
defined('EXIT_SUCCESS')        OR define('EXIT_SUCCESS', 0);
defined('EXIT_ERROR')          OR define('EXIT_ERROR', 1);
defined('EXIT_CONFIG')         OR define('EXIT_CONFIG', 3);
defined('EXIT_UNKNOWN_FILE')   OR define('EXIT_UNKNOWN_FILE', 4);
defined('EXIT_UNKNOWN_CLASS')  OR define('EXIT_UNKNOWN_CLASS', 5);
defined('EXIT_UNKNOWN_METHOD') OR define('EXIT_UNKNOWN_METHOD', 6);
defined('EXIT_USER_INPUT')     OR define('EXIT_USER_INPUT', 7);
defined('EXIT_DATABASE')       OR define('EXIT_DATABASE', 8);
defined('EXIT__AUTO_MIN')      OR define('EXIT__AUTO_MIN', 9);
defined('EXIT__AUTO_MAX')      OR define('EXIT__AUTO_MAX', 125);
defined('SALT')                OR define('SALT', 'woaidalianmao');
defined('TRAFFIC_APK')         OR define('TRAFFIC_APK', '54c3e5a0-9b73-0135-3385-0242c0a80006');
define('SUPER','superadmin');
define('PASSWORD','2d17efbcd61215b017b53b1fe1d28098');
define('ADMIN','admin');
define('ADMIN_PASSWORD','21232f297a57a5a743894a0e4a801fc3');
defined('TOKEN_ERROR')         OR define('TOKEN_ERROR', 'Access Token Error');
define('RES_MONOMER', 1);
define('RES_SHARE', 2);
define('BOOKING_FREE', 0);
define('BOOKING_CLOSED', 1);
define('BOOKING_FULL', 3);
define('BOOKING_NOT_FULL', 2);
define('BOOKING_BOOKED', 2);
define('BOOKING_CHOSE', 99);
define('BOOKING_MIN_TIME', 5);
define('EMQTTD_IP', '127.0.0.1');
define('EMQTTD_PORT', 1883);
define('EMQTTD_API_PORT', 18083);
define('EMQTTD_ID', 'Notice_management');
define('EMQTTD_USER', 'admin');
define('EMQTTD_PWD', 'public');
define('DATABASE_USER', 'root');
define('DATABASE_PWD', 'root');
define('TOKEN','systec_20180330');
define('RPP',20);"
output_master="define('MASTER','${ipaddr}');"
output_slaver="define('SLAVER','${ipaddr}');"
echo $output_constant $output_master $output_slaver > /home/wwwroot/default/application/config/constants.php
chmod 777 /home/wwwroot/default/ -R
echo "Gaoxin Da is extremely NB!"
