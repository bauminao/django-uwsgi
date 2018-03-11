IMAGE_NAME = bauminao/django
CONTAINER_NAME = django

.PHONY: all

all: clean_all build run

clean: clean_container

clean_all: clean_container clean_image

clean_image:
	docker rmi -f ${IMAGE_NAME} 2>/dev/null || true
	docker images | grep ${IMAGE_NAME} || true

clean_container:
	docker rm -f ${CONTAINER_NAME} 2>/dev/null || true
	docker ps -a

build: clean_all
	docker build -t ${IMAGE_NAME} .

rebuild: 
	docker build -t ${IMAGE_NAME} .

stop:
	docker stop ${CONTAINER_NAME}

restart: stop
	docker restart ${CONTAINER_NAME}

run: 
	docker run --name=${CONTAINER_NAME} \
	-p 8000:8000                        \
	-ti -d ${IMAGE_NAME}
	sleep 1
	docker logs --details ${CONTAINER_NAME}

ssh:
	docker exec -ti ${CONTAINER_NAME} bash

shell:
	docker exec -ti ${CONTAINER_NAME} bash

