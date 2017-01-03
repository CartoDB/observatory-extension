from overpass import API

import json

def get_overpass(query):
    '''
    Return results of a raw overpass query.
    '''

    '''
(node
  [amenity]
  (around:400,
40.704301, -73.936658);
way
  [amenity]
  (around:400,
40.704301, -73.936658))
    '''

    '''
(node [amenity] (around:400, 40.704301, -73.936658); way [amenity] (around:400, 40.704301, -73.936658))
    '''

    api = API()
    response = api.Get(query)

    return response['features']
    #return [(el['lat'], el['lon'], el['type'], el['id'], json.dumps(el['tags']) )
    #        for el in response['elements'] if 'lat' in el][0]


def get_overpass_poi(within_geom, geom, filters=None, name=None):
    '''
    Simplified access to overpass API
    '''
    pass
