package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/costexplorer"
	"github.com/aws/aws-sdk-go-v2/service/costexplorer/types"
)

func main() {
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("us-east-1"))
	if err != nil {
		log.Fatalf("unable to load SDK config, %v", err)
	}

	ceClient := costexplorer.NewFromConfig(cfg)

	// Settings
	targetAccountID := "xxxxxxxxxxx" // Replace with your target AWS Account ID
	now := time.Now()
	startOfMonth := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.UTC).Format("2006-01-02")
	endOfPeriod := now.Format("2006-01-02")

	input := &costexplorer.GetCostAndUsageInput{
		TimePeriod: &types.DateInterval{
			Start: aws.String(startOfMonth),
			End:   aws.String(endOfPeriod),
		},
		Granularity: types.GranularityMonthly,
		Metrics:     []string{"UnblendedCost"},
		// --- FILTER BY ACCOUNT ID START ---
		Filter: &types.Expression{
			Dimensions: &types.DimensionValues{
				Key:    types.DimensionLinkedAccount,
				Values: []string{targetAccountID},
			},
		},
		// --- FILTER BY ACCOUNT ID END ---
		GroupBy: []types.GroupDefinition{
		//	{Type: types.GroupDefinitionTypeDimension, Key: aws.String("REGION")}, // Region Specific
			{Type: types.GroupDefinitionTypeDimension, Key:  aws.String("SERVICE"),},
		},
	}

	result, err := ceClient.GetCostAndUsage(context.TODO(), input)
	if err != nil {
		log.Fatalf("failed to get cost and usage, %v", err)
	}

	fmt.Printf("Cost Report for Account %s:\n", targetAccountID)
		for _, period := range result.ResultsByTime {
		for _, group := range period.Groups {
			fmt.Printf("- %s: %s %s\n",
				group.Keys[0],
				*group.Metrics["UnblendedCost"].Amount,
				*group.Metrics["UnblendedCost"].Unit)
		}
	}
}
