# noc_mesh
----

# Network on Chip implemented on a Mesh Infrastructure

This is a implementation of 3x3 mesh type Network on Chip, with total 7 processing nodes implemented in Bluespec System Verilog. Each processing element is a primitive implementation of SMIPS, (from MIT 6.884) running a simple Matrix Vector Product. Each packet routing is done through a sophisticated arc routing generated from running multi commodity flow solver over the network specification to minimize congestion. The idea is to benchmark this routing process over a normal X-Y routing, and analyse the total cycle time and average packet hops taken.

## Dependencies ##
- Bluespec 
- Python 
- Map and Route flow maintained at https://github.com/ssk1328/mcmf/
- src/Lookup.bsv from /bsv folder in git repo https://github.com/ssk1328/mcmf

### Using Bluespec ###
- Run this on machine with bluespec installed (hpc28)
- Setup bluespec on your machine
- Copy the /opt/Bluespec-<version>/ directory from hpc28 to your machine
- Add bluespec library paths as specified in .bashrc of hpc28 to .bashrc of your machine
- To verify $ bluespec this will open GUI window of bluespec

### Setting up map and route git repo ###
`cd ..`

`git clone https://github.com/ssk1328/mcmf.git`

mcmf and noc_mesh should be initiated in the same common directory. More information on generating these results in mcmf repository

While in the noc_mesh git directory, for the route choosen: mcf or xy

## Run ##

`cp ../mcmf/bsv/Lookupmcf.bsv ../noc_mesh/src/`

`mv bsv/Lookupmcf.bsv bsv/Lookup.bsv`

`$ cd sim `

`$ make ` 

This will clean compile link and simulate the source files and give the cycle count as one of the results of system. Data and processor dump files in /dump copied to appropiate folder in scripts

## Scripts ##

`$ cd ..`

`$ cp -r dump/proc scripts/proc_mcf`

`$ cd scripts`

`$ python analyseProcDump.py mcf`

- Generated data report files reportSim_mcf.txt
- This gives average packet inflight time in the network

Multi commodity flow done to generate src/Lookup.bsv, preproceesing for that done here https://github.com/ssk1328/mcmf/

This is done as a part of DDP Stage 2 project work.

Shashank Gangrade  
High Performance Computing Lab  
Department of Electrical Engineering  
IIT Bombay


