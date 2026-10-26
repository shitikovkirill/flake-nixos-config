# ECS Anywhere

Connects a NixOS machine to an AWS ECS cluster as an external (ECS Anywhere)
container instance — **without** AWS's official install script
(`ecs-anywhere-install.sh`).

## Why not the install script

AWS's install script only knows how to install `.deb`/`.rpm` packages and
manage them via `systemctl`/`sysvinit` on Debian/RHEL-family distros. NixOS
has no package manager it can drive and no mutable `/etc` it can write
service files into, so the script fails outright. Instead, this repo wires
up the two pieces it would normally install — the SSM agent and the ECS
agent — using nixpkgs' own native modules: `services.amazon-ssm-agent` and
`services.ecs-agent`.

## What the Nix module does

`server/ecs-anywhere/default.nix` exposes `services.ecsAnywhere`:

| Option | Purpose |
|---|---|
| `enable` | Turns the module on. |
| `cluster` | ECS cluster name → `ECS_CLUSTER`. |
| `region` | AWS region → `AWS_DEFAULT_REGION`. |

When enabled it:
- Turns on `services.amazon-ssm-agent` (links the host to AWS Systems Manager).
- Turns on `services.ecs-agent` with:
  - `ECS_CLUSTER` — the cluster to join.
  - `ECS_EXTERNAL = "true"` — tells the agent this is a non-EC2 (external) instance.
  - `AWS_DEFAULT_REGION` — the region.
  - `ECS_UPDATES_ENABLED = "false"` — NixOS upgrades packages by rebuilding
    the system, not through the agent's built-in self-update mechanism.
  - `ECS_DATADIR = "/var/lib/ecs/data"` — a mutable, non-store directory so
    the agent's container-instance state survives reboots/rebuilds instead
    of registering a brand new instance every time.
- Orders `ecs-agent.service` after `amazon-ssm-agent.service`, since the
  ECS Anywhere credential endpoint the agent relies on is served by the SSM
  agent on localhost.
- Adds `amazon-ssm-agent` to `environment.systemPackages` so the CLI is on
  `PATH` for the one-time registration step below.

It's disabled by default. To use it on a host:

```nix
services.ecsAnywhere = {
  enable = true;
  cluster = "my-cluster";
  region = "eu-central-1";
};
```

## Runbook

The module only covers the always-on systemd services. Everything below is
a one-time, operational step against a real AWS account and the real
machine — not something `nixos-rebuild` can do for you.

### 1. Create the SSM activation

From a machine with AWS CLI credentials for the target account:

```bash
aws ssm create-activation \
  --default-instance-name "<host-name>" \
  --iam-role "<ecs-anywhere-ssm-role>" \
  --registration-limit 1 \
  --region "<region>"
```

Note the `ActivationId` and `ActivationCode` from the output — they're only
shown once. Also note the cluster name and region you intend to join.

### 2. Deploy the Nix config

Set `services.ecsAnywhere.enable/cluster/region` as above (see
[Host wiring](#what-the-nix-module-does)) and `nixos-rebuild switch` the
host. This starts `amazon-ssm-agent.service` (unregistered — it will loop
retrying until step 3 is done) and `ecs-agent.service` (which will likewise
wait/retry until SSM is registered).

### 3. Register the SSM agent (one-time, by hand on the host)

```bash
sudo systemctl stop amazon-ssm-agent
sudo amazon-ssm-agent -register \
  -code "<ActivationCode>" \
  -id "<ActivationId>" \
  -region "<region>"
sudo systemctl start amazon-ssm-agent
```

This writes the registration (managed-instance ID, keys) to
`/var/lib/amazon/ssm/registration` — a normal mutable directory, not under
`/etc` or the Nix store, so it's untouched by `nixos-rebuild` and survives
rebuilds/rollbacks.

### 4. Check the IAM role's permissions

The role passed to `--iam-role` in step 1 needs, at minimum:
- `AmazonSSMManagedInstanceCore` (lets the managed instance talk to SSM).
- `AmazonEC2ContainerServiceforEC2Role`-equivalent permissions for ECS
  Anywhere (`ecs:RegisterContainerInstance`, `ecs:DeregisterContainerInstance`,
  `ecs:DiscoverPollEndpoint`, `ecs:Submit*`, `ecs:Poll`, `ecs:StartTelemetrySession`,
  `ecs:Create*`, `ecs:UpdateContainerInstancesState`, `ecs:Submit*` — in
  practice, attach AWS's managed `AmazonECSInfrastructureRolePolicyForVolumes`
  / the ECS Anywhere-specific managed policies if available in the account,
  or the `AmazonEC2ContainerServiceforEC2Role` policy as a baseline).

If the role is missing permissions, `ecs-agent` will keep failing to
register and its logs (`journalctl -u ecs-agent`) will show access-denied
errors from the ECS API.

### 5. Verify registration

```bash
aws ecs list-container-instances --cluster "<cluster>" --region "<region>"
aws ecs describe-container-instances \
  --cluster "<cluster>" --region "<region>" \
  --container-instances "<arn-from-above>"
```

Confirm `status: ACTIVE` and `capacityProviderName`/instance type indicating
`EXTERNAL`. On the host itself:

```bash
systemctl status amazon-ssm-agent
systemctl status ecs-agent
journalctl -u amazon-ssm-agent -u ecs-agent -e
```

## Connecting further NixOS hosts

Repeat steps 1–5 per host (each needs its own SSM activation — the
`--registration-limit 1` above ties one activation to one instance). The Nix
side only ever needs `services.ecsAnywhere.enable/cluster/region` set on
that host's configuration; nothing else in this repo is host-specific.
