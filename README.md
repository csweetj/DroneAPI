# ローカル環境起動手順

1.リポジトリをローカルにClone
  
	git clone https://github.com/csweetj/DroneAPI.git

2.ルートディレクトリーに移動し、ルートディレクトリに.envファイルを作成
  
	cd DroneAPI

 	touch .env

3.依存関係のインストール
	
 	docker-compose run web bundle install

4.envファイルの中身に下記を記載
 
 >	MYSQL_PASSWORD = "1234abcd"
 >	
 >	MYSQL_DATABASE = "drone_api_production"
 >	
 >	MYSQL_USER = "user"
 >
 >	BASIC_AUTH_USERNAME="user"
 >
 >	BASIC_AUTH_PASSWORD="1234abcd"

5.データベースを作成する

   	docker-compose run web rails db:create
	

6.dockerコンテナをビルド、実行
  
	docker-compose up -d


7.稼働中のコンテナに入り、DBをマイグレーション
  
	docker exec -it droneapi-web-1 bash
  
	rails db:migrate RAILS_ENV=development


8.http://localhost:3000/ にアクセス

9.起動中のコンテナを落とす
	
 	docker-compose down
