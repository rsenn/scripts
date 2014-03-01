c256()
{
  value=$1
  value=$(( ((value & 0x0F) << 4) | ((value & 0xF0) >> 4) ))
  value=$(( ((value & 0x33) << 2) | ((value & 0xCC) >> 2) ))
  value=$(( ((value & 0x55) << 1) | ((value & 0xAA) >> 1) ))
  echo "$value"
}

