# This base image comes shipped with java 8 (needed for scala)
FROM openjdk:8-jdk-alpine
COPY --from=python:3.7 / /

# Set env variables
ENV DAEMON_RUN=true
ENV SPARK_VERSION=3.1.1
ENV HADOOP_VERSION=3.2
ENV SCALA_VERSION=2.12.13
ENV AZURE_VERSION=8.6.6
ENV SCALA_HOME=/usr/share/scala
ENV SPARK_HOME=/spark
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip


# Update commands
RUN apk --update add wget tar bash coreutils procps openssl

# Install Scala
RUN apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    apk add --no-cache bash && \
    cd "/tmp" && \
    wget "https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
    tar xzf "scala-${SCALA_VERSION}.tgz" && \
    mkdir "${SCALA_HOME}" && \
    rm "/tmp/scala-${SCALA_VERSION}/bin/"*.bat && \
    mv "/tmp/scala-${SCALA_VERSION}/bin" "/tmp/scala-${SCALA_VERSION}/lib" "${SCALA_HOME}" && \
    ln -s "${SCALA_HOME}/bin/"* "/usr/bin/" && \
    apk del .build-dependencies && \
    rm -rf "/tmp/"*
    

RUN export PATH="/usr/local/sbt/bin:$PATH" &&  apk update && apk add ca-certificates wget tar && mkdir -p "/usr/local/sbt"

# Get Apache Spark
RUN wget http://mirror.ox.ac.uk/sites/rsync.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz

# Install Spark and move it to the folder "/spark" and then add this location to the PATH env variable
RUN tar -xzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /spark && \
    rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    export PATH=$SPARK_HOME/bin:$PATH

# Install jars needed for communication with Azure
RUN wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-azure/${HADOOP_VERSION}.0/hadoop-azure-${HADOOP_VERSION}.0.jar -P $SPARK_HOME/jars/ && \
    wget https://repo1.maven.org/maven2/com/microsoft/azure/azure-storage/${AZURE_VERSION}/azure-storage-${AZURE_VERSION}.jar -P $SPARK_HOME/jars/
