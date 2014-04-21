rmv()
{ 
    "${COMMAND-command}" rsync -r --remove-source-files -v --partial --size-only --inplace -D --links "$@"
}
