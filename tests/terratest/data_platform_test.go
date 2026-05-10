package test

import (
	"testing"

	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/lambda"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestDataPlatformDev(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../envs/dev",
		NoColor:      true,
	}

	sourceBucket := terraform.Output(t, terraformOptions, "source_bucket_name")
	lambdaName := terraform.Output(t, terraformOptions, "lambda_function_name")

	awsSession := session.Must(session.NewSession())

	s3Client := s3.New(awsSession)
	_, err := s3Client.HeadBucket(&s3.HeadBucketInput{
		Bucket: &sourceBucket,
	})
	assert.NoError(t, err)

	lambdaClient := lambda.New(awsSession)
	_, err = lambdaClient.GetFunction(&lambda.GetFunctionInput{
		FunctionName: &lambdaName,
	})
	assert.NoError(t, err)
}