# cP-Systems-TSP
The accompanying code for our paper on solving the Travelling Salesman Problem in cP Systems, "The Hamiltonian Cycle and Travelling Salesman Problems in cP Systems", by Cooper & Nicolescu published in _Fundamenta Informaticae 164 (2019) 157–180_ by IOS Press (DOI: 10.3233/FI-2019-1760).  Suggestions and pull requests for improvements to existing implementations, as well as implementations in other languages and using other techniques are welcome.

Running the Prolog program is equally simple.  Merely 'consult' the program in SWI-Prolog, and then ask for the result by typing "go(M)." at the prompt.  Different problems can be specified by modifying the e objects defined at the start, and then appropriately updating the v and n objects.

Building and running the F# progam is simple - simply run fsc on the code file to compile it, and then run the output executable.  Different problems can be specified by modifying the adjacency list E, specified as a 2D array in lines 3 to 9.

The Erlang program can be run by compiling the file in the Erlang shell, and calling the tsp:go() function.  Different problems can be specified by modifying the e records defined at the start, and then appropriately updating the V list.

Alternatively, the ETS example can be run by compiling the tsp_ets.erl file in the Erlang shell, and then calling tsp_ets:run(X), where X is a number representing one of the possible data sets.  1 and 2 are data sets from the examples in the paper, while 3 is a random complete-graph-generator, which will generate a graph with edges between every node to every other node with random weights between 1 and 10.
