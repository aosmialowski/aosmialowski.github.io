all: | docker-remove docker-build docker-run docker-start
publish: | build deploy

build:
	docker exec osmialowski.net hugo

deploy:
	rsync -avz --delete public/ osmialowski.net:~/domains/osmialowski.net/public_html/

docker-remove:
	docker rm --force osmialowski.net

docker-build:
	docker build -t osmialowski.net .

docker-run:
	docker run -d \
		-p 1313:1313 \
		-v $(shell pwd):/site \
		--name osmialowski.net \
		--env-file .env \
		osmialowski.net

docker-start:
	docker start osmialowski.net