[![CI](https://github.com/ktooi/ansible-role-argocd-backup/workflows/CI/badge.svg)](https://github.com/ktooi/ansible-role-argocd-backup/actions?query=workflow%3ACI+branch%3Amain)

# Ansible Role: argocd-backup

ArgoCD の設定をバックアップするシェルスクリプトを配置し、 cron で定期的に実行させるための role です。

この role では次のことを行います。

* ArgoCD の設定バックアップスクリプトのインストール。
* ArgoCD の設定バックアップスクリプトを定期的に実行するための cron ファイル配置。

この role では次のことを行いません。

* ArgoCD のインストール。
* `argocd` コマンドのインストール。

## Requirements

この role には特別な要件はありません。

## How does this backup?

この role にて ArgoCD の設定をバックアップするためのスクリプト `backup_argocd.sh` が配置されます。
専用の cron ファイルを配置し、 `backup_argocd.sh` は定期的に実行されます。

`backup_argocd.sh` は次のように動作します。

* `argocd` コマンドで設定情報を出力する(`backup_argocd.sh` が実行する `argocd` コマンドのサンプルは下記参照)。

    ```
    argocd -n <NameSpace> admin export --kueconfig <KubeConfigFile>
    ```
* 出力した設定情報が、以前の設定情報から変わっていた場合に `gzip` 圧縮してバックアップとして保存する。
* スクリプトが正常に完了したら、 `watchdog` ファイルのタイムスタンプを更新する(`backup_argocd.sh` の正常動作監視を行うための機能)。

## Role Variables

```yaml
argocd_backup_ns: "argocd"
```

設定のバックアップを行う argocd がデプロイされている Namespace を指定します。

```yaml
argocd_backup_dst_dir: "/var/argocd/backup"
```

バックアップの保存先ディレクトリを指定します。

```yaml
argocd_backup_schedule: "0 * * * *"
```

バックアップの実行スケジュールを設定します。

cron.d の形式で設定します。

```yaml
argocd_backup_user: root
```

バックアップの実行ユーザを指定します。

```yaml
argocd_backup_script_file: "/usr/local/bin/backup_argocd.sh"
```

バックアップスクリプトのコピー先ファイル名をフルパスで指定します。

```yaml
argocd_backup_cron_file: "/etc/cron.d/argocd-backup"
```

バックアップスクリプトを定期的に実行させる cron ファイルをフルパスで指定します。

```yaml
# argocd_backup_kubeconfig_file:
```

Kubernetes に接続するための認証情報を保存してあるファイル(通常であれば `~/.kube/config` )を指定してください。
`argocd_backup_user` がこのファイルを読み込める必要があります。

この role では `argocd_backup_kubeconfig_file` に指定したファイルの生成やコピーは行いませんので、事前に Kubernetes に接続するための認証情報を配置しておいてください。

なお `argocd_backup_kubeconfig_file` が未指定の場合は、 `argocd_backup_user` のホームディレクトリ配下の `.kube/config` が指定されます。

i.e.: `/root/.kube/config`, `/home/ktooi/.kube/config`

```yaml
argocd_backup_become_user_precheck: true
```

この role ではセットアップ前に Precheck を実施しますが、その際に `argocd_backup_user` にて指定されたユーザにてチェックするか否かを指定します。

* `true` に設定された場合は `argocd_backup_user` にて指定されたユーザを用いてチェックを行います。これは厳密なチェックになりますが、
  `ansible_user` から `argocd_backup_user` にスイッチできない場合には意図せずにチェックが失敗してしまうかもしれません。
* `false` に設定された場合は `ansible_become_user` などで Ansible に指定されたユーザに権限昇格します。概ね問題なく動作すると思いますが、 `true` を指定した時と比べると厳密さは劣ります。

## Dependencies

None.

## Example Playbook

```yaml
- hosts: argocd_server
  roles:
    - ktooi.argocd_backup
```

## Authors

* **Kodai Tooi** [GitHub](https://github.com/ktooi), [Qiita](https://qiita.com/ktooi)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
