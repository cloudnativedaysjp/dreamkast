Dreamkast API Documents
=======================

### Generate mock server locally

```
docker run -u 1000:1000 --rm -v `pwd`:/work swaggerapi/swagger-codegen-cli-v3 generate -l nodejs-server -i /work/swagger.yml -o /work/mock
npm start
```

or

```
make api_mock_run
```

To view the Swagger UI interface:

```
open http://localhost:8080/docs
```