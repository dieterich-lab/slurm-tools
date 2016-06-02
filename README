# slurm-scripts README


## About


This is a repository with shell scripts, manuals and documentation about slurm.

bin/spart  : show information about all partitions (queue), or a specific only
bin/sterm  : load an interactive bash on a node
bin/sjob   : show information about a job (wrap 'scontrol show job -d [ID]') in tabular format
examples/* : example scripts for different tasks

## Authors


Tobias Jakobi
Sven E. Templer
Others/Unknown


## Installation


bin/sterm is installed on the cluster and available via 'module'.


## Usage


bin/spart:

	./spart
	./spart hugemem
	./spart blade

bin/sterm:

	module load slurm_scripts
  sterm
	sterm -p himem

bin/sjob:

	./sjob
	./sjob 123
	./sjob 123 | grep JobState

## Documentation


examples/*:

	script templates with short examples

examples/benchmark:

	script templates to run repeated stuff useful for benchmarking

example/poppy:

	scripts with a pipeline

example/silly:

	more examples, but rather silly ones


## License


Copyright
