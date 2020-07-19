
cat_template_file_sed()
{
	cat $1 | sed -e \
		'
		s|@VAGRANTBOX@|'"$VAGRANTBOX"'|g;
		s|@VBOXVERSION@|'$VBOXVERSION'|g;
		' | cat -s
}

