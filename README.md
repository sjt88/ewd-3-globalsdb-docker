## ewd-3 + GlobalsDb Docker Image

### Install
todo: upload to dockerhub

### Usage
```bash
  docker build -t ewd3-globalsdb
  docker run -p 8080:8080                          \
    -v /path/to/www:/ewd3/www                      \
    -v /path/to/ewd-startup-file.js:/ewd3/app.js   \
    ewd3-globalsdb                                 \
```

