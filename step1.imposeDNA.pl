#merge_seq.fna contains the nucleic acid sequences of all genomes
open IN, "merged_seq.fna";
while (<IN>) {
	s/>//;
	chomp ($id=$_);
	chomp ($seq=<IN>);
	$seq{$id}=$seq;
}

#impose DNA
@files = `ls 02_alignment`;
foreach $file (@files) {
	chomp $file;
	unless ($file =~ s/\.mafft\.msa//) {next}
	open IN, "02_alignment/$file.mafft.msa";
	open OUT, ">02_alignment/$file.imposeDNA.msa";
	while (<IN>) {
		chomp;
		if (s/>//) {
			$id = $_;
			print OUT ">$id\n";
			next
		}
		@faa = split "", $_;
		@fna = split "", $seq{$id};
		for ($i=0, $j=0; exists $faa[$i]; $i++) {
			if ($faa[$i] eq "-") {print OUT "---"}
			else {print OUT "$fna[$j*3]$fna[$j*3+1]$fna[$j*3+2]"; $j++}
		}
		print OUT "\n";
	}
}
