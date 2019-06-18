all:
	docker build --pull -t bzed/pgbouncer .

clean:
	docker rmi bzed/pgbouncer:latest
