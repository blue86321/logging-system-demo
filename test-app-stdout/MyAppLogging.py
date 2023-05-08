import datetime
import json
import random
import uuid


def log_order():
    ts = datetime.datetime.now().isoformat()
    message = {
        "log": "myapp-order",
        "order": {
            "order_id": str(uuid.uuid4()),
            "status": 2,
            "amount": random.randint(10, 100) * 100,
            "order_time": (
                datetime.datetime.now()
                - datetime.timedelta(
                    minutes=random.randint(0, 19), seconds=random.randint(0, 59)
                )
            ).isoformat(),
            "pay_time": ts,
        },
        "user": {
            "uid": str(random.randint(1, 50)),
            "anonymous": False,
        },
        "time": ts,
    }
    datetime.datetime.now().date()
    log(json.dumps(message))


def log_login():
    ts = datetime.datetime.now().isoformat()
    message = {
        "log": "myapp-login",
        "user": {
            "uid": str(random.randint(1, 50)),
            "anonymous": False,
        },
        "time": ts,
        "client_type": random.choice(["web", "ios"]),
    }
    log(json.dumps(message))


def log(message: str):
    print(message)
