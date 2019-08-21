.PHONY: all deps bin-check ansible_deps vagrant-deps clean

BINS :=  ansible
BINS +=  vagrant
BINS +=  terraform

all: deps

bin-check:
	@for i in $(BINS); do                                                 \
		if ! which $$i 2>&1 > /dev/null ; then                        \
			echo "--------------------------------------------- ";\
			echo "$$i not installed, install it. In the         ";\
			echo "future we may have an option to try to do this";\
			echo "for you... but for now, its on you to do this.";\
			echo "--------------------------------------------- ";\
			return 1                                             ;\
		else                                                          \
			echo "$$i installed !"                               ;\
		fi                                                            \
	done

terraform-deps:
	@ansible-playbook -i hosts playbooks/kdevops_terraform.yml 
	@if [ -d terraform ]; then \
		make -C terraform deps; \
	fi

vagrant-deps:
	@ansible-playbook -i hosts playbooks/kdevops_vagrant.yml

ansible_deps:
	@ansible-galaxy install -r requirements.yml

deps: bin-check ansible_deps terraform-deps vagrant-deps
	@echo Installed dependencies

terraform-clean:
	@if [ -d terraform ]; then \
		make -C terraform clean ; \
	fi

clean: terraform-clean
	@echo Cleaned up
