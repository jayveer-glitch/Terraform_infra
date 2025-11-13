package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformAwsExample(t *testing.T) {
	t.Parallel()

	const httpport = 80

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
	}
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	publicIP := terraform.Output(t, terraformOptions, "instance_public_ip")
	url := fmt.Sprintf("http://%s:%d", publicIP, httpport)

	http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello, World", 30, 10*time.Second)

	assert.True(t, len(publicIP) > 0, "Public IP should not be empty")
}