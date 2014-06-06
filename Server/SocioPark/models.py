#!/usr/bin/env python
#
# Copyright 2013 Amit Wolfus

"""Defines the models for the sociopark application"""

__author__= 'amitwolfus@gmail.com (Amit Wolfus'

from google.appengine.ext import db

from geo.geomodel import GeoModel

class ParkingState:
    """Represents an enum for the available
        states of a parking"""
    Empty, Medium, Busy, Full = range(4)
    _names_ = ['empty', 'medium', 'busy', 'full']

    _values_for_names_ = {'empty' : 0,
                          'medium': 1,
                          'busy' : 2,
                          'full' : 3}

    @staticmethod
    def name_of_value(value):
        return _names_[value]

    @staticmethod
    def value_of_name(name):
        return {'empty' : 0,
            'medium': 1,
            'busy' : 2,
            'full' : 3}.get(name.lower(), -1)

class Parking(GeoModel):
    """A location-aware model for a parking, currently
        only in Tel-Aviv"""

    parking_id = db.StringProperty(required=True)
    name = db.StringProperty()
    street_name = db.StringProperty()
    house_number = db.StringProperty()
    current_state = db.IntegerProperty()
    capacity = db.IntegerProperty()
    
    def _get_latitude(self):
        return self.location.lat if self.location else None

    def _set_latitude(self, lat):
        if not self.location:
            self.location = db.GeoPt()
                
        self.location.lat = lat

    latitude = property(_get_latitude, _set_latitude)

    def _get_longitude(self):
        return self.location.lon if self.location else None
                
    def _set_longitude(self, lon):
        if not self.location:
            self.location = db.GeoPt()
                    
        self.location.lon = lon
                
    longitude = property(_get_longitude, _set_longitude)
