{ (match($7, /\/[^ ]+/) > 0)
  print "\\N\t" $1 "\t" $2 "\t" "http:/" substr($7, RSTART, RLENGTH) "\t" $8 "\t" $9 "\t" $10 "\t" $11 "\t" $12 "\t" $13 "\t" $14 "\t" $15
}
