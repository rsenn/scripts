newfile_AUTHOR="Roman Senn"
newfile_EMAIL="rs@adfinis.com"
newfile_ORGANIZATION="adfinis GmbH"

alias newfile='newfile ${newfile_AUTHOR+-a "$newfile_AUTHOR"} ${newfile_EMAIL+-e "$newfile_EMAIL"} ${newfile_ORGANIZATION+-o "$newfile_ORGANIZATION"}'
