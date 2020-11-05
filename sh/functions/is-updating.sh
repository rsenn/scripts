is-updating() {
  [ "$(handle -p $(ps -aW | grep locate32 | awkp) | wc -l)" -ge 20 ]
}
