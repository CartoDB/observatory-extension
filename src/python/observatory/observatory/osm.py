from overpass import API

import json

def get_overpass(query):
    '''
    Return results of a raw overpass query.
    '''
    api = API()
    response = api.Get(query)
    return response['features']
