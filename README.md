# My React App

This project was bootstrapped with [Create React App](https://github.com/facebook/create-react-app).

## CI/CD Pipeline

このプロジェクトはGitHub Actionsを使用してCI/CDパイプラインを設定しています。

### ワークフロー

1. **Simple CI** (`.github/workflows/simple-ci.yml`)
   - プッシュ・プルリクエスト時に自動実行
   - 依存関係のインストール
   - テストの実行
   - ビルドの実行
   - ビルド成果物のアーティファクト保存

2. **Full CI/CD** (`.github/workflows/ci-cd.yml`)
   - テスト実行
   - Dockerイメージのビルドとプッシュ（GitHub Container Registry）
   - GitHub Pagesへの自動デプロイ

3. **AWS ECS + Fargate Deploy** (`.github/workflows/deploy-aws-ecs.yml`)
   - テスト実行
   - DockerイメージをAWS ECRにプッシュ
   - AWS ECS + Fargateへの自動デプロイ

### 必要な設定

#### GitHub Pagesデプロイを有効にする場合：
1. GitHubリポジトリの Settings → Pages
2. Source を "GitHub Actions" に設定

#### Docker イメージプッシュを有効にする場合：
- 特別な設定は不要（GitHub Container Registryを使用）
- プライベートリポジトリの場合、パッケージの可視性設定を確認

#### AWS ECS + Fargateデプロイを有効にする場合：
1. AWSアカウントの作成
2. IAMユーザーとロールの設定
3. ECR、ECS、Fargateリソースの作成
4. GitHubシークレットの設定
5. 詳細は `AWS_ECS_SETUP.md` を参照

## Available Scripts

In the project directory, you can run:

### `npm start`

Runs the app in the development mode.\
Open [http://localhost:3000](http://localhost:3000) to view it in your browser.

The page will reload when you make changes.\
You may also see any lint errors in the console.

### `npm test`

Launches the test runner in the interactive watch mode.\
See the section about [running tests](https://facebook.github.io/create-react-app/docs/running-tests) for more information.

### `npm run build`

Builds the app for production to the `build` folder.\
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.\
Your app is ready to be deployed!

See the section about [deployment](https://facebook.github.io/create-react-app/docs/deployment) for more information.

### `npm run eject`

**Note: this is a one-way operation. Once you `eject`, you can't go back!**

If you aren't satisfied with the build tool and configuration choices, you can `eject` at any time. This command will remove the single build dependency from your project.

Instead, it will copy all the configuration files and the transitive dependencies (webpack, Babel, ESLint, etc) right into your project so you have full control over them. All of the commands except `eject` will still work, but they will point to the copied scripts so you can tweak them. At this point you're on your own.

You don't have to ever use `eject`. The curated feature set is suitable for small and middle deployments, and you shouldn't feel obligated to use this feature. However we understand that this tool wouldn't be useful if you couldn't customize it when you are ready for it.

## Learn More

You can learn more in the [Create React App documentation](https://facebook.github.io/create-react-app/docs/getting-started).

To learn React, check out the [React documentation](https://reactjs.org/).

### Code Splitting

This section has moved here: [https://facebook.github.io/create-react-app/docs/code-splitting](https://facebook.github.io/create-react-app/docs/code-splitting)

### Analyzing the Bundle Size

This section has moved here: [https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size](https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size)

### Making a Progressive Web App

This section has moved here: [https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app](https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app)

### Advanced Configuration

This section has moved here: [https://facebook.github.io/create-react-app/docs/advanced-configuration](https://facebook.github.io/create-react-app/docs/advanced-configuration)

### Deployment

This section has moved here: [https://facebook.github.io/create-react-app/docs/deployment](https://facebook.github.io/create-react-app/docs/deployment)

### `npm run build` fails to minify

This section has moved here: [https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify](https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify)
