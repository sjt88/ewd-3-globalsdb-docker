## ewd-3 + GlobalsDb Docker Image

### Install
todo: upload to dockerhub

### Usage
```bash
  git clone https://github.com/sjt88/ewd-3-globalsdb-docker.git \
  && docker build -t ewd3-globalsdb ./ewd-3-globalsdb-docker    \
  && docker run -p 8080:8080                                    \
    -v /path/to/www:/ewd3/www                                   \
    -v /path/to/ewd-startup-file.js:/ewd3/app.js                \
    ewd3-globalsdb
```

