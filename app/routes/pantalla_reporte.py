from flask import Blueprint, request, jsonify
from geoalchemy2.shape import from_shape
from shapely.geometry import Point
from sqlalchemy import func
from ..models.db import db
from ..models.zona import Zona
from ..models.reporte import Reporte
import json

tureporte_bp = Blueprint('tureporte', __name__)
