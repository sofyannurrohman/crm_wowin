package utils

import (
	"database/sql/driver"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"
)

// FlexTime is a wrapper around time.Time that supports multiple JSON formats during unmarshaling.
type FlexTime struct {
	time.Time
}

// UnmarshalJSON implements json.Unmarshaler.
func (ft *FlexTime) UnmarshalJSON(b []byte) error {
	s := strings.Trim(string(b), "\"")
	if s == "null" || s == "" {
		ft.Time = time.Time{}
		return nil
	}

	// Try RFC3339 first (standard)
	t, err := time.Parse(time.RFC3339, s)
	if err == nil {
		ft.Time = t
		return nil
	}

	// Try common ISO 8601 layouts that don't include timezone
	layouts := []string{
		"2006-01-02T15:04:05.000000000",
		"2006-01-02T15:04:05.000000",
		"2006-01-02T15:04:05.000",
		"2006-01-02T15:04:05",
		"2006-01-02 15:04:05",
		"2006-01-02",
	}

	for _, layout := range layouts {
		t, err = time.Parse(layout, s)
		if err == nil {
			ft.Time = t
			return nil
		}
	}

	return fmt.Errorf("could not parse time %s: %w", s, err)
}

// MarshalJSON implements json.Marshaler.
func (ft FlexTime) MarshalJSON() ([]byte, error) {
	if ft.IsZero() {
		return []byte("null"), nil
	}
	return json.Marshal(ft.Time.Format(time.RFC3339))
}

// Scan implements the sql.Scanner interface.
func (ft *FlexTime) Scan(value interface{}) error {
	if value == nil {
		ft.Time = time.Time{}
		return nil
	}
	t, ok := value.(time.Time)
	if !ok {
		return errors.New("type assertion to time.Time failed")
	}
	ft.Time = t
	return nil
}

// Value implements the driver.Valuer interface.
func (ft FlexTime) Value() (driver.Value, error) {
	if ft.IsZero() {
		return nil, nil
	}
	return ft.Time, nil
}

// Now returns the current time as FlexTime.
func Now() FlexTime {
	return FlexTime{Time: time.Now()}
}

// ToFlexTime converts a time.Time to FlexTime.
func ToFlexTime(t time.Time) FlexTime {
	return FlexTime{Time: t}
}

// ToFlexTimePtr converts a time.Time to a pointer to FlexTime.
func ToFlexTimePtr(t time.Time) *FlexTime {
	if t.IsZero() {
		return nil
	}
	return &FlexTime{Time: t}
}
