#!/usr/bin/env bash
{
a_output2=(); a_output3=()
l_maxsize="1000" # Maximum number of local interactive users before
warning (Default 1,000)
l_valid_shells="^($( awk -F\/ '$NF != "nologin" {print}' /etc/shells | sed
-rn '/^\//{s,/,\\\\/,g;p}' | paste -s -d '|' - ))$"
a_user_and_home=() # Create array with local users and their home
directories
while read -r l_local_user l_local_user_home; do # Populate array with
users and user home location
[[ -n "$l_local_user" && -n "$l_local_user_home" ]] &&
a_user_and_home+=("$l_local_user:$l_local_user_home")
done <<< "$(awk -v pat="$l_valid_shells" -F: '$(NF) ~ pat { print $1 " "
$(NF-1) }' /etc/passwd)"
l_asize="${#a_user_and_home[@]}" # Here if we want to look at number of
users before proceeding
[ "${#a_user_and_home[@]}" -gt "$l_maxsize" ] && printf '%s\n' "" " **
INFO **" \
" - \"$l_asize\" Local interactive users found on the system" \
" - This may be a long running check" ""
file_access_fix()
{
a_access_out=()
l_max="$( printf '%o' $(( 0777 & ~$l_mask)) )"
if [ $(( $l_mode & $l_mask )) -gt 0 ]; then
printf '%s\n' "" " - File: \"$l_hdfile\" is mode: \"$l_mode\" and
should be mode: \"$l_max\" or more restrictive" \
" Updating file: \"$l_hdfile\" to be mode: \"$l_max\" or more
restrictive"
chmod "$l_change" "$l_hdfile"
fi
if [[ ! "$l_owner" =~ ($l_user) ]]; then
printf '%s\n' "" " - File: \"$l_hdfile\" owned by: \"$l_owner\" and
should be owned by \"${l_user//|/ or }\"" \
" Updating file: \"$l_hdfile\" to be owned by \"${l_user//|/ or
}\""
chown "$l_user" "$l_hdfile"
fi
if [[ ! "$l_gowner" =~ ($l_group) ]]; then
printf '%s\n' "" " - File: \"$l_hdfile\" group owned by:
\"$l_gowner\" and should be group owned by \"${l_group//|/ or }\"" \
" Updating file: \"$l_hdfile\" to be group owned by
\"${l_group//|/ or }\""
chgrp "$l_group" "$l_hdfile"
fi
}
while IFS=: read -r l_user l_home; do
a_dot_file=(); a_netrc=(); a_netrc_warn=(); a_bhout=(); a_hdirout=()
if [ -d "$l_home" ]; then
l_group="$(id -gn "$l_user" | xargs)";l_group="${l_group// /|}"
while IFS= read -r -d $'\0' l_hdfile; do
while read -r l_mode l_owner l_gowner; do
case "$(basename "$l_hdfile")" in
.forward | .rhost )
a_dot_file+=(" - File: \"$l_hdfile\" exists" "
Page 976
Please review and manually delete this file") ;;
.netrc )
l_mask='0177'; l_change="u-x,go-rwx"; file_access_fix
a_netrc_warn+=(" - File: \"$l_hdfile\" exists") ;;
.bash_history )
l_mask='0177'; l_change="u-x,go-rwx"; file_access_fix ;;
* )
l_mask='0133'; l_change="u-x,go-wx"; file_access_fix ;;
esac
done < <(stat -Lc '%#a %U %G' "$l_hdfile")
done < <(find "$l_home" -xdev -type f -name '.*' -print0)
fi
[ "${#a_dot_file[@]}" -gt 0 ] && a_output2+=(" - User: \"$l_user\" Home
Directory: \"$l_home\"" "${a_dot_file[@]}")
[ "${#a_netrc_warn[@]}" -gt 0 ] && a_output3+=(" - User: \"$l_user\"
Home Directory: \"$l_home\"" "${a_netrc_warn[@]}")
done <<< "$(printf '%s\n' "${a_user_and_home[@]}")"
[ "${#a_output3[@]}" -gt 0 ] && printf '%s\n' "" " ** WARNING **"
"${a_output3[@]}" ""
[ "${#a_output2[@]}" -gt 0 ] && printf '%s\n' "" "${a_output2[@]}"
}