import random
import time
import GgoLogging

while True:
    # `order` message
    GgoLogging.log_order()
    
    # 30% chance to send a `login` message
    if (random.randint(1, 10) < 3):
        GgoLogging.log_login()

    # sleep for 0 - 30 seconds
    time.sleep(random.random() * 30)
