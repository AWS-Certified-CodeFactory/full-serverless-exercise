FROM public.ecr.aws/lambda/java:11

COPY build/classes/java/main ${LAMBDA_TASK_ROOT}
COPY build/layers/libs/* ${LAMBDA_TASK_ROOT}/lib/

CMD [ "io.micronaut.function.aws.proxy.MicronautLambdaHandler::handleRequest" ]