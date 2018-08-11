git-restore-deleted() {
  git log --diff-filter=D --summary |
  while read -r LINE; do
    case "$LINE" in
        commit\ *) COMMIT=${LINE#* } ;;
        *delete\ mode\ *) 
            MODE=${LINE#*"delete mode "}
            FILE=${MODE#*" "}
            MODE=${MODE%%" "*}
        ;;
        *) MODE= FILE= ;;
    esac
    if [ -n "$FILE" ]; then
        echo git checkout "$COMMIT"~1 -- "$FILE"
    fi
  done
}
