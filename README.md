# Huntaxa

[![Project Status: Abandoned – Initial development has started, but there has not yet been a stable, usable release; the project has been abandoned and the author(s) do not intend on continuing development.](https://www.repostatus.org/badges/latest/abandoned.svg)](https://www.repostatus.org/#abandoned)

## Introduction

Search for specified taxa above a specified relative abundance among microbiome studies. This was a little interactive bash script project for me to learn more about coding and to help me extract data from biom files using the python [biom-format](https://github.com/biocore/biom-format) package.

## Operation

Find publically available datasets as biom files. Download the script into a directory where biom files are stored (including subdirectories). Execute the script and follow the instructions. The script has two main functions:

1. Convert biom files with raw counts into equivalent files with relative abundance, then continue to the second step.
2. Identify presence of specified taxon (by name) in provided biom files exceeding a given relative abundance threshold. This can be done independent of the first step.

Results from step 2 will be stored as simple tsv files which you can use to generalise statement regarding presence/absence/prevalence of taxa found in various studies/environments.
