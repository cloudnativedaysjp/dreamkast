Dreamkast platform
==================

<div align="center">
<img src="images/dreamkast.png" width="300">
</div>

|Name|Description|Platform|Repos|Manifest|
|----|----|----|----|----|
|Dreamkast|See [Docs](dreamkast.md)|Kubernetes|||
|Dreamkast UI|See [Docs](dreamkast-ui.md)|Kubernetes|||
|Dreamkast Infra|Dreamkastの各コンポーネントをIaCするリポジトリ。<br/>- Kubernetesマニフェスト<br/>- CloudFormation - AWSリソースの管理<br/>- Terraform - AWS以外のリソースの管理<br/>- Grafana Dashboard||[Repos](https://github.com/cloudnativedaysjp/dreamkast-infra)|-|
|Dreamkast Relasebot|ChatOpsを実現するコンポーネント。Slackで@dreamkast-releasebotを呼び出すことで、各プロダクトをProduction環境にデプロイできる。<br/>言語/Framework: Go / slack-go (RTM)|Kubernetes|[Repos](https://github.com/cloudnativedaysjp/dreamkast-releasebot)|[Manifest](https://github.com/cloudnativedaysjp/dreamkast-infra/tree/main/manifests/app/dreamkast-releasebot)|
|Dreamkast Review App Operator|GitHubのPull Requestをチェックし、新しいPRが出来たらDreamkastのコンポーネント一式を立ち上げる、KubernetesのOperator。<br/>言語/Framework: Go / Kubebuilder|Kubernetes|[Repos](https://github.com/cloudnativedaysjp/reviewapp-operator)|[Manifest](https://github.com/cloudnativedaysjp/dreamkast-infra/tree/main/manifests/infra/reviewapp-operator)|
|Dreamkast API Docs|DreamkastのAPIを定義しているドキュメント。Swaggerを利用している|Kubernetes|[Repos](https://github.com/cloudnativedaysjp/dreamkast-api-docs)|[Manifest](https://github.com/cloudnativedaysjp/dreamkast-infra/tree/main/manifests/app/dreamkast-api-mock/base)|
