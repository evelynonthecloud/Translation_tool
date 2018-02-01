#!/bin/bash

file1="$1"
file2="$2"
output="$3"
now="$(date +'%Y-%m-%d %T')"

if [ $# -lt 3 ]
then
  echo "Usage: new_file old_file result..."
  exit 1
fi

sort_properties()
{
    FILE=$1
	sed -i '/^\s*$/d' $FILE
	rm -rf "./$FILE"_dup "$FILE"_uni
 	cp ./$FILE "./$FILE"_tmp
 	cp ./$FILE "./$FILE"_dup
 	cp ./$FILE "./$FILE"_uni
	echo "$now Soring props $FILE..."
	cut -d '=' -f 1 $FILE > "./$FILE"_tmp
	sort "./$FILE"_tmp|uniq -d > "./$FILE"_dup
	echo "$now Duplicated property keys are listed in "./$FILE"_dup"
	sort "./$FILE"_tmp|uniq -u > "./$FILE"_uni
	rm -rf "./$FILE"_tmp
	echo "$now Unique property keys are listed in "./$FILE"_uni"
	echo "$now Finished soring"
}

normalize()
{

	FILE=$1
	
	dos2unix $FILE
	sed -i 's/\s*=\s*/=/g' $FILE
	echo "$now Props are normalized."
}

compare()
{
	FILE1=$1
	FILE2=$2
	OUTPUT=$3
	
	normalize $FILE1 
	normalize $FILE2

	FILE1_NEW=$(mktemp)
	FILE1_KEY=$(mktemp)
	FILE2_NEW=$(mktemp)
	FILE2_KEY=$(mktemp)
	pattern="(.*_kr_*|.*_KR_*|.*_Kr_*|.*_kR_*)"
	content_kr="korean"

	echo "$now Compare file $FILE1 $FILE2"
	sort -u $FILE1 > $FILE1_NEW
	sort -u $FILE2 > $FILE2_NEW
	
	cut -d '=' -f 1 $FILE1_NEW|sort > $FILE1_KEY
	cut -d '=' -f 1 $FILE2_NEW|sort > $FILE2_KEY
	
	#compare new keys only in file1 and file2
	#comm -3 $FILE1_NEW $FILE2_NEW > "./$outputfile"
	#compare new keys only in file2
	#comm -13 $FILE1_KEY $FILE2_KEY > "./$OUTPUT"_keys_only_in_new
	#comm -13 $FILE1_NEW $FILE2_NEW > "./$OUTPUT"_entry_only_in_new
	#comm -23 $FILE1_NEW $FILE2_NEW > "./$OUTPUT"_entry_only_in_old
	#sort $FILE2_NEW $FILE1_NEW $FILE1_NEW |uniq -u > "./$outputfile"
	if [[ "$FILE1" =~ ${pattern} ]];then
		awk -F'=' 'NR==FNR {arr[$1]=$0;next;}; !($1 in arr) {print $0}' $FILE1_NEW $FILE2_NEW > "./$OUTPUT"
	else
		awk -F'=' 'NR==FNR {arr[$1]=$0;next;}; !($1 in arr) {print $0}' $FILE1_NEW $FILE2_NEW |grep -v $content_kr > "./$OUTPUT"
	fi
	rm -rf $FILE1_NEW $FILE2_NEW $FILE1_KEY $FILE2_KEY
	echo "$now Finished comapring, listed all the new keys only in $FILE2"
}

compare $file1 $file2 $output
