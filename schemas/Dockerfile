FROM swaggerapi/swagger-codegen-cli-v3:3.0.46 as builder
WORKDIR /mock-seed
COPY ./swagger.yml ./
WORKDIR /mock-server
RUN java -jar /opt/swagger-codegen-cli/swagger-codegen-cli.jar generate -l nodejs-server -i /mock-seed/swagger.yml -l nodejs-server -o ./

FROM node:16.20.2-alpine as mock
WORKDIR /mock-server
COPY --from=builder /mock-server ./
RUN npm install
EXPOSE 8080
CMD ["npm", "start"]
