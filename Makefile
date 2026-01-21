REPO ?= agentivo/overlap

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Setup:"
	@echo "  setup          Run full setup (tunnel + data key)"
	@echo "  setup-tunnel   Configure Cloudflare tunnel"
	@echo "  setup-data     Create data branch and DATA_KEY secret"
	@echo ""
	@echo "Operations:"
	@echo "  deploy         Trigger deploy workflow"
	@echo "  status         List recent workflow runs"
	@echo "  logs           View latest run logs"

setup: setup-tunnel setup-data

setup-tunnel:
	python3 scripts/setup_tunnel.py

setup-data:
	@openssl rand -base64 32 | gh secret set DATA_KEY --repo $(REPO)
	@echo "DATA_KEY secret set"
	@git ls-remote --heads origin data >/dev/null 2>&1 || \
		(git switch --orphan data && git commit --allow-empty -m "init" && git push origin data && git switch main)
	@echo "data branch ready"

deploy:
	gh workflow run deploy.yml --repo $(REPO)

logs:
	gh run list --repo $(REPO) --limit 1 --json databaseId --jq '.[0].databaseId' | xargs -I {} gh run view {} --repo $(REPO) --log

status:
	gh run list --repo $(REPO) --limit 5
