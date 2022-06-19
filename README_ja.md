[![CI](https://github.com/ktooi/ansible-role-argocd-backup/workflows/CI/badge.svg)](https://github.com/ktooi/ansible-role-argocd-backup/actions?query=workflow%3ACI+branch%3Amain)

# Ansible Role: argocd-backup

定期的に ArgoCD の設定のバックアップを取得します。

この role では次のことを行います。

* ArgoCD の設定バックアップスクリプトのインストール。
* ArgoCD の設定バックアップスクリプトを定期的に実行するための cron ファイル配置。

この role では次のことを行いません。

* ArgoCD のインストール。
* `argocd` コマンドのインストール。

## Requirements

この role には特別な要件はありません。

## Role Variables

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
