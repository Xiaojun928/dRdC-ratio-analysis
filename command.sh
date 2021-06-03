#create a folder named "00_seqs" containing the protein (.faa) and DNA (.fna) sequences
#create a file named "00_genome_list.txt" for clade division

#Predict orthologous gene families (OGs) using Orthofinder
/usr/bin/python /home-user/software/OrthoFinder/OrthoFinder-2.2.1/orthofinder.py -og -1 -t 16 -a 16 -S diamond -M msa -f 00_seqs -n ortho
mv 00_seqs/Results_ortho_* 01_orthofinder_result

#Extract .faa and .fna sequences for single-copied OGs
perl step0.trans_gene_id.pl

#Alignment on amino acid level and impose DNA sequence to alignment
einsi OG0000362.faa > OG0000362.mafft.msa
perl ~/pipeline/trans_fasta_2_one_line.pl 02_alignment/*mafft.msa
rename .oneline.msa .msa 02_alignment/*.oneline.msa
perl step1.imposeDNA.pl
perl step2.degap.pl 02_alignment/*imposeDNA.msa

#Create configration file
mkdir 03_tstv
cp 02_alignment/*fasta 03_tstv
cd 03_tstv
ls *fasta > filelist.txt
nohup ~/database/megacc_linux/megacc -a ../ts2tv.mao -d filelist.txt
perl ../step3.summary_tstv.pl

#transfer file format
perl ../step4.trans_format.pl
perl -i -pe 's/_.*$//' *seq
cd ..

#Run RCCalculator
sh step5.prepare_RCCalculator_scripts.sh
sh step5.run_RCCalculator.sh
sh step6.remove_divergent_genfam.sh
sh step7.calculate_average_PNC_PNR.sh
sh step8.get_statistics.sh
sh step9.parse_stat.sh
Rscript step9.plot_dRdC.R output/dRdC.target_TargetClade.Rout_parsed output/output.pdf

