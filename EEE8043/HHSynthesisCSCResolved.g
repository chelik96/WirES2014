# STG file generated by Workcraft -- http://workcraft.org
.internal csc1
.inputs Ai Ri
.outputs Ao Ro
.graph
Ai+ Ro-
Ai- csc1+
Ao+ Ri-
Ao- Ai- Ri+
Ri+ Ao+ csc1+
Ri- csc1-
Ro+ Ai+ Ao+
Ro- csc1-
csc1+ Ro+
csc1- Ao-
.marking {<csc1-,Ao->}
.end
