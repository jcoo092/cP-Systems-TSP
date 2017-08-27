# cP-Systems-TSP
The accompanying code for our paper on solving the Travelling Salesman Problem in cP Systems, an informally published research report version of which is available at https://www.cs.auckland.ac.nz/research/groups/CDMTCS/researchreports/ (report 510, under 2017).  A version of the paper has been submitted to a conference, and is presently undergoing peer review.  This page will be updated if/when it is published.  Suggestions/pull requests for improvements to existing implementations, as well as implementations in other languages, are welcome.

Planned further work includes implementing the algorithm in CUDA or OpenCL, to use with GPGPU resources.  Also modifying the algorithm to a form more close to the Tissue-like P Systems model, for running in the cloud as a distributed computation.

Running the Prolog program is equally simple.  Merely 'consult' the program in SWI-Prolog, and then ask for the result by typing "go(M)." at the prompt.  Different problems can be specified by modifying the e objects defined at the start, and then appropriately updating the v and n objects.

Building and running the F# progam is simple - simply run fsc on the code file to compile it, and then run the output executable.  Different problems can be specified by modifying the adjacency list E, specified as a 2D array in lines 3 to 9.

The Erlang program can be run by compiling the file in the Erlang shell, and calling the tsp:go() function.  Different problems can be specified by modifying the e records defined at the start, and then appropriately updating the V list.
