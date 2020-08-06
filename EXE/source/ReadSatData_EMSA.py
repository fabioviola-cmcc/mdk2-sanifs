# requirements
import sys
import time
from xml.dom.minidom import parse

# read command line arguments
path_image=sys.argv[1]                  
N_OS=sys.argv[2]

# setting some variables
dens=0.922
thick=0.00001
index=int(float(N_OS)-1)

print("[ReadSatData_EMSA.py] -- %s" %index)
dom1=parse(path_image)
time_in=dom1.getElementsByTagName("sat:source")[0].getElementsByTagName("sat:startTime")[0].toxml()
area=dom1.getElementsByTagName("gml:featureMember")[index].getElementsByTagName("os:feature")[0].getElementsByTagName("os:oilSpill")[0].getElementsByTagName("os:area")[0].toxml()
Coord=dom1.getElementsByTagName("os:location")[index].getElementsByTagName("gml:pos")[0].toxml()
Points=dom1.getElementsByTagName("gml:featureMember")[index].getElementsByTagName("os:feature")[0].getElementsByTagName("os:oilSpill")[0].getElementsByTagName("gml:Polygon")[0].getElementsByTagName("gml:exterior")[0].getElementsByTagName("gml:LinearRing")[0].getElementsByTagName("gml:posList")[0].toxml()

split1=time_in.split('>')[1].split('<')[0].split('-')
year=split1[0]
month=split1[1]
split2=split1[2].split('T')
day=split2[0]
split3=split2[1].split(':')
hour=split3[0]
minutes=split3[1]


coord1=Coord.split('>')[1].split('<')[0].split(' ')
Lat_dec=str(float(coord1[0]))
Lon_dec=str(float(coord1[1]))

points1=Points.split('>')[1].split('<')[0].split(' ')
n_points0=len(points1)
n_points=str(n_points0/2)

Lat=coord1[0].split('.')
Lat_degrees=Lat[0]
Lat_min=(float(Lat_dec)-float(Lat_degrees))*60
print("[ReadSatData_EMSA.py] -- %s" % Lat_degrees)
print("[ReadSatData_EMSA.py] -- %s" % Lat_min)

Lon=coord1[1].split('.')
Lon_degrees=Lon[0]
Lon_min=(float(Lon_dec)-float(Lon_degrees))*60
print("[ReadSatData_EMSA.py] -- %s" % Lon_degrees)
print("[ReadSatData_EMSA.py] -- %s" % Lon_min)

Area_split=area.split('>')[1].split('<')[0]
Volume_=float(Area_split)*dens*thick
Volume=str(round(Volume_,2))

document=year+"/"+month+"/"+day+" "+hour+":"+minutes+"   Date of satellite image"+"\n"
document=document+n_points+"        Number of data points"+"\n"
document=document+"  lat     lon"+"\n"
document=document+Lat_dec+" "+Lon_dec+"\n"
for i in range(0, n_points0-1,2):
   points_split1=points1[i].split(',')
   points_lat=str(float(points_split1[0]))
   points_split2=points1[i+1].split(',')
   points_lon=str(float(points_split2[0]))   
   document=document+points_lat+" "+points_lon+"\n" 
name="initial"

file1=file(name+".txt",'w')
file1.writelines(document)
file1.close()

document2="day "+day+"\n"
document2=document2+"month "+month+"\n"
document2=document2+"year "+year[2:4]+"\n"
document2=document2+"hour "+hour+"\n"
document2=document2+"minutes "+minutes+"\n"
document2=document2+"lat_degree "+Lat_degrees+"\n"
document2=document2+"lat_minutes "+str(Lat_min)[0:5]+"\n"
document2=document2+"lon_degree "+Lon_degrees+"\n"
document2=document2+"lon_minutes "+str(Lon_min)[0:5]+"\n"
document2=document2+"spillrate "+Volume+"\n"
document2=document2+"duration "+"0000"+"\n"
document2=document2+"output_name "+"out"+"\n"
document2=document2+"step_output "+"001"+"\n"

file2=file("medslik_sat.inp",'w')
file2.writelines(document2)
file2.close()
