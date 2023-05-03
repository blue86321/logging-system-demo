import random
import time
import MyAppLogging

while True:
    # `order` message
    MyAppLogging.log_order()
    
    # 30% chance to send a `login` message
    if (random.randint(1, 10) < 3):
        MyAppLogging.log_login()

    # sleep for 0 - 30 seconds
    time.sleep(random.random() * 30)
