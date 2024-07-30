import string
import random

def id_generator(size=40, chars=string.ascii_letters + string.digits):
    return ''.join(random.SystemRandom().choice(string.ascii_letters + string.digits) for _ in range(size))


print(id_generator())
