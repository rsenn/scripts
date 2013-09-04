filter_files_list()
{ 
    sed -u "s|/files\.list:|/|"
}
