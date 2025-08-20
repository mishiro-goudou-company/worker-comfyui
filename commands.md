# ComfyUI Anime FaceID - コマンドリファレンス

## 🚀 クイックスタート

```bash
# 1. ビルドスクリプトに実行権限を付与
chmod +x build.sh

# 2. Docker Hubユーザー名を設定（実際の名前に変更）
export DOCKERHUB_USER="your-dockerhub-username"

# 3. 基本ビルド
./build.sh --user $DOCKERHUB_USER

# 4. ビルド&プッシュ
./build.sh --user $DOCKERHUB_USER --push

# 5. ローカルテスト
./build.sh --user $DOCKERHUB_USER --test
```

## 📦 ビルドコマンド

### 基本ビルド
```bash
# シンプルビルド
./build.sh

# バージョン指定
./build.sh --version 1.1.0

# ユーザー名指定
./build.sh --user myusername

# キャッシュなし
./build.sh --no-cache
```

### プッシュ付きビルド
```bash
# ビルド&プッシュ
./build.sh --user myusername --push

# バージョン&プッシュ
./build.sh --user myusername --version 1.2.0 --push

# 追加タグ付きプッシュ
./build.sh --user myusername --tag stable --push
```

### テスト付きビルド
```bash
# ビルド&テスト
./build.sh --test

# 全部込み
./build.sh --user myusername --version 1.0.0 --push --test
```

## 🐳 手動Dockerコマンド

### ビルド
```bash
# 基本ビルド
docker build \
  --platform linux/amd64 \
  -f Dockerfile.anime-faceid \
  -t myusername/comfyui-anime-faceid:1.0.0 \
  .

# マルチタグビルド
docker build \
  --platform linux/amd64 \
  -f Dockerfile.anime-faceid \
  -t myusername/comfyui-anime-faceid:1.0.0 \
  -t myusername/comfyui-anime-faceid:latest \
  .

# キャッシュなしビルド
docker build \
  --platform linux/amd64 \
  -f Dockerfile.anime-faceid \
  --no-cache \
  -t myusername/comfyui-anime-faceid:1.0.0 \
  .
```

### プッシュ
```bash
# 単一タグプッシュ
docker push myusername/comfyui-anime-faceid:1.0.0

# 複数タグプッシュ
docker push myusername/comfyui-anime-faceid:1.0.0
docker push myusername/comfyui-anime-faceid:latest
```

### 実行
```bash
# 基本実行
docker run -d \
  --name comfyui-anime-faceid \
  -p 8188:8188 \
  myusername/comfyui-anime-faceid:latest

# 開発モード（API有効）
docker run -d \
  --name comfyui-anime-faceid-dev \
  -p 8188:8188 \
  -p 8000:8000 \
  -e SERVE_API_LOCALLY=true \
  myusername/comfyui-anime-faceid:latest

# GPU指定実行
docker run -d \
  --name comfyui-anime-faceid-gpu \
  --gpus all \
  -p 8188:8188 \
  myusername/comfyui-anime-faceid:latest
```

## 🔧 管理コマンド

### イメージ管理
```bash
# イメージ一覧
docker images | grep comfyui-anime-faceid

# イメージサイズ確認
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep comfyui-anime-faceid

# 未使用イメージ削除
docker image prune

# 特定イメージ削除
docker rmi myusername/comfyui-anime-faceid:1.0.0
```

### コンテナ管理
```bash
# 実行中コンテナ確認
docker ps | grep comfyui-anime-faceid

# 全コンテナ確認
docker ps -a | grep comfyui-anime-faceid

# コンテナ停止
docker stop comfyui-anime-faceid

# コンテナ削除
docker rm comfyui-anime-faceid

# 強制削除
docker rm -f comfyui-anime-faceid
```

### ログ・デバッグ
```bash
# ログ確認
docker logs comfyui-anime-faceid

# リアルタイムログ
docker logs -f comfyui-anime-faceid

# コンテナ内部アクセス
docker exec -it comfyui-anime-faceid /bin/bash

# ファイルコピー
docker cp comfyui-anime-faceid:/comfyui/output/ ./output/
```

## 🌐 ネットワーク・ポート

```bash
# ポート確認
docker port comfyui-anime-faceid

# ネットワーク確認
docker network ls
docker inspect bridge

# カスタムネットワーク作成
docker network create comfyui-network
docker run --network comfyui-network ...
```

## 📊 モニタリング

```bash
# リソース使用量
docker stats comfyui-anime-faceid

# システム情報
docker system df
docker system info

# イベント監視
docker events --filter container=comfyui-anime-faceid
```

## 🔄 CI/CD用コマンド

```bash
# GitHub Actions用
docker build \
  --platform linux/amd64 \
  -f Dockerfile.anime-faceid \
  -t $REGISTRY/$IMAGE_NAME:$GITHUB_SHA \
  -t $REGISTRY/$IMAGE_NAME:latest \
  .

# タグ付けとプッシュ
docker tag $IMAGE_NAME:latest $REGISTRY/$IMAGE_NAME:$VERSION
docker push $REGISTRY/$IMAGE_NAME:$VERSION
docker push $REGISTRY/$IMAGE_NAME:latest
```

## 🚨 トラブルシューティング

```bash
# ビルドエラー時
docker build --progress=plain --no-cache -f Dockerfile.anime-faceid .

# 容量不足時
docker system prune -a
docker volume prune

# 権限エラー時
sudo docker ...
# または
sudo usermod -aG docker $USER
newgrp docker

# ネットワークエラー時
docker network prune
systemctl restart docker
```

## 📝 環境変数

```bash
# よく使う環境変数
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKERHUB_USER="your-username"
export IMAGE_NAME="comfyui-anime-faceid"
export VERSION="1.0.0"

# 使用例
docker build -t $DOCKERHUB_USER/$IMAGE_NAME:$VERSION .
```
