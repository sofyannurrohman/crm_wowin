package utils

// Ptr returns a pointer to the value passed in.
func Ptr[T any](v T) *T {
	return &v
}

// If returns a if cond is true, otherwise b.
func If[T any](cond bool, a, b T) T {
	if cond {
		return a
	}
	return b
}
