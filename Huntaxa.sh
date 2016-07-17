#!/usr/bin/env/bash

# Huntaxa 2016
# Simple taxa search with abundance treshold critera from microbiome studies
# Kevin C Lee
# http://kev.in

conversion() {
# conversion() does the the following:
# 1. Find all biom files in the subdirectories
# 2. Convert the counts to relative abundance
# 3. Convert biom files to tsv tables in the current directory
for i in $(find -iregex ".*.biom");
do
file=$(basename -s .biom $i)
biom normalize-table -i $i -o ${file}_rel.biom -r
biom convert -i ${file}_rel.biom -o ${file}.tsv --to-tsv --table-type "OTU table" --header-key "taxonomy"
done
echo "Conversion completed."
}

analysis() {
read -p "Enter taxa name of interest:" name
read -p "Enter the relative abundance threshold in fractions (i.e. 1=100%):" threshold
# In zsh, use read "?Enter taxa name..."

file_list=$(find -maxdepth 1 -name "*.tsv") # Only find in current directory, not subdirectories.

# Sanity check to if this analysis has already been done before.
if [ -d "${name}_${threshold}" ]; then
	echo "Error: Directory/Analysis ${name}_${treshold} already exists!" >&2; exit 1
fi

# Checking to see if threshold input is numerical.
re='^[0-9]+([.][0-9]+)?$'
if ! [[ $threshold =~ $re ]] ; then
	   echo "Error: Not a number" >&2; exit 1
   fi

mkdir ${name}_${threshold} #Create a directory based on the search pattern & threshold value

while read -r line; do #While loop to go through each study
	otu_file=$(basename -s .tsv $line)
	head $line -n2 | tail -n1 > ${name}_${threshold}/${name}_${otu_file}.tsv #Including the sample header
	grep $name $line >> ${name}_${threshold}/${name}_${otu_file}.tsv
done <<< "$file_list"

cd ${name}_${threshold}

# Awk search on individual grep output
for i in *.tsv; do
	grep_file=$(basename -s .tsv $i)
	head $i -n1 > ${grep_file}_${threshold}.tsv # Inherit the sample header from the previous groups of files
	awk -v var="$threshold" -F '\t' 'FNR>1 {for (i=2; i<NF; i++) if ($i >=var) {print $0;next}}' $i >> \
	${grep_file}_${threshold}.tsv
done

# Or use tee to print to screen for diagnostics while outputting to a file.
# I can probably prepend the first line of the OTU table for the sample headers...
cd ..
echo "Analysis completed."
}

main() {
cat<<EOF
 
 Microbiome meta-analysis script v1.0
 Simple taxa search with abundance treshold critera from microbiome studies
------------------------------
 Kevin C Lee 2016 http://kev.in

 * Purpose: Find occurances of taxa of interest exceeding certain relative abundance in multiple microbiomes
 * Dependency: Python package 'biom-format' (biom-format.org)

 * Input:        biom files (.biom) with count information & taxonomic metadata (e.g. from qiita.ucsd.edu)
 * Intermediary: relative abundance biom files, a tsv file with lines containing the specified taxon name 
 * Output:       tsv file containing lines of taxon of interest exceeding the specified relative
                 abundance threshold

 For the first run, you should select (1) to convert the biom files to relative abundance
 tables in plain text format. You may use option (2) to conduct additional analysis with different
 taxa and abundance threshold. Press (3) to exit this script.
------------------------------
EOF

PS3="Select an option (1-3):"
select yn1 in "Conversion + Analysis" "Analysis Only" "Exit"; do
	case $yn1 in
		Conversion\ \+\ Analysis)
			echo "(1) Conducting conversion & analysis."
	       	       conversion; analysis;;
		Analysis\ Only)
			echo "(2) Conducting analysis without conversion."
			analysis;;
		Exit)
			echo "(3) Exit script."
			break;;
		*)
			echo "Error: Please try again (select 1..3)."
	esac
done
}

# A note to self, the spaces in the conditional expression [ $variable = "true" ]  are mandatory

main
echo "All done. Have a nice day!"
exit 0

