# Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
S3_BUCKET ?= CONFIGURE_S3_BUCKET_HERE
REGION ?= eu-west-1
PARAMS_FILE ?= parameters.cfg
STACK_NAME ?= automated-personalize-retraining

all:
	aws cloudformation package \
		--template-file stack.template \
		--s3-bucket $(S3_BUCKET) \
		--output-template-file packaged-template.yaml
	aws cloudformation deploy \
		--template-file packaged-template.yaml \
		--s3-bucket $(S3_BUCKET) \
		--stack-name $(STACK_NAME) \
		--capabilities CAPABILITY_IAM \
		--parameter-overrides $$(cat $(PARAMS_FILE)) \
		--region $(REGION)
