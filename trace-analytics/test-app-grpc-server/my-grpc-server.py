from concurrent import futures

import grpc
import hello_pb2
import hello_pb2_grpc

from MyAppLogging import log_order


class Greeter(hello_pb2_grpc.GreeterServicer):
    def SayHello(self, request, context):
        # log
        log_order()
        return hello_pb2.HelloReply(message="Hello, %s!" % request.name)


def serve():
    port = "50051"
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    hello_pb2_grpc.add_GreeterServicer_to_server(Greeter(), server)
    server.add_insecure_port("[::]:" + port)
    server.start()
    print("Server started, listening on " + port)
    server.wait_for_termination()


if __name__ == "__main__":
    serve()
