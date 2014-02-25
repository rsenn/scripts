explore()
{ 
  ( r=$(realpath "$1");
  [ -z "$r" ] && r=$1
  r=${r%/.};
  r=${r#./};
  p=$(msyspath -w "$r");
  ( set -x;
  cmd /c "explorer.exe /n,/e,$p" ) )
}
