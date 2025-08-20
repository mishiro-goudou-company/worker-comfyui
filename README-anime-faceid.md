# ComfyUI Anime FaceID Worker

anime faceid ワークフロー用のカスタムComfyUIワーカーです。RunPodサーバーレス環境向けに最適化されています。

## 特徴

- **事前インストール済みモデル**: novaAnimeXL_ilV100.safetensors (7GB)
- **カスタムノード**: InstantID、ControlNet、Face Detection等
- **高速起動**: モデルがイメージに含まれているため、ランタイムでのダウンロード不要
- **RunPod最適化**: サーバーレス環境での効率的な実行

## 含まれるモデル

- **メインチェックポイント**: novaAnimeXL_ilV100.safetensors
- **ControlNet**: controlnet-union-sdxl-1.0
- **InstantID**: ip-adapter.bin
- **InsightFace**: antelopev2 モデル

## 含まれるカスタムノード

- `artventure` - AV_ControlNetPreprocessor
- `essentials` - ImageResize+
- `comfyui-face-detection-node` - FaceDetectionNode  
- `instantid` - ApplyInstantID, InstantIDModelLoader
- `comfyui_controlnet_aux` - ControlNet補助機能

## ビルド方法

### 1. 基本ビルド

```bash
# 基本的なビルド
./build.sh

# バージョン指定
./build.sh --version 1.1.0

# キャッシュなしでビルド
./build.sh --no-cache
```

### 2. Docker Hubにプッシュ

```bash
# ユーザー名を指定してビルド&プッシュ
./build.sh --user your-dockerhub-username --push

# 追加タグ付きでプッシュ
./build.sh --user your-dockerhub-username --tag stable --push
```

### 3. テスト実行

```bash
# ビルド後にテストコンテナを起動
./build.sh --test

# 全部込み
./build.sh --user your-dockerhub-username --version 1.1.0 --push --test
```

### 4. 手動ビルドコマンド

```bash
# 基本的な手動ビルド
docker build \
  --platform linux/amd64 \
  --file Dockerfile.anime-faceid \
  --tag your-username/comfyui-anime-faceid:1.0.0 \
  --tag your-username/comfyui-anime-faceid:latest \
  .

# キャッシュなし
docker build \
  --platform linux/amd64 \
  --file Dockerfile.anime-faceid \
  --no-cache \
  --tag your-username/comfyui-anime-faceid:1.0.0 \
  .

# プッシュ
docker push your-username/comfyui-anime-faceid:1.0.0
docker push your-username/comfyui-anime-faceid:latest
```

## ローカルテスト

```bash
# コンテナ起動
docker run -d \
  --name comfyui-anime-faceid-test \
  --platform linux/amd64 \
  -p 8188:8188 \
  -e SERVE_API_LOCALLY=true \
  your-username/comfyui-anime-faceid:latest

# アクセス
# ComfyUI: http://localhost:8188
# API: http://localhost:8000

# 停止・削除
docker stop comfyui-anime-faceid-test
docker rm comfyui-anime-faceid-test
```

## RunPodでの使用

1. **テンプレート作成**:
   - Container Image: `your-username/comfyui-anime-faceid:latest`
   - Container Disk: 20GB以上推奨

2. **エンドポイント作成**:
   - GPU: RTX 4090以上推奨 (VRAM 24GB)
   - Workers: 必要に応じて設定

3. **API呼び出し例**:
```json
{
  "input": {
    "workflow": {
      // anime_faceid.jsonの内容
    },
    "images": [
      {
        "name": "IMG_2544.JPG",
        "image": "data:image/jpeg;base64,..."
      }
    ]
  }
}
```

## トラブルシューティング

### ビルドエラー

```bash
# モデルファイルパスの確認
ls -la /Applications/Data/Models/StableDiffusion/novaAnimeXL_ilV100.safetensors

# Dockerfileの構文チェック
docker build --dry-run -f Dockerfile.anime-faceid .
```

### 実行時エラー

```bash
# ログ確認
docker logs container-name

# コンテナ内部確認
docker exec -it container-name /bin/bash
```

## イメージサイズ

- **推定サイズ**: 15-18GB
- **内訳**:
  - ベースイメージ: ~5GB
  - メインモデル: ~7GB
  - その他モデル: ~3-6GB

## 必要システム要件

- **ビルド環境**: 
  - Docker Desktop
  - 20GB以上の空き容量
  - macOS/Linux (Windows WSL2)

- **実行環境**:
  - NVIDIA GPU (VRAM 16GB以上推奨)
  - CUDA 12.6+対応

## ライセンス

このプロジェクトは元のComfyUIワーカーのライセンスに従います。
