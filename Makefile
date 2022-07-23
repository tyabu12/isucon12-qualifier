fetch:
	git fetch -p
	git reset --hard origin/master
	git clean -df
	cp conf/.gitconfig ~

deploy-app1:
	sudo cp conf/nginx/nginx.conf /etc/nginx/nginx.conf
	sudo cp conf/nginx/sites-enabled/* /etc/nginx/sites-enabled
	sudo cp conf/mysql.conf.d/* /etc/mysql/mysql.conf.d/
	$(MAKE) restart-nginx restart-app restart-db
	$(MAKE) clean-log

deploy-app2: deploy-app1

deploy-app3: deploy-app1

restart: restart-db restart-nginx

restart-app:
	sudo systemctl restart isuports

restart-db:
	sudo systemctl restart mysql

restart-nginx:
	sudo systemctl restart nginx

clean-log:
	sudo truncate -s 0 /var/log/nginx/access.log /var/log/nginx/error.log /var/log/mysql/mysql.log /var/log/mysql/mysql-slow.log

install-alp:
	cd /tmp
	wget https://github.com/tkuchiki/alp/releases/download/v1.0.8/alp_linux_amd64.zip
	unzip alp_linux_amd64.zip
	sudo mv ./alp /usr/local/bin
	rm alp_linux_amd64.zip

install-percona-toolkit:
	sudo apt install percona-toolkit

publish-mysql-host:
	mysql -uisucon -pisucon mysql -e"RENAME USER 'isucon'@'localhost' to 'isucon'@'%';"

alp-log:
	sudo cat /var/log/nginx/access.log | alp ltsv -m "/api/player/player/[0-9-a-z]+,/api/organizer/competition/[0-9a-z]+/score,/api/player/competition/[0-9a-z]+/ranking,/api/organizer/player/[0-9a-z]+/disqualified,/api/organizer/competition/[0-9a-z]+/finish" -r

slow-query:
	sudo pt-query-digest /var/log/mysql/mysql-slow.log

ssh-mysql:
	mysql -uisucon -pisucon isuports

# TODO: 修正必要
#recreate-sql-init-data:
	#mysqldump -uisucon -pisucon -t isuports > ./sql/1_InitData.sql

