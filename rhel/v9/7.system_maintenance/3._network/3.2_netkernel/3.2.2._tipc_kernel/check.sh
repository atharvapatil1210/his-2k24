#!/usr/bin/env bash

# Initialize variables and arrays
l_output3=""
l_dl=""
unset a_output
unset a_output2
l_mod_name="tipc" # set module name
l_mod_type="net" # set module type
l_mod_path="$(readlink -f /lib/modules/**/kernel/$l_mod_type | sort -u)"

# Function to check module status
f_module_chk() {
    l_dl="y"
    a_showconfig=()
    while IFS= read -r l_showconfig; do
        a_showconfig+=("$l_showconfig")
    done < <(modprobe --showconfig | grep -P -- '\b(install|blacklist)\h+'"${l_mod_name//-/_}"'\b')

    # Check if module is loaded
    if ! lsmod | grep "$l_mod_name" &> /dev/null; then
        a_output+=(" - kernel module: \"$l_mod_name\" is not loaded")
    else
        a_output2+=(" - kernel module: \"$l_mod_name\" is loaded")
    fi

    # Check if module is set to /bin/true or /bin/false
    if grep -Pq -- '\binstall\h+'"${l_mod_name//-/_}"'\h+\/bin\/(true|false)\b' <<< "${a_showconfig[*]}"; then
        a_output+=(" - kernel module: \"$l_mod_name\" is not loadable")
    else
        a_output2+=(" - kernel module: \"$l_mod_name\" is loadable")
    fi

    # Check if module is denylisted
    if grep -Pq -- '\bblacklist\h+'"${l_mod_name//-/_}"'\b' <<< "${a_showconfig[*]}"; then
        a_output+=(" - kernel module: \"$l_mod_name\" is deny listed")
    else
        a_output2+=(" - kernel module: \"$l_mod_name\" is not deny listed")
    fi
}

# Iterate through module paths to check for the module
for l_mod_base_directory in $l_mod_path; do
    if [ -d "$l_mod_base_directory/${l_mod_name/-/\/}" ] && [ -n "$(ls -A $l_mod_base_directory/${l_mod_name/-/\/})" ]; then
        l_output3="$l_output3\n - \"$l_mod_base_directory\""
        [[ "$l_mod_name" =~ overlay ]] && l_mod_name="${l_mod_name::-2}"
        [ "$l_dl" != "y" ] && f_module_chk
    else
        a_output+=(" - kernel module: \"$l_mod_name\" doesn't exist in \"$l_mod_base_directory\"")
    fi
done

# Output results
[ -n "$l_output3" ] && echo -e "\n\n -- INFO --\n - module: \"$l_mod_name\" exists in:$l_output3"
if [ "${#a_output2[@]}" -le 0 ]; then
    printf '%s\n' "" "- Audit Result:" " ** PASS **" "${a_output[@]}"
else
    printf '%s\n' "" "- Audit Result:" " ** FAIL **" " - Reason(s) for audit failure:" "${a_output2[@]}"
    [ "${#a_output[@]}" -gt 0 ] && printf '%s\n' "- Correctly set:" "${a_output[@]}"
fi
