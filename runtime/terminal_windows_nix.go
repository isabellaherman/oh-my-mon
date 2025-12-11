//go:build !darwin

package runtime

import (
	"time"

	"github.com/isabellaherman/oh-my-mon/log"
	"github.com/isabellaherman/oh-my-mon/runtime/battery"
)

func (term *Terminal) BatteryState() (*battery.Info, error) {
	defer log.Trace(time.Now())
	info, err := battery.Get()
	if err != nil {
		log.Error(err)
		return nil, err
	}
	return info, nil
}
