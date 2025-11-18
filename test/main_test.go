package test

import (
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformAwsExample(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		BackendConfig: map[string]interface{}{
			"bucket":         "demo-bucket-batak-420",
			"key":            "path/to/my/terraform.tfstate",
			"region":         "ap-south-1",
			"dynamodb_table": "demo-table-batak-420",
		},
	}

	//defer terraform.Destroy(t, terraformOptions)
	//terraform.InitAndApply(t, terraformOptions)

	serverPort := terraform.Output(t, terraformOptions, "server_port")
	expectedPort := "80"

	if serverPort != expectedPort {
		t.Fatalf("Policy Violation: Server port is '%s', but must be '%s'", serverPort, expectedPort)
	}

	publicIP := terraform.Output(t, terraformOptions, "instance_public_ip")

	url := fmt.Sprintf("http://%s:%s", publicIP, serverPort)

	http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello, World!", 30, 10*time.Second)

	assert.True(t, len(publicIP) > 0, "Public IP should not be empty")
}
