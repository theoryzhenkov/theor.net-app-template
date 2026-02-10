# myapp.theor.net

App template for deploying to theor.net infrastructure.

## Quick start

```bash
# 1. Rename placeholders
chmod +x setup.sh
./setup.sh <your-app-name>

# 2. Set up your Dockerfile (see comments in Dockerfile)

# 3. Set up infra (in the theor.net infra repo)
just app create <name>           # creates nixos/apps/<name>.yaml
just app init-secrets <name>     # generates Age keypair, prints keys
# Follow the printed instructions to add the private key to infra SOPS

just app generate && just deploy

# 4. Configure secrets in this repo
# Edit .sops.yaml — replace placeholder keys with the ones from step 3
sops secrets/production.enc.yaml   # add your app secrets

# 5. Push to GitHub — CI builds image and pushes secrets artifact
git add . && git commit -m "initial setup" && git push
```

## How it works

```
Push to main
  ├── CI: build Docker image → ghcr.io/<repo>/<name>:latest
  └── CI: push encrypted secrets → ghcr.io/<repo>/<name>-secrets:production
                │
                ▼
Server (auto-update every 5 min)
  ├── pulls image, restarts if changed
  ├── checks secrets artifact digest, restarts if changed
  └── on start: crane export secrets artifact
                 → sops decrypt with per-app Age key
                 → docker run --env-file (secrets + DATABASE_URL)
```

## Project structure

```
├── .github/workflows/deploy.yml   CI: image + secrets push
├── .sops.yaml                     SOPS encryption config
├── secrets/production.enc.yaml    Encrypted app secrets (created by you)
├── .env.example                   Local dev env vars
├── .envrc.example                 direnv config
├── Dockerfile                     Container build (you fill this in)
├── flake.nix                      Nix dev shell
├── justfile                       Dev commands
└── nginx.conf                     Optional: for static/SPA apps
```

## Secrets

There are two kinds of environment variables your app receives:

**Infra-provided** (managed in the infra repo):
- `DATABASE_URL` — injected automatically if your app YAML has `database: true`

**App-owned** (managed in this repo):
- Everything in `secrets/production.enc.yaml` — encrypted with SOPS, pushed as an OCI artifact, decrypted on the server at service start

### Setting up secrets

1. In the infra repo, generate an Age keypair:
   ```bash
   just app init-secrets <name>
   ```
   This prints a public key and a private key.

2. Add the **private key** to infra SOPS secrets:
   ```bash
   sops nixos/secrets/secrets.enc.yaml
   # Add: age_key_<name>: AGE-SECRET-KEY-...
   ```

3. Edit `.sops.yaml` in this repo with both keys:
   ```yaml
   keys:
     - &app <public-key-from-step-1>
     - &local <your-local-age-public-key>
   ```
   The `&local` key is from the infra repo's `.age-key.txt` (run `age-keygen -y path/to/.age-key.txt` to get the public key).

4. Create and edit secrets:
   ```bash
   sops secrets/production.enc.yaml
   ```
   Add key-value pairs in YAML format:
   ```yaml
   API_KEY: sk-...
   SESSION_SECRET: random-string
   BASE_URL: https://<name>.theor.net
   ```

### Manual fallback

If CI isn't set up yet, push secrets directly:
```bash
# From the infra repo:
just app secrets-push <name> path/to/secrets/production.enc.yaml
```

## Infra-side setup

In the `theor.net` infra repo:

1. **Create app config:**
   ```bash
   just app create <name>
   ```
   Then edit `nixos/apps/<name>.yaml`:
   ```yaml
   image: ghcr.io/theoryzhenkov/<repo>/<name>:latest
   containerPort: 3000
   hostPort: <pick an unused port 8100-8199>
   domain: <name>.theor.net
   database: true                                              # if needed
   secrets: ghcr.io/theoryzhenkov/<repo>/<name>-secrets:production  # if needed
   ```

2. **Add DNS** (in `terraform/main.tf`):
   ```hcl
   resource "porkbun_dns_record" "theor_net_<name>" {
     domain   = "theor.net"
     name     = "<name>"
     type     = "A"
     content  = hcloud_primary_ip.web_ipv4.ip_address
     ttl      = 600
     priority = 0
   }
   ```
   Then: `cd terraform && just apply`

3. **Deploy:**
   ```bash
   just app generate && just deploy
   ```

## Local development

```bash
cp .envrc.example .envrc    # then: direnv allow
cp .env.example .env        # fill in local values
just install
just dev
```
