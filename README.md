# NodeJS Docker

The project is made possible by volunteer contributors who have put in many hours of their own time, and made the source code freely available under the [Apache License 2.0](https://github.com/jpavlic/docker-nodejs/blob/master/LICENSE.md).

## Docker images for NodeJS Standalone Server
[Travis CI](https://travis-ci.org/jpavlic/docker-nodejs)

Images included:
- __jpavlic/base__: Base image which includes Java runtime
- __jpavlic/nodejs-base__: Base image for NodeJS
- __jpavlic/nodejs__: NodeJS installed
- __jpavlic/nodejs-debug__: NodeJS installed and runs a VNC server
- __jpavlic/standalone-nodejs__: NodeJS Standalone
- __jpavlic/standalone-nodejs-debug__: NodeJS Standalone and runs a VNC server

##

## Running the images

NodeJS
``` bash
$ docker run -d -p 8080:8080 jpavlic/standalone-nodejs:latest
```

### Standalone NodeJS

``` bash
$ docker run -d -p 8080:8080 jpavlic/standalone-nodeJS:latest
```

_Note: Only one NodeJS image can run on port_ `8080` _at a time._

To inspect visually what the browser is doing use the `standalone-chrome-debug` or `standalone-firefox-debug` images. See [Debugging](#debugging) section for details.


#### Via docker-compose
The most simple way to start a grid is with [docker-compose](https://docs.docker.com/compose/overview/), use the following
snippet as your `docker-compose.yaml`, save it locally and in the same folder run `docker-compose up`.

### Deploying to Kubernetes

Check out [the Kubernetes examples](https://github.com/kubernetes/examples/tree/master/staging/jpavlic)
on how to deploy selenium hub and nodes on a Kubernetes cluster.

## Configuring the containers

## Building the images

Clone the repo and from the project directory root you can build everything by running:

``` bash
$ VERSION=local make build
```

If you need to configure environment variable in order to build the image (http proxy for instance), simply set an environment variable `BUILD_ARGS` that contains the additional variables to pass to the docker context (this will only work with docker >= 1.9)

``` bash
$ BUILD_ARGS="--build-arg http_proxy=http://acme:3128 --build-arg https_proxy=http://acme:3128" make build
```

_Note: Omitting_ `VERSION=local` _will build the images with the current version number thus overwriting the images downloaded from [Docker Hub](https://hub.docker.com/r/selenium/)._

## Debugging

In the event you wish to visually see what the browser is doing you will want to run the `debug` variant of node or standalone images. A VNC server will run on port 5900. You are free to map that to any free external port that you wish. Keep in mind that you will only be able to run one node per port so if you wish to include a second node, or more, you will have to use different ports, the 5900 as the internal port will have to remain the same though as thats the VNC service on the node. The second example below shows how to run multiple nodes and with different VNC ports open:
``` bash
$ docker run -d -P -p <port4VNC>:5900 --link selenium-hub:hub -v /dev/shm:/dev/shm selenium/node-chrome-debug:latest
$ docker run -d -P -p <port4VNC>:5900 --link selenium-hub:hub -v /dev/shm:/dev/shm selenium/node-firefox-debug:latest
```
e.g.:
``` bash
$ docker run -d -P -p 5900:5900 --link selenium-hub:hub -v /dev/shm:/dev/shm selenium/node-chrome-debug:latest
$ docker run -d -P -p 5901:5900 --link selenium-hub:hub -v /dev/shm:/dev/shm selenium/node-firefox-debug:latest
```
to connect to the Chrome node on 5900 and the Firefox node on 5901 (assuming those node are free, and reachable).

And for standalone:
``` bash
$ docker run -d -p 4444:4444 -p <port4VNC>:5900 -v /dev/shm:/dev/shm selenium/standalone-chrome-debug:latest
# OR
$ docker run -d -p 4444:4444 -p <port4VNC>:5900 -v /dev/shm:/dev/shm selenium/standalone-firefox-debug:latest
```
or
``` bash
$ docker run -d -p 4444:4444 -p 5900:5900 -v /dev/shm:/dev/shm selenium/standalone-chrome-debug:latest
# OR
$ docker run -d -p 4444:4444 -p 5901:5900 -v /dev/shm:/dev/shm selenium/standalone-firefox-debug:latest
```

You can acquire the port that the VNC server is exposed to by running:
(Assuming that we mapped the ports like this: 49338:5900)
``` bash
$ docker port <container-name|container-id> 5900
#=> 0.0.0.0:49338
```

In case you have [RealVNC](https://www.realvnc.com/) binary `vnc` in your path, you can always take a look, view only to avoid messing around your tests with an unintended mouse click or keyboard interrupt:
``` bash
$ ./bin/vncview 127.0.0.1:49160
```

If you are running [Boot2Docker](https://docs.docker.com/installation/mac/) on OS X then you already have a [VNC client](http://www.davidtheexpert.com/post.php?id=5) built-in. You can connect by entering `vnc://<boot2docker-ip>:49160` in Safari or [Alfred](http://www.alfredapp.com/).

When you are prompted for the password it is `secret`. If you wish to change this then you should either change it in the `/NodeBase/Dockerfile` and build the images yourself, or you can define a Docker image that derives from the posted ones which reconfigures it:
``` dockerfile
#FROM selenium/node-chrome-debug:latest
#FROM selenium/node-firefox-debug:latest
#Choose the FROM statement that works for you.

RUN x11vnc -storepasswd <your-password-here> /home/nodejsuser/.vnc/passwd
```

If you want to run VNC without password authentication you can set the environment variable `VNC_NO_PASSWORD=1`.

### Troubleshooting

All output is sent to stdout so it can be inspected by running:
``` bash
$ docker logs -f <container-id|container-name>
```

You can turn on debugging by passing environment variable to the hub and the nodes containers:
```
GRID_DEBUG=true
```

#### Headless

If you see the following selenium exceptions:

`Message: invalid argument: can't kill an exited process`

or

`Message: unknown error: Chrome failed to start: exited abnormally`

The reason _might_ be that you've set the `START_XVFB` environment variable to "false", but forgot to actually run Firefox or Chrome (respectively) in headless mode.
# docker-nodejs
