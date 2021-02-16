# Automated Personalize Retraining

This sets up a pipeline for periodic re-training of your Personalize model.
Once deployed, the sample will automatically trigger a re-import of your data and re-train the Personalize model (using the same parameters that you initially configured). The cadence of the re-training can be configured in the template (defaults to once per 7 days).

## Deployment

The pipeline deployed via the templates provided here **does not** setting up include the model in [Amazon Personalize](https://docs.aws.amazon.com/personalize/latest/dg/setup.html), but relies on an already predeployed model. In the following, we'll list the required steps to be able to deploy this template and its prerequisites.

### Prerequisites

These prerequisites are required before setting this pipeline up:

 - You need to have a set up of [Amazon Personalize](https://docs.aws.amazon.com/personalize/latest/dg/setup.html), for later steps you will need ARNs of
   - A role that is able to import the datasets
   - Amazon S3 paths of the datasets
   - ARNs of solution and/or campaigns to be updated via this pipeline
 - The [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) installed
 - [Make](https://www.gnu.org/software/make/) installed: If you don't have make, you might work around this by executing the commands in the [Makefile](https://github.com/aws-samples/amazon-personalize-automated-retraining/blob/master/Makefile) using a script
 - An Amazon S3 bucket for deploying these scripts as part of the Makefile
 
### Deploying the retraining pipeline

Once you have done the steps listed in the [Prerequisites](#Prerequisites), you need to:

1. Fill in the S3 bucket you created for housing the deployment files, as well as the AWS Region to the first lines of the [Makefile](https://github.com/aws-samples/amazon-personalize-automated-retraining/blob/master/Makefile#L3-L4).
2. Update the required parameters (e.g., ARNs from the datasets, retraining rate,...) in the [parameters.cfg](parameters.cfg). You'll find a list of all parameters and their description below.
3. (Optional): You might want to adjust the (currently fixed) `--stack-name` from the [Makefile](https://github.com/aws-samples/amazon-personalize-automated-retraining/blob/master/Makefile#L14) in case you want to deploy multiple pipelines. (See [Advanced use](#advanced-use))

Now you can run `make` from your command line to deploy the pipeline.

The parameters are

| Parameter Name                  | Description                                                                                                                                | Required |
|---------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|----------|
| ImportRoleArn                   | ARN of the role that is used to re-import the dataset from S3 (requires read privileges to the S3 bucket containing the dataset).          | Yes      |
| SolutionArn                     | ARN of the Solution that should be used to create a new version for the re-imported dataset.                                               | Yes      |
| UserDatasetArn                  | ARN of the user dataset (in Personalize) that should be re-imported. If left empty, the dataset will not be re-imported.                   | No (*)   |
| S3UserDatasourcePath            | S3 Path to the csv file, the user dataset should be re-imported from. If left empty, the dataset will not be re-imported.                  | No (*)   |
| ItemDatasetArn                  | ARN of the item dataset (in Personalize) that should be re-imported. If left empty, the dataset will not be re-imported.                   | No (*)   |
| S3ItemDatasourcePath            | S3 Path to the csv file, the item dataset should be re-imported from. If left empty, the dataset will not be re-imported.                  | No (*)   |
| UserInteractionDatasetArn       | ARN of the user item interaction dataset (in Personalize) that should be re-imported. If left empty, the dataset will not be re-imported.  | No (*)   |
| S3UserInteractionDatasourcePath | S3 Path to the csv file, the user item interaction dataset should be re-imported from. If left empty, the dataset will not be re-imported. | No (*)   |
| CampaignArn                     | The ARN of the campaign that should be updated (with the retrained solution version). No campaign is updated if this is left empty.        | No       |
| RetrainingRate                  | Rate at which the Personalize should be retrained, defaults to **7 days** if not set.                                                      | No       |

(*) One of the datasources needs to be updated, otherwise, creating a new solution version does not make sense. For the datasource that should be updated, the dataset ARN as well as the S3 path are required.

### Advanced use
The parameter `--stack-name` in `Makefile` determines the name of the stack. You can modify it by setting the environment variable `STACK_NAME` before running make, like so
```bash
$ STACK_NAME=personalize-retraining-2 make
```
Parameters by default are loaded form `parameters.cfg`. You can override this behaviour by setting the `PARAMS_FILE` environment variable.
The combination of the above two options, allows you to practically run multiple instances of retraining automation in parallel. Let's say you have a dataset for your production enviroment and another one for your staging:
```bash
$ STACK_NAME=personalize-retraining-staging PARAMS_FILE=parameters.staging.cfg make  # For staging
$ STACK_NAME=personalize-retraining-prod PARAMS_FILE=parameters.prod.cfg make  # For prod
```

## Components of this sample

![Architecture Diagram](PersonalizeRetraining.png "High level architecture overview of Personalize retraining setup")

*High level architecture overview of Personalize retraining setup*

## License

This library is licensed under the MIT-0 License. See the [LICENSE](LICENSE) file.

