package utils

import (
	"fmt"
	"image/jpeg"
	"mime/multipart"
	"os"
	"path/filepath"

	"github.com/disintegration/imaging"
)

// ProcessAndSaveImage reads a multipart file header, resizes and compresses it, then saves to disk.
func ProcessAndSaveImage(fileHeader *multipart.FileHeader, targetPath string, maxWidth, maxHeight int, quality int) error {
	// 1. Open the source file
	src, err := fileHeader.Open()
	if err != nil {
		return fmt.Errorf("failed to open uploaded file: %w", err)
	}
	defer src.Close()

	// 2. Decode the image
	img, err := imaging.Decode(src)
	if err != nil {
		return fmt.Errorf("failed to decode image: %w", err)
	}

	// 3. Resize proportionally if larger than target
	bounds := img.Bounds()
	if bounds.Dx() > maxWidth || bounds.Dy() > maxHeight {
		img = imaging.Fit(img, maxWidth, maxHeight, imaging.Lanczos)
	}

	// 4. Ensure target directory exists
	dir := filepath.Dir(targetPath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return fmt.Errorf("failed to create target directory: %w", err)
	}

	// 5. Create the target file
	out, err := os.Create(targetPath)
	if err != nil {
		return fmt.Errorf("failed to create destination file: %w", err)
	}
	defer out.Close()

	// 6. Encode as JPEG with specified quality
	err = jpeg.Encode(out, img, &jpeg.Options{Quality: quality})
	if err != nil {
		return fmt.Errorf("failed to encode/save compressed image: %w", err)
	}

	return nil
}
