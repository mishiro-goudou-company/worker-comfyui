#!/bin/bash
# anime faceid ComfyUI worker ビルドスクリプト

set -euo pipefail

# 設定
IMAGE_NAME="comfyui-anime-faceid"
VERSION="1.0.0"
REGISTRY_USER="your-dockerhub-username"  # 実際のDocker Hubユーザー名に変更
DOCKERFILE="Dockerfile.anime-faceid"

# カラー出力用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 使用方法
usage() {
    echo "使用方法: $0 [オプション]"
    echo ""
    echo "オプション:"
    echo "  -h, --help          このヘルプを表示"
    echo "  -v, --version VER   バージョンを指定 (デフォルト: $VERSION)"
    echo "  -u, --user USER     Docker Hubユーザー名を指定"
    echo "  -t, --tag TAG       追加のタグを指定"
    echo "  --no-cache          キャッシュを使用せずにビルド"
    echo "  --push              ビルド後にDocker Hubにプッシュ"
    echo "  --test              ビルド後にテストコンテナを起動"
    echo ""
    echo "例:"
    echo "  $0 --version 1.1.0 --push"
    echo "  $0 --user myusername --tag latest --push"
    echo "  $0 --no-cache --test"
}

# デフォルト値
NO_CACHE=""
PUSH=false
TEST=false
ADDITIONAL_TAG=""

# 引数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -u|--user)
            REGISTRY_USER="$2"
            shift 2
            ;;
        -t|--tag)
            ADDITIONAL_TAG="$2"
            shift 2
            ;;
        --no-cache)
            NO_CACHE="--no-cache"
            shift
            ;;
        --push)
            PUSH=true
            shift
            ;;
        --test)
            TEST=true
            shift
            ;;
        *)
            log_error "不明なオプション: $1"
            usage
            exit 1
            ;;
    esac
done

# 必要なファイルの存在確認
log_info "必要なファイルの確認中..."
if [[ ! -f "$DOCKERFILE" ]]; then
    log_error "Dockerfileが見つかりません: $DOCKERFILE"
    exit 1
fi

if [[ ! -f "anime_faceid.json" ]]; then
    log_error "ワークフローファイルが見つかりません: anime_faceid.json"
    exit 1
fi

# モデルファイルの存在確認
MODEL_PATH="/Applications/Data/Models/StableDiffusion/novaAnimeXL_ilV100.safetensors"
if [[ ! -f "$MODEL_PATH" ]]; then
    log_error "メインモデルファイルが見つかりません: $MODEL_PATH"
    exit 1
fi

# タグの構築
FULL_TAG="$REGISTRY_USER/$IMAGE_NAME:$VERSION"
LATEST_TAG="$REGISTRY_USER/$IMAGE_NAME:latest"

log_info "ビルド設定:"
log_info "  イメージ名: $IMAGE_NAME"
log_info "  バージョン: $VERSION"
log_info "  フルタグ: $FULL_TAG"
log_info "  Dockerfile: $DOCKERFILE"

# Docker ビルド
log_info "Dockerイメージをビルド中..."
docker build \
    --platform linux/amd64 \
    --file "$DOCKERFILE" \
    --tag "$FULL_TAG" \
    --tag "$LATEST_TAG" \
    $NO_CACHE \
    .

if [[ $? -eq 0 ]]; then
    log_success "ビルドが完了しました: $FULL_TAG"
else
    log_error "ビルドに失敗しました"
    exit 1
fi

# 追加タグの適用
if [[ -n "$ADDITIONAL_TAG" ]]; then
    ADDITIONAL_FULL_TAG="$REGISTRY_USER/$IMAGE_NAME:$ADDITIONAL_TAG"
    log_info "追加タグを適用中: $ADDITIONAL_FULL_TAG"
    docker tag "$FULL_TAG" "$ADDITIONAL_FULL_TAG"
fi

# イメージサイズの表示
log_info "ビルドされたイメージ:"
docker images | grep "$REGISTRY_USER/$IMAGE_NAME" | head -5

# プッシュ
if [[ "$PUSH" == true ]]; then
    log_info "Docker Hubにプッシュ中..."
    
    # ログイン確認
    if ! docker info | grep -q "Username"; then
        log_warning "Docker Hubにログインしていません"
        log_info "docker login を実行してください"
        exit 1
    fi
    
    docker push "$FULL_TAG"
    docker push "$LATEST_TAG"
    
    if [[ -n "$ADDITIONAL_TAG" ]]; then
        docker push "$ADDITIONAL_FULL_TAG"
    fi
    
    log_success "プッシュが完了しました"
fi

# テスト実行
if [[ "$TEST" == true ]]; then
    log_info "テストコンテナを起動中..."
    
    CONTAINER_NAME="test-$IMAGE_NAME-$(date +%s)"
    
    docker run -d \
        --name "$CONTAINER_NAME" \
        --platform linux/amd64 \
        -p 8188:8188 \
        -e SERVE_API_LOCALLY=true \
        "$FULL_TAG"
    
    log_info "テストコンテナが起動しました: $CONTAINER_NAME"
    log_info "ComfyUI: http://localhost:8188"
    log_info "API: http://localhost:8000"
    log_info ""
    log_info "テスト終了後は以下のコマンドでコンテナを停止・削除してください:"
    log_info "  docker stop $CONTAINER_NAME"
    log_info "  docker rm $CONTAINER_NAME"
fi

log_success "すべての処理が完了しました！"
