#!/bin/bash
#Copyright Ajay


chapters=0
orig=$1
IFS="."
s=$1
set -- $s
arr=($s)
string=${arr[0]}
i=0
mkdir data-$1
pdfsam-console -f $1.pdf -s BLEVEL -bl 1  -o data-$1/ split 1>asd.txt
error_str=`cat asd.txt | grep FATAL`
if [ -z "$error_str" ]; then
echo "Successfuly split at chapters"
echo "Splitting individual Chapters..."
cd data-$1
chapters=1
renameDir="Cover"
for d in *.pdf
do
	arr2=($d)
	mkdir ${arr2[0]}
	echo ${arr2[0]}
	pdfsam-console -f ${arr2[0]}.pdf -s BURST -o ${arr2[0]}/ split 1>/dev/null
	cd ${arr2[0]}
	first=1
	for e in *.pdf
	do
		arr3=($e)
		echo ${arr3[0]}
		pdftoppm ${arr3[0]}.pdf > ${arr3[0]}.ppm
		mogrify -scale 200% ${arr3[0]}.ppm
		tesseract ${arr3[0]}.ppm ${arr3[0]}
		text2wave ${arr3[0]}.txt -o ${arr3[0]}.wav
		if [ $first -eq 1 ]; then
			sed '/^ *$/d' ${arr3[0]}.txt > ${arr3[0]}.bak
			mv ${arr3[0]}.bak ${arr3[0]}.txt
			renameDir=`head -1 ${arr3[0]}.txt`
			first=0
		fi
	done
	cd ..
	mv ${arr2[0]} $renameDir
done
cd ..
rm *.pdf
else
echo "Error No Bookmarks found.\n Splitting page by page"
pdfsam-console -f $1.pdf -s BURST -o data-$1/ split 1>/dev/null
cd data-$1
for c in *.pdf
do
arr1=($c)
string1=${arr1[0]}
echo $string1
pdftoppm $string1.pdf > $string1.ppm 
mogrify -scale 200% $string1.ppm
tesseract $string1.ppm $string1 1>/dev/null 2>/dev/null
text2wave $string1.txt -o $string1.wav 1>/dev/null 2>/dev/null
i=`expr $i + 1`
echo "$i %"
done
fi

#sox *.wav $string.wav 1>/dev/null 2>/dev/null
#gst-launch-0.10 filesrc location=$string.wav ! decodebin ! lame ! filesink location=$string.mp3 1>/dev/null 2>/dev/null

