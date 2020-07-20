# Create required volume and network
docker volume create db-data
docker network create --driver overlay frontend
docker network create --driver overlay backend

# create required services
docker service create --name redis --network frontend redis:alpine
docker service create --name db --network backend -e POSTGRES_HOST_AUTH_METHOD=trust --constraint=node.labels.ssd==true --mount type=volume,source=db-data,target=/var/lib/postgresql/data postgres:9.6
docker service create --name vote -p 5000:80 --network frontend --replicas 2 --constraint=node.role==worker bretfisher/examplevotingapp_vote
docker service create --name result -p 5001:80 --network backend bretfisher/examplevotingapp_result
docker service create --name worker --network frontend --network backend --mode global --constraint=node.role==worker bretfisher/examplevotingapp_worker:java

