package cli

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/isabellaherman/oh-my-mon/build"
	"github.com/isabellaherman/oh-my-mon/cache"
	"github.com/isabellaherman/oh-my-mon/log"
	"github.com/spf13/cobra"
)

var (
	configFlag   string
	shellName    string
	printVersion bool
	trace        bool
	exitcode     int

	// for internal use only
	silent bool

	// deprecated
	initialize bool
)

var RootCmd = &cobra.Command{
	Use:   "oh-my-mon",
	Short: "oh-my-mon is a monitoring and system prompt tool",
	Long: `oh-my-mon is a cross-platform monitoring and system prompt tool.
It provides system monitoring capabilities with customizable prompts
for any shell environment.`,
	Run: func(cmd *cobra.Command, args []string) {
		if initialize {
			runInit(strings.ToLower(shellName), getFullCommand(cmd, args))
			return
		}

		if printVersion {
			fmt.Println(build.Version)
			return
		}

		_ = cmd.Help()
	},
	PersistentPreRun: func(cmd *cobra.Command, args []string) {
		traceEnv := os.Getenv("MON_TRACE")
		if traceEnv == "" && !trace {
			return
		}

		trace = true

		log.Enable(true)

		log.Debug("version:", build.Version)
		log.Debug("command:", getFullCommand(cmd, args))
	},
	PersistentPostRun: func(cmd *cobra.Command, args []string) {
		defer func() {
			if exitcode != 0 {
				os.Exit(exitcode)
			}
		}()

		if !trace {
			return
		}

		var prefix string
		if shellName != "" {
			prefix = fmt.Sprintf("%s-", shellName)
		}

		cli := append([]string{cmd.Name()}, args...)

		filename := fmt.Sprintf("%s-%s%s.log", time.Now().Format("02012006T150405.000"), prefix, strings.Join(cli, "-"))

		logPath := filepath.Join(cache.Path(), "logs")
		err := os.MkdirAll(logPath, 0755)
		if err != nil {
			return
		}

		err = os.WriteFile(filepath.Join(logPath, filename), []byte(log.String()), 0644)
		if err != nil {
			return
		}
	},
}

func Execute() {
	if err := RootCmd.Execute(); err != nil {
		// software error
		os.Exit(70)
	}
}

func init() {
	RootCmd.PersistentFlags().StringVarP(&configFlag, "config", "c", "", "config file path")
	RootCmd.PersistentFlags().BoolVar(&silent, "silent", false, "do not print anything")
	RootCmd.PersistentFlags().BoolVar(&trace, "trace", false, "enable tracing")
	RootCmd.PersistentFlags().BoolVar(&plain, "plain", false, "plain text output (no ANSI)")
	RootCmd.Flags().BoolVar(&printVersion, "version", false, "print the version number and exit")

	// Deprecated flags, should be kept to avoid breaking CLI integration.
	RootCmd.Flags().BoolVarP(&initialize, "init", "i", false, "init")
	RootCmd.Flags().StringVarP(&shellName, "shell", "s", "", "shell")

	// Hide flags that are deprecated or for internal use only.
	_ = RootCmd.PersistentFlags().MarkHidden("silent")

	// Disable completions
	RootCmd.CompletionOptions.DisableDefaultCmd = true
}
