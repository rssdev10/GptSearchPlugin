# OpenSearch as a vector storage

OpenSearch is a search application licensed under Apache 2.0 and available as a cloud solution on AWS.  OpenSearch can be installed in [a number of ways](https://opensearch.org/downloads.html). But the easiest way to have it locally without authentication is to use Docker.

Use our [compose-script](docker-compose.yml) and run the following command in a terminal:

    docker-compose up

If you want to configure a cluster [see full instructions](https://opensearch.org/docs/latest/install-and-configure/index/)

To enable OpenSearch use:
```bash
export DATASTORE=OPENSEARCH
```
