## Neo4jDB_Galaxy_IE

[![Neo4j_IE](http://dockeri.co/image/thoba/neo4j_galaxy_ie)](https://hub.docker.com/r/thoba/neo4j_galaxy_ie/)

[![Docker Repository on Quay](https://quay.io/repository/thoba/neo_ie/status "Docker Repository on Quay")](https://quay.io/repository/thoba/neo_ie)
A modified version of the Neo4j:2.3.3 Docker image to cater for the current [Galaxy port_mapping](https://github.com/galaxyproject/galaxy/blob/dev/lib/galaxy/web/base/interactive_environments.py#L381).

**This image has been modified to expose a single port(7474).**

**Build the image:**

```
$ docker build -t quay.io/thoba/neo_ie:v1 .
```

*or*

**Pull the image:**

```
$ docker pull quay.io/thoba/neo_ie:v1
```

*Try make sure you have nodejs `v0.10.45` and that you can run `$ node` (you might have to set a symlink)*

```
$ apt-cache policy nodejs
nodejs:
  Installed: 0.10.45-1nodesource1~trusty1
  Candidate: 0.10.45-1nodesource1~trusty1
  Version table:
 *** 0.10.45-1nodesource1~trusty1 0
        500 https://deb.nodesource.com/node/ trusty/main amd64 Packages
        100 /var/lib/dpkg/status
```


```
$ node -v
v0.10.45
```
Set `interactive_environment_plugins_directory` to `config/plugins/interactive_environments` in `config/galaxy.ini`

Next, [follow](galaxy/README.md) in the `galaxy` folder to get the Neo4j IE installed.

Then, [setup](https://docs.galaxyproject.org/en/master/admin/interactive_environments.html#setting-up-the-proxy) your proxy accordingly.

You should the see the image below upon firing up the IE:

![Neo4j_IE](https://raw.githubusercontent.com/thobalose/neo4j_galaxy_ie/master/neo4j_ie.png)

Thanks to [@bgruening](https://github.com/bgruening) and [@erasche](https://github.com/erasche).

For interest's sake, to run this:

```sh
$ docker run -d \
    -p 7474:7474 \
    -v /tmp/data:/data \
    -e NEO4J_AUTH=none -e USER_UID=$(id -u) -e USER_GID=$(id -g) \
    quay.io/thoba/neo_ie:v1
```
