package ai

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strings"

	"github.com/google/generative-ai-go/genai"
	"google.golang.org/api/option"
)

type ReceiptItem struct {
	Name     string  `json:"name"`
	Quantity float64 `json:"quantity"`
	Unit     string  `json:"unit"`
	Price    float64 `json:"price"`
}

type GeminiService interface {
	AnalyzeReceipt(ctx context.Context, imagePath string, mimeType string) ([]ReceiptItem, error)
}

type geminiServiceImpl struct {
	apiKey string
}

func NewGeminiService(apiKey string) GeminiService {
	return &geminiServiceImpl{apiKey: apiKey}
}

func (s *geminiServiceImpl) AnalyzeReceipt(ctx context.Context, imagePath string, mimeType string) ([]ReceiptItem, error) {
	client, err := genai.NewClient(ctx, option.WithAPIKey(s.apiKey))
	if err != nil {
		return nil, fmt.Errorf("failed to create genai client: %w", err)
	}
	defer client.Close()

	model := client.GenerativeModel("gemini-2.0-flash")
	
	// Ensure structured output
	model.ResponseMIMEType = "application/json"

	imgData, err := os.ReadFile(imagePath)
	if err != nil {
		return nil, fmt.Errorf("failed to read image file: %w", err)
	}

	prompt := []genai.Part{
		genai.ImageData(strings.TrimPrefix(mimeType, "image/"), imgData),
		genai.Text(`Extract all line items from this receipt. 
Return a JSON array of objects. Each object must have:
- name: string (product name as written on receipt)
- quantity: number (the quantity, default 1 if not clear)
- unit: string (the unit, e.g., 'pcs', 'dus', 'kg', default 'pcs' if not clear)
- price: number (the unit price)

If there are totals or taxes, ignore them. Only extract the individual products.`),
	}

	resp, err := model.GenerateContent(ctx, prompt...)
	if err != nil {
		return nil, fmt.Errorf("failed to generate content: %w", err)
	}

	if len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0 {
		return nil, fmt.Errorf("no response candidates from Gemini")
	}

	var result string
	for _, part := range resp.Candidates[0].Content.Parts {
		if text, ok := part.(genai.Text); ok {
			result += string(text)
		}
	}

	// Clean up markdown if Gemini ignored the ResponseMIMEType (happens sometimes)
	result = strings.TrimSpace(result)
	result = strings.TrimPrefix(result, "```json")
	result = strings.TrimSuffix(result, "```")
	result = strings.TrimSpace(result)

	var items []ReceiptItem
	if err := json.Unmarshal([]byte(result), &items); err != nil {
		return nil, fmt.Errorf("failed to unmarshal Gemini response: %w. Response was: %s", err, result)
	}

	return items, nil
}
