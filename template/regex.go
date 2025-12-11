package template

import "github.com/isabellaherman/oh-my-mon/regex"

func matchP(pattern, text string) bool {
	return regex.MatchString(pattern, text)
}

func replaceP(pattern, text, replaceText string) string {
	return regex.ReplaceAllString(pattern, text, replaceText)
}

func findP(pattern, text string, index int) string {
	match, _ := regex.FindStringMatch(pattern, text, index)
	return match
}
