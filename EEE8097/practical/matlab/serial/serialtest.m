s = serial('COM1','BaudRate',115200,'ByteOrder','bigEndian');

fopen(s);
fprintf(s,challengegen);
[a,out] = fscanf(s)
fclose(s);
delete(s);
clear s;