
source ${TOPDIR}/scripts/lib_terraform.sh
source ${TOPDIR}/scripts/aws/lib.sh
source ${TOPDIR}/scripts/gce/lib.sh
source ${TOPDIR}/scripts/azure/lib.sh
source ${TOPDIR}/scripts/openstack/lib.sh

cat_template_file_sed()
{
	cat $1 | sed -e \
		'
		s|@VAGRANTBOX@|'"$VAGRANTBOX"'|g;
		s|@VBOXVERSION@|'$VBOXVERSION'|g;
		' | cat -s
}

cat_template_terraform_sed()
{
	cat $1 | sed -e \
		'
		s|@LIMITBOXES@|'"$LIMITBOXES"'|g;
		s|@LIMITNUMBOXES@|'"$LIMITNUMBOXES"'|g;
		s|@AWSREGION@|'$AWSREGION'|g;
		s|@AWSAVREGION@|'$AWSAVREGION'|g;
		s|@AWSNAMESEARCH@|'$AWSNAMESEARCH'|g;
		s|@AWSVIRTTYPE@|'$AWSVIRTTYPE'|g;
		s|@AWSAMIOWNER@|'$AWSAMIOWNER'|g;
		s|@AWSINSTANCETYPE@|'$AWSINSTANCETYPE'|g;
		s|@SSHCONFIGPUBKEYFILE@|'$SSHCONFIGPUBKEYFILE'|g;
		s|@SSHCONFIGUSER@|'$SSHCONFIGUSER'|g;
		s|@SSHCONFIGUPDATE@|'$SSHCONFIGUPDATE'|g;
		s|@SSHCONFIGFILE@|'$SSHCONFIGFILE'|g;
		s|@SSHCONFIGSTRICT@|'$SSHCONFIGSTRICT'|g;
		s|@SSHCONFIGBACKUP@|'$SSHCONFIGBACKUP'|g;
		' | cat -s
}
