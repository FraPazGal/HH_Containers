# HH_Containers

## Overview

This is a side project that aims to make the instalattion of [HumHub](https://www.humhub.com/) easier by usign a containerized LAMP structure. Usign an existing container of [MariaDB](https://github.com/bitnami/bitnami-docker-mariadb), it allows a fast set-up and the possibility of deploying this solution to a K8s platform. 

## How to use it?

### Docker Compose

```sh
$ curl -sSL https://raw.githubusercontent.com/frapazgal/hh_containers/master/docker-compose.yml > docker-compose.yml
$ docker-compose up -d
```

### Docker Run

The HumHub-MariaDB Docker Image can be found on [Docker Hub](https://hub.docker.com/repository/docker/frapazgal/humhub_mariadb), so you only need to pull it to your pc.

```sh
$ docker pull frapazgal/humhub_mariadb:latest
```
At the moment, there and only two versions of this image on the [Docker Hub Registry](https://hub.docker.com/repository/docker/frapazgal/humhub_mariadb/tags), both been identical, given the current development.

You can also clone this repository and build the HumHub image yourself with the Dockefile and using the `docker build` command in the directory of the downloaded `Dockerfile`. 
#### Clone and build your own image
```sh
$ git clone https://github.com/FraPazGal/HH_Containers.git
$ docker build -t frapazgal/humhub_mariadb:latest
```

Then you will just need to us the `docker run` command to create the Humhub and MariaDB containers. The HumHub container needs a database to work properly, so we will need to create a network to make communication between both containers possible. Given that we need to especify the database hostname to humhub, we will assign a subnet to the network and a static IP to the DB container.
#### Create a network
```sh
$ docker network create --subnet=172.18.0.0/16 humhub-network
```

With our network created, we can now execute the `docker run` command to create the MariaDB container. We will also use the `docker volume create` command to create a volume for our MariaDb persistence.
#### Create a data volume and a MariaDB container
```sh
$ docker volume create --name humhub_db_data
$ docker run -d --name humhub_db \
    -e ALLOW_EMPTY_PASSWORD=yes \
    -e MARIADB_USER=nami \
    -e MARIADB_PASSWORD=janna \
    -e MARIADB_DATABASE=humhub_db \
    --network humhub-network --ip 172.18.0.10 \
    --volume humhub_db_data:/bitnami/mariadb \
    bitnami/mariadb:latest
```

We have added several env variables to create the user and database that HumHub will use. This can be done after the MariaDB container is up, but it is easier to set it up just as we create the container. For more information regarding the env variables used, visit the [Bitnami MariaDB documentation](https://github.com/bitnami/bitnami-docker-mariadb#creating-a-database-user-on-first-run).

Now that we have the database running, it is time to create our HumHub container. If you have used the env variables values given in the MariaDb `docker run` example, we won't need to change any of the default env variables of this container. Like so, we would just need to specify the network and the port that our container will be listening to.
#### Create a data volume and a HumHub container
```sh
$ docker volume create --name humhub_data
$ docker run -d --name humhub -p 80:8080 \
    --network humhub-network \
    --volume humhub_data:/var/www/humhub \
    frapazgal/humhub_mariadb:latest
```

## Data persistence

Both the MariaDB and the Humhub containers can use volumes to persist their data. As we have seen in the previous examples, the common practice is to use docker volumes for our data persistence, but we can also mount host directories as data volumes. Because both our containers are non-root, we would need to give ownership/writing permissions to the user that is running the containers (UID: 1001 by default).

If we want to mount host directories as data volumes, we will have to make some changes to our docker-compose.yml file, as it uses docker volumes by default. You can find the necessary changes in the `docker-compose_host_volumes.yml` of this repository. Remember that the docker-compose up command will read the file named as docker-compose.yml. 

If we are using the command line and the `docker run` command to create our containers, we won't need to execute the `docker volume create` and our `--volume` variable will change as described in the following example.

```sh
$ docker run -d --name humhub -p 80:8080 \
    --network humhub-network \
    --volume /path/to/humhub-persistence:/var/www/humhub \
    frapazgal/humhub_mariadb:latest
```

## Configuration

### Environment variables

In this section we will concentrate on the environment variables of the HumHub container, as we have already covered the ones we will use for the MariaDB container.

These variables will let you make the initial configuration of your HumHub site by passing their values on the docker run command or the `docker-compose.up` file.

#### User and site configuration

All of this data can be changed once your site is running.

`HH_SITE_NAME`: our site name. Default: **Humhub Site Name**  
`HH_SITE_EMAIL`: our site email. Default: **humhub@example.com**  
`HH_SITE_BASEURL`: our site baseURL. Default: **http://www.example.net**  
`HH_ADMIN_USERNAME`: our admin account username. Default: **morgana**   
`HH_ADMIN_EMAIL`: our admin account email. Default: **morgana@example.com**   
`HH_ADMIN_PASS`: our admin account password. Default: **leona**   
`HH_ADMIN_FIRSTNAME`: our admin account firs name. Default: **Morgana**   
`HH_ADMIN_LASTNAME`: our admin account last name. Default: **The Fallen**   
`HH_GUEST_ACCESS`: whether to allow guests to see some of the content (those specified as such). Default: **YES**   
`HH_APPROVAL_AFTER_REGISTRATION`: make new accounts approval by admins mandatory. Default: **NO**   
`HH_ANON_REGISTRATION`: whether to allow anon registration. Default: **YES**    
`HH_INVITE_BY_EMAIL`: enables invitations by email. Default: **NO**   
`HH_FRIENSHIP_MODULE`: enables the friendship module. Default: **YES**    
`HH_SAMPLE_DATA`: whether we want or site populated with some initial sample data. Default: **YES**   

#### Database connection configuration

Remember that this values must match the ones given for the MariaDB environment variables container. 

`HH_MARIADB_HOST`: database hostname. Default: **172.18.0.10**  
`HH_MARIADB_DBNAME`: database name. Default: **humhub_db**  
`HH_MARIADB_USER`: database username. Default: **nami**   
`HH_MARIADB_USER_PASS`: password of the created database user. Default: **janna** 

#### Apache configuration

These are the recommended minimum values given by the HumHub developers. In the case of the `APACHE_HTTP_PORT_NUMBER` variable, remember that it must be the same as the one specified on the `-p "80:8080"` variable of the `docker run` command and on the `docker-compose.yml` file.

`APACHE_HTTP_PORT_NUMBER`: apache por number. Default: **8080**   
`APACHE_MAX_EXEC_TIME`: apache maximum execution time in seconds. Default: **300**  
`APACHE_POST_MAX_FILESIZE`: apache maximum filesize post allowed. Default: **64M**  
`APACHE_UPLOAD_MAX_FILESIZE`: apache maximum filesize upload allowed. Default: **64M**  

#### Non-root user configuration

The following two environment values cannot be changed directly, as they take their value from the ARG variables. Although not recommended, if you wish to run the container as another user, change those variables instead.

`USER_UID`: UID of the non-root user that will run the container. Default: **$UID = 1001**  
`USER_GID`: GID of the non-root user that will run the container. Default: **$GUD = 1001**  

## Kubernetes deployment

The following instructions have only been tested for the [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine) (GKE).

After creating a project on Google Cloud Platform we will have to create a cluster in GKE using our console. To create it, we will first need to install gcloud and kubectl, then set up a project and finally create a cluster for said project.  The [Google documentation](https://cloud.google.com/kubernetes-engine/docs/quickstart) explains this process step-by-step but here is an example of the project and cluster set-up.
#### Project and cluster set-up
```sh
$ gcloud config set project project-id
$ gcloud config set compute/zone europe-west6
$ gcloud auth login
$ gcloud container clusters create cluster-name --zone europe-west6-a
$ gcloud container clusters get-credentials cluster-name --zone europe-west6-a
```

To deploy our HumHub application, we will first create two PersistentVolumeClaims [(PVC)](https://cloud.google.com/kubernetes-engine/docs/concepts/persistent-volumes#dynamic_provisioning). GKE will automatically assign us a PersistentVolume and we will only need to claim that volume in our deployments. After that we will deploy our MariaDB image with a ClusterIP service and finally we will deploy our HumHub image with a LoadBalancer service.

In the K8s folder you will find the three .yaml files needed to have our HumHub app running on GKE. All the environment variables previously detailed can be changed before the deployment. As an example, we will complete our app deployment executing the `kubectl apply` command. It is recommended to wait until each PVC/service/deployment has an *OK* status in GKE before executing the following command.
#### Deployment
```sh
$ cd K8s/
$ kubectl apply -f volumes.yaml
$ kubectl apply -f mariadb.yaml
$ kubectl apply -f humhub.yaml
```

## Known Issues

- After the initial HumHub setup, the header doesn't display the name of the site. It is requiered to click `save` on Administration -> Settings -> General to reload the header.
- Even with a sleep time of 6.5s at the start of the entrypoint file of the HumHub container, it may be possible that the MariaDB container requires a longer time to be up and running, failing the `docker-compose up`. If so, increase the sleep time in the `/rootfs/docker-entrypoint.sh` file.

## Future Improvements

- Environment variables input validation
- HTTPS implemntation
- SMTP implementation
- Better logs management
- General code styling

