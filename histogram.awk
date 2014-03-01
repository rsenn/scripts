#!/usr/bin/awk -f 
{ 
	counts[$0] = counts[$0] + 1
} END { 
  for (word in counts) print counts[word], word
}
