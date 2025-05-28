# ビルドステージ
FROM node:18-alpine AS builder

WORKDIR /app

# 依存関係のインストール
COPY package*.json ./
RUN npm ci

# アプリケーションのソースコピーとビルド
COPY . .
RUN npm run build

# 配信ステージ
FROM nginx:1.24-alpine AS production

# ビルド成果物をNginxの公開ディレクトリへコピー
COPY --from=builder /app/build /usr/share/nginx/html

# 必要ならカスタムnginx.confを追加
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
