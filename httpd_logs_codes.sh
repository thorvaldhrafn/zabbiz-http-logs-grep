#!/bin/bash

export LANG=en_US.UTF-8

log_path="/var/log/nginx/"
date_timestmp=$(date +%s)

time_range=$2
http_code=$1

date_timestmp_prev=$((date_timestmp-time_range))

date_day=$(date -d @"${date_timestmp}" "+%d")
date_month=$(date -d @"${date_timestmp}" "+%b")
date_year=$(date -d @"${date_timestmp}" "+%Y")
date_hour=$(date -d @"${date_timestmp}" "+%H")
date_min=$(date -d @"${date_timestmp}" "+%M")

date_day_prev=$(date -d @$date_timestmp_prev "+%d")
date_month_prev=$(date -d @$date_timestmp_prev "+%b")
date_year_prev=$(date -d @$date_timestmp_prev "+%Y")
date_hour_prev=$(date -d @$date_timestmp_prev "+%H")
date_min_prev=$(date -d @$date_timestmp_prev "+%M")

fs_date_min=${date_min:0:1}
ss_date_min=${date_min:1:2}
fs_date_min_prev=${date_min_prev:0:1}
ss_date_min_prev=${date_min_prev:1:2}
fs_date_min_prev1=$((fs_date_min_prev+1))
fs_date_min1=$((fs_date_min-1))

if [[ ${fs_date_min_prev1} -gt "5" ]]; then
  date_min_prev_range="false"
else
  date_min_prev_range="[${fs_date_min_prev1}-5][0-9]"
fi

if [[ ${fs_date_min1} = "-1" ]]; then
  date_min_range="false"
else
  date_min_range="[0-$fs_date_min1][0-9]"
fi

if [[ ${time_range} -eq 60 ]]; then
  time_regexp="${date_day_prev}/${date_month_prev}/${date_year_prev}:${date_hour_prev}:${date_min_prev}"
fi

if [[ ${time_range} -ge 600 ]]; then
  if [[ ${date_hour_prev#0} -eq ${date_hour#0} ]]; then
    if [[ "$date_min_prev_range" != "false" ]]; then
      date_min_prev_range="[${fs_date_min_prev1}-$fs_date_min1][0-9]"
      date_min_range="false"
    fi
    if [[ ${fs_date_min_prev1} -gt ${fs_date_min1} ]]; then
      date_min_prev_range="false"
      date_min_range="false"
    fi
  fi
  time_regexp="(($date_day_prev/$date_month_prev/$date_year_prev:$date_hour_prev:([$fs_date_min_prev][${ss_date_min_prev}-9]|${date_min_prev_range}))|($date_day/$date_month/$date_year:$date_hour:(${date_min_range}|[$fs_date_min][0-$ss_date_min])))"
fi

if [[ ${http_code} = 200 ]]; then
  regexp_code="20.{1}"
fi
if [[ ${http_code} = 300 ]]; then
  regexp_code="30.{1}"
fi
if [[ ${http_code} = 400 ]]; then
  regexp_code="404"
fi
if [[ ${http_code} = 499 ]]; then
  regexp_code="499"
fi
if [[ ${http_code} = 500 ]]; then
  regexp_code="50.{1}"
fi
if [[ ${http_code} = "accepts" ]]; then
  regexp_code="(20.{1}|30.{1})"
fi
if [[ ${http_code} = "errors" ]]; then
  regexp_code="(40.{1}|499|50.{1})"
fi

result=0
cd ${log_path} || exit
for i in $(find ${log_path} -type f -name "*.log" --print0); do
  if [[ -r ${i} ]]; then
    result_temp=$(grep -E -c ".+\[${time_regexp}.*\] .* $regexp_code .*" "${i}")
    result=$((result+result_temp))
  fi
done

echo ${result}
