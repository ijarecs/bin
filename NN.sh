imapfilter -c ~/.imapfilter/NN.lua >>~/.imapfilter/NN.output
cat ~/.imapfilter/NN.output | lynx -stdin -dump | egrep -e 'A befektet' -e ' EUR'
