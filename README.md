# noc_mesh

# Network on Chip implemented on a Mesh Infrastructure

This is a implementation of 3x3 mesh type Network on Chip, with total 7 processing nodes implemented in Bluespec System Verilog. Each processing element is a primitive implementation SMIPS, (from MIT 6.884) running a simple Matrix Vector Multiplication Application. Each packet routing is done through a sophisticated arc routing generated from running multi commodity flow solver over the network specification to minimize congestion. The idea is to benchmark this routing process over a normal X-Y routing, and analyse the total cycle time and average packet hops taken.

Multi commodity flow done to generate src/Lookup.bsv, preproceesing for that done here https://github.com/ssk1328/mcmf/

This is done as a part of DDP Stage 2 project work.

Shashank Gangrade  
High Performance Computing Lab  
Department of Electrical Engineering  
IIT Bombay

