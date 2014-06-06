#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

__author__ = 'amitwolfus@gmail.com (Amit Wolfus)'

import os
import logging

from django.utils import simplejson

import webapp2
from google.appengine.ext import db

from geo import geotypes

from models import Parking, ParkingState

__default_max_results__ = 10
__default_radius__ = 1000

class ParkingsHandler(webapp2.RequestHandler):
    """Defines the handler for the parkings search"""
    
    def get(self):
        def _simple_error(message, code=400):
            self.error(code)
            self.response.out.write(simplejson.dumps({
                'status': 'error',
                'error': { 'message': message },
                'results': []
            }))
            return None
        
        self.response.headers['Content-Type'] = 'application/json'
        
        try:
            center = geotypes.Point(float(self.request.get('lat')),
                                    float(self.request.get('lon')))
        except ValueError:
                return _simple_error('lat and lon parameters must be valid latitude and longitude values.')
        
        max_results = self.request.get('results')
        try:
            max_results = int(max_results) if max_results else __default_max_results__
        except ValueError:
            return _simple_error('results must be a valid integer value')
        
        radius = self.request.get('radius')
        try:
            radius = int(radius) if radius else __default_radius__
        except ValueError:
            return _simple_error('radius must be a valid integer in meters')
        base_query = Parking.all()
        logging.info('radius is %d' %radius)
        logging.info('max results is %d' % max_results)
        results = Parking.proximity_fetch(base_query,center,max_results=max_results, max_distance=radius)
        logging.info('queried %d parkings' % len(results))
        results_arr = [{'id':result.parking_id,
                        'name':result.name,
                        'street':result.street_name,
                        'house':result.house_number,
                        'location':{'latitude':result.latitude,
                                    'longitude':result.longitude},
                        'state':result.current_state,
                        'capacity':result.capacity}
                       for result in results]

        self.response.out.write(simplejson.dumps(
                                        {'status':'success','results':results_arr},indent=4))

#class ParkingsAdder(webapp2.RequestHandler):
#    def get(self):
#        def _simple_error(message, code=400):
#            self.error(code)
#            self.response.out.write(simplejson.dumps({
#                                                     'status': 'error',
#                                                     'error': { 'message': message },
#                                                     'results': []
#                                                     }))
#            return None
#        
#        id = self.request.get('id')
#
#        try:
#            lat = float(self.request.get('lat'))
#        except ValueError:
#            return _simple_error('Invalid value for latitude')
#        try:
#            lon = float(self.request.get('lon'))
#        except ValueError:
#            return _simple_error('Invalid value for latitude')
#
#        street = self.request.get('street')
#        house = self.request.get('house')
#        name = self.request.get('name')
#        name = name if name else street
#        capa = int(self.request.get('capacity'))
#        state = ParkingState.Empty
#        parking = Parking(key_name=id,
#                          parking_id=id,
#                          name=name,
#                          street_name=street,
#                          house_number=house,
#                          current_state=state,
#                          capacity = capa,
#                          location=db.GeoPt(lat,lon))
#        parking.update_location()
#        parking.put()

class ParkingStateHandler(webapp2.RequestHandler):
    def get(self):
        def _simple_error(message, code=400):
            self.error(code)
            self.response.out.write(simplejson.dumps({
                                                     'status': 'error',
                                                     'error': { 'message': message }
                                                     },indent=4))
            return None
        
        self.response.headers['Content-Type'] = 'application/json'
        
        state = self.request.get('state')
        if not state:
            return _simple_error('state parameter is required')
        state_val = ParkingState.value_of_name(state)
        if state_val is -1:
            return _simple_error('state parameter isn\'t a valid state')
    
        parking_id = self.request.get('id')
        if not parking_id:
            return _simple_error('parking identifier must be specified')

        parking_key = db.Key.from_path('Parking', parking_id)
        parking = db.get(parking_key)
        if not parking:
            return _simple_error('specified parking wasn\'t found')
        if not parking.current_state == state_val:
                parking.current_state = state_val
                db.put(parking)
        self.response.out.write(simplejson.dumps({'status':'success'},indent=4))

app = webapp2.WSGIApplication([
    ('/parkings', ParkingsHandler), ('/parking',ParkingStateHandler)],
        debug=('Development' in os.environ['SERVER_SOFTWARE']))
