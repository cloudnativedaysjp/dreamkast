FROM swaggerapi/swagger-codegen-cli-v3:3.0.76 as builder
WORKDIR /mock-seed
COPY ./swagger.yml ./
WORKDIR /mock-server
RUN java -jar /opt/swagger-codegen-cli/swagger-codegen-cli.jar generate -l nodejs-server -i /mock-seed/swagger.yml -l nodejs-server -o ./

FROM node:22.23.3-alpine as mock
WORKDIR /mock-server
COPY --from=builder /mock-server ./
RUN npm install
USER node
EXPOSE 8080
CMD ["npm", "start"]
