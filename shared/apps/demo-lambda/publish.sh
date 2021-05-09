aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 327229172692.dkr.ecr.us-west-2.amazonaws.com
docker build -t demo_micronaut .
docker tag demo_micronaut:latest 327229172692.dkr.ecr.us-west-2.amazonaws.com/demo_micronaut:latest
docker push 327229172692.dkr.ecr.us-west-2.amazonaws.com/demo_micronaut:latest