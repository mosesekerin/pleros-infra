VAULT := inventory/group_vars/all/vault.yml
PLAY  := ansible-playbook

.PHONY: help hooks bootstrap bootstrap-key ping check deploy app cron vault-init vault-edit vault-check lint ssh logs

help: ## show commands
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-14s %s\n", $$1, $$2}'

hooks: ## install the git hook that blocks committing an unencrypted vault
	@printf '#!/bin/sh\nmake -s vault-check\n' > .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit && echo "pre-commit hook installed"

bootstrap: ## FIRST RUN: log in as root with the password Contabo emailed
	$(PLAY) playbooks/bootstrap.yml --ask-pass

bootstrap-key: ## FIRST RUN: if your SSH key was added when the server was ordered
	$(PLAY) playbooks/bootstrap.yml

ping: ## check Ansible can reach the server as the deploy user
	ansible all -m ansible.builtin.ping

check: ## dry run: show what would change, change nothing
	$(PLAY) playbooks/site.yml --check --diff

deploy: ## configure everything (safe to re-run)
	$(PLAY) playbooks/site.yml

app: ## update only the app (pull latest code, rebuild if needed, restart)
	$(PLAY) playbooks/site.yml --tags app

cron: ## update only the cron jobs
	$(PLAY) playbooks/site.yml --tags cron

vault-init: ## create the encrypted secrets file from the template
	@test -f $(VAULT) && echo "$(VAULT) already exists" && exit 1 || true
	cp $(VAULT).example $(VAULT)
	ansible-vault encrypt $(VAULT)
	@echo "Now run: make vault-edit"

vault-edit: ## edit the encrypted secrets (opens your editor)
	ansible-vault edit $(VAULT)

vault-check: ## fail if the vault file is not encrypted
	@if [ -f $(VAULT) ] && ! head -1 $(VAULT) | grep -q '^\$$ANSIBLE_VAULT'; then \
	  echo "STOP: $(VAULT) is NOT encrypted. Run: ansible-vault encrypt $(VAULT)"; exit 1; fi

lint: ## lint the playbooks
	ansible-lint

ssh: ## open a shell on the server
	ssh -i ~/.ssh/pleros_ed25519 deploy@$$(ansible-inventory --host pleros-prod | jq -r .ansible_host)

logs: ## follow the app logs
	ssh -i ~/.ssh/pleros_ed25519 deploy@$$(ansible-inventory --host pleros-prod | jq -r .ansible_host) "cd /opt/pleros && docker compose logs -f --tail=100"
