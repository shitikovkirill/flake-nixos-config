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

## Nix module

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
  - `HOME = "/root"` — see [Credentials chain errors](#credentials-chain-errors-no-valid-providers-in-chain).
- Sets `HOME = "/root"` on `amazon-ssm-agent.service` too, for the same reason.
- Orders `ecs-agent.service` after `amazon-ssm-agent.service`, since
  `ecs-agent` reads the shared credentials file `amazon-ssm-agent` writes
  on startup.
- Adds `amazon-ssm-agent` to `environment.systemPackages` so the CLI is on
  `PATH` for the one-time registration step in the runbook below.

It's disabled by default — nothing in this repo turns it on for any host.

## Usage

### Enabling on a host

```nix
services.ecsAnywhere = {
  enable = true;
  cluster = "my-cluster";
  region = "eu-central-1";
};
```

### Finding `ECS_CLUSTER`

`cluster` is the ECS cluster **name** (not ARN).

- Existing cluster — list them and take the part after the last `/`:

  ```bash
  $ aws ecs list-clusters --region eu-central-1
  {
      "clusterArns": [
          "arn:aws:ecs:eu-central-1:123456789012:cluster/my-cluster"
      ]
  }
  ```

  `my-cluster` is the value for both `cluster` here and `--iam-role`'s
  cluster context below. Same name is visible in the AWS Console under
  ECS → Clusters.

- No cluster yet — create one:

  ```bash
  aws ecs create-cluster --cluster-name my-cluster --region eu-central-1
  ```

  ECS Anywhere clusters don't need EC2/Fargate capacity providers — external
  instances register into them directly via the SSM activation.

The region used here must match `region` above and the region passed to
`aws ssm create-activation`.

### Multiple hosts

Each host gets its own `services.ecsAnywhere` block (and its own SSM
activation — see runbook step 1). They can join the same cluster or
different ones:

```nix
# hosts/asus-n56vj/server.nix
services.ecsAnywhere = {
  enable = true;
  cluster = "my-cluster";
  region = "eu-central-1";
};
```

```nix
# hosts/some-other-host/server.nix
services.ecsAnywhere = {
  enable = true;
  cluster = "my-cluster";          # same cluster, second instance
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

Example:

```bash
$ aws ssm create-activation \
    --default-instance-name "nixos-asus-n56vj" \
    --iam-role "ECSAnywhereRole" \
    --registration-limit 1 \
    --region eu-central-1
{
    "ActivationId": "a1b2c3d4-5678-90ab-cdef-exampleabcd",
    "ActivationCode": "AbCdEfGhIjKlMnOpQrStUvWx"
}
```

Note the `ActivationId` and `ActivationCode` from the output — they're only
shown once. Also note the cluster name and region you intend to join.
Activations expire after 24 hours by default and `--registration-limit 1`
allows exactly one successful registration, so a second `-register` attempt
with the same code will fail — create a fresh activation per host, per
attempt.

### 2. Deploy the Nix config

Set `services.ecsAnywhere.enable/cluster/region` (see [Usage](#usage)) and
`nixos-rebuild switch` the host. This starts `amazon-ssm-agent.service`
(unregistered — it will loop retrying until step 3 is done) and
`ecs-agent.service` (which will likewise wait/retry until SSM is
registered).

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

The role passed to `--iam-role` in step 1 is assumed by SSM on the managed
instance's behalf, so it needs a trust policy for the SSM service, plus
managed policies covering SSM and ECS Anywhere:

Trust policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ssm.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

Attach these AWS-managed policies:

```bash
aws iam attach-role-policy \
  --role-name ECSAnywhereRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

aws iam attach-role-policy \
  --role-name ECSAnywhereRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role
```

`AmazonSSMManagedInstanceCore` lets the managed instance talk to SSM at
all; `AmazonEC2ContainerServiceforEC2Role` (despite the EC2-sounding name,
it's the policy AWS documents for ECS Anywhere roles too) covers
`ecs:RegisterContainerInstance`, `ecs:DeregisterContainerInstance`,
`ecs:DiscoverPollEndpoint`, `ecs:Submit*`, `ecs:Poll`,
`ecs:StartTelemetrySession`, and `ecs:UpdateContainerInstancesState`.

### 5. Verify registration

```bash
aws ecs list-container-instances --cluster "<cluster>" --region "<region>"
aws ecs describe-container-instances \
  --cluster "<cluster>" --region "<region>" \
  --container-instances "<arn-from-above>"
```

Example:

```bash
$ aws ecs list-container-instances --cluster my-cluster --region eu-central-1
{
    "containerInstanceArns": [
        "arn:aws:ecs:eu-central-1:123456789012:container-instance/my-cluster/0123456789abcdef0123456789abcdef"
    ]
}

$ aws ecs describe-container-instances \
    --cluster my-cluster --region eu-central-1 \
    --container-instances arn:aws:ecs:eu-central-1:123456789012:container-instance/my-cluster/0123456789abcdef0123456789abcdef
{
    "containerInstances": [
        {
            "status": "ACTIVE",
            "capacityProviderName": "",
            "ec2InstanceId": "mi-0123456789abcdef",
            "attributes": [
                { "name": "ecs.os-type", "value": "linux" }
            ]
        }
    ]
}
```

`ec2InstanceId` holding an `mi-...` (managed instance) ID rather than
`i-...` confirms this is an EXTERNAL instance, not an EC2 one. On the host
itself:

```bash
systemctl status amazon-ssm-agent ecs-agent
journalctl -u amazon-ssm-agent -u ecs-agent -e
```

## Connecting further NixOS hosts

Repeat steps 1–5 per host (each needs its own SSM activation — the
`--registration-limit 1` above ties one activation to one instance). The Nix
side only ever needs `services.ecsAnywhere.enable/cluster/region` set on
that host's configuration; nothing else in this repo is host-specific.

## Debugging

SSM registration and ECS registration are two **independent** credential
paths — the agents don't talk to each other directly, they each
authenticate to their own AWS service. A healthy `amazon-ssm-agent` says
nothing about whether `ecs-agent` can register, and vice versa. Diagnose
them separately, in this order:

1. Is the host visible to **Systems Manager** at all? (SSM identity/registration)
2. Is the host visible as a **container instance** in the ECS cluster? (ECS registration)
3. If both check out on AWS's side but the console looks empty, it's a
   console navigation/account/region issue, not an agent problem.

### Quick checks

```bash
# SSM side — does AWS see this managed instance, and is it Online?
aws ssm describe-instance-information --region <region>

# ECS side — is it a registered, ACTIVE container instance?
aws ecs list-container-instances --cluster <cluster> --region <region>

# Confirm you're looking at the right AWS account from the CLI
aws sts get-caller-identity

# On the host: service status + the actual error, not just "active"
systemctl status amazon-ssm-agent ecs-agent
journalctl -u amazon-ssm-agent -u ecs-agent -n 150 --no-pager

# File logs some messages don't make it into systemd's journal
sudo cat /var/log/amazon/ssm/amazon-ssm-agent.log
sudo cat /var/log/amazon/ssm/errors.log
```

If `describe-instance-information`/`list-container-instances` already show
the host but the AWS Console doesn't, double-check the region selector
(top-right) and the account (`aws sts get-caller-identity` vs. the account
shown under your username in the console) before suspecting the agents —
Fleet Manager's node-type filter in particular can hide hybrid/on-premises
instances if it's not set to "All".

### Host missing from Systems Manager

`sudo cat /var/lib/amazon/ssm/registration` should contain a
`ManagedInstanceID` (`mi-...`) and region. If it's empty or the agent keeps
restarting without ever logging `Agent will take identity from OnPrem`,
check, roughly in order of likelihood:

- **Activation expired or already consumed.** Default activations expire
  after 24h and `--registration-limit 1` allows exactly one successful
  `-register`. Create a fresh activation (runbook step 1) and re-register.
- **Clock skew.** SSM's API calls are SigV4-signed; a drifted clock fails
  signature validation with no obvious error on the agent side.
  `timedatectl status` should show `System clock synchronized: yes`.
- **Outbound network blocked.** The agent needs HTTPS (443) to
  `ssm.<region>.amazonaws.com`, `ssmmessages.<region>.amazonaws.com`, and
  `ec2messages.<region>.amazonaws.com`. A bare `curl -v https://ssm.<region>.amazonaws.com`
  returning an HTTP 400 (not a connection failure/timeout) means the
  network path is fine — that 400 is just the API rejecting an unsigned
  GET.

### Host missing from the ECS cluster

If SSM shows the host `Online` but it's not a container instance in the
cluster, check `journalctl -u ecs-agent` for one of these two signatures:

**IAM role missing ECS permissions** — the role from `create-activation`
lacks the policies in runbook step 4:

```
level=error msg="AccessDeniedException: User: arn:aws:sts::123456789012:assumed-role/ECSAnywhereRole/mi-0123456789abcdef is not authorized to perform: ecs:RegisterContainerInstance"
```

Fix: attach `AmazonSSMManagedInstanceCore` and
`AmazonEC2ContainerServiceforEC2Role` to that role (see step 4).

#### Credentials chain errors (`no valid providers in chain`)

```
level=error msg="Error getting ECS instance credentials from credentials chain: no valid providers in chain: failed to get shared config profile, default\n...no EC2 IMDS role found..."
level=error msg="Received terminal error from RegisterContainerInstance call, exiting"
```

On a hybrid-registered instance, `amazon-ssm-agent` refreshes temporary
credentials into `~/.aws/credentials` (the `default` profile) — that's the
mechanism ECS Anywhere relies on for `ecs-agent` to get its ECS API
credentials. Both services run as root with no `User=` set in their
systemd units, so systemd never populates `$HOME` for them, and the Go AWS
SDK (`os.UserHomeDir()`, which only reads `$HOME`, has no NSS fallback)
can't find that file at all — `ecs-agent` fails immediately after logging
`"Registering Instance with ECS"`, even though `amazon-ssm-agent`'s own
logs look completely healthy (`[CredentialRefresher] Credentials ready`,
periodic rotation messages).

The module already sets `HOME = "/root"` on both `amazon-ssm-agent.service`
and `ecs-agent.service` to fix this (so they agree on
`/root/.aws/credentials`). If you still hit this error after
`nixos-rebuild switch`, confirm the file actually exists and has fresh
credentials, then restart both agents:

```bash
sudo cat /root/.aws/credentials
sudo systemctl restart amazon-ssm-agent ecs-agent
```
