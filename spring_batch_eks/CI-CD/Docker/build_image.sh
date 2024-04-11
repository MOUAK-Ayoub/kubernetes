docker build -t ayoubmouak/sprinbatch-eks:1.0.0-SNAPSHOT -f ./CI-CD/Dockerfile .

 docker run \
   --name springbatch
   -e SPRING_DATASOURCE_URL=jdbc:postgresql://172.31.17.190:5432/test \
   -d -p 8082:8082 ayoubmouak/spring-batch-eks:1.0.0SNAPSHOT


