IMG_NAME=majel

COMMAND_RUN=docker run \
	  --name test \
	  --detach=false \
	  --network host \
	  -e DISPLAY=${DISPLAY} \
	  -v /tmp/.X11-unix:/tmp/.X11-unix \
	  --rm \
	  -v `pwd`:/mnt/shared \
	  -i \
          -t \
	  ${IMG_NAME} /bin/bash -c

build:
	docker build --network host --no-cache --rm -t ${IMG_NAME} .
 
remove-image:
	docker rmi ${IMG_NAME}

run:
	$(COMMAND_RUN) \
            "cd ~/volttron && ~/volttron/run.sh && bash"