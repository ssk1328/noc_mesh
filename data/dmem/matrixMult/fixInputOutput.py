initFileName="dmem_init_"
dumpFileName="dmem_dump_"

num_cores=7

for i in range(num_cores):
  f1 = open(initFileName+str(i)+".txt",'r')
  f2 = open(dumpFileName+str(i)+".txt",'r')
  s1=f1.read()
  initlines=s1.splitlines()
  s3=f2.read()
  dumplines=s3.splitlines()
  f2.close()
  f3 = open(dumpFileName+"new_"+str(i)+".txt",'w')
  for j in range(len(dumplines)):
    initlinewords = initlines[j].split()
    if("input" in initlinewords or "output" in initlinewords):
      dumplines[j]=dumplines[j]+" "+" ".join(initlinewords[1:])+"\n"
    else :
      dumplines[j]=dumplines[j]+"\n"
    f3.write(dumplines[j])
  f3.close();

    

