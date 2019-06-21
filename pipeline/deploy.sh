#!/bin/bash

docker run -d -p 4023:4023 --cpus=1 --memory="600m" --add-host=og.rfitzy.net:10.136.154.102 --add-host=redis.rfitzy.net:10.136.154.102 --name blog --restart unless-stopped blog
