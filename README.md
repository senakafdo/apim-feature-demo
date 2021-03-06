# WSO2 API Manager Feature Demo #

**Environment Setup**
  1. To run the examples of this workshop, it is neccessary to have the following tools installed on your laptop.
     - Docker or Docker-machine
       - LINUX users need to install [Docker](https://www.docker.com/)
       - Windows and OSx user need to install [Docker-machine](https://docs.docker.com/machine/install-machine/).
  2. This README assumes that the followers may use Windows or OSx. Therefore,
     - The example docker commands are mostly provided according to Windows and OSx.
     - LINUX users can skip commands related to `docker-machine`, which are marked as `dmr`.
  3. Add a host entry to the host machine (`dmr`)
     - `docker-machine start` - will start the docker machine if you are using `windows` or `OSx`.
     - `docker-machine ip` - will display the IP address of the docker machine.
     - Open the `hosts` file of the host machine, and add an entry as `<ip-address> docker.machine`.
  4. Download WSO2 product binary packages
     - WSO2 API Manager 1.10.0 - `wso2am-1.10.0.zip`
     - WSO2 Data Analytics Server 3.0.1 - `wso2das-3.0.1.zip`
  5. Add these 2 binary packs to the `packs` directory.
  
**The Microservice (REST API)**

  1. Start the Microservice container
     - `docker-compose up -d mres` - will create the container image and boot it up.
     - `docker ps` - lists the running container information. 
     - Observe the NAME value ( res.apimdemo.com ) of the containers.
  2. Try the Swagger definition
     - [http://docker.machine:8080/swagger?path=/matches](http://docker.machine:8080/swagger?path=/matches)
  3. Try API resources
     - [http://docker.machine:8080/matches/EUL2016/results](http://docker.machine:8080/matches/EUL2016/results)
     - [http://docker.machine:8080/matches/EUL2016/results/4](http://docker.machine:8080/matches/EUL2016/results/4)
     
**Supporting server instances**
  1. Start the databse container
     - `docker-compose up -d dbs` - will create the database container image and boot it up.
     - Wait for a few seconds until the database server becomes ready to be used.
  2. Start the Analytics container
     - `docker-compose up -d das` - will create the analytics profile container image and boot it up.

**WSO2 API Manager (API-M)**

  1. Start the API-M container
     - `docker-compose up -d apim` - will create the API-M container image and boot it up.
     - `docker ps` - lists the running containers information. 
     - Observe the NAME values ( api.apimdemo.com, das.apimdemo.com ) of the containers.
  2. To view API-M server logs, execute the command
     - `docker exec -it api.apimdemo.com tailf wso2/wso2am-1.10.0/repository/logs/wso2carbon.log`
  3. To get into the API-M container filesystem, execute the command
     - `docker exec -it api.apimdemo.com bash`
  4. Open API-M user interfaces (user=admin, password=admin).
     - API-M Admin Console [https://docker.machine:9443/carbon](https://docker.machine:9443/carbon)
     - API-M Publisher [https://docker.machine:9443/publisher](https://docker.machine:9443/publisher)
     - API-M Store [https://docker.machine:9443/store](https://docker.machine:9443/store)
  5. Publish the API using the Swagger definition of the Microservice.
     - Create an API on API-M publisher.
     - Import swagger definition from `apim-feature-demo/mres/swagger.json` of the repository.
     - Provide a proper resource path (i.e. `/uefa`)
     - Go to the next page and add the URL `http://res.apimdemo.com:8080` as the Managed API URL.
     - Select a few throttling tiers and publish the API.
  6. Subscribe to the API via the API-M Store.
  7. Try the API with Swagger based API Console on the API-M Store UI.
     - With resource `GET /matches/{tournementID}/results` use the input parameter `EUL2016`.
     - With resource `GET /matches/{tournementID}/results/{recordId}` use the input parameters `EUL2016` and a number beteen 1 and 8 such as `4`.
  8. Or, use a REST client like [POSTMAN](https://chrome.google.com/webstore/detail/postman/fhbjgbiflinjbdggehcddcbncdddomop?hl=en)
     - `https://docker.machine:8243/uefa/1.0/matches/EUL2016/results`
     - `https://docker.machine:8243/uefa/1.0/matches/EUL2016/results/8`

**When You are done...**

  1. Run `docker stop $(docker ps -a -q)` to stop all containers.
  2. Run `docker-machine stop` to stop the machine.
  
