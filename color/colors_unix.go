//go:build !windows && !darwin

package color

import "github.com/isabellaherman/oh-my-mon/runtime"

func GetAccentColor(_ runtime.Environment) (*RGB, error) {
	return nil, &runtime.NotImplemented{}
}
