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
	@if [ -z "$$(git ls-remote --heads origin data)" ]; then \
		TREE=$$(gh api repos/$(REPO)/git/trees -f 'tree[][path]=.gitkeep' -f 'tree[][mode]=100644' -f 'tree[][type]=blob' -f 'tree[][content]=' --jq '.sha') && \
		COMMIT=$$(gh api repos/$(REPO)/git/commits -f message="init" -f tree="$$TREE" --jq '.sha') && \
		gh api repos/$(REPO)/git/refs -f ref="refs/heads/data" -f sha="$$COMMIT" > /dev/null && \
		echo "data branch created"; \
	fi
	@echo "data branch ready"

deploy:
	gh workflow run deploy.yml --repo $(REPO)

logs:
	gh run list --repo $(REPO) --limit 1 --json databaseId --jq '.[0].databaseId' | xargs -I {} gh run view {} --repo $(REPO) --log

status:
	gh run list --repo $(REPO) --limit 5
