# STG file generated by Workcraft -- http://workcraft.org
.inputs Ai Ri
.outputs Ao Ro
.graph
Ai+ Ro-
Ai- p1
Ao+ Ri-
Ao- p0
Ri+ Ao+
Ri- Ao-
Ro+ Ai+
Ro- Ai-
p0 Ri+
p1 Ro+
.marking {p0 p1}
.end
