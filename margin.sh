#!/bin/sh
# $Id: margin.sh,v 1.5 2010/10/24 14:12:56 micro Exp $
# script to be run from cron to email me instrument margins.


date=$(date +%d%m%Y)
outdir='/usr/local/micro/margin'
prefix='ib_margin'
file="$outdir/${prefix}-${date}"
tickers='(EUR|E7|GBP|JPY|AUD|CAD|CHF|CL|QM|COIL|QG|WTI|ZN|DX)'
email='rprimus@gmail.com'
subject="margin: ${date}"

cd $HOME/erlang/margin
erl -noshell -s margin gen_list -s init stop
egrep -we ${tickers} ${file} | mutt  -a ${file} -s "${subject} `date`" -- ${email}

./margin.pl
