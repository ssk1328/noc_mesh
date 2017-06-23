################# DESCRIPTION ########################

## Used to Analyse the Proc Dump files from bluespec simluations of the mesh architecture and 
## Calculate total traffic(sum total of cycles for which a packet is in flight in the network, for
## all packets) in the network

######################################################

################# ALGORITHM ###########################
 
## Read the files into dump tables
## Pop the entries out one by one in ascending order of cycle count
## If Sent packet type, then create new entry in Packet List and leave empty spot for receive cycle time
## If Received packet type, then fill the empty spot in the first packet that matches the (src,dest)
## Repeat 2,3,4 till entries exist in the table
## Calculate the hop time for each packet and sum it up

######################################################

import sys
if len(sys.argv) >= 2:
    if sys.argv[1] == "mesh":

        dumpFileName = "./proc_dump_"
        reportFileName = "reportSimMeshNetworkTraffic.txt"

    elif sys.argv[1] == "pg":

        dumpFileName = "./proc_dump_"
        reportFileName = "reportSimPGNetworkTraffic.txt"

    else :
        print "Specify argument 'mesh' or 'pg'\n "
        exit()
else : 
    print "Specify argument 'mesh' or 'pg'\n "
    exit()

################ CREATING DUMP TABLE ################
numCores = 7
dumpTable = []


for i in range(numCores):
    dumpTable.append([])
    
    dumpFile = open(dumpFileName+str(i)+".txt",'r')
    dumpFileBuff = dumpFile.read()
    dumpLines = dumpFileBuff.splitlines()
    
    for j in range(len(dumpLines)):
        dumpEntry = dumpLines[j].split(',')
        
        entryProc = dumpEntry[0].split(":")
        entryProcVal = int(entryProc[1])

        entryCycle = dumpEntry[1].split(":")
        
        entrySrc = dumpEntry[2].split(":")

        entryDest = dumpEntry[3].split(":")

        entryPacketType = dumpEntry[4]
        
        ## Structure of Dictionary : {'Cycle', 'Src', 'Dest' , 'PacketType'}
        dumpTable[entryProcVal].append({entryCycle[0]:int(entryCycle[1]),
                                        entrySrc[0]:int(entrySrc[1]),
                                        entryDest[0]:int(entryDest[1]),
                                        "PacketType":entryPacketType})

    
#######################################################################
#for i in range(numCores):
#    print str(i)+" is Proc NUmber \n"
#    print dumpTable[i]
#    print "\n"
#######################################################################

################ CREATING PACKET TABLE ################

packetTable = []

done = 0

while ( done == 0):
    
    ## Initialise smallestCycleCount 
    for i in range(numCores):
        if(len(dumpTable[i]) is not 0):
            toPopProc = i
            smallestCycleCount = dumpTable[i][0]["Cycle"]
##          print "Init toPopProc is :"+str(toPopProc)+" and cycle count is : "+str(smallestCycleCount);
            break
    
    ## Find the dumpTable entry with earliest cycle count
    for i in range(numCores):
        if(len(dumpTable[i]) is not 0):
            currCycleCount = dumpTable[i][0]["Cycle"]
            if (currCycleCount < smallestCycleCount) :
                toPopProc = i
                smallestCycleCount = currCycleCount;
    
    
    toPopEntry = dumpTable[toPopProc][0]

    ## Fill packetTable with toPopEntry
    if(toPopEntry["PacketType"] == "Sent"):
        packetTable.append({"PacketID":str(toPopEntry["Src"])+":"+str(toPopEntry["Dest"]),
                            "Sent Cycle":toPopEntry["Cycle"],
                            "Received Cycle":"?" })

    if(toPopEntry["PacketType"] == "Received"):
        for j in range(len(packetTable)):
            if( packetTable[j]["PacketID"] == (str(toPopEntry["Src"])+":"+str(toPopEntry["Dest"]))):
                packetTable[j]["Received Cycle"] = toPopEntry["Cycle"]
                break
    
    #Remove the toPopEntry
    dumpTable[toPopProc].remove(toPopEntry)         

    ## Specify terminating condition
    allEmpty = True
    for i in range(numCores):
        if(len(dumpTable[i]) != 0):
            allEmpty = False

    if( allEmpty == True):
        done = 1

print "Number of Packets is : %d"%len(packetTable)

#######################################################################

################ CALCULATE FLIGHT TIME AND DUMP REPORT ################

reportFile = open(reportFileName,'w')
totalCycles = 0

reportFile.write("#########################################################################\n")
reportFile.write("Report of Analysis of Processor Dump - Calculation of Flight Time of Packets\n");
reportFile.write("#########################################################################\n\n")

for i in range(len(packetTable)):
    flightTime = int(packetTable[i]["Received Cycle"]) - int(packetTable[i]["Sent Cycle"])
    reportFile.write("PacketID :"+str(packetTable[i]["PacketID"])+", Sent Cycle: "+str(packetTable[i]["Sent Cycle"])+",Received Cycle: "+str(packetTable[i]["Received Cycle"])+", Flight Time: "+str(flightTime)+"\n")
    totalCycles += flightTime

reportFile.write("\n\n###########################################\n")
reportFile.write("Total Cycles in Flight for all Packets - "+str(totalCycles)+"\n");
reportFile.write("###########################################\n")
    
    




