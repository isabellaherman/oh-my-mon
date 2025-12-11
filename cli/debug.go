package cli

import (
	"fmt"
	"os"
	"time"

	"github.com/isabellaherman/oh-my-mon/build"
	"github.com/isabellaherman/oh-my-mon/cache"
	"github.com/isabellaherman/oh-my-mon/config"
	"github.com/isabellaherman/oh-my-mon/log"
	"github.com/isabellaherman/oh-my-mon/prompt"
	"github.com/isabellaherman/oh-my-mon/runtime"
	"github.com/isabellaherman/oh-my-mon/shell"
	"github.com/isabellaherman/oh-my-mon/template"
	"github.com/isabellaherman/oh-my-mon/terminal"

	"github.com/spf13/cobra"
)

// debugCmd represents the debug command
var (
	debugCmd  = createDebugCmd()
	startTime = time.Now()
)

func init() {
	RootCmd.AddCommand(debugCmd)
}

func createDebugCmd() *cobra.Command {
	debugCmd := &cobra.Command{
		Use:   "debug",
		Short: "Print the prompt in debug mode",
		Long:  "Print the prompt in debug mode.",
		Run: func(_ *cobra.Command, _ []string) {
			startTime := time.Now()

			log.Enable(plain)

			flags := &runtime.Flags{
				Debug: true,
				PWD:   pwd,
				Shell: shell.GENERIC,
				Plain: plain,
			}

			env := &runtime.Terminal{}
			env.Init(flags)

			cache.Init(os.Getenv("POSH_SHELL"))

			cfg := getDebugConfig(configFlag)

			template.Init(env, cfg.Var, cfg.Maps)

			defer func() {
				template.SaveCache()
				cache.Close()
			}()

			terminal.Init(shell.GENERIC)
			terminal.BackgroundColor = cfg.TerminalBackground.ResolveTemplate()
			terminal.Colors = cfg.MakeColors(env)
			terminal.Plain = plain

			eng := &prompt.Engine{
				Config: cfg,
				Env:    env,
				Plain:  plain,
			}

			fmt.Print(eng.PrintDebug(startTime, build.Version))
		},
	}

	debugCmd.Flags().StringVar(&pwd, "pwd", "", "current working directory")

	// Deprecated flags, should be kept to avoid breaking CLI integration.
	debugCmd.Flags().StringVar(&shellName, "shell", "", "the shell to print for")

	// Hide flags that are deprecated or for internal use only.
	_ = debugCmd.Flags().MarkHidden("shell")

	return debugCmd
}

func getDebugConfig(configpath string) *config.Config {
	if len(configpath) != 0 {
		return config.Load(configpath, false)
	}

	reload, _ := cache.Get[bool](cache.Device, config.RELOAD)
	return config.Get(configpath, reload)
}
