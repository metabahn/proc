package main

import _ "embed"

import (
	"bytes"
	"flag"
	"fmt"
	"github.com/vmihailenco/msgpack/v5"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
)

//go:embed VERSION
var version string

//go:embed help/root.txt
var help string

//go:embed help/compile.txt
var compileHelp string

//go:embed help/run.txt
var runHelp string

//go:embed help/version.txt
var versionHelp string

func main() {
	if len(os.Args) > 1 {
		globalFlags := flag.NewFlagSet("proc", flag.ExitOnError)
		globalFlags.Usage = func() {
			commandHelp(false, true)
		}

		versionFlags := flag.NewFlagSet("version", flag.ExitOnError)
		versionFlags.Usage = func() {
			commandHelpVersion(false, true)
		}

		compileFlags := flag.NewFlagSet("compile", flag.ExitOnError)
		compileFlags.Usage = func() {
			commandHelpCompile(false, true)
		}

		runFlags := flag.NewFlagSet("run", flag.ExitOnError)
    runJsonArg := runFlags.Bool("json", false, "")
		runFlags.Usage = func() {
			commandHelpRun(false, true)
		}

		authorizationArg := globalFlags.String("auth", "", "")
		globalHelpArg := globalFlags.Bool("help", false, "")

		globalFlags.Parse(os.Args[1:])

		if *globalHelpArg {
			if len(globalFlags.Args()) > 0 {
				switch globalFlags.Args()[0] {
				case "version":
					commandHelpVersion(true, false)
				case "compile":
					commandHelpCompile(true, false)
				case "run":
					commandHelpRun(true, false)
				default:
					commandHelp(true, false)
				}
			} else {
				commandHelp(true, false)
			}

			os.Exit(0)
		}

		authorization := ensureAuth(*authorizationArg)

		switch globalFlags.Args()[0] {
		case "version":
			versionFlags.Parse(globalFlags.Args()[1:])

			commandVersion()
		case "compile":
			compileFlags.Parse(globalFlags.Args()[1:])
			compileCommandArgs := compileFlags.Args()

			if len(compileCommandArgs) > 0 {
				commandCompile(compileCommandArgs[0], authorization)
			} else {
				commandHelpCompile(false, true)
        os.Exit(1)
			}
		case "run":
			runFlags.Parse(globalFlags.Args()[1:])
			runCommandArgs := runFlags.Args()

      var accept string
      if *runJsonArg {
        accept = "application/json"
      } else {
        accept = "text/plain"
      }

			if len(runCommandArgs) > 0 {
				commandRun(runCommandArgs[0], authorization, accept)
			} else {
				commandHelpRun(false, true)
        os.Exit(1)
			}
		default:
			fmt.Fprintln(os.Stderr, "unknown command: "+globalFlags.Args()[0]+"\n")
			commandHelp(false, false)
			os.Exit(1)
		}
	} else {
		commandHelp(false, false)
		os.Exit(1)
	}
}

func commandHelp(success bool, topbreak bool) {
	output(help, success, topbreak)
}

func commandHelpCompile(success bool, topbreak bool) {
	output(compileHelp, success, topbreak)
}

func commandHelpRun(success bool, topbreak bool) {
	output(runHelp, success, topbreak)
}

func commandHelpVersion(success bool, topbreak bool) {
	output(versionHelp, success, topbreak)
}

func commandVersion() {
	fmt.Println("Proc CLI v" + version)
}

func commandCompile(path string, authorization string) {
	checkPath(path)

	data, error := ioutil.ReadFile(path)
	check(error)

	parts := strings.Split(path, ".")
	ext := parts[len(parts)-1]

	ast := []interface{}{
		[3]interface{}{
			"$$",
			"code",
			[2]string{"%%", string(data)}},
		[3]interface{}{
			"$$",
			"lang",
			[2]string{"%%", ext}}}

	callProc("core/compile", authorization, ast, "application/json")
}

func commandRun(path string, authorization string, accept string) {
	checkPath(path)

	data, error := ioutil.ReadFile(path)
	check(error)

	parts := strings.Split(path, ".")
	ext := parts[len(parts)-1]

	ast := []interface{}{
		[3]interface{}{
			"$$",
			"proc",
			[3]interface{}{
				"{}",
				[4]interface{}{
					"()",
					"core.compile",
					[3]interface{}{
						"$$",
						"code",
						[2]string{"%%", string(data)}},
					[3]interface{}{
						"$$",
						"lang",
						[2]string{"%%", ext}}},
				[2]string{"()", "core.exec"}}}}

	callProc("core/exec", authorization, ast, accept)
}

func callProc(path string, authorization string, ast []interface{}, accept string) {
	buffer, error := msgpack.Marshal(ast)
	check(error)

	request, error := http.NewRequest("POST", "https://api.proc.dev/"+path, bytes.NewReader(buffer))
	request.Header.Add("Authorization", "bearer "+authorization)
	request.Header.Add("Content-Type", "application/vnd.proc+msgpack")
	request.Header.Add("Accept", accept)

	client := &http.Client{}
	response, error := client.Do(request)
	check(error)

	defer response.Body.Close()
	body, error := ioutil.ReadAll(response.Body)
	check(error)

	switch response.StatusCode {
	case 200:
		fmt.Println(string(body))
	default:
		fmt.Println(response.Status+": ", string(body))
		os.Exit(1)
	}
}

func ensureAuth(authorization string) string {
	if authorization == "" {
		authorization = os.Getenv("PROC_AUTH")
	}

	if authorization == "" {
		userDirectory, _ := os.UserHomeDir()
		procAuthPath := fmt.Sprint(userDirectory, "/.proc/auth")
		_, error := os.Stat(procAuthPath)

		if error == nil {
			data, _ := ioutil.ReadFile(procAuthPath)
			authorization = strings.TrimSuffix(string(data), "\n")
		}
	}

	return authorization
}

func check(err error) {
	if err != nil {
    fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func checkPath(path string) {
	_, err := os.Stat(path)
	check(err)
}

func output(output string, success bool, topbreak bool) {
	var finalOutput string

	if topbreak {
		finalOutput = "\n" + output
	} else {
		finalOutput = output
	}

	if success {
		fmt.Println(finalOutput)
	} else {
		fmt.Fprintln(os.Stderr, finalOutput)
	}
}
