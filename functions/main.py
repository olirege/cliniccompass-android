from firebase_functions.firestore_fn import on_document_updated,Event, DocumentSnapshot
from firebase_functions.https_fn import on_request, Request, Response, on_call, CallableRequest
from firebase_admin import initialize_app, firestore
import google.cloud.firestore
from google.cloud.firestore_v1.base_query import FieldFilter
import logging
import datetime
import requests
from dotenv import load_dotenv
import os
from jsonschema import validate, ValidationError

initialize_app()
logger = logging.getLogger('cloudfunctions.googleapis.com%2Fcloud-functions')
logger.setLevel(logging.INFO)
logger.addHandler(logging.StreamHandler())

@on_request()
def update_clinic(req: Request) -> Response:
    logger.log(msg='update_clinic', level=logging.INFO)
    clinic_data = req.get_json()
    if clinic_data is None:
        return Response(status=400)
    clinic_id = clinic_data.get('id')
    logger.log(msg=clinic_id, level=logging.INFO)
    if clinic_id is None:
        logger.log(msg='clinic_id is None', level=logging.INFO)
        return Response(status=400)
    firestore_client = google.cloud.firestore.Client = firestore.client()
    firestore_client.collection('clinics').document(clinic_id).set(clinic_data, merge=True)
    return Response(status=200)

clinic_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string", "minLength": 1, "maxLength": 100, "pattern": "^[a-zA-Z0-9 ]*$"},
        "address": {"type": "string", "minLength": 1, "maxLength": 100, "pattern": "^[a-zA-Z0-9 ]*$"},
        "totalOccupancy": {"type": "number", "minimum": 0},
        "phonenumber": {"type": "string", "minLength": 1, "maxLength": 100, "pattern": "^[0-9]*$"},
        "maxCapacity": {"type": "number", "minimum": 0},
        "location": {"type": "object"}, # "latitude": {"type": "number"}, "longitude": {"type": "number"}}, "required": ["latitude", "longitude"]},
        "avgWaitingTime": {"type": "number", "minimum": 0},
        "updatedAt": {},
        "id": {"type": "string"}
    },
    "required": ["name", "address", "phonenumber"]
}
def get_geocode(address, api_key):
    base_url = "https://maps.googleapis.com/maps/api/geocode/json"
    params = {
        "address": address,
        "key": api_key
    }
    response = requests.get(base_url, params=params)
    if response.status_code == 200:
        result = response.json()
        if result["status"] == "OK":
            location = result["results"][0]["geometry"]["location"]
            return location["lat"], location["lng"]
    return None, None

@on_request()
def create_clinic(req: Request) -> Response:
    logger.log(msg='create_clinic', level=logging.INFO)
    clinic_data = req.get_json()
    if clinic_data is None:
        logger.log(msg='clinic_data is None', level=logging.INFO)
        return Response(status=400)
    try:
        logger.log(msg="clinic_data: " + str(clinic_data), level=logging.INFO)
        validate(instance=clinic_data, schema=clinic_schema)
    except ValidationError as err:
        logger.log(msg=err, level=logging.INFO)
        return Response(status=400, response=str(err))
    # generate id for clinic
    firestore_client = google.cloud.firestore.Client = firestore.client()
    clinic_ref = firestore_client.collection('clinics').document()
    clinic_id = clinic_ref.id
    clinic_data['id'] = clinic_id
    logger.log(msg="clinic_id: " + clinic_id, level=logging.INFO)
    # get geocode
    address = clinic_data.get('address')
    if address is None:
        logger.log(msg='address is None', level=logging.INFO)
        return Response(status=400)
    load_dotenv()
    api_key = os.getenv('GEOCODE_API_KEY')
    if api_key is None:
        logger.log(msg='api_key is None', level=logging.INFO)
        return Response(status=400)
    latitude, longitude = get_geocode(address, api_key)
    if latitude is None or longitude is None:
        logger.log(msg='latitude or longitude is None', level=logging.INFO)
        return Response(status=400)
    clinic_data['location'] = {
        'latitude': latitude,
        'longitude': longitude
    }
    clinic_data['maxCapacity'] = 0
    clinic_data['totalOccupancy'] = 0
    clinic_data['avgWaitingTime'] = 0
    clinic_data['updatedAt'] = datetime.datetime.now()
    # set clinic
    clinic_ref.set(clinic_data)
    return Response(status=200)

