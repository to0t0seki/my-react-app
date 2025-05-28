# AWS ECS + Fargate デプロイ設定手順

## 前提条件
- AWSアカウントが作成済み
- AWS CLIがインストール済み（ローカル設定用）

## 1. IAMユーザーとロールの作成

### IAMユーザー作成（GitHub Actions用）
1. AWS Console → IAM → Users → Create user
2. ユーザー名: `github-actions-user`
3. プログラマティックアクセスを有効化
4. 以下のポリシーをアタッチ:
   - `AmazonECS_FullAccess`
   - `AmazonEC2ContainerRegistryFullAccess`
   - `IAMReadOnlyAccess`

### ECSタスク実行ロール作成
```bash
# AWS CLIで作成
aws iam create-role \
  --role-name ecsTaskExecutionRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }'

# ポリシーをアタッチ
aws iam attach-role-policy \
  --role-name ecsTaskExecutionRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

### ECSタスクロール作成
```bash
aws iam create-role \
  --role-name ecsTaskRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }'
```

## 2. ECRリポジトリ作成

```bash
# ECRリポジトリ作成
aws ecr create-repository \
  --repository-name my-react-app \
  --region ap-northeast-1
```

## 3. ECSクラスター作成

```bash
# Fargateクラスター作成
aws ecs create-cluster \
  --cluster-name my-react-app-cluster \
  --capacity-providers FARGATE \
  --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1
```

## 4. CloudWatch Logs グループ作成

```bash
# ログ用のCloudWatch Logs グループ作成
aws logs create-log-group \
  --log-group-name /ecs/my-react-app \
  --region ap-northeast-1
```

## 5. VPCとセキュリティグループ設定

### デフォルトVPCのサブネット確認
```bash
# デフォルトVPCのサブネットID取得
aws ec2 describe-subnets \
  --filters "Name=default-for-az,Values=true" \
  --query 'Subnets[*].[SubnetId,AvailabilityZone]' \
  --output table
```

### セキュリティグループ作成
```bash
# セキュリティグループ作成
aws ec2 create-security-group \
  --group-name my-react-app-sg \
  --description "Security group for my-react-app ECS service"

# HTTP(80)ポートを開放
aws ec2 authorize-security-group-ingress \
  --group-name my-react-app-sg \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0
```

## 6. Application Load Balancer作成（オプション）

```bash
# ALB作成
aws elbv2 create-load-balancer \
  --name my-react-app-alb \
  --subnets subnet-12345678 subnet-87654321 \
  --security-groups sg-12345678

# ターゲットグループ作成
aws elbv2 create-target-group \
  --name my-react-app-targets \
  --protocol HTTP \
  --port 80 \
  --vpc-id vpc-12345678 \
  --target-type ip \
  --health-check-path /
```

## 7. ECSサービス作成

```bash
# ECSサービス作成
aws ecs create-service \
  --cluster my-react-app-cluster \
  --service-name my-react-app-service \
  --task-definition my-react-app-task:1 \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345678,subnet-87654321],securityGroups=[sg-12345678],assignPublicIp=ENABLED}"
```

## 8. GitHubシークレット設定

GitHubリポジトリの Settings → Secrets and variables → Actions で以下を設定:

```
AWS_ACCESS_KEY_ID: (IAMユーザーのアクセスキー)
AWS_SECRET_ACCESS_KEY: (IAMユーザーのシークレットキー)
```

## 9. task-definition.json の修正

`task-definition.json` ファイル内の以下を実際の値に置換:

```json
{
  "executionRoleArn": "arn:aws:iam::YOUR_ACCOUNT_ID:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::YOUR_ACCOUNT_ID:role/ecsTaskRole",
  "image": "YOUR_ACCOUNT_ID.dkr.ecr.ap-northeast-1.amazonaws.com/my-react-app:latest"
}
```

## 10. デプロイ実行

1. 上記設定完了後、`main`ブランチにプッシュ
2. GitHub Actionsが自動実行される
3. ECSサービスのパブリックIPでアクセス可能

## コスト概算（東京リージョン）

- **Fargate**: 約$0.04/時間（256 CPU, 512 MB）
- **ALB**: 約$0.025/時間 + データ転送料
- **ECR**: 0.5GB まで無料、以降 $0.10/GB/月
- **CloudWatch Logs**: 5GB まで無料、以降 $0.50/GB

**月額概算**: 約$30-50（24時間稼働の場合）

## トラブルシューティング

### よくあるエラー
1. **タスクが起動しない**: セキュリティグループとサブネット設定を確認
2. **イメージプルエラー**: ECRの権限とリポジトリ名を確認
3. **ヘルスチェック失敗**: アプリケーションのポート設定を確認

### ログ確認
```bash
# ECSタスクのログ確認
aws logs get-log-events \
  --log-group-name /ecs/my-react-app \
  --log-stream-name ecs/my-react-app-container/TASK_ID
``` 