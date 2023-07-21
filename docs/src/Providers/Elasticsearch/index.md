# Elasticsearch as a vector storage

Elasticsearch can be installed in a number of ways. But the easiest way to have it locally without authentication is to use Docker.
Use our [compose-script](docker-compose.yml) and run the following command in a terminal:

    docker-compose up

If you want to configure a cluster [see full instructions](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker)

To enable ElasticSearch use:
```bash
export DATASTORE=ELASTICSEARCH
```