department_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string", "minLength": 1, "maxLength": 100, "pattern": "^[a-zA-Z0-9 ]*$"},
        "occupancy": {"type": "number", "minimum": 0},
        "phonenumber": {"type": "string", "minLength": 1, "maxLength": 100, "pattern": "^[0-9]*$"},
        "capacity": {"type": "number", "minimum": 0},
        "waitingTime": {"type": "number", "minimum": 0},
        "updatedAt": {},
        "id": {"type": "string"},
        "clinicId": {"type": "string"}
    },
    "required": ["name", "clinicId", "capacity"]
}
@on_request()
def create_department(req: Request) -> Response:
    """
    Creates a new department in the clinic.

    Args:
        req (Request): The request object containing the department data.

    Returns:
        Response: The response object indicating the status of the operation.
    
    Steps:
        1. Get the department data from the request object.
        2. Check if the department data fields exists and are valid.
        3. Generate an id for the department.
        4. Set the department default values.
        5. Set the department in Firestore.
    """
    logger.log(msg='create_department', level=logging.INFO)
    department_data = req.get_json()
    if department_data is None:
        logger.log(msg='department_data is None', level=logging.INFO)
        return Response(status=400)
    try:
        validate(instance=department_data, schema=department_schema)
    except ValidationError as err:
        logger.log(msg=err, level=logging.INFO)
        return Response(status=400, response=str(err))
    # generate id for department
    firestore_client = google.cloud.firestore.Client = firestore.client()
    clinic_ref = firestore_client.collection('clinics').document(department_data['clinicId'])
    department_ref = firestore_client.collection('clinics').document(department_data['clinicId']).collection('departments').document()
    department_id = department_ref.id
    department_data['id'] = department_id
    logger.log(msg="department_id: " + department_id, level=logging.INFO)
    # set department
    department_data['occupancy'] = 0
    department_data['waitingTime'] = 0
    department_data['updatedAt'] = datetime.datetime.now()
    department_ref.set(department_data)
    clinic_ref.set({'maxCapacity': firestore.Increment(department_data['capacity']), 'updatedAt': datetime.datetime.now()}, merge=True)
    return Response(status=200)
def update_clinic_aggregates(clinic_id):
    """
    Update the aggregate values for a clinic based on its departments' data.

    Args:
        clinic_id (str): The ID of the clinic.

    Returns:
        None
    """
    firestore_client = firestore.client()
    departments = firestore_client.collection('clinics').document(clinic_id).collection('departments').stream()
    total_occupancy = 0
    total_capacity = 0
    total_waiting_time = 0
    department_count = 0
    for department in departments:
        dept_data = department.to_dict()
        total_occupancy += dept_data.get('occupancy', 0)
        total_capacity += dept_data.get('capacity', 0)
        total_waiting_time += dept_data.get('waitingTime', 0)
        department_count += 1

    if department_count > 0:
        avg_waiting_time = total_waiting_time / department_count
    else:
        avg_waiting_time = 0

    clinic_ref = firestore_client.collection('clinics').document(clinic_id)
    clinic_ref.update({
        'totalOccupancy': total_occupancy,
        'maxCapacity': total_capacity,
        'avgWaitingTime': avg_waiting_time
    })

