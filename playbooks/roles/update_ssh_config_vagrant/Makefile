all: refresh

add-remote:
	git remote add update_ssh_config https://github.com/mcgrof/update_ssh_config.git

add-commits:
	git subtree add --prefix=update_ssh_config update_ssh_config master

refresh:
	git fetch update_ssh_config
	git subtree pull --prefix=update_ssh_config update_ssh_config master
