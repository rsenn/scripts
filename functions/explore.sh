explore()
{ 
  ( r=$(realpath "$1");
  r=${r%/.};
  r=${r#./};
  p=$(msyspath -w "$r");
  ( set -x;
  cmd /c "explorer.exe /n,/e,$p" ) )
}
