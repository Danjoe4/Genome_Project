#!/usr/bin/env bash

echo "Starting..."
echo $(rm Processed_R*) # delete the junks

# make these match the names of your input files
IN1="NBP03_S165_R1_001.fastq"
IN2="NBP03_S165_R2_001.fastq"

############# ADJUST THESE as desired ###############################
SLIDING_WINDOW="SLIDINGWINDOW:4:30"
REMOVE_ADAPTERS="ILLUMINACLIP:/Smaug_SSD/bin/Trimmomatic-0.39/adapters/NexteraPE-PE.fa:2:30:10:2:True"
LEAD="LEADING:4"
TRAIL="TRAILING:30"
MIN_LEN="MINLEN:36"
AVGQUAL="AVGQUAL:30"
HEADCROP="HEADCROP:15"

# remove/add params here. order does matter, $MIN_LEN should be last
PARAMS="$REMOVE_ADAPTERS $HEADCROP $TRAIL $SLIDING_WINDOW $AVGQUAL $MIN_LEN"
######################################################

# output files, these don't need to be changed
OUT1="Processed_R1.fastq"
OUT2="Processed_R1.Unpaired.fastq"
OUT3="Processed_R2.fastq"
OUT4="Processed_R2.Unpaired.fastq"
REF="GCA_013133755.1_ASM1313375v1_genomic.fasta" # reference genome

BASE_CMD="java -jar /Smaug_SSD/bin/Trimmomatic-0.39/trimmomatic-0.39.jar PE"
TRIM_CMD="$BASE_CMD $IN1 $IN2 $OUT1 $OUT2 $OUT3 $OUT4 $PARAMS"
COMPARE_CMD="/Smaug_SSD/bin/bbmap/bbmap.sh in=$OUT1 in2=$OUT3 ref=$REF minid=0.90 threads=16 statsfile=stats_out.txt"

# check for input files
if [ -f "$IN1" ]; then
    echo "$IN1 exists."
else
    echo "$IN1 not found"
fi

if [ -f "$IN2" ]; then
    echo "$IN2 exists."
else
    echo "$IN2 not found"
fi

# run our main operations
echo $($TRIM_CMD)
echo $($COMPARE_CMD) # produce the stats_out file
echo $(grep "mapped:" stats_out.txt)


# prompt for input
echo "save the stats_out file for later? (y/n)"
read yn
if [ "$yn" = "y" ]; then
    echo "Type the name you'd like to save it as: "
    read name
    if [ ! -d "saved_stats_files" ]; then
        echo $(mkdir saved_stats_files)
    fi
    echo $(mv stats_out.txt saved_stats_files/"$name")
else
    echo ""
fi
