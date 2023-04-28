import datetime
import json
import random
import uuid


def log_order():
    ts = datetime.datetime.now().isoformat()
    start_time = datetime.datetime.now().replace(minute=0, second=0, microsecond=0) + \
        datetime.timedelta(days=random.randint(2, 10))
    store_id = str(random.randint(1, 100))
    message = {
        "log": "ggo-order",
        "order": {
            "order_id": str(uuid.uuid4()),
            "status": 2,
            "amount": random.randint(10, 100) * 100,
            "order_time": (datetime.datetime.now() - datetime.timedelta(minutes=random.randint(0, 19), seconds=random.randint(0, 59))).isoformat(),
            "pay_time": ts,
            "vehicle_id": str(random.randint(1, 100)),
            "start_store_id": store_id,
            "start_time": start_time.isoformat(),
            "end_store_id": store_id,
            "end_time": (start_time + datetime.timedelta(days=random.randint(0, 10))).isoformat(),
        },
        "uid": str(random.randint(1, 50)),
        "time": ts,
    }
    datetime.datetime.now().date()
    log(json.dumps(message))


def log_login():
    ts = datetime.datetime.now().isoformat()
    message = {
        "log": "ggo-login",
        "uid": str(random.randint(1, 50)),
        "time": ts,
        "client_type": random.choice(["web", "ios"]),
    }
    log(json.dumps(message))


def log(message: str):
    print(message)