@on_request()
def update_department(req: Request) -> Response:
    """
    Update department data in Firestore.

    Args:
        req (Request): The request object containing the department data.

    Returns:
        Response: The response object indicating the status of the update operation.
    
    Steps:
        1. Get the department data from the request object.
        2. Check if the department data fields exists and are valid.
        3. Update the department data in Firestore.
    """
    logger.log(msg='update_department', level=logging.INFO)
    department_data = req.get_json()
    department_id = department_data.get('id')
    if department_id is None:
        return Response(status=400)
    firestore_client = google.cloud.firestore.Client = firestore.client()
    department_query = firestore_client.collection_group('departments').where(filter=FieldFilter('id','==',department_id)).limit(1)
    departments = department_query.stream()
    department_ref = None
    for department in departments:
        department_ref = department.reference
        break

    if department_ref is None:
        return Response(status=404, response='Department not found')
    department = department_ref.get()
    merged_data = {**department.to_dict(), **department_data}
    try:
        validate(instance=merged_data, schema=department_schema)
    except ValidationError as e:
        return Response(status=400, response=str(e))
    if department_data.get('occupancy') is not None:
        department_data['updatedAt'] = datetime.datetime.now()
        # Assuming department_data['updatedAt'] and department['updatedAt'] are the datetime objects
        updated_at = department_data.get('updatedAt')
        original_updated_at = department.get('updatedAt')
        # Convert both to the same type (offset-aware or offset-naive) before subtraction
        updated_at_naive = updated_at.replace(tzinfo=None) if updated_at.tzinfo else updated_at
        original_updated_at_naive = original_updated_at.replace(tzinfo=None) if original_updated_at.tzinfo else original_updated_at
        # Now perform the subtraction
        time_difference = (updated_at_naive - original_updated_at_naive).total_seconds() / 60
        department_data['waitingTime'] = department.get('waitingTime') + time_difference
        if department_data['waitingTime'] < 0:
            department_data['waitingTime'] = 0
        # update clinic occupancy and waiting time
    department_data['updatedAt'] = datetime.datetime.now()
    if department_ref.set(department_data, merge=True):
        update_clinic_aggregates(department.get('clinicId'))
    
    return Response(status=200)

request_schema = {
    "type": "object",
    "properties": {
        "type": {"type": "string", "enum": ["chat", "video", "call"]}, 
    },
    "required": ["type"]
}
@on_call()
def request_to_join(req: CallableRequest):
    # TODO
    uid = req.auth.uid
    if uid is None:
        print("no uid")
        return { "status": 400 }
    if req.data is None:
        print("no data")
        return { "status": 400 }
    try:
        validate(instance=req.data, schema=request_schema)
    except ValidationError as err:
        print(err)
        return { "status": 400 }
    firestore_client = google.cloud.firestore.Client = firestore.client()
    # check if any employeesOnline
    employees_ref = firestore_client.collection('employeesOnline')
    if employees_ref.count() == 0:
        print("no employees online")
        return { "status": 404 }
    # store request to joinRequest collection
    join_request_ref = firestore_client.collection('joinRequests').document()
    join_request_data = {
        "id": join_request_ref.id,
        "type": req.data['type'],
        "status": "pending",
        "createdAt": datetime.datetime.now(),
        "uid": uid
    }
    join_request_ref.set(join_request_data)
    return { "status": 200, "id": join_request_ref.id }

@on_call()
def cancel_request_to_join(req: CallableRequest):
    # TODO
    uid = req.auth.uid
    print("uid", uid)
    if uid is None:
        print("no uid")
        return { "status": 400 }
    firestore_client = google.cloud.firestore.Client = firestore.client()
    # check if any employeesOnline
    join_request_ref = firestore_client.collection('joinRequests').where(filter=FieldFilter('uid', "==", uid)).limit(1)
    join_request_ref.delete()
    return { "status": 200, "id": uid }

@on_call()
def get_agora_app_id(req: CallableRequest):
    if req.auth.uid is None:
        return { "status": 401 }
    firestore_client = google.cloud.firestore.Client = firestore.client()
    agora_app_id_ref = firestore_client.collection('agoraAppId').document('agoraAppId')
    agora_app_id = agora_app_id_ref.get().to_dict()['agoraAppId']
    return { "status": 200, "agoraAppId": agora_app_id }