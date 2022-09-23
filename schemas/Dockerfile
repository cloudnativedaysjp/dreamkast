FROM swaggerapi/swagger-codegen-cli-v3:3.0.24 as builder
WORKDIR /mock-seed
COPY ./swagger.yml ./
WORKDIR /mock-server
RUN java -jar /opt/swagger-codegen-cli/swagger-codegen-cli.jar generate -l nodejs-server -i /mock-seed/swagger.yml -l nodejs-server -o ./

FROM node:15.5.1-alpine3.10 as mock
WORKDIR /mock-server
COPY --from=builder /mock-server ./
RUN npm install
EXPOSE 8080
CMD ["npm", "start"]
