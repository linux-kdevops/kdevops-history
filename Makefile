.PHONY: all deps ansible_deps vagrant-deps clean

all: deps

terraform-deps:
	@make -C terraform deps

vagrant-deps:
	@ansible-playbook -i hosts playbooks/kdevops_vagrant.yml

ansible_deps:
	@ansible-galaxy install -r requirements.yml

deps: ansible_deps terraform-deps vagrant-deps
	@echo Installed dependencies

terraform-clean:
	@make -C terraform clean

clean: terraform-clean
	@echo Cleaned up
