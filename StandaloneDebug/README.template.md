# NodeJS - Debug

_This image is only intended for development purposes!_ Runs NodeJS with a VNC Server to allow you to interact with the server.


## Dockerfile

[`jpavlic/standalone-nodejs-debug` Dockerfile](https://github.com/jpavlic/docker-nodejs/blob/master/##FOLDER##/Dockerfile)

## How to use this image


```
$ docker run -d -p 5900:5900 -v /dev/shm:/dev/shm jpavlic/standalone-nodejs-debug
```

You can acquire the port that the VNC server is exposed to by running:
(Assuming that we mapped the ports like this: 49338:5900)
``` bash
$ docker port <container-name|container-id> 5900
#=> 0.0.0.0:49338
```

In case you have [RealVNC](https://www.realvnc.com/) binary `vnc` in your path, you can always take a look, view only to avoid messing around your tests with an unintended mouse click or keyboard interrupt:
``` bash
$ ./bin/vncview 127.0.0.1:49338
```

If you are running Boot2Docker on Mac then you already have a [VNC client](http://www.davidtheexpert.com/post.php?id=5) built-in. You can connect by entering `vnc://<boot2docker-ip>:49160` in Safari or [Alfred](http://www.alfredapp.com/)

## What is NodeJS?
_NodeJS runs javascript applications._ That's it!

See the Selenium [site](http://nodejs.org/) for documation on usage within your test code.

## License

View [license information](https://github.com/jpavlic/docker-nodejs/blob/master/LICENSE.md) for the software contained in this image.
