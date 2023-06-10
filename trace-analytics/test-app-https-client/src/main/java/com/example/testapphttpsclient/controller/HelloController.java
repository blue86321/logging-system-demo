package com.example.testapphttpsclient.controller;

import com.example.proto.GreeterGrpc;
import com.example.proto.HelloReply;
import com.example.proto.HelloRequest;
import com.fasterxml.jackson.annotation.JsonAutoDetect;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.PropertyAccessor;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import net.devh.boot.grpc.client.inject.GrpcClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Random;
import java.util.UUID;

@RestController
public class HelloController {

    Logger logger = LoggerFactory.getLogger(HelloController.class);

    @GrpcClient("test-app-grpc-server")
    private GreeterGrpc.GreeterBlockingStub helloStub;

    @GetMapping("/hello/{name}")
    public String hello(@PathVariable String name) throws JsonProcessingException {
        // Log
        ObjectMapper om = new ObjectMapper().registerModule(new JavaTimeModule());
        om.setVisibility(PropertyAccessor.FIELD, JsonAutoDetect.Visibility.ANY);
        String json = om.writeValueAsString(new OrderLog());
        logger.info(json);

        // GRPC
        HelloReply helloReply = helloStub.sayHello(
            HelloRequest.newBuilder().setName(name).build()
        );
        return helloReply.getMessage();
    }

    static class OrderLog {
        String log_name = "myapp-order-java";
        Order order;
        User user;
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS", timezone = "UTC")
        Instant time = Instant.now();

        public OrderLog() {
            this.order = new Order();
            this.user = new User();
        }

        class Order {
            String order_id = UUID.randomUUID().toString();
            int status = 2;
            int amount = new Random().nextInt(3000) + 2000;
            @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS", timezone = "UTC")
            Instant order_time = Instant.now();
            @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS", timezone = "UTC")
            Instant pay_time = Instant.now();
        }

        class User {
            String uid = UUID.randomUUID().toString();
            boolean anonymous = false;
        }
    }
}
