# /bin/python
import pika
from threading import Thread

def on_message(ch, method, properties, body):
    print "****** Message received!!********"
    print body
    print "*****************************"
    print " "

    
def threaded_rmq(channel):
    result = channel.queue_declare(queue='presentation_queue')
    queue_name = result.method.queue
    channel.basic_consume(on_message, queue=queue_name,
                                  no_ack=True)
    channel.start_consuming()


connection = pika.BlockingConnection(pika.ConnectionParameters('192.168.99.100', 30672))
channel = connection.channel()

thread_rmq = Thread(target=threaded_rmq, args=(channel,))
thread_rmq.start()
