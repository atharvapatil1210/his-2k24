#!/usr/bin/env bash

## <--Configure Filesystem Kernel Modules: Start-->
fs_kernel_module_chk(){
l_mname="$@" # set module name
l_mtype="fs" # set module type
l_mpath="/lib/modules/**/kernel/$l_mtype"
l_mpname="$(tr '-' '_' <<< "$l_mname")"
l_mndir="$(tr '-' '/' <<< "$l_mname")"
module_loadable_fix()
{
# If the module is currently loadable, add "install {MODULE_NAME} /bin/false" to a file in
# "/etc/modprobe.d"
l_loadable="$(modprobe -n -v "$l_mname")"
[ "$(wc -l <<< "$l_loadable")" -gt "1" ] && l_loadable="$(grep -P -"(^\h*install|\b$l_mname)\b" <<< "$l_loadable")"
if ! grep -Pq -- '^\h*install \/bin\/(true|false)' <<< "$l_loadable"; then
echo -e " - module: \"$l_mname\" is loadable: \"$l_loadable\""
echo -e " - setting module: \"$l_mname\" to be not loadable"
echo -e "install $l_mname /bin/false" >> /etc/modprobe.d/"$l_mpname".conf
fi
}
module_loaded_fix()
{
# If the module is currently loaded, unload the module
if lsmod | grep "$l_mname" > /dev/null 2>&1; then
echo -e " - module: \"$l_mname\" is not loaded"
echo -e " - unloading module \"$l_mname\""
modprobe -r "$l_mname"
fi
}
module_deny_fix()
{
# If the module isn't deny listed, denylist the module
if ! modprobe --showconfig | grep -Pq -- "^\h*blacklist\h+$l_mpname\b"; then
echo -e " - module: \"$l_mname\" is not deny listed"
echo -e " - deny listing \"$l_mname\""
echo -e "blacklist $l_mname" >> /etc/modprobe.d/"$l_mpname".conf
fi
}
# Check if the module exists on the system
echo -e "\n - remediation of module: \"$l_mname\" started.\n"
for l_mdir in $l_mpath; do
if [ -d "$l_mdir/$l_mndir" ] && [ -n "$(ls -A $l_mdir/$l_mndir)" ]; then
echo -e " - module: \"$l_mname\" exists in \"$l_mdir\"\n - checking if disabled..."
module_deny_fix
if [ "$l_mdir" = "/lib/modules/$(uname -r)/kernel/$l_mtype" ]; then
module_loadable_fix
module_loaded_fix
fi
else
echo -e "\n - module: \"$l_mname\" doesn't exist in \"$l_mdir\"\n"
fi
done
echo -e "\n - remediation of module: \"$l_mname\" complete\n"
#echo -e "\n- Audit Result:\n ** PASS **\n\n"
}

fs_kernel_module=("cramfs" "freevxfs" "hfs" "hfsplus" "jffs2" "squashfs" "udf" "usb-storage")

for module in "${fs_kernel_module[@]}";do
	fs_kernel_module_chk $module
done


## <--Configure Filesystem Kernel Modules: EnD-->