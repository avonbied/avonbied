#!/bin/sh
config_dir='.config'
mkdir -p "$config_dir"
mkdir -p "$bash_dir"

config_arr=('.bash_profile' '.bash_history' '.bash_logout' '.bashrc' '.gitconfig')
# Expected mapping: .bash_profile -> ; .(bash|git)* -> .config/(bash|git)
config_dest="s/^.bash_profile\$//g;s/^.(bash|git)[a-zA-Z0-9._]+/.config\/\1/g;"
# Expected mapping: .bash_profile -> .profile; .(bash|git)[_]*<name> -> name;
config_name='s/^.bash_profile\$/.profile/g;s/^.(bash|git)[_]*//g'

# config_len=${#config_arr[@]}
for i in "${!config_arr[@]}"; do
	$new_file="${echo $config_arr[$i] | sed $config_dest}/${echo $config_arr[$i] | sed $config_name}"
	if [ !-L "~/${$config_arr[$i]}" ]; then
		mv "~/{$config_arr[$i]}" "~/$new_file"
	else
		rm "~/{$config_arr[$i]}"
		ln -s "~/$new_file" "~/{$config_arr[$i]}"
	fi
	if [ !-f "~/$new_file" ]; then
		touch "~/$new_file"
	fi
done

# Config git
read -p 'Enter your Git username: ' input
git config --global user.name $input
read -p 'Enter your Git name: ' input
git config --global user.name $input
read -p 'Enter your Git email: ' input
git config --global user.email $input
