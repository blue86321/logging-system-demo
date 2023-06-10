import datetime
import json
import random
from typing import Any, Dict
import uuid
import logging


def log_order():
    ts = datetime.datetime.now().isoformat()
    message = {
        "log_name": "myapp-order-grpc",
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
    log(message)


def log(message: Dict[str, Any]):
    logging.info(json.dumps(message))
