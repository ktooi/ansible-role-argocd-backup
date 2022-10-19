[![CI](https://github.com/ktooi/ansible-role-argocd-backup/workflows/CI/badge.svg)](https://github.com/ktooi/ansible-role-argocd-backup/actions?query=workflow%3ACI+branch%3Amain)

# Ansible Role: argocd-backup

This role is used to deploy a shell script to backup ArgoCD configuration and run it periodically by cron.

This role does the following

* Install ArgoCD configuration backup scripts.
* Deploy a cron file to run the ArgoCD configuration backup script periodically.

This role does not do the following

* Install ArgoCD.
* Install the `argocd` command.

## Requirements

There are no special requirements for this role.

## How does this backup?

This role will contain the script `backup_argocd.sh` which will backup the ArgoCD configuration.
A dedicated cron file will be placed and `backup_argocd.sh` will be run periodically.

`backup_argocd.sh` works as follows.

* Output configuration information with the `argocd` command (see below for a sample of the `argocd` command that `backup_argocd.sh` executes).

    ```
    argocd -n <NameSpace> admin export --kueconfig <KubeConfigFile>
    ```
* If the output configuration information has changed from the previous one, `gzip` it and save it as a backup.
* Update the timestamp in the `watchdog` file when the script completes successfully (a function of `backup_argocd.sh` to monitor normal operation).

## Role Variables

```yaml
argocd_backup_ns: "argocd"
```

Specifies the Namespace where argocd is deployed and whose configuration is to be backed up.

```yaml
argocd_backup_dst_dir: "/var/argocd/backup"
```

Specifies the directory where backups will be stored.

```yaml
argocd_backup_schedule: "0 * * * *"
```

Sets the schedule for performing backups.

Set in cron.d format.

```yaml
argocd_backup_user: root
```

Specifies the user as which backups will be performed.

```yaml
argocd_backup_script_file: "/usr/local/bin/backup_argocd.sh"
```

Specifies the full path of the file to which the backup script will be copied.

```yaml
argocd_backup_cron_file: "/etc/cron.d/argocd-backup"
```

Specifies the full path of the cron file that you want the backup script to run periodically.

```yaml
# argocd_backup_kubeconfig_file:
```

Specify the file (usually `~/.kube/config`) where you store the credentials to connect to Kubernetes.
`argocd_backup_user` must be able to read this file.

This role will not generate or copy the file specified in `argocd_backup_kubeconfig_file`, so you should have credentials in place to connect to Kubernetes in advance.

If `argocd_backup_kubeconfig_file` is not specified, `.kube/config` under `argocd_backup_user` home directory will be specified.

i.e.: `/root/.kube/config`, `/home/ktooi/.kube/config`

```yaml
argocd_backup_become_user_precheck: true
```

This role will perform a precheck before the setup, and whether or not the user specified in ``argocd_backup_user`` should be used for the precheck.

* If set to `true`, the check is performed using the user specified by `argocd_backup_user`. This is a strict check, but you can also specify the user from `ansible_user` to
If you cannot switch from `ansible_user` to `argocd_backup_user`, the check may fail unintentionally.
* If set to `false`, it will promote to the user specified by Ansible, e.g. `ansible_become_user`. This should generally work fine, but is less strict than with `true`.

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
