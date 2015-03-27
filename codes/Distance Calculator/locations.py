import urllib
import simplejson
import sys
import math
g = open('distance_column.txt','w')
def main():
  with open('hotels-1.txt') as f:
    content = f.readlines()
    i=0
    for line in content:
    # print line
      query = str(line)
      checklatlong(query,g)
    g.close()

def checklatlong(toponym,f):
  googleGeocodeUrl = 'http://maps.googleapis.com/maps/api/geocode/json?'
  from_sensor=False
  toponym = toponym.encode('utf-8')
  params = {
  'address': toponym,
  'sensor': "true" if from_sensor else "false"
  }
  url = googleGeocodeUrl + urllib.urlencode(params)
  json_response = urllib.urlopen(url)
  response = simplejson.loads(json_response.read())
  comment = "No results"
  # Colva Beach Latitude and Longitude
  ALat,ALong = 15.5735995, 73.7407064
  RLat, RLong = 14.9393764, 74.0881008
  CLat,CLong=15.2761,73.9172
  default = 200
  if response['results']:
    location = response['results'][0]['geometry']['location']
    latitude, longitude = location['lat'], location['lng']
    distanceFromC=distance_on_unit_sphere(latitude,longitude,CLat,CLong)
    distanceFromA=distance_on_unit_sphere(latitude,longitude,ALat,ALong)
    distanceFromR=distance_on_unit_sphere(latitude,longitude,RLat,RLong)
    #if distanceFromC > 200 :
    #  print default
    #else:
    g.write(toponym+', '+str(distanceFromC+distanceFromA+distanceFromR)+'\n')
    print distanceFromC
  else:
    latitude, longitude = None, None
    if toponym and not toponym.isspace():
      g.write(toponym+', 200\n')
      #print default

 
def distance_on_unit_sphere(lat1, long1, lat2, long2):
 
    # Convert latitude and longitude to 
    # spherical coordinates in radians.
  degrees_to_radians = math.pi/180.0       
    # phi = 90 - latitude
  phi1 = (90.0 - lat1)*degrees_to_radians
  phi2 = (90.0 - lat2)*degrees_to_radians
         
    # theta = longitude
  theta1 = long1*degrees_to_radians
  theta2 = long2*degrees_to_radians
         
    # Compute spherical distance from spherical coordinates.
         
    # For two locations in spherical coordinates 
    # (1, theta, phi) and (1, theta, phi)
    # cosine( arc length ) = 
    #    sin phi sin phi' cos(theta-theta') + cos phi cos phi'
    # distance = rho * arc length
  cos = (math.sin(phi1)*math.sin(phi2)*math.cos(theta1 - theta2) + math.cos(phi1)*math.cos(phi2))
  arc = math.acos( cos )
 
    # Remember to multiply arc by the radius of the earth 
    # in your favorite set of units to get length.
  return arc*6373

if __name__=='__main__':
  main()
  
