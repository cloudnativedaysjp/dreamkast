## mockファイル群をディレクトリごと削除
remove_mock:
	rm -rf mock/*

## ymlからmockを生成
build_mock:
	$(MAKE) remove_mock
	docker run -u 1000:1000 --rm -v `pwd`:/work swaggerapi/swagger-codegen-cli-v3 generate -l nodejs-server -i /work/swagger.yml -o /work/mock

## mockServerを起動
api_mock_run:
	$(MAKE) build_mock
	cd ./mock && npm start
